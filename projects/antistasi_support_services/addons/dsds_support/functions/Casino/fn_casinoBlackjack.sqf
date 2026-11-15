params ["_s","_op"];private _bet=_s get "bet";
if (_op=="START") then {
 _s set ["playerCards",[[_s] call DSDS_fnc_casinoDraw,[_s] call DSDS_fnc_casinoDraw]];
 _s set ["dealerCards",[[_s] call DSDS_fnc_casinoDraw,[_s] call DSDS_fnc_casinoDraw]];_s set ["phase","playing"];
 private _p=[_s get "playerCards"] call DSDS_fnc_casinoScore;private _d=[_s get "dealerCards"] call DSDS_fnc_casinoScore;
 if (_p==21 || {_d==21}) then {[_s,if (_p==_d) then {_bet} else {if (_p==21) then {_bet*2.5} else {0}},if (_p==_d) then {"Push. Your stake is returned."} else {if (_p==21) then {"Blackjack! Paid 3:2."} else {"Dealer blackjack."}}] call DSDS_fnc_casinoFinishRound;};
};
if (_s get "phase"!="playing") exitWith {true};
if (_op in ["HIT","DOUBLE"]) then {private _p=_s get "playerCards";_p pushBack ([_s] call DSDS_fnc_casinoDraw);_s set ["playerCards",_p];};
private _p=[_s get "playerCards"] call DSDS_fnc_casinoScore;
if (_p>21) exitWith {[_s,0,"Bust. Dealer wins."] call DSDS_fnc_casinoFinishRound};
if (_op in ["STAND","DOUBLE","TIMEOUT"] || {_p==21 && {_op!="START"}}) then {
 private _d=_s get "dealerCards";while {([_d] call DSDS_fnc_casinoScore)<17} do {_d pushBack ([_s] call DSDS_fnc_casinoDraw);};_s set ["dealerCards",_d];
 private _score=[_d] call DSDS_fnc_casinoScore;
 [_s,if (_score>21 || {_p>_score}) then {_bet*2} else {if (_p==_score) then {_bet} else {0}},if (_score>21 || {_p>_score}) then {"You win."} else {if (_p==_score) then {"Push. Your stake is returned."} else {"Dealer wins."}}] call DSDS_fnc_casinoFinishRound;
};true
