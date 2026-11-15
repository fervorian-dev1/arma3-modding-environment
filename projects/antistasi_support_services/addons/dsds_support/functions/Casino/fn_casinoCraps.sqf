params ["_s","_op"];
if (_op=="START") then {_s set ["phase","playing"];_s set ["point",0];};
if !(_op in ["START","ROLL","TIMEOUT"]) exitWith {false};
private _repeat=if (_op=="TIMEOUT") then {100} else {1};
for "_roll" from 1 to _repeat do {
 if (_s get "phase"=="finished") exitWith {};
 private _a=1+floor random 6;private _b=1+floor random 6;private _sum=_a+_b;private _point=_s getOrDefault ["point",0];_s set ["dice",[_a,_b]];
 if (_point==0) then {
  if (_sum in [7,11]) then {[_s,(_s get "bet")*2,"Natural! Pass line wins."] call DSDS_fnc_casinoFinishRound;} else {
   if (_sum in [2,3,12]) then {[_s,0,"Craps. Pass line loses."] call DSDS_fnc_casinoFinishRound;} else {_s set ["point",_sum];_s set ["message",format ["Point is %1. Roll the point before a seven.",_sum]];};
  };
 } else {
  if (_sum==_point) then {[_s,(_s get "bet")*2,"Point made! Pass line wins."] call DSDS_fnc_casinoFinishRound;};
  if (_sum==7) then {[_s,0,"Seven out. Pass line loses."] call DSDS_fnc_casinoFinishRound;};
 };
};
if (_op=="TIMEOUT" && {_s get "phase"!="finished"}) then {[_s,_s get "bet","Round void; stake returned."] call DSDS_fnc_casinoFinishRound;};true
