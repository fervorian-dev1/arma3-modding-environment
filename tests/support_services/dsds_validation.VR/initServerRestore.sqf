[] spawn {
    sleep 3;
    call compile preprocessFileLineNumbers "phase.sqf";
    DSDS_testFailures=0;
    private _assert={params ["_ok","_name"];if (!_ok) then {DSDS_testFailures=DSDS_testFailures+1;};diag_log format ["[DSDS TEST] %1: %2",["FAIL","PASS"] select _ok,_name];};
    teamPlayer=west;
    A3A_saveTarget=[false,"DSDS_TEST_ISOLATED",worldName];
    private _group=createGroup sideLogic;
    server=_group createUnit ["Logic",[0,0,0],[],0,"NONE"];
    private _state=["DSDS_mechanicState"] call A3A_fnc_returnSavedStat;
    [!isNil "_state","prior process wrote mechanic campaign state to disk"] call _assert;
    private _npc=[] call DSDS_fnc_restoreMechanic;
    if (DSDS_expectAlive) then {
        [!isNull _npc && {alive _npc},"fresh process restores hired mechanic without purchase"] call _assert;
        [uniform _npc=="DSDS_MechanicUniform" && {headgear _npc=="H_Cap_blk"} && {(primaryWeapon _npc find "rhs_")==0},"cross-process restoration retains black outfit and mod weapon"] call _assert;
        _npc setDamage 1;
        sleep 0.1;
        saveMissionProfileNamespace;
        diag_log "[DSDS TEST] Saved dead state for final restart test.";
    } else {
        [isNull _npc,"fresh process does not resurrect killed mechanic"] call _assert;
        missionProfileNamespace setVariable ["DSDS_mechanicStateDSDS_TEST_ISOLATED",nil];
        saveMissionProfileNamespace;
    };
    diag_log format ["[DSDS TEST] COMPLETE phase=%1 failures=%2",["RestoreDead","RestoreAlive"] select DSDS_expectAlive,DSDS_testFailures];
};
