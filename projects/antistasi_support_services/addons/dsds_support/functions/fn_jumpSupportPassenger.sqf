if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {false};
params ["_unit","_aircraft"];
if (!local _unit || {!alive _unit} || {vehicle _unit != _aircraft}) exitWith {false};
private _position = (getPosASL _unit) vectorAdd [0,0,-8];
private _chute = createVehicle ["Steerable_Parachute_F",ASLToATL _position,[],0,"FLY"];
if (isNull _chute) exitWith {false};
_chute disableCollisionWith _aircraft;
_chute setPosASL _position;
moveOut _unit;
_unit moveInDriver _chute;
_unit setVariable ["DSDS_parachute",_chute,true];
// No backpack swap: the passenger keeps its exact backpack and inventory.
[_unit,_chute] spawn {
    params ["_unit","_chute"];
    private _deadline = diag_tickTime + 600;
    waitUntil {sleep 0.5; isNull _chute || {crew _chute isEqualTo []} || {getPosATL _chute select 2 < 2} || {diag_tickTime > _deadline}};
    if (isNull _chute) exitWith {};
    if (getPosATL _chute select 2 < 2) then {
        if (vehicle _unit == _chute) then {moveOut _unit;};
        sleep 1;
    };
    if (crew _chute isEqualTo []) then {deleteVehicle _chute;};
};
true
