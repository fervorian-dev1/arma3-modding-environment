params ["_game","_s","_actor"];
private _same=(_s getOrDefault ["game",""])==_game;private _phase=if (_same) then {_s getOrDefault ["phase","idle"]} else {"idle"};
private _dealerCards=if (_same) then {+(_s getOrDefault ["dealerCards",[]])} else {[]};
if (_game=="BLACKJACK" && {_phase!="finished"} && {count _dealerCards>1}) then {_dealerCards=[_dealerCards select 0];};
private _holder=_actor getVariable ["owner",_actor];
[_game,if (_same) then {_s getOrDefault ["id",""]} else {""},if (_same) then {_s getOrDefault ["revision",0]} else {0},_phase,if (_same) then {_s getOrDefault ["bet",0]} else {0},if (_same) then {_s getOrDefault ["payout",0]} else {0},if (_same) then {_s getOrDefault ["message",""]} else {""},if (_same) then {_s getOrDefault ["playerCards",[]]} else {[]},_dealerCards,if (_same) then {_s getOrDefault ["dice",[]]} else {[]},if (_same) then {_s getOrDefault ["point",0]} else {0},if (_same) then {_s getOrDefault ["started",serverTime]} else {serverTime},_holder getVariable ["moneyX",0],_actor getVariable ["DSDS_casinoBetToken",""],missionNamespace getVariable ["DSDS_casinoSequence",0]]
