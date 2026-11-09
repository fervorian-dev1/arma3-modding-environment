params ["_position"];
if (!isServer) exitWith {};
private _start = serverTime;
private _end = _start + 90;
private _rendered = [];
private _nextSound = 0;
playSound3D ["a3\sounds_f\weapons\explosion\expl_big_3.wss",objNull,false,AGLToASL _position,5,0.6,3000];
{_x hideObjectGlobal true;} forEach nearestTerrainObjects [_position,["tree","bush","small tree"],30];
while {serverTime < _end} do {
    if (serverTime >= _nextSound && {serverTime < _end - 8.3}) then {
        playSound3D ["a3\sounds_f\sfx\fire1_loop.wss",objNull,false,AGLToASL _position,5,0.7,3000];
        _nextSound = serverTime + 8.3;
    };
    {
        private _uid = getPlayerUID _x;
        if (_uid != "" && {!(_uid in _rendered)}) then {
            _rendered pushBack _uid;
            [_position,_start,""] remoteExec ["A3A_fnc_napalmParticles",_x];
        };
    } forEach allPlayers;
    private _victims = _position nearObjects ["All",30];
    private _crew = [];
    {_crew append crew _x;} forEach _victims;
    _victims append _crew;
    {
        if (!isNull _x && {(_x getVariable ["A3A_napalm_processing",0]) < serverTime}) then {
            _x setVariable ["A3A_napalm_processing",serverTime + 30];
            [_x,true,""] remoteExecCall ["A3A_fnc_napalmDamage",2 max owner _x];
        };
    } forEach _victims;
    sleep 5;
};
