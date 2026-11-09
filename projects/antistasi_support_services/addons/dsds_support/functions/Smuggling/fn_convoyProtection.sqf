/* Supplemental native-convoy guards and kinetic-only air cover. Objective/routes stay native. */
params ["_record",["_nativeExtras",false]];
if (!isServer || {isRemoteExecuted} || {_record getOrDefault ["coverInitialized",false]}) exitWith {};
_record set ["coverInitialized",true];
private _truck=_record get "truck";private _side=_record get "side";
private _faction=[_side] call DSDS_fnc_smugglingFaction;
if (isNull _truck || {count _faction==0}) exitWith {_record set ["coverReady",true];};
private _profile=[_side] call DSDS_fnc_convoyDefenseProfile;_record set ["defense",_profile];
private _assets=createHashMapFromArray [["id",(_record get "id")+"_COVER"],["side",_side],["faction",_faction],["vehicles",[]],["units",[]],["groups",[]]];
_record set ["cover",_assets];
// Native road travel owns driver orders/speed. Do not run a competing controller.
if (!(_truck getVariable ["DSDS_nativeConvoyTravel",false])) then {[_record] spawn DSDS_fnc_convoyCohesion;};
private _groundPool=[_side,_profile] call DSDS_fnc_convoyEscortPool;
// Extra aggression-scaled escorts are now created inside the native worker,
// sharing its route/departure/spacing, rather than blocking it from the roadside.
private _ground=if (_nativeExtras && {!(_truck getVariable ["DSDS_nativeConvoyTravel",false])}) then {_profile get "extraGround"} else {0};
private _roads=if (_ground>0) then {(getPosATL _truck nearRoads 600) select {private _road=_x;_road distance2D _truck>120 && {(allPlayers findIf {alive _x && {_x distance2D _road<400}})<0}}} else {[]};
for "_i" from 1 to _ground do {
 if (_groundPool isEqualTo [] || {_roads isEqualTo []}) exitWith {};
 private _road=_roads deleteAt floor random count _roads;private _pos=getPosATL _road;_roads=_roads select {_x distance2D _pos>40};
 private _spawn=[_assets,selectRandom _groundPool,_pos,_profile get "passengers",false,_profile get "skill"] call DSDS_fnc_smugglingVehicle;
 private _vehicle=_spawn select 0;
 if (!isNull _vehicle) then {_vehicle setDir (_pos getDir getPosATL _truck);_vehicle limitSpeed 45;(_spawn select 1) setVariable ["lambs_danger_disableGroupAI",true,true];};
};
private _air=if (_record get "kind"=="ISOTOPE") then {_profile get "airEscorts"} else {if (_record get "kind"=="SPECIAL" && {_profile get "band">=2}) then {_profile get "airEscorts"} else {0}};
private _airPool=if (_air>0) then {[_side] call DSDS_fnc_convoyDoorHelis} else {[]};
for "_i" from 1 to _air do {
 if (_airPool isEqualTo []) exitWith {diag_log "[DSDS Convoy] No suitable same-side door-gun transport available.";};
 private _pos=[getPosATL _truck,random 360,1400+_i*150,140] call DSDS_fnc_smugglingAirStart;
 if (_pos isNotEqualTo []) then {
  private _spawn=[_assets,selectRandom _airPool,_pos,0,true,_profile get "skill"] call DSDS_fnc_smugglingVehicle;
  private _heli=_spawn select 0;
  (_spawn select 1) setVariable ["DSDS_noContactRetask",true,true];
  if (!isNull _heli) then {
   if ([_heli] call DSDS_fnc_sanitizeConvoyHeli) then {
    _heli flyInHeight 110;_heli limitSpeed 170;(driver _heli) disableAI "AUTOTARGET";(driver _heli) disableAI "TARGET";
   } else {{deleteVehicle _x;} forEach crew _heli;deleteVehicle _heli;};
  };
 };
};
_record set ["coverReady",true];
diag_log format ["[DSDS Convoy] %1 aggression %2: %3 supplemental vehicles (air cover %4).",_record get "id",_profile get "aggression",count (_assets get "vehicles"),{!isNull _x && {_x isKindOf "Helicopter"}} count (_assets get "vehicles")];
private _task=_record getOrDefault ["task",""];
private _active=true;
while {_active} do {
 private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
 _active=!isNull _truck && {alive _truck} && {_truck getVariable ["ownerSide",_side]!=_rebels} && {isNull driver _truck || {!isPlayer driver _truck}};
 if (_task!="" && {!([_task] call BIS_fnc_taskExists) || {[_task] call BIS_fnc_taskState in ["SUCCEEDED","FAILED","CANCELED"]}}) then {_active=false;};
 if (_active) then {
  {
   private _vehicle=_x;
   if (!isNull _vehicle && {alive _vehicle} && {!isNull driver _vehicle} && {!isPlayer driver _vehicle} && {(crew _vehicle findIf {isPlayer _x})<0} && {_vehicle getVariable ["ownerSide",_side]==_side} && {!(_vehicle getVariable ["DSDS_escortUnarmed",false])}) then {
    if (_vehicle isKindOf "Helicopter" && {!([_vehicle] call DSDS_fnc_sanitizeConvoyHeli)}) exitWith {
     _vehicle setVariable ["DSDS_escortUnarmed",true];
     private _group=group driver _vehicle;while {count waypoints _group>0} do {deleteWaypoint [_group,0];};
     private _away=_group addWaypoint [(getPosATL _vehicle) getPos [4000,getDir _vehicle],0];_away setWaypointType "MOVE";
    };
    private _group=group driver _vehicle;private _wp=_group getVariable ["DSDS_coverWaypoint",[]];
    if (_wp isEqualTo []) then {_wp=_group addWaypoint [getPosATL _truck,70];_wp setWaypointType "MOVE";_group setVariable ["DSDS_coverWaypoint",_wp];};
    _wp setWaypointPosition [(getPosATL _truck) getPos [if (_vehicle isKindOf "Helicopter") then {120} else {55},getDir _truck+(_forEachIndex*80)],40];
   };
  } forEach (_assets get "vehicles");
 };
 sleep 5;
};
// Keep cleanup away from players, and preserve anything captured or player-occupied.
sleep 120;
private _remaining=+(_assets get "vehicles");
while {_remaining isNotEqualTo []} do {
 private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
 {
  private _vehicle=_x;
  if (!isNull _vehicle && {_vehicle getVariable ["ownerSide",_side]!=_rebels} && {(crew _vehicle findIf {isPlayer _x})<0} && {(allPlayers findIf {_x distance2D _vehicle<1000})<0}) then {
   {if (!isPlayer _x && {side group _x!=_rebels}) then {deleteVehicle _x;};} forEach crew _vehicle;deleteVehicle _vehicle;
  };
 } forEach _remaining;
 _remaining=_remaining select {!isNull _x && {_x getVariable ["ownerSide",_side]!=_rebels} && {(crew _x findIf {isPlayer _x})<0}};
 sleep 15;
};
{if (count units _x==0) then {deleteGroup _x;};} forEach (_assets get "groups");
