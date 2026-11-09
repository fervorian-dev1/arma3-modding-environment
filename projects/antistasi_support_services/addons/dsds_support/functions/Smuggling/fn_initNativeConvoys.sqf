/* Scoped adapter for Ultimate's two-argument Petros scheduler request.
   Keep the installed worker, routes, rewards and despawning; change only the
   objective truck for our cargo. Explicit attack/intel/debug calls stay native. */
if (hasInterface && {!isServer} || {isRemoteExecuted} || {missionNamespace getVariable ["DSDS_nativeConvoyAdapter",false]} || {isNil "A3A_fnc_convoy"}) exitWith {};
private _cfg=configFile >> "CfgFunctions" >> "A3A" >> "Missions";
// Category still points to the installed addon; only the convoy entry's file is
// redirected in our config because Ultimate compiles its functions final.
private _path=getText (_cfg >> "file")+"\fn_convoy.sqf";
if (!fileExists _path) exitWith {diag_log "[DSDS Convoy] Native convoy source unavailable; original worker retained.";};
private _source=preprocessFileLineNumbers _path;
// Only the Money convoy's successful HQ-delivery payout. Keep native scaling
// whenever it already exceeds the requested minimum; failed missions pay none.
private _reward="[0,5000*_bonus] remoteExec";
private _rewardIndex=_source find _reward;
if (_rewardIndex>=0 && {((_source select [_rewardIndex+count _reward]) find _reward)<0}) then {
 _source=(_source select [0,_rewardIndex])+"[0,((5000*_bonus) max 70000)] remoteExec"+(_source select [_rewardIndex+count _reward]);
} else {diag_log "[DSDS Convoy] Money payout signature changed; native reward retained for review.";};
_source=[_source] call DSDS_fnc_adaptConvoySafety;
DSDS_nativeConvoyOriginal=compile _source;
private _anchor="private _vehObj = [_typeVehObj, _objText] call _fnc_spawnConvoyVehicle;";
private _index=_source find _anchor;
private _taskAnchor="private _taskId = ""CONVOY"" + str A3A_taskCount;";
private _taskIndex=_source find _taskAnchor;
if (_index<0 || {_taskIndex<0} || {((_source select [_index+count _anchor]) find _anchor)>=0}) exitWith {diag_log "[DSDS Convoy] Native objective/briefing signature changed; original worker retained.";};
private _hook="if (!isNil '_dsdsPetrosConvoySelection' && {(_dsdsPetrosConvoySelection select 1)!=''}) then {_typeVehObj=_dsdsPetrosConvoySelection select 1;}; ";
private _custom=(_source select [0,_index])+_hook+(_source select [_index]);
private _briefHook="if (!isNil '_dsdsPetrosConvoySelection' && {(_dsdsPetrosConvoySelection select 0)!=''}) then {_taskTitle=switch (_dsdsPetrosConvoySelection select 0) do {case 'SPECIAL':{'Special Convoy'};case 'MEDICAL':{'Medical Convoy'};default {'Isotope Convoy'};};_textX=format ['A %1 will depart %2 at %3, bound for %4 (grid %5).',_taskTitle,_nameOrigin,_displayTime,_nameDest,mapGridPosition _posDest];}; ";
_custom=(_custom select [0,_taskIndex])+_briefHook+(_custom select [_taskIndex]);
DSDS_nativeCargoConvoy=compile _custom;
DSDS_nativeConvoyAdapter=true;
if (isServer) then {DSDS_petrosConvoyQueue=[];};
if (isServer) then {[] spawn {while {true} do {if (DSDS_petrosConvoyQueue isNotEqualTo []) then {private _args=DSDS_petrosConvoyQueue deleteAt 0;_args spawn A3A_fnc_convoy;};sleep 0.5;};};};
diag_log "[DSDS Convoy] Petros mixed cargo rotation connected to installed native convoy worker.";
