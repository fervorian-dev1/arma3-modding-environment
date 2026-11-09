if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_gameplayHotfixes",false]}) exitWith {};
DSDS_gameplayHotfixes=true;
if (hasInterface) then {
 private _path=getText (configFile >> "CfgFunctions" >> "SCRT" >> "Common" >> "file")+"\fn_common_unconsciousEventHandler.sqf";
 if (fileExists _path) then {DSDS_nativeReviveKeys=compile preprocessFileLineNumbers _path;};
 [] spawn {while {true} do {if (!isNull player) then {[player] call DSDS_fnc_repairReviveUI;};sleep 0.2;};};
};
if (isServer) then {[] spawn {waitUntil {sleep 1;missionNamespace getVariable ["serverInitDone",false]};while {true} do {[] call DSDS_fnc_protectOswaldArsenal;sleep 30;};};};
