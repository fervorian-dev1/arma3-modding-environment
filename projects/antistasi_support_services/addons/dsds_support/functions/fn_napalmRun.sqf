// Local adapter for Antistasi Plus 2.3.2's invalid playSound3D position argument.
// Other Antistasi support callers and functions remain untouched.
params ["_plane","_length"];
if (!isServer) exitWith {};
private _interval = ((_length / 2) / (30 max (speed _plane / 3.6))) max 0.2;
sleep (_interval / 2 + 170 / (30 max (speed _plane / 3.6)));
for "_i" from 1 to 2 do {
    sleep _interval;
    if (!alive _plane) exitWith {};
    private _position = (getPosATL _plane) vectorAdd [0,0,-5];
    private _bomb = createVehicle ["ammo_Bomb_SDB",_position,[],0,"CAN_COLLIDE"];
    if (!isNull _bomb) then {
        _bomb setVelocity [0,0,-50];
        _bomb setShotParents [_plane,driver _plane];
        [_bomb,_position] spawn {
            params ["_bomb","_position"];
            private _deadline = diag_tickTime + 60;
            while {!isNull _bomb && {diag_tickTime < _deadline}} do {_position = getPosATL _bomb; sleep 0.1;};
            if (!isNull _bomb) exitWith {deleteVehicle _bomb;};
            _position set [2,0];
            [_position] spawn DSDS_fnc_napalmEffect;
        };
    };
};
