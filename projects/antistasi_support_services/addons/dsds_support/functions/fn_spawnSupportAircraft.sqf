params ["_job"];
private _type = _job get "type";
private _origin = +(_job get "origin");
private _target = _job get "target";
private _strike = _type in ["HE","CLUSTER","NAPALM","CHEMICAL"];
if (_type == "PARADROP") then {_origin = getPosATL (_job get "player"); _origin set [2,0];};
private _bearing = _origin getDir _target;
if (_origin distance2D _target < 50) then {_bearing = random 360;};
private _airClass = "B_Heli_Transport_01_F";
if (isClass (configFile >> "CfgVehicles" >> "RHS_C130J")) then {_airClass = "RHS_C130J";};
if (_type == "LOOTHELI") then {_airClass = "B_Heli_Transport_01_F";};
if (_strike) then {
    // Installed RHS T-50: verified afterburner_source and native sonic-boom soundset.
    private _candidates = ["RHS_T50_vvs_generic_ext","RHS_T50_vvs_generic"] select {
        isClass (configFile >> "CfgVehicles" >> _x) && {[_x,"CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}
    };
    _airClass = _candidates param [0,""];
};
if (_airClass == "") exitWith {diag_log "[DSDS] No installed DLC-free supersonic strike aircraft available."; []};
private _altitude = if (_type == "PARADROP") then {800} else {if (_strike) then {getNumber (configFile >> "DSDS_StrikeFlight" >> "terrainClearance")} else {300}};
private _spawn = _origin getPos [if (_strike) then {4500} else {3000},_bearing + 180];
_spawn set [2,_altitude];
private _aircraft = createVehicle [_airClass,_spawn,[],0,"FLY"];
if (isNull _aircraft) exitWith {[]};
_aircraft setDir _bearing; _aircraft setPosATL _spawn;
private _strikeASL = 0;
if (_strike) then {
    _strikeASL = [_spawn,_bearing,getNumber (configFile >> "DSDS_StrikeFlight" >> "speed")] call DSDS_fnc_strikeFlightAltitude;
    _aircraft setPosASL [_spawn select 0,_spawn select 1,_strikeASL];
};
_aircraft setVariable ["DSDS_serviceVehicle",true,true];
createVehicleCrew _aircraft;
private _crew = crew _aircraft;
private _oldGroups = _crew apply {group _x};
private _group = createGroup [teamPlayer,true];
_crew joinSilent _group;
{if (count units _x == 0) then {deleteGroup _x;};} forEach (_oldGroups arrayIntersect _oldGroups);
if (isNull driver _aircraft) exitWith {deleteVehicle _aircraft; {deleteVehicle _x;} forEach _crew; deleteGroup _group; []};
if (_type=="PARADROP") then {
    // Apply after creating the AI crew. Passengers can leave/jump normally,
    // but cannot switch into the pilot or copilot/turret control stations.
    _aircraft lockDriver true;
    {_aircraft lockTurret [_x,true];} forEach allTurrets [_aircraft,true];
};
_group setBehaviourStrong "CARELESS"; _group setCombatMode "BLUE";
if (_strike) then {_group setSpeedMode "FULL";};
{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"; _x setSkill 1;} forEach _crew;
{[_x,"FLIGHT"] call DSDS_fnc_configureAddonAI;} forEach _crew;
_aircraft flyInHeight _altitude;
private _speed = if (_strike) then {getNumber (configFile >> "DSDS_StrikeFlight" >> "speed")} else {if (_aircraft isKindOf "Plane") then {85} else {55}};
_aircraft setVelocity [sin _bearing * _speed,cos _bearing * _speed,0];
private _waypoints = [];
{
    private _position = +_x; _position set [2,_altitude];
    private _wp = _group addWaypoint [_position,0]; _wp setWaypointType "MOVE"; _wp setWaypointCompletionRadius 80;
    _waypoints pushBack _wp;
} forEach [_origin,_target,_target getPos [6000,_bearing]];
_group setCurrentWaypoint (_waypoints select 0);
if (_strike) then {[_aircraft,_bearing,_strikeASL,_speed] spawn DSDS_fnc_flyStrikeAircraft;};
[_aircraft,_crew,_group,_target] spawn DSD_fnc_cleanupSupplyAircraft;
[_aircraft,_crew,_group,_waypoints,_origin,_target]
