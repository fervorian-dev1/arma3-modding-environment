params ["_cards",["_baccarat",false]];private _total=0;private _aces=0;
{private _rank=(_x mod 13)+1;if (_baccarat) then {_total=(_total+(_rank min 10)) mod 10;} else {if (_rank==1) then {_aces=_aces+1;_total=_total+11;} else {_total=_total+(_rank min 10);};};} forEach _cards;
if (!_baccarat) then {while {_total>21 && {_aces>0}} do {_total=_total-10;_aces=_aces-1;};};_total
