/* Local effects on EVERY machine, including server/HC/JIP and missile owners. */
params [["_protected",missionNamespace getVariable ["DSDS_oswaldVehicles",[]]]];
if (isRemoteExecuted) exitWith {};
private _handles=missionNamespace getVariable ["DSDS_oswaldLocal",createHashMap];
{
 private _entry=_handles get _x;_entry params ["_vehicle","_previous"];
 if (isNull _vehicle || {!(_vehicle in _protected)} || {!alive _vehicle}) then {
  if (!isNull _vehicle) then {
   private _current=_vehicle setTargetSize [];private _restore=+_current;
   {if ((_current select _x)==0) then {_restore set [_x,_previous select _x];};} forEach [1,2];
   _vehicle setTargetSize _restore;
  };
  _handles deleteAt _x;
 };
} forEach (keys _handles);
{
 private _vehicle=_x;
 if (!isNull _vehicle && {alive _vehicle} && {_vehicle isKindOf "Air"}) then {
  private _key=netId _vehicle;private _current=_vehicle setTargetSize [];
  private _entry=_handles getOrDefault [_key,[_vehicle,+_current]];private _previous=_entry select 1;
  {if ((_current select _x)!=0) then {_previous set [_x,_current select _x];};} forEach [1,2];
  _vehicle setTargetSize [_current select 0,0,0];_handles set [_key,_entry];
 };
} forEach _protected;
DSDS_oswaldLocal=_handles;
if (_protected isNotEqualTo []) then {
 {if (local _x && {missileTarget _x in _protected}) then {_x setMissileTarget [objNull,true];};} forEach (allMissionObjects "MissileBase");
};
