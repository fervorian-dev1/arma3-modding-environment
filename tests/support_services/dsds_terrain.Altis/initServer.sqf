[] spawn {
    sleep 3;
    private _failures=0;
    private _assert={params ["_ok","_name"];if (!_ok) then {_failures=_failures+1;};diag_log format ["[DSDS TERRAIN] %1: %2",["FAIL","PASS"] select _ok,_name];};
    teamPlayer=west;
    private _peak=[6000,18000,0];
    private _peakHeight=-1000;
    for "_x" from 1000 to 26000 step 250 do {
        for "_y" from 1000 to 26000 step 250 do {
            private _height=getTerrainHeightASL [_x,_y];
            if (_height>_peakHeight) then {_peakHeight=_height; _peak=[_x,_y,0];};
        };
    };
    [_peakHeight>300,"real Altis route crosses mountainous terrain"] call _assert;
    private _target=_peak getPos [3000,90];
    private _job=createHashMapFromArray [["type","HE"],["origin",_peak],["target",_target]];
    private _flight=[_job] call DSDS_fnc_spawnSupportAircraft;
    [_flight isNotEqualTo [],"strike jet spawns for mountain flight"] call _assert;
    if (_flight isNotEqualTo []) then {
        private _plane=_flight select 0;
        private _minimum=10000;
        private _maximumGround=-10000;
        private _minimumGround=10000;
        private _nearPeak=false;
        private _deadline=diag_tickTime+25;
        while {alive _plane && {diag_tickTime<_deadline}} do {
            private _position=getPosASL _plane;
            private _ground=0 max getTerrainHeightASL _position;
            _minimum=_minimum min ((_position select 2)-_ground);
            _minimumGround=_minimumGround min _ground;
            _maximumGround=_maximumGround max _ground;
            if (_plane distance2D _peak<250) then {_nearPeak=true;};
            sleep 0.05;
        };
        diag_log format ["[DSDS TERRAIN] minClearance=%1 terrainRange=%2 peak=%3 peakHeight=%4",_minimum,_maximumGround-_minimumGround,_peak,_peakHeight];
        [alive _plane && {_nearPeak},"jet survives crossing selected mountain summit"] call _assert;
        [_maximumGround-_minimumGround>200,"measured flight crosses substantial terrain elevation change"] call _assert;
        [_minimum>80 && {_minimum<225},"terrain following maintains a low pass with ground clearance"] call _assert;
        {deleteVehicle _x;} forEach crew _plane;
        deleteVehicle _plane;
    };
    diag_log format ["[DSDS TERRAIN] COMPLETE failures=%1",_failures];
};
