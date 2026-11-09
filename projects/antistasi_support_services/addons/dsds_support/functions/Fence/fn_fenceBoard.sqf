/* Only the server may instruct the buyer's local machine to board/start a purchase. */
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
params ["_player","_plane",["_start",false]];
if (!local _player || {!alive _player} || {isNull _plane} || {!alive _plane} || {_plane getVariable ["DSDS_fenceBuyer",objNull] != _player}) exitWith {};
if (!_start) exitWith {
    if (vehicle _player == _player && {isNull driver _plane}) then {
        if (backpack _player == "" && {isClass (configFile >> "CfgVehicles" >> "B_Parachute")}) then {_player addBackpack "B_Parachute";};
        _player moveInDriver _plane;
    };
};
[_player,_plane] spawn {
    params ["_player","_plane"];
    private _deadline=diag_tickTime+5;
    waitUntil {sleep 0.01;local _plane || {diag_tickTime > _deadline} || {isNull _plane}};
    if (isNull _plane || {driver _plane != _player} || {!local _plane}) exitWith {};
    _plane engineOn true;
    private _cfg=configFile >> "CfgVehicles" >> typeOf _plane;
    private _speed=((getNumber (_cfg >> "landingSpeed") max 150)*1.5/3.6) max 80;
    _plane setVelocityModelSpace [0,_speed,0];
    _plane setAirplaneThrottle 1;
};
