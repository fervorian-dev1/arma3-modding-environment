if (!isServer || {isNil "DSDS_luckyPlayers"} || {isNil "A3A_saveTarget"}) exitWith {false};
private _rows=[];
{private _p=_y;_rows pushBack [_x,_p get "tokens",_p get "cars",+(_p get "items"),_p get "gummies",_p get "met",(_p get "spin") isNotEqualTo []];} forEach DSDS_luckyPlayers;
["DSDS_luckyState",[1,_rows]] call A3A_fnc_setStatVariable;true
