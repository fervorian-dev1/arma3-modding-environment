params ["_record"];
if (!isServer || {isRemoteExecuted} || {_record get "finished"}) exitWith {false};
private _pool=_record getOrDefault ["pool",[]];
private _holders=(_record get "holders") select {!isNull _x};
private _present=_holders select {private _cargo=if (_x isKindOf "CAManBase") then {items _x} else {itemCargo _x};(_cargo findIf {_x in _pool})>=0};
if (_present isNotEqualTo []) then {
 private _moving=_present select {(_x isKindOf "CAManBase" && {isPlayer _x}) || {!isNull isVehicleCargo _x} || {abs speed _x>1}};
 private _target=if (_moving isEqualTo []) then {_present select 0} else {_moving select 0};
 _record set ["last",getPosATL _target];
};
if !(_record get "alerted") exitWith {
 private _truck=_record get "truck";
 if (!isNull _truck && {damage _truck>0.05 || {isPlayer driver _truck} || {crew _truck findIf {behaviour _x=="COMBAT"}>=0}}) then {[_truck] call DSDS_fnc_alertConvoy;};
 false
};
if !(_record getOrDefault ["deployed",false]) exitWith {false};
{
 private _heli=_x;
 if (!isNull _heli && {alive _heli} && {alive driver _heli} && {(crew _heli findIf {isPlayer _x})<0} && {side group driver _heli==(_record get "side")} && {!(_heli getVariable ["DSDS_escortUnarmed",false])} && {!([_heli] call DSDS_fnc_sanitizeConvoyHeli)}) then {
  _heli setVariable ["DSDS_escortUnarmed",true];private _group=group driver _heli;
  while {count waypoints _group>0} do {deleteWaypoint [_group,0];};
  private _away=_group addWaypoint [(getPosATL _heli) getPos [4000,getDir _heli],0];_away setWaypointType "MOVE";
 };
} forEach (_record get "spotters");
private _spotters=(_record get "spotters") select {alive _x && {alive driver _x} && {!isPlayer driver _x} && {side group driver _x==(_record get "side")} && {!(_x getVariable ["DSDS_escortUnarmed",false])}};
if (_spotters isEqualTo []) exitWith {
 _record set ["finished",true];
 {if (!isNil "A3A_fnc_groupDespawner") then {[_x] spawn A3A_fnc_groupDespawner;};} forEach (_record get "groups");
 {if (!isNil "A3A_fnc_VEHdespawner") then {[_x] spawn A3A_fnc_VEHdespawner;};} forEach (_record get "vehicles");
 true
};
private _position=_record get "last";
{
 private _group=group driver _x;private _wp=_group getVariable ["DSDS_pursuitWP",[]];
 if (_wp isEqualTo []) then {_wp=_group addWaypoint [_position,150];_wp setWaypointType "MOVE";_group setVariable ["DSDS_pursuitWP",_wp];};
 private _follow=if (_present isEqualTo []) then {_position} else {getPosATL (_present select (_forEachIndex mod count _present))};
 _wp setWaypointPosition [_follow getPos [200,(serverTime*3+_forEachIndex*180) mod 360],80];
 {(leader _group) reveal [_x,4];} forEach (_holders select {_x isKindOf "CAManBase"});
} forEach _spotters;
{
 if (_x getVariable ["DSDS_hunt",false] && {count units _x>0}) then {
  private _leader=leader _x;
  if (vehicle _leader==_leader || {vehicle _leader isKindOf "LandVehicle"}) then {
   private _wp=_x getVariable ["DSDS_pursuitWP",[]];if (_wp isEqualTo []) then {_wp=_x addWaypoint [_position,100];_wp setWaypointType "SAD";_x setVariable ["DSDS_pursuitWP",_wp];};
   _wp setWaypointPosition [_position,100];_x setBehaviourStrong "COMBAT";
  };
 };
} forEach (_record get "groups");
false
