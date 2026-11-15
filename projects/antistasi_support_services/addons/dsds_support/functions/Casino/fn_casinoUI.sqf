disableSerialization;
params ["_op",["_args",[]]];
if (!hasInterface) exitWith {};
if (_op=="PLACE_OPEN") exitWith {
 _args params ["_token","_class","_price"];
 if (!createDialog "DSDS_CasinoPlacementDialog") exitWith {};
 private _d=findDisplay 88471;_d setVariable ["DSDS_buildToken",_token];_d setVariable ["DSDS_buildPosition",[]];
 (_d displayCtrl 2011) ctrlSetText format ["Aurum Casino | %1 credits",_price];
 (_d displayCtrl 2012) ctrlSetText "Choose a clear, flat, dry site about 30 metres across. Click the map, set the direction, then place. No charge until placement is accepted.";
};
if (_op=="PLACE_CLICK") exitWith {
 _args params ["_map","_button","_x","_y"];if (_button!=0) exitWith {};
 private _d=ctrlParent _map;private _p=_map ctrlMapScreenToWorld [_x,_y];private _pos=[_p select 0,_p select 1,0];_d setVariable ["DSDS_buildPosition",_pos];
 if (getMarkerColor "DSDS_CasinoPreview"=="") then {createMarkerLocal ["DSDS_CasinoPreview",_pos];};
 "DSDS_CasinoPreview" setMarkerPosLocal _pos;"DSDS_CasinoPreview" setMarkerShapeLocal "RECTANGLE";"DSDS_CasinoPreview" setMarkerSizeLocal [12,12];"DSDS_CasinoPreview" setMarkerColorLocal "ColorYellow";"DSDS_CasinoPreview" setMarkerBrushLocal "Border";
 "DSDS_CasinoPreview" setMarkerDirLocal (parseNumber ctrlText (_d displayCtrl 2013));
};
if (_op=="BUILD") exitWith {
 private _d=findDisplay 88471;private _p=_d getVariable ["DSDS_buildPosition",[]];
 if (_p isEqualTo []) exitWith {systemChat "Choose a location on the map first.";};
 ["PLACE",player,objNull,[_d getVariable ["DSDS_buildToken",""],_p,parseNumber ctrlText (_d displayCtrl 2013)]] remoteExecCall ["DSDS_fnc_casinoRequest",2];
};
if (_op=="PLACE_CLOSED") exitWith {deleteMarkerLocal "DSDS_CasinoPreview";["CANCEL_BUILD",player,objNull,[(_args param [0,displayNull]) getVariable ["DSDS_buildToken",""]]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
if (_op=="GAME_OPEN") exitWith {
 _args params ["_dealer","_snapshot"];
 if (!isNull findDisplay 88470) then {closeDialog 0;};
 if (!createDialog "DSDS_CasinoDialog") exitWith {};
 private _d=findDisplay 88470;_d setVariable ["DSDS_casinoDealer",_dealer];_d setVariable ["DSDS_casinoSnapshot",_snapshot];
 private _game=_snapshot select 0;private _cfg=configFile >> "DSDS_Casino" >> "Games" >> _game;
 (_d displayCtrl 1900) ctrlSetText ("AURUM  |  "+getText (_cfg >> "label")+"  |  "+getText (_cfg >> "dealer"));
 (_d displayCtrl 1902) ctrlSetText getText (_cfg >> "rules");
 private _combo=_d displayCtrl 1904;lbClear _combo;
 private _choices=getArray (_cfg >> "choices");private _labels=getArray (_cfg >> "choiceLabels");
 {private _i=_combo lbAdd (_labels param [_forEachIndex,_x]);_combo lbSetData [_i,_x];} forEach _choices;
 if (_game=="ROULETTE") then {for "_n" from 0 to 36 do {private _i=_combo lbAdd format ["Straight number %1",_n];_combo lbSetData [_i,format ["N:%1",_n]];};};
 _combo lbSetCurSel 0;
 (_d displayCtrl 1903) ctrlSetText "1000";
 ["RENDER",[]] call DSDS_fnc_casinoUI;
 [_d] spawn {
  disableSerialization;params ["_d"];private _poll=0;
  while {!isNull _d && {alive player}} do {
   ["RENDER",[]] call DSDS_fnc_casinoUI;
   if (diag_tickTime>=_poll) then {_poll=diag_tickTime+0.5;["READ",player,_d getVariable ["DSDS_casinoDealer",objNull],[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
   sleep 0.1;
  };
  if (!isNull _d) then {_d closeDisplay 2;};
 };
};
if (_op=="CLOSED") exitWith {private _closing=_args param [0,displayNull];if (!isNull _closing) then {["CLOSE",player,_closing getVariable ["DSDS_casinoDealer",objNull],[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};};
private _d=findDisplay 88470;if (isNull _d) exitWith {};
private _dealer=_d getVariable ["DSDS_casinoDealer",objNull];private _s=_d getVariable ["DSDS_casinoSnapshot",[]];if (count _s<14) exitWith {};
_s params ["_game","_id","_revision","_phase","_bet","_payout","_message","_p","_b","_dice","_point","_started","_balance","_token"];
if (_op=="BET") exitWith {private _combo=_d displayCtrl 1904;["BET",player,_dealer,[parseNumber ctrlText (_d displayCtrl 1903),_combo lbData lbCurSel _combo,_token]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
if (_op=="ACTION") exitWith {
 private _actions=getArray (configFile >> "DSDS_Casino" >> "Games" >> _game >> "actions");private _i=_args param [0,0];
 if (_i<count _actions) then {["ACTION",player,_dealer,[_id,_revision,_actions select _i]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
};
if (_op=="CLOSED") exitWith {["CLOSE",player,_dealer,[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];};
if (_op!="RENDER") exitWith {};
private _cfg=configFile >> "DSDS_Casino" >> "Games" >> _game;private _active=!(_phase in ["idle","finished"]);
(_d displayCtrl 1901) ctrlSetText format ["Personal credits: %1  |  Stake: %2  |  Last return: %3",_balance,_bet,_payout];
(_d displayCtrl 1905) ctrlEnable (!_active);(_d displayCtrl 1903) ctrlEnable (!_active);(_d displayCtrl 1904) ctrlEnable (!_active);
private _actions=getArray (_cfg >> "actions");private _labels=getArray (_cfg >> "actionLabels");
for "_i" from 0 to 2 do {private _button=_d displayCtrl (1906+_i);_button ctrlShow (_i<count _actions);if (_i<count _actions) then {_button ctrlSetText (_labels select _i);_button ctrlEnable (_phase=="playing");};};
private _body="Place your stake to begin.";
switch (_game) do {
 case "BLACKJACK": {
  if (_p isNotEqualTo []) then {_body=format ["<t size='1.35'>Your hand: %1</t><br/>Total: %2<br/><br/><t size='1.35'>Dealer: %3%4</t>",[_p] call DSDS_fnc_casinoCardsText,[_p] call DSDS_fnc_casinoScore,[_b] call DSDS_fnc_casinoCardsText,if (_active) then {"   [hidden]"} else {format ["  (%1)",[_b] call DSDS_fnc_casinoScore]}];};
  (_d displayCtrl 1908) ctrlEnable (_phase=="playing" && {count _p==2} && {_balance>=_bet} && {_bet*2<=getNumber (configFile >> "DSDS_Casino" >> "maximumBet")});
 };
 case "ROULETTE": {if (_phase=="spinning") then {_body=format ["<t size='2.8' color='#d9b55c'>%1</t><br/>The wheel is spinning...",floor (diag_tickTime*15) mod 37];} else {if (_phase=="finished") then {_body="The ball has settled.";};};};
 case "CRASH": {if (_active) then {_body=format ["<t size='3.2' color='#d9b55c'>%1x</t><br/>Cash out before the crash.",(floor (exp ((serverTime-_started)/9)*100))/100];};};
 case "CRAPS": {if (count _dice==2) then {_body=format ["<t size='2.4'>%1 + %2 = %3</t><br/><br/>%4",_dice select 0,_dice select 1,(_dice select 0)+(_dice select 1),if (_point==0) then {"Come-out roll"} else {format ["Point: %1",_point]}];};};
 case "BACCARAT": {if (_phase=="dealing") then {_body="The cards are being dealt...";} else {if (_p isNotEqualTo []) then {_body=format ["<t size='1.35'>Player: %1 (%2)</t><br/><br/><t size='1.35'>Banker: %3 (%4)</t>",[_p] call DSDS_fnc_casinoCardsText,[_p,true] call DSDS_fnc_casinoScore,[_b] call DSDS_fnc_casinoCardsText,[_b,true] call DSDS_fnc_casinoScore];};};};
};
(_d displayCtrl 1910) ctrlSetStructuredText parseText (_body+"<br/><br/><t color='#d9b55c'>"+_message+"</t>");

