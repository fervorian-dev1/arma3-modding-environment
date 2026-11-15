if (!hasInterface || {isMultiplayer && {(!isRemoteExecuted) || {remoteExecutedOwner!=2}}}) exitWith {};
params ["_op",["_data",[]]];
switch (_op) do {
 case "SITE": {["SITE_RESULT",_data] call DSDS_fnc_casinoUI;};
 case "LUCKY": {["SYNC",_data] call DSDS_fnc_luckyUI;};
 case "PLACE": {["PLACE_OPEN",_data] call DSDS_fnc_casinoUI;};
 case "BUILT": {if (!isNull findDisplay 88471) then {closeDialog 0;};systemChat "Aurum Casino is open. Its location is marked on the map.";};
 case "BUILD_FAILED": {if (!isNull findDisplay 88471) then {closeDialog 0;};systemChat "The casino could not be placed. Your credits have been returned or queued for your next spawn.";};
 case "OPEN": {["GAME_OPEN",_data] call DSDS_fnc_casinoUI;};
 case "STATE": {
  disableSerialization;private _display=findDisplay 88470;
  if (!isNull _display && {(_display getVariable ["DSDS_casinoDealer",objNull])==(_data select 0)}) then {private _incoming=_data select 1;private _old=_display getVariable ["DSDS_casinoSnapshot",[]];if ((_incoming param [14,0])>=(_old param [14,0])) then {_display setVariable ["DSDS_casinoSnapshot",_incoming];};["RENDER",[]] call DSDS_fnc_casinoUI;};
 };
};
