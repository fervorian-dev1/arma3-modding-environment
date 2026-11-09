/* The dispatcher runs outside RPC context; private mission workers stay non-remote. */
if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_customMissionsInitialized",false]}) exitWith {};
DSDS_customMissionsInitialized=true;
if (isServer) then {
    DSDS_missionQueue=[];DSDS_debugMissions=createHashMap;
    diag_log format ["[DSDS AI] Loaded: Accuracy Fix=%1, AI Behavior Modification=%2, LAMBS Danger=%3. Global mod settings retained.",isClass (configFile >> "CfgPatches" >> "tws_aimfix"),isClass (configFile >> "CfgPatches" >> "AI_behavior_modification_core"),isClass (configFile >> "CfgPatches" >> "lambs_danger")];
    [] spawn {
        private _workers=[];
        while {true} do {
            if (DSDS_missionQueue isNotEqualTo []) then {
                private _request=DSDS_missionQueue deleteAt 0;
                _request params ["_kind","_actor","_position","_debug"];
                private _entry=configFile >> "DSDS_DebugMissions" >> _kind;
                private _handler=missionNamespace getVariable [getText (_entry >> "handler"),{}];
                private _worker=[_actor,_position,_debug,getText (_entry >> "variant")] spawn _handler;
                _workers pushBack [_kind,_actor,_worker];
            };
            {
                _x params ["_kind","_actor","_worker"];
                if (scriptDone _worker && {_kind in ["STASH","ISOTOPE_STASH"]} && {missionNamespace getVariable ["DSDS_stashPending",false]}) then {
                    DSDS_stashPending=false;diag_log "[DSDS Stash] Worker ended without clearing pending flag; request unlocked.";
                    ["MESSAGE",["The stash lead could not be prepared. Please retry; details are in the server log."]] remoteExecCall ["DSDS_fnc_clientService",_actor];
                };
            } forEach _workers;
            _workers=_workers select {!scriptDone (_x select 2)};
            {private _entry=DSDS_debugMissions get _x;[_entry] call DSDS_fnc_tickDebugMission;} forEach +(keys DSDS_debugMissions);
            sleep 0.5;
        };
    };
};
if (hasInterface) then {
    if (!isNil "zen_custom_modules_fnc_register") then {
        {
            private _code=compile format ["params ['_position'];['%1',player,_position] remoteExecCall ['DSDS_fnc_debugMissionRequest',2];",configName _x];
            ["DEBUG",getText (_x >> "displayName"),_code] call zen_custom_modules_fnc_register;
        } forEach ("true" configClasses (configFile >> "DSDS_DebugMissions"));
    };
};
