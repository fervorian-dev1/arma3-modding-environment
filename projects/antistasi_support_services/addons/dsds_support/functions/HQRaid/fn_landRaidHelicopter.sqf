params ["_raid","_heli","_pilots","_cargo","_landing","_origin"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _pad = createVehicle ["Land_HelipadEmpty_F",_landing,[],0,"NONE"];
(_raid get "pads") pushBack _pad;
_heli setVariable ["DSDS_raidReturn",_origin];
_pilots setBehaviourStrong "CARELESS"; _pilots setCombatMode "BLUE";
_heli flyInHeight 120;
private _wp = _pilots addWaypoint [_landing,0]; _wp setWaypointType "MOVE"; _wp setWaypointCompletionRadius 150;
private _deadline = diag_tickTime + (DSDS_raidConfig get "landingTimeout");
private _ordered = false;
waitUntil {
    sleep 1;
    if (!_ordered && {_heli distance2D _landing < 500}) then {_heli land "GET OUT"; _ordered = true;};
    _raid get "ended" || {!alive _heli} || {!alive driver _heli} || {diag_tickTime > _deadline} || {_heli distance2D _landing < 100 && {getPosATL _heli select 2 < 3} && {abs speed _heli < 6}}
};
private _landed = alive _heli && {getPosATL _heli select 2 < 3} && {abs speed _heli < 6};
if (_landed && {!(_raid get "ended")}) then {
    _heli setVariable ["DSDS_raidLanded",true,true];
    _cargo leaveVehicle _heli;
    {unassignVehicle _x; doGetOut _x;} forEach units _cargo;
    private _outDeadline = diag_tickTime + 30;
    waitUntil {sleep 0.5; {vehicle _x == _heli} count units _cargo == 0 || {diag_tickTime > _outDeadline} || {_raid get "ended"} || {!alive _heli}};
    if (alive _heli && {getPosATL _heli select 2 < 3}) then {
        {if (alive _x && {vehicle _x == _heli}) then {moveOut _x;};} forEach units _cargo;
    };
    if (!(_raid get "ended")) then {
        _cargo setBehaviourStrong "AWARE"; _cargo setCombatMode "RED"; _cargo setSpeedMode "NORMAL";
        private _move = _cargo addWaypoint [_raid get "hq",60]; _move setWaypointType "MOVE";
        private _attack = _cargo addWaypoint [_raid get "hq",80]; _attack setWaypointType "SAD";
        _cargo setCurrentWaypoint _move;
        _cargo setVariable ["DSDS_raidAssault",true];
        diag_log format ["[DSDS HQ] Raid %1 helicopter landed; %2 infantry advancing from %3 m.",_raid get "id",count units _cargo,round (_landing distance2D (_raid get "hq"))];
    };
} else {
    // A destroyed aircraft may leave survivors on the ground; let them attack too.
    if (!(_raid get "ended")) then {
        private _survivors = (units _cargo) select {alive _x && {vehicle _x == _x}};
        if (_survivors isNotEqualTo []) then {private _wp = _cargo addWaypoint [_raid get "hq",60]; _wp setWaypointType "SAD"; _cargo setCurrentWaypoint _wp;};
    };
    diag_log format ["[DSDS HQ] Raid %1 helicopter landing failed or aborted.",_raid get "id"];
};
_raid set ["landingsDone",(_raid get "landingsDone") + 1];
if (alive _heli && {alive driver _heli} && {{isPlayer _x} count crew _heli == 0}) then {
    _heli land "NONE"; _heli flyInHeight 160;
    private _wp = _pilots addWaypoint [_origin,0]; _wp setWaypointType "MOVE"; _wp setWaypointBehaviour "CARELESS"; _pilots setCurrentWaypoint _wp;
    // Keep helipad until the aircraft has actually left the landing area.
    private _clearDeadline = diag_tickTime + 120;
    waitUntil {sleep 2; !alive _heli || {_heli distance2D _landing > 250} || {diag_tickTime > _clearDeadline}};
};
if (!isNull _pad) then {deleteVehicle _pad;};
