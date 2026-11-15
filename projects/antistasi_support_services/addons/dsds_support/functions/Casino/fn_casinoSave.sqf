if (!isServer || {isNil "A3A_saveTarget"} || {isNil "DSDS_casinoState"}) exitWith {false};
private _s=DSDS_casinoState;private _escrow=[];
{if (_y getOrDefault ["phase","finished"]!="finished" && {!(_y getOrDefault ["settled",false])}) then {_escrow pushBack [_x,_y get "bet"];};} forEach DSDS_casinoSessions;
private _data=[1,_s getOrDefault ["class",""],_s getOrDefault ["position",[]],_s getOrDefault ["direction",0],[],_escrow];
_data pushBack (_s getOrDefault ["pendingBuild",[]]);
_data set [4,(keys DSDS_casinoCredits) apply {[_x,DSDS_casinoCredits get _x]}];
["DSDS_casinoState",_data] call A3A_fnc_setStatVariable;true
