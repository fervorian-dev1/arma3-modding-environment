params ["_player","_begin"];
if (isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer" || {_dsdsAuthorizedPlayer != _player}}) exitWith {false};
if (!isServer) exitWith {false};
private _npc = missionNamespace getVariable ["DSDS_mechanic",objNull];
if (isNull _npc || {!alive _npc}) exitWith {false};
if (_begin) exitWith {
    if (isNull _player || {!alive _player} || {_player distance _npc > 6} || {vehicle _player != _player} || {!isNull attachedTo _npc}) exitWith {false};
    _npc setVariable ["DSDS_mover",_player,true];
    _npc attachTo [_player,[0,2.5,0]];
    true
};
private _mover = _npc getVariable ["DSDS_mover",objNull];
if (!isNull _player && {_mover != _player}) exitWith {false};
detach _npc;
private _position = getPosASL _npc;
private _surfaces = lineIntersectsSurfaces [_position vectorAdd [0,0,0.5],_position vectorAdd [0,0,-100],_npc,_mover,true,1,"GEOM","NONE"];
if (_surfaces isNotEqualTo []) then {
    _npc setPosASL (((_surfaces select 0) select 0) vectorAdd [0,0,0.03]);
} else {
    _npc setPosATL [(_position select 0),(_position select 1),0];
};
_npc setVelocity [0,0,0];
if (!isNull _mover) then {_npc setDir getDir _mover;};
_npc setVariable ["DSDS_mover",objNull,true];
_npc disableAI "PATH";
[] call DSDS_fnc_persistMechanic;
true
