params ["_jobID"];
private _dsdsContractJob = _jobID;
if (!isServer || {isNil {DSDS_jobs get _jobID}}) exitWith {};
private _job = DSDS_jobs get _jobID;
if ((_job get "state") != "paid") exitWith {};
_job set ["state","deploying"];
private _type = _job get "type";
if (_type=="PARADROP") then {_job set ["departure",getPosATL (_job get "player")];};
private _target = _job get "target";
// Native smoke/illumination payloads, without invoking the commander's shared marker state.
if (_type in ["SMOKE","FLARE"]) exitWith {
    private _ammo = if (_type == "SMOKE") then {"Smoke_82mm_AMOS_White"} else {"F_40mm_White"};
    if (!isClass (configFile >> "CfgAmmo" >> _ammo)) exitWith {[_jobID,false,"Support ammunition unavailable."] call DSDS_fnc_finishSupportContract;};
    sleep 10;
    private _created = 0;
    for "_i" from 1 to 5 do {
        private _position = [(_target select 0) - 20 + random 40,(_target select 1) - 20 + random 40,130];
        private _round = createVehicle [_ammo,_position,[],0,"CAN_COLLIDE"];
        if (!isNull _round) then {_created = _created + 1; _round setVelocity [0,0,-5];};
        sleep 1;
    };
    _job set ["roundsCreated",_created];
    [_jobID,_created > 0,"Artillery payload deployment"] call DSDS_fnc_finishSupportContract;
};
private _flight = [_job] call DSDS_fnc_spawnSupportAircraft;
if (_flight isEqualTo []) exitWith {[_jobID,false,"Transport creation failed."] call DSDS_fnc_finishSupportContract;};
_flight params ["_aircraft","_crew","_group","_waypoints","_origin"];
_job set ["aircraft",_aircraft];
if (_type == "PARADROP") then {
    [_job get "player",_aircraft] remoteExecCall ["DSDS_fnc_boardSupportPassenger",_job get "player"];
    private _boardingDeadline = diag_tickTime + 15;
    waitUntil {sleep 0.25; vehicle (_job get "player") == _aircraft || {diag_tickTime > _boardingDeadline}};
    if (vehicle (_job get "player") != _aircraft) then {_job set ["boardingFailed",true];};
};
if (_job getOrDefault ["boardingFailed",false]) exitWith {
    _aircraft setVariable ["DSD_departing",true]; _group setCurrentWaypoint (_waypoints select 2);
    [_jobID,false,"Could not board the requester."] call DSDS_fnc_finishSupportContract;
};
private _releasePoint = if (_type in ["HE","CLUSTER","NAPALM","CHEMICAL","VEH_AIRDROP"]) then {_origin} else {_target};
private _deadline = diag_tickTime + 240;
waitUntil {sleep 0.15; !alive _aircraft || {!alive driver _aircraft} || {_aircraft distance2D _releasePoint < 180} || {diag_tickTime > _deadline}};
if (!alive _aircraft || {!alive driver _aircraft} || {diag_tickTime > _deadline}) exitWith {
    _aircraft setVariable ["DSD_departing",true];
    [_jobID,false,"Transport could not reach the target."] call DSDS_fnc_finishSupportContract;
};
if (_type in ["HE","CLUSTER","NAPALM","CHEMICAL"]) exitWith {
    _job set ["releaseSpeed",speed _aircraft];
    _job set ["aircraftClass",typeOf _aircraft];
    _job set ["afterburnerPhase",_aircraft animationSourcePhase "afterburner_source"];
    _job set ["releaseAltitude",getPosATL _aircraft select 2];
    diag_log format ["[DSDS] Strike %1: %2 at %3 km/h, %4 m above terrain.",_type,typeOf _aircraft,round speed _aircraft,round (getPosATL _aircraft select 2)];
    private _count = switch (_type) do {case "CHEMICAL":{1}; case "HE":{4}; default {2};};
    private _bombs = if (_type == "NAPALM") then {
        [_aircraft,100 max (_origin distance2D _target)] spawn DSDS_fnc_napalmRun
    } else {
        [_aircraft,_type,_count,100 max (_origin distance2D _target)] spawn A3A_fnc_airbomb
    };
    _job set ["nativeScript",_bombs];
    [_aircraft,_group,_waypoints,_bombs] spawn {
        params ["_aircraft","_group","_waypoints","_bombs"];
        waitUntil {sleep 1; isNull _aircraft || {scriptDone _bombs}};
        if (!isNull _aircraft) then {_aircraft setVariable ["DSD_departing",true]; _group setCurrentWaypoint (_waypoints select 2);};
    };
    [_jobID,true] call DSDS_fnc_finishSupportContract;
};
_aircraft setVariable ["DSD_departing",true];
_group setCurrentWaypoint (_waypoints select 2);
if (_type == "RECON") exitWith {
    [_target,350,180] spawn SCRT_fnc_common_recon;
    [_jobID,true] call DSDS_fnc_finishSupportContract;
};
if (_type == "PARADROP") exitWith {
    private _unit=_job get "player";
    private _jumped=[_unit,_aircraft,_job getOrDefault ["departure",_job get "origin"]] call DSDS_fnc_confirmPassengerJump;
    [_jobID,_jumped] call DSDS_fnc_finishSupportContract;
};
private _payloadClass = "B_supplyCrate_F";
if (_type == "VEH_AIRDROP") then {
    private _vehicles = (A3A_faction_reb getOrDefault ["vehiclesBasic",[]]) select {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "LandVehicle"} && {[_x,"CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}};
    _payloadClass = if (_vehicles isEqualTo []) then {"B_G_Offroad_01_F"} else {selectRandom _vehicles};
};
private _position = getPosASL _aircraft; _position set [2,(_position select 2) - 12];
private _chute = createVehicle ["B_Parachute_02_F",ASLToATL _position,[],0,"FLY"];
private _payload = createVehicle [_payloadClass,ASLToATL _position,[],0,"CAN_COLLIDE"];
_job set ["payload",_payload];
if (isNull _chute || {isNull _payload}) exitWith {
    if (!isNull _chute) then {deleteVehicle _chute;}; if (!isNull _payload) then {deleteVehicle _payload;};
    [_jobID,false,"Payload creation failed."] call DSDS_fnc_finishSupportContract;
};
_payload allowDamage false; _chute allowDamage false; _chute setPosASL _position;
_payload attachTo [_chute,[0,0,-4]]; _chute setVelocity [0,0,-4];
if (_type == "SUPPLY") then {
    private _manifest = [_payload,50] call DSD_fnc_fillSupplyCrate;
    if (_manifest isEqualTo []) then {_job set ["payloadFailed",true];};
};
if (_type == "LOOTHELI") then {
    clearWeaponCargoGlobal _payload; clearMagazineCargoGlobal _payload; clearItemCargoGlobal _payload; clearBackpackCargoGlobal _payload;
    [_payload,300,_target] call SCRT_fnc_loot_gatherLoot;
};
if (_job getOrDefault ["payloadFailed",false]) exitWith {
    detach _payload; deleteVehicle _payload; deleteVehicle _chute;
    [_jobID,false,"No valid supply manifest could be generated."] call DSDS_fnc_finishSupportContract;
};
if (_type == "VEH_AIRDROP") then {_payload setVariable ["ownerX",_job get "uid",true];};
{_x addCuratorEditableObjects [[_payload],false];} forEach allCurators;
private _landed = [_payload,_chute,_type == "VEH_AIRDROP"] call DSDS_fnc_landSupportPayload;
[_jobID,_landed,if (_landed) then {""} else {"Payload could not land."}] call DSDS_fnc_finishSupportContract;
