/* Installed Ultimate's official plugin events survive its per-save HM reset. */
if (!isServer || {isRemoteExecuted} || {missionNamespace getVariable ["DSDS_campaignPersistenceInit",false]}) exitWith {};
DSDS_campaignPersistenceInit=true;
["A3A_event_serverGameSave",{
 params ["_plugins"];
 if (!isServer || {!(_plugins isEqualType createHashMap)}) exitWith {};
 if ((missionNamespace getVariable ["DSDS_mysticState",createHashMap]) getOrDefault ["loaded",false]) then {[] call DSDS_fnc_mysticSave;};
 if (!isNil "DSDS_casinoState") then {[] call DSDS_fnc_casinoSave;};
 if (!isNil "DSDS_luckyPlayers") then {[] call DSDS_fnc_luckySave;};
 private _rows=[];
 if (!isNil "A3A_saveDataHM") then {{if ((_x find "DSDS_")==0) then {_rows pushBack [_x,_y];};} forEach A3A_saveDataHM;};
 _plugins set ["DSDS_SupportServices",[1,_rows]];
}] call CBA_fnc_addEventHandler;
["A3A_event_serverGameLoad",{_this call DSDS_fnc_restoreCampaignData;}] call CBA_fnc_addEventHandler;
