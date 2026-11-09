/* One server cleanup pass. Optional observers support isolated engine fixtures only. */
params ["_response",["_observers",allPlayers],["_distance",1200]];
if (!isServer || {isRemoteExecuted} || {!(_response getOrDefault ["ended",false])}) exitWith {false};
private _side=_response get "side";
private _vehicles=_response getOrDefault ["cleanupVehicles",+(_response get "vehicles")];
private _units=_response getOrDefault ["cleanupUnits",+(_response get "units")];
private _protected=_response getOrDefault ["cleanupProtectedUnits",[]];
private _ownedUnits=_response get "units";
private _far={params ["_object"];(_observers findIf {!isNull _x && {_x distance2D _object<_distance}})<0};
private _pendingVehicles=[];
private _removedUnits=[];
private _deleted=_response getOrDefault ["cleanupDeleted",[0,0]];
{
 private _vehicle=_x;
 if (!isNull _vehicle) then {
  private _claimed=(_vehicle getVariable ["ownerSide",_side])!=_side
   || {(crew _vehicle findIf {isPlayer _x || {!(_x in _ownedUnits)} || {alive _x && {side group _x!=_side || {captive _x}}}})>=0}
   || {unitIsUAV _vehicle && {((UAVControl [_vehicle,"all"]) findIf {!isNull _x && {isPlayer _x}})>=0}};
  if (_claimed) then {
   // Release the asset and its passengers permanently from this cleanup job.
   {_protected pushBackUnique _x;} forEach crew _vehicle;
  } else {
   if ([_vehicle] call _far) then {
    {_removedUnits pushBack _x;deleteVehicle _x;_deleted set [0,(_deleted select 0)+1];} forEach crew _vehicle;
    deleteVehicle _vehicle;_deleted set [1,(_deleted select 1)+1];
   } else {_pendingVehicles pushBack _vehicle;};
  };
 };
} forEach _vehicles;
private _pendingUnits=[];
{
 private _unit=_x;
 if (!isNull _unit && {!isPlayer _unit} && {!(_unit in _removedUnits)} && {!(_unit in _protected)} && {!(alive _unit && {side group _unit!=_side || {captive _unit}})}) then {
  private _vehicle=vehicle _unit;
  if (_vehicle==_unit) then {
   if ([_unit] call _far) then {deleteVehicle _unit;_deleted set [0,(_deleted select 0)+1];} else {_pendingUnits pushBack _unit;};
  } else {
   // Never touch a unit that has boarded a captured or unrelated vehicle.
   if (_vehicle in _pendingVehicles) then {_pendingUnits pushBack _unit;};
  };
 };
} forEach _units;
{if (!isNull _x && {count units _x==0}) then {deleteGroup _x;};} forEach (_response get "groups");
_response set ["cleanupVehicles",_pendingVehicles];_response set ["cleanupUnits",_pendingUnits];
_response set ["cleanupProtectedUnits",_protected];_response set ["cleanupDeleted",_deleted];
_response set ["cleanupPasses",(_response getOrDefault ["cleanupPasses",0])+1];
private _pending=_pendingVehicles isNotEqualTo [] || {_pendingUnits isNotEqualTo []};
_response set ["cleanupDone",!_pending];
_pending
