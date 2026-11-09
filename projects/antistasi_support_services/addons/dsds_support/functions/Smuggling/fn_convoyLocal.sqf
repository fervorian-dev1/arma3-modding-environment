/* Whitelisted locality bridge: only the server may order pace/recovery/contact sharing. */
if (isRemoteExecuted && {remoteExecutedOwner!=2}) exitWith {};
if (!isRemoteExecuted && {!isServer}) exitWith {};
params ["_object","_mode",["_data",[]]];
if (_mode=="CONTACT") exitWith {
 private _group=_object;
 if (isNull _group || {!local _group} || {(units _group findIf {isPlayer _x})>=0}) exitWith {};
 {if (!isNull _x && {alive _x}) then {_group reveal [_x,4];};} forEach _data;
 private _target=_data param [0,objNull];private _leader=leader _group;
 // Stationary weapons receive intel, but cannot march. Mobile enemy groups can pursue it.
 if (!isNull _target && {alive _leader} && {!(vehicle _leader isKindOf "StaticWeapon")} && {!(_group getVariable ["DSDS_convoyTask",false])} && {!(_group getVariable ["DSDS_noContactRetask",false])}) then {
  private _wp=_group getVariable ["DSDS_contactWaypoint",[]];
  if (_wp isEqualTo []) then {_wp=_group addWaypoint [getPosATL _target,80];_wp setWaypointType "SAD";_group setVariable ["DSDS_contactWaypoint",_wp];};
  _wp setWaypointPosition [getPosATL _target,80];_group setCurrentWaypoint _wp;
 };
};
private _vehicle=_object;
if (isNull _vehicle || {!local _vehicle} || {!alive _vehicle} || {(crew _vehicle findIf {isPlayer _x})>=0}) exitWith {};
if (_mode=="RESTORE") exitWith {_vehicle forceSpeed -1;_vehicle limitSpeed getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "maxSpeed");};
if (_mode!="PACE" || {!canMove _vehicle} || {isNull driver _vehicle}) exitWith {};
_data params ["_speed","_hold",["_recovery",[]]];
_vehicle setConvoySeparation 35;_vehicle limitSpeed _speed;_vehicle forceSpeed (if (_hold) then {0} else {-1});
if (_recovery isNotEqualTo []) then {
 _vehicle setVelocity [0,0,0];_vehicle setPosATL _recovery;
};
private _group=group driver _vehicle;
if (!_hold && {speed _vehicle<2}) then {
 private _wp=[_group,currentWaypoint _group];
 if (waypointPosition _wp distance2D _vehicle>15) then {_group setCurrentWaypoint _wp;driver _vehicle doMove waypointPosition _wp;};
};
