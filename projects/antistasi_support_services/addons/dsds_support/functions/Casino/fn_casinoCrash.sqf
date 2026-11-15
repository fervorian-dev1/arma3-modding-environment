params ["_s","_op"];
if (_op=="START") exitWith {_s set ["phase","playing"];_s set ["crashPoint",((floor ((0.97/((1-random 1) max 0.00001))*100))/100) max 1 min 100];true};
private _mult=(floor ((exp ((serverTime-(_s get "started"))/9))*100))/100;
if (_mult>=(_s get "crashPoint")) exitWith {[_s,0,format ["Crashed at %1x.",_s get "crashPoint"]] call DSDS_fnc_casinoFinishRound};
if (_op=="CASHOUT") exitWith {[_s,(_s get "bet")*_mult,format ["Cashed out at %1x.",_mult]] call DSDS_fnc_casinoFinishRound};
if (_op=="TIMEOUT") exitWith {[_s,0,"Round abandoned before cash-out."] call DSDS_fnc_casinoFinishRound};true
