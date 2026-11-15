params ["_s"];
if (!isServer || {_s getOrDefault ["settled",false]} || {_s getOrDefault ["phase",""]!="finished"}) exitWith {false};
_s set ["settled",true];[_s get "uid",_s getOrDefault ["payout",0]] call DSDS_fnc_casinoCredit;[] call DSDS_fnc_casinoSave;true
