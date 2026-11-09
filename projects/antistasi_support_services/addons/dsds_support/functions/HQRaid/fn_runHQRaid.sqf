params ["_raid"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _id = _raid get "id";
private _hq = _raid get "hq";
private _plan = [_hq] call DSDS_fnc_planHQRaid;
if (count _plan == 0) exitWith {[_raid,"no safe faction-compatible deployment"] call DSDS_fnc_endHQRaid;};
_raid set ["war",_plan get "war"]; _raid set ["plannedMen",_plan get "men"];
_raid set ["landingsTotal",count (_plan get "flights")];
private _side = _plan get "side";
private _troopTypes = _plan get "troops";
{
    if (_raid get "ended") exitWith {};
    _x params ["_class","_landing","_spawn","_count"];
    private _heli = createVehicle [_class,_spawn,[],0,"FLY"];
    if (isNull _heli) then {_raid set ["landingsDone",(_raid get "landingsDone") + 1];} else {
        (_raid get "vehicles") pushBack _heli;
        _heli setVariable ["DSDS_raidID",_id,true];
        _heli setDir (_spawn getDir _landing);
        _heli setPosASL [_spawn select 0,_spawn select 1,(0 max getTerrainHeightASL _spawn) + (_spawn select 2)];
        private _pilots = createGroup [_side,true]; (_raid get "groups") pushBack _pilots;
        private _pilot = [_pilots,_plan get "pilot",_spawn,_raid] call DSDS_fnc_spawnRaidUnit;
        if (!isNull _pilot) then {_pilot assignAsDriver _heli; _pilot moveInDriver _heli;};
        private _cargo = createGroup [_side,true]; (_raid get "groups") pushBack _cargo;
        private _capacity = _count min (_heli emptyPositions "cargo");
        for "_i" from 1 to _capacity do {
            private _type = _troopTypes select ((_i - 1) mod count _troopTypes);
            private _unit = [_cargo,_type,_spawn,_raid] call DSDS_fnc_spawnRaidUnit;
            if (!isNull _unit) then {
                _unit assignAsCargo _heli; _unit moveInCargo _heli;
                if (vehicle _unit == _heli) then {(_raid get "infantry") pushBack _unit;} else {deleteVehicle _unit;};
            };
            sleep 0.05;
        };
        if (isNull driver _heli || {units _cargo isEqualTo []}) then {
            {deleteVehicle _x;} forEach crew _heli; deleteVehicle _heli;
            _raid set ["landingsDone",(_raid get "landingsDone") + 1];
        } else {
            [_raid,_heli,_pilots,_cargo,_landing,_spawn] spawn DSDS_fnc_landRaidHelicopter;
        };
    };
    sleep 2;
} forEach (_plan get "flights");
{
    if (_raid get "ended") exitWith {};
    _x params ["_class","_position"];
    private _vehicle = createVehicle [_class,_position,[],0,"NONE"];
    if (!isNull _vehicle) then {
        (_raid get "vehicles") pushBack _vehicle; _vehicle setVariable ["DSDS_raidID",_id,true];
        _vehicle setDir (_position getDir _hq);
        private _group = createGroup [_side,true]; (_raid get "groups") pushBack _group;
        private _driver = [_group,_plan get "crew",_position,_raid] call DSDS_fnc_spawnRaidUnit;
        if (!isNull _driver) then {_driver assignAsDriver _vehicle; _driver moveInDriver _vehicle;};
        {
            private _path = _x;
            private _turret = configOf _vehicle;
            {_turret = ("true" configClasses (_turret >> "Turrets")) param [_x,configNull];} forEach _path;
            if (getNumber (_turret >> "dontCreateAI") == 0 && {getNumber (_turret >> "showAsCargo") == 0}) then {
                private _gunner = [_group,_plan get "crew",_position,_raid] call DSDS_fnc_spawnRaidUnit;
                if (!isNull _gunner) then {_gunner assignAsTurret [_vehicle,_path]; _gunner moveInTurret [_vehicle,_path];};
            };
        } forEach (allTurrets [_vehicle,false]);
        _group setBehaviourStrong "AWARE"; _group setCombatMode "RED";
        private _wp = _group addWaypoint [_hq,150]; _wp setWaypointType "SAD";
        if (isNull gunner _vehicle) then {
            [_raid,_vehicle,_group,_hq] spawn {
                params ["_raid","_vehicle","_group","_hq"];
                private _deadline = diag_tickTime + 600;
                waitUntil {sleep 3; _raid get "ended" || {!alive _vehicle} || {_vehicle distance2D _hq < 450} || {diag_tickTime > _deadline}};
                if (_raid get "ended" || {!alive _vehicle}) exitWith {};
                _group leaveVehicle _vehicle; {unassignVehicle _x; doGetOut _x;} forEach units _group;
                private _wp = _group addWaypoint [_hq,60]; _wp setWaypointType "SAD"; _group setCurrentWaypoint _wp;
            };
        };
    };
} forEach (_plan get "ground");
_raid set ["spawnComplete",true];
_raid set ["initialCombatants",count (_raid get "infantry")];
if (count (_raid get "infantry") < 20) exitWith {[_raid,"insufficient successfully boarded troops"] call DSDS_fnc_endHQRaid;};
diag_log format ["[DSDS HQ] Raid %1 deployed: war=%2 airborne=%3 transports=%4 ground=%5 side=%6",_id,_plan get "war",count (_raid get "infantry"),count (_plan get "flights"),count (_plan get "ground"),_side];
private _deadline = diag_tickTime + (DSDS_raidConfig get "assaultTimeout");
private _reason = "assault timed out";
waitUntil {
    sleep 5;
    private _petros = _raid get "petros";
    if (!alive _petros) exitWith {_reason = "Petros lost"; true};
    if (_petros != missionNamespace getVariable ["petros",objNull] || {_petros distance2D _hq > 150} || {!isNull attachedTo _petros}) exitWith {_reason = "HQ moved"; true};
    if (missionNamespace getVariable ["bigAttackInProgress",false]) exitWith {_reason = "yielding to native major attack"; true};
    if (_raid get "ended") exitWith {true};
    private _capable = {alive _x && {!captive _x} && {!fleeing _x} && {!(_x getVariable ["ACE_isUnconscious",false])}} count (_raid get "infantry");
    if (_raid get "landingsDone" >= _raid get "landingsTotal" && {_capable <= 0.25 * (_raid get "initialCombatants")}) exitWith {_reason = "attackers defeated or failed to deploy"; true};
    diag_tickTime > _deadline
};
[_raid,_reason] call DSDS_fnc_endHQRaid;
