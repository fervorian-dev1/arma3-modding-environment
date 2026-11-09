/* Server authority: no damage event-handler or medical-addon replacement. */
params ["_unit",["_now",serverTime]];
if (!isServer || {isNull _unit} || {isRemoteExecuted}) exitWith {false};
if (!alive _unit) exitWith {
    _unit setVariable ["DSDS_lootOverdose",nil,true];_unit setVariable ["DSDS_lootDoses",nil];false
};
private _over=_unit getVariable ["DSDS_lootOverdose",[0,0]];
if ((_over select 1)>0 && {_now>=(_over select 1)}) exitWith {
    // Mark before applying, so an invulnerable test/admin body is not hit every tick.
    _unit setVariable ["DSDS_lootOverdose",[0,0],true];
    _unit setDamage 1;
    diag_log format ["[DSDS Loot] Fatal overdose on body %1.",netId _unit];
    true
};
if ((_over select 0)>0 && {(_over select 0)<=_now} && {(_over select 1)<=0}) then {_unit setVariable ["DSDS_lootOverdose",nil,true];};
false
