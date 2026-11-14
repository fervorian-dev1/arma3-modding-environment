/* Execute where the passenger is local. Works for humans and future squad services. */
if (isRemoteExecuted && {isMultiplayer} && {remoteExecutedOwner != 2}) exitWith {false};
params ["_unit","_aircraft"];
if (!local _unit || {!alive _unit} || {isNull _aircraft} || {!alive _aircraft}) exitWith {false};
// Explicitly select an empty rear cargo proxy. Never let the engine choose a
// front passenger/copilot position or fall back to a crew station.
private _seats=(fullCrew [_aircraft,"cargo",true]) select {isNull (_x select 0) && {(_x select 2)>=0} && {!(_x select 4)}};
if (_seats isEqualTo []) exitWith {diag_log "[DSDS] Parachute transport has no free cargo seat.";false};
private _indices=_seats apply {_x select 2};_indices sort false;
private _index=_indices select 0;
if (isNull objectParent _unit) then {_unit setVariable ["DSDS_boardOrigin",getPosATL _unit];};
if (vehicle _unit != _unit) then {moveOut _unit;};
unassignVehicle _unit;
_unit assignAsCargoIndex [_aircraft,_index];
_unit moveInCargo [_aircraft,_index];
private _seat=(fullCrew [_aircraft,"cargo",false]) select {(_x select 0)==_unit && {(_x select 2)==_index}};
vehicle _unit==_aircraft && {_seat isNotEqualTo []}
