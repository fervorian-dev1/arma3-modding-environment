/* Optional owned loopback client probe: exercises the real non-dedicated CWP code. */
[] spawn {
 waitUntil {sleep 0.2;!isNull player && {!isNil "CBRN_SpawnMist"} && {count (missionNamespace getVariable ["CBRN_contaminationspawners",[]])>=2}};
 player allowDamage false;
 diag_log "[CLIENT CHEM TEST] Joined owned validation mission with live client.";
 private _start=(missionNamespace getVariable ["CBRN_contaminationspawners",[0,0]]) select 1;
 private _id="DSDS_CLIENT_CHEM_PROBE";
 [_id,[13000,15000,0],serverTime+90,60,1] call DSDS_fnc_chemicalCloud;
 private _deadline=diag_tickTime+55;
 waitUntil {sleep 0.2;((missionNamespace getVariable ["CBRN_contaminationspawners",[0,0]]) select 1)>_start || {diag_tickTime>_deadline}};
 private _source=(missionNamespace getVariable ["DSDS_cloudSources",createHashMap]) getOrDefault [_id,[]];
 private _ok=((missionNamespace getVariable ["CBRN_contaminationspawners",[0,0]]) select 1)>_start && {count _source==3 && {abs ((_source select 2)-6)<0.01}};
 diag_log format ["[CLIENT CHEM TEST] %1: real CWP active counter and corrected particle-source altitude; source=%2 counter=%3.",["FAIL","PASS"] select _ok,_source,missionNamespace getVariable ["CBRN_contaminationspawners",[]]];
};
