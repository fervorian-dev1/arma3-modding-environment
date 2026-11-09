if (!isServer) exitWith {false};
params ["_unit",["_now",serverTime]];
if (isNull _unit || {!alive _unit}) exitWith {false};
private _effects=_unit getVariable ["DSDS_stimEffects",createHashMap];
private _morphine=_effects getOrDefault ["DSDS_Morphine",[]];
private _healEnd=_morphine param [2,0];
if (_healEnd<=0) exitWith {_unit setVariable ["DSDS_morphineHealApplied",nil];false};
private _profile=configFile >> "DSDS_Effects" >> "DSDS_Morphine";
private _duration=getNumber (_profile >> "healDuration");
if (_duration<=0) exitWith {false};
private _applied=_unit getVariable ["DSDS_morphineHealApplied",0];
if (_applied<0) exitWith {false};
private _start=_healEnd-_duration;
private _progress=((_now-_start)/_duration) max 0 min 1;
private _target=getNumber (_profile >> "healAmount")*_progress;
private _delta=(_target-_applied) max 0;
if (_delta>0) then {
    _unit setDamage ((damage _unit-_delta) max 0);
    _unit setVariable ["DSDS_morphineHealApplied",_target];
};
if (_now>=_healEnd) then {_unit setVariable ["DSDS_morphineHealApplied",-1];};
true