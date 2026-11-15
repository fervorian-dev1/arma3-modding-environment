disableSerialization;
params ["_op",["_args",[]]];
if (!hasInterface) exitWith {};
if (_op=="SYNC") exitWith {
 private _s=_args;_s params ["_npc","_tokens","_cars","_items","_gummies","_spin","_result","_message","_nonce","_money","_open","_earned"];
 player setVariable ["DSDS_luckyTokens",_tokens];uiNamespace setVariable ["DSDS_luckySnapshot",_s];
 if (_tokens>0 || {_open} || {_earned}) then {if (isNull (uiNamespace getVariable ["DSDS_luckyHUD",displayNull])) then {("DSDS_LuckyHUD" call BIS_fnc_rscLayer) cutRsc ["DSDS_LuckyHUD","PLAIN",0,false];};};
 private _hud=uiNamespace getVariable ["DSDS_luckyHUD",displayNull];if (!isNull _hud) then {(_hud displayCtrl 22300) ctrlSetText format ["Tokens: %1",_tokens];};
 if (_earned) then {playSound "Hint";systemChat format ["Roxie: One less ex. Lucky token earned! Tokens: %1",_tokens];};
 if (_open) then {
  if (!isNull findDisplay 88470) then {closeDialog 0;};if (!isNull findDisplay 88472) then {closeDialog 0;};
  if (createDialog "DSDS_LuckyDialog") then {
   private _d=findDisplay 88472;_d setVariable ["DSDS_luckyDealer",_npc];
   [_d] spawn {disableSerialization;params ["_d"];private _poll=0;while {!isNull _d && {alive player}} do {
    private _dealer=_d getVariable ["DSDS_luckyDealer",objNull];if (isNull _dealer || {player distance _dealer>12}) exitWith {_d closeDisplay 2;};
    ["RENDER"] call DSDS_fnc_luckyUI;
    if (diag_tickTime>=_poll) then {_poll=diag_tickTime+0.6;["READ",player,_dealer,[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};sleep 0.05;
   };if (!isNull _d) then {_d closeDisplay 2;};};
  };
 };
 ["RENDER"] call DSDS_fnc_luckyUI;
};
private _d=findDisplay 88472;if (isNull _d) exitWith {};
private _s=uiNamespace getVariable ["DSDS_luckySnapshot",[]];if (count _s<12) exitWith {};
_s params ["_npc","_tokens","_cars","_items","_gummies","_spin","_result","_message","_nonce","_money"];
if (_op=="ACTION") exitWith {[_args param [0,""],player,_npc,[_nonce]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
if (_op!="RENDER") exitWith {};
(_d displayCtrl 2201) ctrlSetText format ["Tokens: %1   |   Personal credits: %2",_tokens,_money];
(_d displayCtrl 2202) ctrlSetStructuredText parseText _message;
(_d displayCtrl 2203) ctrlEnable (_tokens>0 && {_spin isEqualTo []});
(_d displayCtrl 2204) ctrlEnable (_money>=150);
(_d displayCtrl 2205) ctrlSetText format ["Collect Hellcat (%1)",_cars];(_d displayCtrl 2205) ctrlEnable (_cars>0);
(_d displayCtrl 2206) ctrlSetText format ["Collect items (%1)",_items+_gummies];(_d displayCtrl 2206) ctrlEnable (_items+_gummies>0);
[_d,_spin,_result,_tokens] call DSDS_fnc_luckyVisual;
