params ["_s","_op"];if (_op=="START") exitWith {_s set ["phase","dealing"];_s set ["due",serverTime+3];true};
if !(_op in ["RESOLVE","TIMEOUT"]) exitWith {false};
private _p=[[_s] call DSDS_fnc_casinoDraw,[_s] call DSDS_fnc_casinoDraw];private _b=[[_s] call DSDS_fnc_casinoDraw,[_s] call DSDS_fnc_casinoDraw];
private _pt=[_p,true] call DSDS_fnc_casinoScore;private _bt=[_b,true] call DSDS_fnc_casinoScore;
if (_pt<8 && {_bt<8}) then {
 private _third=-1;
 if (_pt<=5) then {private _card=[_s] call DSDS_fnc_casinoDraw;_p pushBack _card;_third=((_card mod 13)+1) min 10;_third=_third mod 10;};
 private _draw=if (_third<0) then {_bt<=5} else {_bt<=2 || {_bt==3 && {_third!=8}} || {_bt==4 && {_third>=2 && {_third<=7}}} || {_bt==5 && {_third>=4 && {_third<=7}}} || {_bt==6 && {_third in [6,7]}}};
 if (_draw) then {_b pushBack ([_s] call DSDS_fnc_casinoDraw);};
};
_pt=[_p,true] call DSDS_fnc_casinoScore;_bt=[_b,true] call DSDS_fnc_casinoScore;_s set ["playerCards",_p];_s set ["dealerCards",_b];
private _winner=if (_pt==_bt) then {"TIE"} else {if (_pt>_bt) then {"PLAYER"} else {"BANKER"}};
private _choice=_s get "choice";private _mult=if (_choice==_winner) then {switch (_winner) do {case "TIE":{9};case "BANKER":{1.95};default {2};}} else {if (_winner=="TIE" && {_choice in ["PLAYER","BANKER"]}) then {1} else {0}};
[_s,(_s get "bet")*_mult,format ["Player %1 - Banker %2. %3.",_pt,_bt,_winner]] call DSDS_fnc_casinoFinishRound
