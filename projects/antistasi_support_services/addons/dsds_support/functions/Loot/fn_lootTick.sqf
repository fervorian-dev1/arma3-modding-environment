/* Owning-machine update. Does not enable stamina if the mission disabled it. */
params ["_unit",["_now",serverTime]];
if (isRemoteExecuted) exitWith {};
if (isNull _unit) exitWith {};
private _ends=_unit getVariable ["DSDS_lootEffects",[0,0,0,0,0]];
private _sick=((_unit getVariable ["DSDS_lootOverdose",[0,0]]) select 0)>_now;
private _stim=[_unit,_now] call DSDS_fnc_stimModifiers;
if (!local _unit || {!alive _unit} || {(_ends findIf {_x>_now})<0 && {!_sick} && {!(_stim get "active")}}) exitWith {[_unit] call DSDS_fnc_lootCleanup;};
private _cfg=configFile >> "DSDS_Consumables";
private _state=_unit getVariable ["DSDS_lootLocal",createHashMap];
if (count _state==0) then {
    _state=createHashMapFromArray [
        ["aimBase",getCustomAimCoef _unit],["aimLast",getCustomAimCoef _unit],
        ["speedBase",getAnimSpeedCoef _unit],["speedLast",getAnimSpeedCoef _unit],
        ["loadBase",_unit getUnitTrait "loadCoef"],["loadLast",_unit getUnitTrait "loadCoef"],
        ["staminaLast",getStamina _unit],["tickLast",diag_tickTime],["damageEH",-1],["blur",-1],
        ["recoilBase",unitRecoilCoefficient _unit],["recoilLast",unitRecoilCoefficient _unit],
        ["staminaEnabledBase",isStaminaEnabled _unit],["staminaEnabledLast",isStaminaEnabled _unit]
    ];
    _unit setVariable ["DSDS_lootLocal",_state];
};
([_ends,_now] call DSDS_fnc_lootModifiers) params ["_aim","_movement","_regen","_cap","_weed","_cocaine","_zyn","_crash"];
_aim=_aim*(_stim get "aim");_movement=_movement*(_stim get "move");_regen=_regen*(_stim get "regen");_cap=_cap min (_stim get "cap");
_crash=_crash || {_stim get "crash"};
if (_sick) then {_aim=_aim*getNumber (_cfg >> "sicknessSway");_movement=_movement min getNumber (_cfg >> "sicknessMovement");_cap=_cap min getNumber (_cfg >> "sicknessStamina");};
if (hasInterface && {_unit==player} && {_crash} && {!(_state getOrDefault ["crashNotified",false])}) then {
    systemChat getText (_cfg >> "crashMessage");_state set ["crashNotified",true];
};
if (!_crash) then {_state set ["crashNotified",false];};
// Incorporate later role/mission changes rather than hard-resetting native coefficients to 1.
{
    _x params ["_key","_actual"];
    if (abs (_actual-(_state get (_key+"Last")))>0.001) then {_state set [_key+"Base",_actual];};
} forEach [["aim",getCustomAimCoef _unit],["speed",getAnimSpeedCoef _unit],["load",_unit getUnitTrait "loadCoef"],["recoil",unitRecoilCoefficient _unit]];
if ((isStaminaEnabled _unit) isNotEqualTo (_state get "staminaEnabledLast")) then {_state set ["staminaEnabledBase",isStaminaEnabled _unit];};
private _enabled=(_state get "staminaEnabledBase") && {!(_stim get "unlimited")};
_unit enableStamina _enabled;_state set ["staminaEnabledLast",_enabled];
if (_stim get "unlimited") then {_unit setFatigue 0;};
private _onFoot=isNull objectParent _unit && {lifeState _unit!="INCAPACITATED"};
if (!_onFoot) then {_movement=1;};
private _sprinting=(toLower animationState _unit) find "meva">=0;
if (_onFoot && {_cocaine} && {_sprinting} && {!_sick} && {!_weed}) then {_movement=getNumber (_cfg >> "cocaineSprint");};
if (_onFoot && {_sprinting} && {!_sick} && {!_weed} && {!_crash}) then {_movement=_movement max (_stim get "sprint");};
private _aimNext=(_state get "aimBase")*_aim;
private _speedNext=(_state get "speedBase")*_movement;
private _carry=(_stim get "carry") max (if (_zyn) then {getNumber (_cfg >> "zynCapacity")} else {1});
private _loadNext=if (_stim get "unlimited") then {0} else {(_state get "loadBase")/_carry};
_unit setCustomAimCoef _aimNext;_state set ["aimLast",_aimNext];
_unit setAnimSpeedCoef _speedNext;_state set ["speedLast",_speedNext];
_unit setUnitTrait ["loadCoef",_loadNext];_state set ["loadLast",_loadNext];
private _recoil=(_state get "recoilBase")*(_stim get "recoil");_unit setUnitRecoilCoefficient _recoil;_state set ["recoilLast",_recoil];
if (_stim get "calm") then {_unit setSuppression 0;};
if (isStaminaEnabled _unit) then {
    private _current=getStamina _unit;
    private _elapsed=(diag_tickTime-(_state get "tickLast")) max 0.001;
    private _delta=_current-(_state get "staminaLast");
    private _duration=getNumber (configFile >> "CfgMovesFatigue" >> "staminaDuration");
    if (_duration<=0) then {_duration=60;};
    private _nativeCap=_duration*((1-load _unit*_loadNext) max 0);
    // Only amplify observed recovery, never add stamina while sprinting or holding breath.
    private _extra=if (_delta>0 && {_delta<5*_elapsed} && {!_sprinting}) then {_delta*(_regen-1)} else {0};
    private _next=(_current+_extra) min (_nativeCap*_cap);
    if (abs (_next-_current)>0.0001) then {_unit setStamina (_next max 0);};
    _state set ["staminaLast",getStamina _unit];
};
_state set ["tickLast",diag_tickTime];
// No damage resistance or injury handler: gameplay buffs coexist with PiR/ACE.
if (hasInterface && {_unit==player}) then {
    [_unit,_now] call DSDS_fnc_lootVisuals;
    private _pp=_state get "blur";
    private _blurred=_weed || {_sick};
    private _strength=if (_sick) then {getNumber (_cfg >> "sicknessBlur")} else {getNumber (_cfg >> "marijuanaBlur")};
    if (_blurred && {_pp<0}) then {
        private _priority=2700;
        while {_pp<0 && {_priority<2720}} do {_pp=ppEffectCreate ["DynamicBlur",_priority];_priority=_priority+1;};
        _state set ["blur",_pp];
        if (_pp>=0) then {_pp ppEffectEnable true;};
    };
    if (_blurred && {_pp>=0} && {_strength!=(_state getOrDefault ["blurStrength",-1])}) then {_pp ppEffectAdjust [_strength];_pp ppEffectCommit 1;_state set ["blurStrength",_strength];};
    if (!_blurred && {_pp>=0}) then {ppEffectDestroy _pp;_state set ["blur",-1];_state set ["blurStrength",-1];};
};
