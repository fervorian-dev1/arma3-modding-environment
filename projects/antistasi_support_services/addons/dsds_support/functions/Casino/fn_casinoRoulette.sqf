params ["_s","_op"];if (_op=="START") exitWith {_s set ["phase","spinning"];_s set ["due",serverTime+3];true};
if !(_op in ["RESOLVE","TIMEOUT"]) exitWith {false};
private _n=floor random 37;private _red=_n in [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];private _choice=_s get "choice";private _mult=0;
if ((_choice find "N:")==0) then {if (_n==parseNumber (_choice select [2])) then {_mult=36;};} else {
 if (_n>0) then {
  switch (_choice) do {
   case "RED": {if (_red) then {_mult=2;};};case "BLACK": {if (!_red) then {_mult=2;};};
   case "ODD": {if (_n mod 2==1) then {_mult=2;};};case "EVEN": {if (_n mod 2==0) then {_mult=2;};};
   case "LOW": {if (_n<=18) then {_mult=2;};};case "HIGH": {if (_n>=19) then {_mult=2;};};
   case "DOZEN1": {if (_n<=12) then {_mult=3;};};case "DOZEN2": {if (_n>=13 && {_n<=24}) then {_mult=3;};};case "DOZEN3": {if (_n>=25) then {_mult=3;};};
   case "COLUMN1": {if (_n mod 3==1) then {_mult=3;};};case "COLUMN2": {if (_n mod 3==2) then {_mult=3;};};case "COLUMN3": {if (_n mod 3==0) then {_mult=3;};};
  };
 };
};
_s set ["number",_n];[_s,(_s get "bet")*_mult,format ["%1 %2. %3",_n,if (_n==0) then {"green"} else {if (_red) then {"red"} else {"black"}},if (_mult>0) then {"You win."} else {"No win this spin."}]] call DSDS_fnc_casinoFinishRound
