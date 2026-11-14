params ["_unit"];
if (isNull _unit || {serverTime<(_unit getVariable ["DSDS_autoRescueUntil",0])}) exitWith {""};
private _state=[_unit] call DSDS_fnc_lootDownState;
if (_state==0) exitWith {""};
private _order=if (_state==1) then {["DSDS_Morphine","DSDS_Adrenaline"]} else {["DSDS_Adrenaline","DSDS_Morphine"]};
private _uses=_unit getVariable ["DSDS_rescueUses",createHashMap];
private _i=_order findIf {_x in items _unit && {(_uses getOrDefault [_x,0])<2}};if (_i<0) exitWith {""};_order select _i
