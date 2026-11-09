/* Finite pursuit of attributed attackers. One UAV, one fully loaded specialist Osprey. */
// Optional target list is for trusted server engine fixtures; never an RPC/UI argument.
params ["_record",["_serverTargets",[],[[]]]];
if (!isServer || {isRemoteExecuted} || {_record getOrDefault ["responseStarted",false]}) exitWith {};
_record set ["responseStarted",true];
private _attackers=_record getOrDefault ["attackers",createHashMap];
private _uids=(keys _attackers) select {serverTime-(_attackers get _x)<600};
private _resolveTargets={if (_serverTargets isNotEqualTo []) then {_serverTargets select {!isNull _x && {alive _x}}} else {allPlayers select {alive _x && {getPlayerUID _x in _uids}}}};
private _targets=call _resolveTargets;
if (_targets isEqualTo []) exitWith {diag_log "[DSDS CBRN] No attributed player attacker online; no bystanders were selected.";};
// Multiple isotope wrecks cannot stack identical aerial hunts on the same person.
private _existing=(missionNamespace getVariable ["DSDS_contaminationResponses",[]]) select {!(_x getOrDefault ["ended",false])};
if ((_existing findIf {!(_x getOrDefault ["ended",false]) && {((_x get "uids") arrayIntersect _uids) isNotEqualTo []}})>=0) exitWith {diag_log "[DSDS CBRN] Existing pursuit already covers these attackers.";};
private _classes=[] call DSDS_fnc_responseAssets;
private _side=_record get "side";private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
if (_side==_rebels || {_side getFriend _rebels>=0.6}) exitWith {diag_log "[DSDS CBRN] Convoy owner is not hostile; faction relations were not altered.";};
private _faction=[_side] call DSDS_fnc_smugglingFaction;
if (count _faction==0) exitWith {};
private _response=createHashMapFromArray [["id",(_record get "id")+"_CBRN"],["uids",_uids],["side",_side],["faction",_faction],["vehicles",[]],["units",[]],["groups",[]],["ended",false],["expires",serverTime+3600],["landed",false]];
_record set ["response",_response];_existing pushBack _response;DSDS_contaminationResponses=_existing;
private _drone=objNull;private _droneCrew=grpNull;private _target=_targets select 0;
private _start=[getPosATL _target,random 360,4500,450] call DSDS_fnc_smugglingAirStart;
if (_start isEqualTo []) exitWith {_response set ["ended",true];};
if (_classes get "drone"!="") then {
 private _spawn=[_response,_classes get "drone",_start,_target] call DSDS_fnc_spawnResponseDrone;
 _drone=_spawn select 0;_droneCrew=_spawn select 1;
} else {diag_log "[DSDS CBRN] Installed WK450 class unavailable; no substitute drone was invented.";};
_response set ["drone",_drone];
_response set ["lastReported",getPosATL _target];
private _troops=grpNull;
if (_classes get "osprey"!="" && {_classes get "specialist"!=""}) then {
 // Use NATO woodland CBRN appearance, joined to the existing hostile side. No setFriend/faction replacement.
 private _insertFaction=createHashMapFromArray ((keys _faction) apply {[_x,_faction get _x]});_insertFaction set ["troops",[_classes get "specialist"]];
 private _insert=createHashMapFromArray [["id",_response get "id"],["side",_side],["faction",_insertFaction],["vehicles",[]],["units",[]],["groups",[]]];
 private _airStart=[getPosATL _target,random 360,5000,220] call DSDS_fnc_smugglingAirStart;
 if (_airStart isNotEqualTo []) then {
  private _spawn=[_insert,_classes get "osprey",_airStart,100,true,0.85] call DSDS_fnc_smugglingVehicle;
  // Spawn in flight: the transport's actual empty cargo seats determine a full load.
  private _aircraft=_spawn select 0;_troops=_spawn select 2;
  (_spawn select 1) setVariable ["DSDS_noContactRetask",true,true];
  if (!isNull _aircraft) then {
   _aircraft setPosASL [_airStart select 0,_airStart select 1,(getTerrainHeightASL _airStart max 0)+220];_aircraft engineOn true;_aircraft setVelocityModelSpace [0,60,0];
   {[_x,"FLIGHT"] call DSDS_fnc_configureAddonAI;} forEach units (_spawn select 1);
   {(_response get _x) append (_insert get _x);} forEach ["vehicles","units","groups"];
   _response set ["osprey",_aircraft];_response set ["troops",_troops];_response set ["seatsFilled",count units _troops];
   [_response,_aircraft,_spawn select 1,_troops,_target] spawn DSDS_fnc_landContaminationTeam;
  };
 };
} else {diag_log format ["[DSDS CBRN] Missing installed Osprey/woodland specialist: %1",_classes];};
diag_log format ["[DSDS CBRN] %1 response assets %2, attributed UIDs %3; expires in 3600s or drone destruction.",_record get "id",_classes,_uids];
private _huntWP=[];
while {serverTime<(_response get "expires")} do {
 _targets=call _resolveTargets;
 if (_targets isEqualTo []) exitWith {};
 _target=_targets select 0;
 private _scouting=!isNull _drone && {alive _drone} && {alive driver _drone} && {side group driver _drone==_side} && {_drone getVariable ["ownerSide",_side]==_side} && {((UAVControl [_drone,"crew"]) findIf {!isNull _x && {isPlayer _x}})<0};
 if (_scouting) then {
  [_droneCrew, currentWaypoint _droneCrew] setWaypointPosition [getPosATL _target,0];
  private _seen=_targets select {_drone distance2D _x<3000 && {[_drone,"VIEW"] checkVisibility [getPosASL _drone,eyePos _x]>0.2}};
  if (_seen isNotEqualTo []) then {
   {if (count units _x>0 && {side _x in [missionNamespace getVariable ["Occupants",west],missionNamespace getVariable ["Invaders",east]]} && {side _x!=_rebels} && {side _x getFriend _rebels<0.6}) then {
    [_x,"CONTACT",_seen] remoteExecCall ["DSDS_fnc_convoyLocal",groupOwner _x];
   };} forEach allGroups;
   _response set ["lastReported",getPosATL (_seen select 0)];_response set ["reports",(_response getOrDefault ["reports",0])+1];
  };
 } else {if (_response getOrDefault ["droneLostAt",0]==0) then {_response set ["droneLostAt",serverTime];};};
 // The landed squad hunts actual attributed targets, even after its scout is shot down.
 if (!isNull _troops && {(_response get "landed")} && {{alive _x} count units _troops>0}) then {
  if (_huntWP isEqualTo []) then {_huntWP=_troops addWaypoint [getPosATL _target,60];_huntWP setWaypointType "SAD";};
  _huntWP setWaypointPosition [_response get "lastReported",60];_troops setCurrentWaypoint _huntWP;
 };
 if (!_scouting) then {_response set ["surveillanceEnded",true];};
 sleep 20;
};
_response set ["ended",true];
if (!isNull _drone && {alive _drone} && {alive driver _drone} && {side group driver _drone==_side} && {(crew _drone findIf {isPlayer _x})<0}) then {
 private _exit=_droneCrew addWaypoint [(getPosATL _drone) getPos [6000,getDir _drone],0];_exit setWaypointType "MOVE";_droneCrew setCurrentWaypoint _exit;
};
// Retry every30s until distant owned assets are removed or captured assets are released.
[_response] spawn DSDS_fnc_cleanupContaminationResponse;
