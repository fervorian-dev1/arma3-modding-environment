/* Scheduled server descent monitor, bounded even if objects are removed by Zeus. */
params ["_requester", "_crate", "_chute", "_smoke"];
private _deadline = diag_tickTime + 600;
private _landed = false;
private _nextDiagnostic = diag_tickTime;
waitUntil {
    sleep 0.25;
    // Attached objects can retain a stale isTouchingGround state from creation.
    // Require actual terrain proximity, not that contact flag alone.
    _landed = !isNull _crate && {(getPosATL _crate select 2) < 1.3};
    if (!isNull _crate && {diag_tickTime > _nextDiagnostic}) then {
        diag_log format ["[DSD] Descent: crate %1m AGL, chute %2m AGL", round (getPosATL _crate select 2), if (isNull _chute) then {-1} else {round (getPosATL _chute select 2)}];
        _nextDiagnostic = diag_tickTime + 20;
    };
    _landed || {isNull _crate} || {isNull _chute} || {diag_tickTime > _deadline}
};
if (!_landed || {isNull _crate} || {surfaceIsWater getPosASL _crate}) exitWith {
    if (!isNull _crate) then {detach _crate; deleteVehicle _crate;};
    if (!isNull _chute) then {deleteVehicle _chute;};
    [_requester, "Drop failed: descent interrupted, timed out, or drifted into water. Temporary objects removed."] call DSD_fnc_notifySupplyDrop;
};
detach _crate;
_crate setVelocity [0, 0, 0];
if (!isNull _chute) then {deleteVehicle _chute;};
sleep 1;
if (isNull _crate) exitWith {};
_crate allowDamage true;
_crate setVariable ["DSD_landed", true, true];
_crate setVariable ["DSD_landingTime", diag_tickTime, true];
[_crate] call DSD_fnc_registerAntistasiCrate;
if (_smoke && {isClass (configFile >> "CfgAmmo" >> "SmokeShellGreen")}) then {
    private _marker = createVehicle ["SmokeShellGreen", (getPosATL _crate) vectorAdd [3, 0, 0.3], [], 0, "CAN_COLLIDE"];
    [_marker] spawn {params ["_marker"]; sleep 120; if (!isNull _marker) then {deleteVehicle _marker;};};
};
[_requester, format ["Supplies landed at grid %1. Crate remains until collected, destroyed, or removed by Zeus.", mapGridPosition getPosASL _crate]] call DSD_fnc_notifySupplyDrop;
