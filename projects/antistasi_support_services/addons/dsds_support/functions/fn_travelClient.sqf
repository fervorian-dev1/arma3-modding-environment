if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner!=2}) exitWith {};
params ["_unit","_aircraft",["_return",[]]];
if (_unit!=player || {!local _unit}) exitWith {};
if (_return isNotEqualTo []) exitWith {if (alive _unit) then {moveOut _unit;_unit setPosATL _return;};};
[_unit,_aircraft] spawn {
 params ["_unit","_aircraft"];
 if (isNull _aircraft || {!alive _unit}) exitWith {};
 private _camera="camera" camCreate (_aircraft modelToWorld [35,-65,15]);
 _camera cameraEffect ["INTERNAL","BACK"];
 _camera camSetTarget _aircraft;_camera camCommit 0;
 private _until=diag_tickTime+5;
 while {diag_tickTime<_until && {alive _unit} && {!isNull _aircraft}} do {
  _camera camSetPos (_aircraft modelToWorld [35,-65,15]);_camera camCommit 0.1;sleep 0.1;
 };
 _camera cameraEffect ["TERMINATE","BACK"];camDestroy _camera;
};
