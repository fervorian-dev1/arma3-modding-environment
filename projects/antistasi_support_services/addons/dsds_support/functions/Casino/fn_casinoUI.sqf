disableSerialization;
params ["_op",["_args",[]]];
if (!hasInterface) exitWith {};
if (_op=="PLACE_OPEN") exitWith {
 _args params ["_token","_class","_price"];
 if (!createDialog "DSDS_CasinoPlacementDialog") exitWith {};
 private _d=findDisplay 88471;_d setVariable ["DSDS_buildToken",_token];_d setVariable ["DSDS_buildPosition",[]];
 (_d displayCtrl 2011) ctrlSetText (if (_price==0) then {"Relocate / place owned casino"} else {format ["Aurum Casino | %1 credits",_price]});
 (_d displayCtrl 2012) ctrlSetText "Click the map or use Find suitable location. The casino clears local vegetation and prepares a level pad. Existing structures, roads and steep cliffs are protected.";
};
if (_op=="FIND_SITE") exitWith {
 private _d=findDisplay 88471;private _p=_d getVariable ["DSDS_buildPosition",getPosATL player];
 if (_p isEqualTo []) then {_p=getPosATL player;};
 (_d displayCtrl 2016) ctrlEnable false;(_d displayCtrl 2012) ctrlSetText "Searching nearby land. Vegetation can be cleared; existing structures and roads are protected.";
 ["FIND_SITE",player,objNull,[_d getVariable ["DSDS_buildToken",""],_p]] remoteExecCall ["DSDS_fnc_casinoRequest",2];
};
if (_op=="SITE_RESULT") exitWith {
 _args params ["_token","_site"];private _d=findDisplay 88471;
 if (isNull _d || {_d getVariable ["DSDS_buildToken",""]!=_token}) exitWith {};
 (_d displayCtrl 2016) ctrlEnable true;
 if (_site isEqualTo []) exitWith {(_d displayCtrl 2012) ctrlSetText "No suitable nearby land found. Click a different area and search again.";};
 _site params ["_pos","_dir"];_d setVariable ["DSDS_buildPosition",_pos];(_d displayCtrl 2013) ctrlSetText str _dir;
 private _map=_d displayCtrl 2010;_map ctrlMapAnimAdd [0.4,0.08,_pos];ctrlMapAnimCommit _map;
 if (getMarkerColor "DSDS_CasinoPreview"=="") then {createMarkerLocal ["DSDS_CasinoPreview",_pos];};
 "DSDS_CasinoPreview" setMarkerPosLocal _pos;"DSDS_CasinoPreview" setMarkerShapeLocal "RECTANGLE";"DSDS_CasinoPreview" setMarkerSizeLocal [20,36];"DSDS_CasinoPreview" setMarkerDirLocal _dir;"DSDS_CasinoPreview" setMarkerColorLocal "ColorYellow";"DSDS_CasinoPreview" setMarkerBrushLocal "Border";
 (_d displayCtrl 2012) ctrlSetText "Suitable site found. Review the map and press Place casino. Vegetation is cleared and a small level pad is prepared only when placed.";
};
if (_op=="PLACE_CLICK") exitWith {
 _args params ["_map","_button","_x","_y"];if (_button!=0) exitWith {};
 private _d=ctrlParent _map;private _p=_map ctrlMapScreenToWorld [_x,_y];private _pos=[_p select 0,_p select 1,0];_d setVariable ["DSDS_buildPosition",_pos];
 if (getMarkerColor "DSDS_CasinoPreview"=="") then {createMarkerLocal ["DSDS_CasinoPreview",_pos];};
 "DSDS_CasinoPreview" setMarkerPosLocal _pos;"DSDS_CasinoPreview" setMarkerShapeLocal "RECTANGLE";"DSDS_CasinoPreview" setMarkerSizeLocal [20,36];"DSDS_CasinoPreview" setMarkerColorLocal "ColorYellow";"DSDS_CasinoPreview" setMarkerBrushLocal "Border";
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
   sleep 0.025;
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
 case "ROULETTE": {_body=if (_phase=="spinning") then {"The ball is in motion."} else {"Select a pocket or an outside bet, then spin."};};
 case "CRASH": {if (_active) then {_body=format ["<t size='3.2' color='#d9b55c'>%1x</t><br/>Cash out before the crash.",(floor (exp ((serverTime-_started)/9)*100))/100];};};
 case "CRAPS": {if (count _dice==2) then {_body=format ["<t size='2.4'>%1 + %2 = %3</t><br/><br/>%4",_dice select 0,_dice select 1,(_dice select 0)+(_dice select 1),if (_point==0) then {"Come-out roll"} else {format ["Point: %1",_point]}];};};
 case "BACCARAT": {if (_phase=="dealing") then {_body="The cards are being dealt...";} else {if (_p isNotEqualTo []) then {_body=format ["<t size='1.35'>Player: %1 (%2)</t><br/><br/><t size='1.35'>Banker: %3 (%4)</t>",[_p] call DSDS_fnc_casinoCardsText,[_p,true] call DSDS_fnc_casinoScore,[_b] call DSDS_fnc_casinoCardsText,[_b,true] call DSDS_fnc_casinoScore];};};};
};
(_d displayCtrl 1910) ctrlSetStructuredText parseText (_body+"<br/><br/><t color='#d9b55c'>"+_message+"</t>");


if (_game=="ROULETTE") then {[_d,_s] call DSDS_fnc_rouletteVisual;};

if (_game in ["BLACKJACK","CRASH"]) then {[_d,_s] call DSDS_fnc_casinoGameVisual;};
