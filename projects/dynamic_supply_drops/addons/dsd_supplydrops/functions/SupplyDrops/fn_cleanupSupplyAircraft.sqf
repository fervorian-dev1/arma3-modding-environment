/* Give the transport time to fly away. Do not delete vehicles occupied by players. */
params ["_aircraft", "_crew", "_group", "_target"];
private _startTime = diag_tickTime;
waitUntil {
    sleep 2;
    isNull _aircraft || {diag_tickTime - _startTime > 420} || {
        diag_tickTime - _startTime > 90 && {alive _aircraft} && {_aircraft getVariable ["DSD_departing", false]} && {_aircraft distance2D _target > 3500}
    } || {!alive _aircraft && {diag_tickTime - _startTime > 120}}
};
if (!isNull _aircraft && {(crew _aircraft findIf {isPlayer _x}) != -1}) exitWith {
    diag_log "[DSD] Transport occupied by player; cleanup handed over to mission/Zeus.";
};
{if (!isNull _x && {!isPlayer _x}) then {deleteVehicle _x;};} forEach _crew;
if (!isNull _aircraft) then {deleteVehicle _aircraft;};
if (!isNull _group && {count units _group == 0}) then {deleteGroup _group;};
diag_log "[DSD] Transport and AI crew cleaned up.";
