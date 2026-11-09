/* Server-only effect ledger. Never remotely exposed; caller authenticates consumption. */
params ["_unit","_class",["_now",serverTime],["_roll",-1],["_autoRescue",false]];
if (isRemoteExecuted && {isNil "_dsdsLootAuthorized"}) exitWith {false};
if !(_class in ([] call DSDS_fnc_consumableClasses)) exitWith {false};
if (!isServer || {isNull _unit} || {!alive _unit}) exitWith {false};
private _cfg=configFile >> "DSDS_Consumables";
private _profile=configFile >> "DSDS_Effects" >> _class;
if (isClass _profile && {getNumber (_profile >> "killChance")>0}) then {
    if (_roll<0) then {_roll=random 1;};
    if (_roll<getNumber (_profile >> "killChance")) then {
        if (isPlayer _unit) then {["MESSAGE",_unit,["Your heart stops."]] remoteExecCall ["DSDS_fnc_lootClient",owner _unit];};
        _unit setDamage 1;
    };
};
if (!alive _unit) exitWith {true};
if (isClass _profile) then {
    private _states=_unit getVariable ["DSDS_stimEffects",createHashMap];
    private _old=_states getOrDefault [_class,[0,0]];
    if ((_old select 1)<=_now) then {
        private _end=_now+getNumber (_profile >> "duration");
        private _record=[_end,_end+getNumber (_profile >> "crashDuration")];
        if (_class=="DSDS_Morphine") then {_record pushBack (_now+getNumber (_profile >> "healDuration"));_unit setVariable ["DSDS_morphineHealApplied",0];};
        _states set [_class,_record];
        _unit setVariable ["DSDS_stimEffects",_states,true];
    };
};
private _ends=+(_unit getVariable ["DSDS_lootEffects",[0,0,0,0,0]]);
switch (_class) do {
    case "DSDS_Marijuana": {_ends set [0,_now+getNumber (_cfg >> "marijuanaDuration")];};
    case "DSDS_NicotineVape": {_ends set [1,_now+getNumber (_cfg >> "vapeDuration")];};
    case "DSDS_Cocaine": {
        // Redosing adds toxicity, but never postpones the current crash.
        if ((_ends select 3)>_now) exitWith {};
        _ends set [2,_now+getNumber (_cfg >> "cocaineDuration")];
        _ends set [3,(_ends select 2)+getNumber (_cfg >> "crashDuration")];
    };
    case "DSDS_Zyn": {_ends set [4,_now+getNumber (_cfg >> "zynDuration")];};
    default {};
};
_unit setVariable ["DSDS_lootEffects",_ends,true];
private _key=switch (_class) do {case "DSDS_Marijuana": {"marijuanaMessage"};case "DSDS_NicotineVape": {"vapeMessage"};case "DSDS_Cocaine": {"cocaineMessage"};default {"zynMessage"};};
private _message=getText (_cfg >> _key);
if (isClass _profile) then {
 _message=getText (_profile >> "message");
 private _times=(_unit getVariable ["DSDS_stimEffects",createHashMap]) getOrDefault [_class,[0,0]];
 if ((_times select 0)<=_now && {(_times select 1)>_now}) then {_message="You still feel drained.";};
};
if (_class=="DSDS_Cocaine" && {(_ends select 2)<=_now}) then {_message="You feel wired, but exhausted.";};
private _warning=if (_autoRescue) then {""} else {[_unit,_class,_now] call DSDS_fnc_lootDose;};
if (_autoRescue) then {_message="You're back on your feet.";};
if (_warning!="") then {_message=_warning;};
if (isPlayer _unit) then {["MESSAGE",_unit,[_message]] remoteExecCall ["DSDS_fnc_lootClient",owner _unit];};
true
