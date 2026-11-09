params ["_payload","_chute",["_vehicle",false]];
private _deadline = diag_tickTime + 600;
waitUntil {sleep 0.25; isNull _payload || {isNull _chute} || {getPosATL _payload select 2 < 1.5} || {diag_tickTime > _deadline}};
if (isNull _payload) exitWith {if (!isNull _chute) then {deleteVehicle _chute;}; false};
if (isNull _chute || {diag_tickTime > _deadline} || {surfaceIsWater getPosASL _payload}) exitWith {
    detach _payload; deleteVehicle _payload; if (!isNull _chute) then {deleteVehicle _chute;}; false
};
detach _payload; _payload setVelocity [0,0,0]; deleteVehicle _chute;
sleep 1;
_payload allowDamage true;
_payload setVariable ["DSD_landed",true,true];
if (!_vehicle) then {[_payload] call DSD_fnc_registerAntistasiCrate;};
true
