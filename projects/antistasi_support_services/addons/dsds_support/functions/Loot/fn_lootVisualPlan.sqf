/* Pure plan from the same expiry ledgers as buffs/debuffs. No timers of its own. */
params ["_unit",["_now",serverTime]];
private _ends=_unit getVariable ["DSDS_lootEffects",[0,0,0,0,0]];
private _meth=(_unit getVariable ["DSDS_stimEffects",createHashMap]) getOrDefault ["DSDS_Methamphetamine",[0,0]];
private _wanted=[];
{
 _x params ["_key","_end"];
 if (_end>_now) then {_wanted pushBack [_key,_end];};
} forEach [["Meth",_meth select 1],["Cocaine",(_ends select 2) max (_ends select 3)],["Marijuana",_ends select 0],["Vape",_ends select 1],["Zyn",_ends select 4]];
_wanted
