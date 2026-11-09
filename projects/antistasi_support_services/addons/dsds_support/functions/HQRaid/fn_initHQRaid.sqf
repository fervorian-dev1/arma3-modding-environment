if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_noiseInitialized",false]}) exitWith {};
DSDS_noiseInitialized = true;
if (isServer) then {
    DSDS_raidConfig = createHashMap;
    {DSDS_raidConfig set [configName _x,getNumber _x];} forEach (configProperties [configFile >> "DSDS_HQRaid","isNumber _x",true]);
    DSDS_noise = createHashMapFromArray [["phase","quiet"],["score",0],["lastTick",diag_tickTime],["hq",[]],["generation",0]];
    [] spawn {
        waitUntil {sleep 1; missionNamespace getVariable ["serverInitDone",false]};
        while {true} do {[] call DSDS_fnc_tickHQNoise; sleep 1;};
    };
};
if (hasInterface) then {
    DSDS_noiseQueue = createHashMap;
    [] spawn {
        while {true} do {
            if (missionNamespace getVariable ["serverInitDone",false] && {!isNull player}) then {
                [player] call DSDS_fnc_registerNoisePlayer;
                if (count DSDS_noiseQueue > 0) then {
                    private _batch = values DSDS_noiseQueue;
                    DSDS_noiseQueue = createHashMap;
                    [player,_batch] remoteExecCall ["DSDS_fnc_reportHQNoise",2];
                };
            };
            sleep 0.5;
        };
    };
};
diag_log "[DSDS HQ] Noise raid controller initialized (v1.4).";
