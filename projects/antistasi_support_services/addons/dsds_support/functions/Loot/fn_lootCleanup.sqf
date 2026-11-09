/* Remove only our handles and restore values only while they are still ours. */
params ["_unit"];
if (isRemoteExecuted) exitWith {};
if (isNull _unit) exitWith {};
private _state=_unit getVariable ["DSDS_lootLocal",createHashMap];
if (count _state==0) exitWith {};
[_unit,serverTime,true] call DSDS_fnc_lootVisuals;
if (local _unit) then {
    if (abs (unitRecoilCoefficient _unit-(_state getOrDefault ["recoilLast",unitRecoilCoefficient _unit]))<0.001) then {_unit setUnitRecoilCoefficient (_state getOrDefault ["recoilBase",unitRecoilCoefficient _unit]);};
    if ((isStaminaEnabled _unit) isEqualTo (_state getOrDefault ["staminaEnabledLast",isStaminaEnabled _unit])) then {_unit enableStamina (_state getOrDefault ["staminaEnabledBase",isStaminaEnabled _unit]);};
    if (abs (getCustomAimCoef _unit-(_state get "aimLast"))<0.001) then {_unit setCustomAimCoef (_state get "aimBase");};
    if (abs (getAnimSpeedCoef _unit-(_state get "speedLast"))<0.001) then {_unit setAnimSpeedCoef (_state get "speedBase");};
    if (abs ((_unit getUnitTrait "loadCoef")-(_state get "loadLast"))<0.001) then {_unit setUnitTrait ["loadCoef",_state get "loadBase"];};
};
private _eh=_state getOrDefault ["damageEH",-1];
if (_eh>=0) then {_unit removeEventHandler ["HandleDamage",_eh];};
private _pp=_state getOrDefault ["blur",-1];
if (_pp>=0) then {ppEffectDestroy _pp;};
_unit setVariable ["DSDS_lootLocal",nil];
