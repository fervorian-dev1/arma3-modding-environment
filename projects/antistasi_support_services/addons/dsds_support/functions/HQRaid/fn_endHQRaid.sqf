params ["_raid","_reason"];
if (!isServer || {isRemoteExecuted} || {_raid getOrDefault ["ended",false]}) exitWith {false};
_raid set ["ended",true]; _raid set ["result",_reason];
if (!isNil "DSDS_noise" && {DSDS_noise get "generation" == _raid get "id"}) then {
    DSDS_noise set ["phase","recovery"]; DSDS_noise set ["score",0];
    DSDS_noise set ["readyAt",diag_tickTime + (DSDS_raidConfig get "recovery")];
};
private _hq = _raid get "hq";
{
    private _group = _x;
    if (!isNull _group && {side _group == Occupants} && {{isPlayer _x} count units _group == 0} && {{alive _x && {!captive _x}} count units _group > 0}) then {
        if ({captive _x} count units _group > 0) then {
            // Leave captives in their group; retreat only the uncaptured survivors.
            private _retreat = createGroup [side _group,true];
            ((units _group) select {alive _x && {!captive _x}}) joinSilent _retreat;
            (_raid get "groups") pushBack _retreat;
            _group = _retreat;
        };
        while {count waypoints _group > 0} do {deleteWaypoint ((waypoints _group) select 0);};
        private _vehicle = vehicle leader _group;
        private _return = _vehicle getVariable ["DSDS_raidReturn",[]];
        if (_return isEqualTo []) then {
            _return = [_hq,2200,3200,10,0,0.4,0,[],[_hq,_hq]] call BIS_fnc_findSafePos;
        };
        {if (alive _x) then {_x disableAI "AUTOCOMBAT";};} forEach units _group;
        _group setBehaviourStrong "AWARE"; _group setCombatMode "YELLOW";
        if (_vehicle isKindOf "Air") then {_vehicle land "NONE"; _vehicle flyInHeight 160; _group setBehaviourStrong "CARELESS";};
        private _wp = _group addWaypoint [_return,50]; _wp setWaypointType "MOVE"; _group setCurrentWaypoint _wp;
    };
} forEach (+(_raid get "groups"));
[_raid] spawn DSDS_fnc_cleanupHQRaid;
diag_log format ["[DSDS HQ] Raid %1 ended (%2); noise cleared. Fresh post-recovery noise required.",_raid get "id",_reason];
true
