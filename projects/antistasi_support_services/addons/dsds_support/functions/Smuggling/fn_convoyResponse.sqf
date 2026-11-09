params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _faction=[_record get "side"] call DSDS_fnc_smugglingFaction;
if (count _faction==0) exitWith {diag_log "[DSDS] No valid convoy faction; response cancelled without faction substitution.";};
_record set ["faction",_faction];
private _target=_record get "last";private _war=missionNamespace getVariable ["tierWar",1];
private _profile=[_record get "side"] call DSDS_fnc_convoyDefenseProfile;
_record set ["responseDefense",_profile];
private _bearing=random 360;
private _ownership=missionNamespace getVariable ["sidesX",objNull];
private _bases=((missionNamespace getVariable ["airportsX",[]])+(missionNamespace getVariable ["milbases",[]])+(missionNamespace getVariable ["outposts",[]])) select {!isNull _ownership && {_ownership getVariable [_x,sideUnknown]==(_record get "side")}};
if (_bases isNotEqualTo []) then {_bearing=_target getDir markerPos ([_bases,_target] call BIS_fnc_nearestPosition);};
private _groundCount=_profile get "responseGround";
private _roads=(_target nearRoads 2800) select {_x distance2D _target>1500};
// Never spawn response vehicles immediately beside a player.
_roads=_roads select {private _road=_x;(allPlayers findIf {alive _x && {_x distance2D _road<900}})<0};
private _groundPool=[_record get "side",_profile] call DSDS_fnc_convoyEscortPool;
private _armedHelis=[_record get "side"] call DSDS_fnc_convoyDoorHelis;
for "_i" from 1 to _groundCount do {
 if (_groundPool isEqualTo [] || {_roads isEqualTo []}) exitWith {};
 private _road=_roads deleteAt floor random count _roads;private _pos=getPosATL _road;
 _roads=_roads select {_x distance2D _pos>50};
 private _pool=if (_i<=2 && {(_faction get "trucks") isNotEqualTo []}) then {_faction get "trucks"} else {_groundPool};
 private _spawn=[_record,selectRandom _pool,_pos,_profile get "responsePassengers",false,_profile get "skill"] call DSDS_fnc_smugglingVehicle;
 _spawn params ["_vehicle","_crew","_cargo"];
 if (!isNull _vehicle) then {
  _vehicle setDir (_pos getDir _target);_crew setVariable ["DSDS_hunt",true];
  private _wp=_crew addWaypoint [_target,200];_wp setWaypointType "MOVE";
  [_record,_vehicle,_crew,_cargo] spawn {
   params ["_record","_vehicle","_crew","_cargo"];private _deadline=serverTime+600;
   waitUntil {sleep 3;!alive _vehicle || {_vehicle distance2D (_record get "last")<450} || {serverTime>_deadline}};
   if (alive _vehicle) then {_cargo leaveVehicle _vehicle;{unassignVehicle _x;doGetOut _x;} forEach units _cargo;};
  };
 };
};
for "_i" from 1 to (_profile get "responseHelis") do {
 if (_armedHelis isEqualTo []) exitWith {diag_log "[DSDS Convoy] No armed door-gun insertion helicopter available; air insertion skipped.";};
 private _lz=[_target,650,1100,25,0,0.18,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
 if (_lz distance2D [0,0,0]>100) then {
  private _pos=[_lz,_bearing+_i*30,3500,200] call DSDS_fnc_smugglingAirStart;
  if (_pos isNotEqualTo []) then {
   private _spawn=[_record,selectRandom _armedHelis,_pos,10,true] call DSDS_fnc_smugglingVehicle;
   _spawn params ["_heli","_pilots","_cargo"];
   if (!isNull _heli && {[_heli] call DSDS_fnc_sanitizeConvoyHeli}) then {
    private _landing=createHashMapFromArray [["id",_record get "id"],["hq",_target],["pads",[]],["ended",false],["landingsDone",0]];
    [_landing,_heli,_pilots,_cargo,_lz,_pos] spawn DSDS_fnc_landRaidHelicopter;
   } else {if (!isNull _heli) then {{deleteVehicle _x;} forEach crew _heli;deleteVehicle _heli;};};
  };
 };
};
private _scouts=_armedHelis;
for "_i" from 1 to (_profile get "spotters") do {
 if (_scouts isEqualTo []) exitWith {};
 private _pos=[_target,_bearing+_i*35,3200,240] call DSDS_fnc_smugglingAirStart;
 if (_pos isNotEqualTo []) then {
  private _spawn=[_record,selectRandom _scouts,_pos,0,true] call DSDS_fnc_smugglingVehicle;
  private _heli=_spawn select 0;if (!isNull _heli) then {
   if ([_heli] call DSDS_fnc_sanitizeConvoyHeli) then {_heli flyInHeight 200;(_record get "spotters") pushBack _heli;} else {{deleteVehicle _x;} forEach crew _heli;deleteVehicle _heli;};
  };
 };
};
_record set ["deployed",true];
diag_log format ["[DSDS] Special convoy response: %1 troops/crew, %2 vehicles, %3 spotters.",count (_record get "units"),count (_record get "vehicles"),count (_record get "spotters")];
