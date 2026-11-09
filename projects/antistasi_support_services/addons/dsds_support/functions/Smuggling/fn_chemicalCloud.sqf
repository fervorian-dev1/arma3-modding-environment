/* Client CWP effect: wait for initialization, correct native -6m particle offset, replay for JIP. */
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner!=2}}) exitWith {false};
params ["_id","_position","_expires","_radius","_type"];
if (_expires<=serverTime) exitWith {false};
if (isNil "DSDS_cloudJobs") then {DSDS_cloudJobs=[];};
if (_id in DSDS_cloudJobs) exitWith {false};
DSDS_cloudJobs pushBack _id;
[_id,_position,_expires,_radius,_type] spawn {
 params ["_id","_position","_expires","_radius","_type"];
 private _deadline=diag_tickTime+45;
 waitUntil {sleep 0.2;(!isNil "CBRN_fnc_spawnMist" && {!isNil "CBRN_SpawnMist"} && {count (missionNamespace getVariable ["CBRN_contaminationspawners",[]])>_type} && {count (missionNamespace getVariable [format ["CBRN_color_contamination%1",_type],[]])>=3}) || {diag_tickTime>_deadline} || {serverTime>=_expires}};
 if (isNil "CBRN_SpawnMist" || {serverTime>=_expires} || {diag_tickTime>_deadline}) exitWith {
  DSDS_cloudJobs=DSDS_cloudJobs-[_id];diag_log format ["[DSDS Chemical] %1: CWP initialization unavailable; effect not started.",_id];
 };
 if (missionNamespace getVariable ["CBRN_KillSwitch",false]) exitWith {DSDS_cloudJobs=DSDS_cloudJobs-[_id];diag_log "[DSDS Chemical] CWP global kill switch is enabled; no settings were overridden.";};
 // Native CWP renders its particle origins at [0,0,-6]; source must be 6m ATL.
 private _source=+_position;_source set [2,6];
 if (isNil "DSDS_cloudSources") then {DSDS_cloudSources=createHashMap;};
 DSDS_cloudSources set [_id,_source];
 [_source,_radius,_expires-serverTime,_type,4,12,0.25] spawn CBRN_fnc_spawnMist;
 [_source,45,90 min (_expires-serverTime),_type,4,8,0.3] spawn CBRN_fnc_spawnMist;
 diag_log format ["[DSDS Chemical] %1 native CWP area + dense rupture cloud started at %2 (corrected ATL source).",_id,_source];
};
true
