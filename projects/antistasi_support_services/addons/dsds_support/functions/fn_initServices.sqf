if (missionNamespace getVariable ["DSDS_initialized",false]) exitWith {};
DSDS_initialized = true;
if (isServer) then {
    DSDS_jobs = createHashMap;
    DSDS_jobSequence = 0;
    DSDS_mechanic = objNull;
    publicVariable "DSDS_mechanic";
    [] spawn {
        waitUntil {sleep 2; missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_saveTarget"}};
        if (!isNil "A3A_saveData" && {(A3A_saveData getOrDefault ["startType",""]) == "load"}) then {
            [] call DSDS_fnc_restoreMechanic;
        } else {
            // A fresh campaign must not inherit an orphaned record if a deleted ID is reused.
            [] call DSDS_fnc_persistMechanic;
        };
        while {true} do {
            private _npc = missionNamespace getVariable ["DSDS_mechanic",objNull];
            if (!isNull _npc && {alive _npc}) then {
                private _mover = _npc getVariable ["DSDS_mover",objNull];
                if (!isNull attachedTo _npc && {isNull _mover || {!alive _mover} || {!isPlayer _mover} || {vehicle _mover != _mover}}) then {
                    [_mover,false] call DSDS_fnc_moveMechanic;
                };
                [] call DSDS_fnc_persistMechanic;
            };
            sleep 5;
        };
    };
};
if (hasInterface) then {
    [] spawn {
        while {true} do {
            if (missionNamespace getVariable ["serverInitDone",false] && {!isNull player}) then {
                [] call DSDS_fnc_serviceActions;
                // Also catch refunds/native salary and transactions outside this addon.
                private _holder = player getVariable ["owner",player];
                private _snapshot = [_holder,_holder getVariable ["moneyX",0]];
                if (_snapshot isNotEqualTo (missionNamespace getVariable ["DSDS_walletDisplay",[]])) then {
                    DSDS_walletDisplay = _snapshot;
                    if (!isNil "A3A_fnc_statistics") then {[] spawn A3A_fnc_statistics;};
                };
            };
            sleep 2;
        };
    };
};
diag_log format ["[DSDS] Antistasi Support Services 2.9 initialized (%1).",if (isClass (configFile >> "CfgPatches" >> "A3A_ultimate")) then {"Ultimate compatibility"} else {"Plus compatibility"}];



