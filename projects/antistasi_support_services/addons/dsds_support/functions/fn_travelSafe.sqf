params ["_unit"];
if (isNull _unit || {!alive _unit} || {_unit getVariable ["incapacitated",false]} || {lifeState _unit in ["INCAPACITATED","UNCONSCIOUS"]} || {behaviour _unit=="COMBAT"} || {serverTime-(_unit getVariable ["DSDS_travelCombatAt",-1000])<60}) exitWith {false};
private _side=side group _unit;
((nearestObjects [_unit,["CAManBase"],150]) findIf {alive _x && {_side getFriend (side group _x)<0.6} && {side group _x!=civilian}})<0
