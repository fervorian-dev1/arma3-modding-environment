/* Optional AI compatibility, scoped to units owned by this addon. Never changes global settings. */
params ["_unit",["_role","COMBAT"],["_skill",0.65]];
if (!isServer || {isNull _unit} || {isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer"}}) exitWith {};
if (_role in ["FIXED","FLIGHT"]) exitWith {
    // Installed LAMBS 2.6.2 checks these variables before autonomous manoeuvres.
    _unit setVariable ["lambs_danger_disableAI",true,true];
    (group _unit) setVariable ["lambs_danger_disableGroupAI",true,true];
};
if (_unit getVariable ["DSDS_aiConfigured",false]) exitWith {};
_unit setVariable ["DSDS_aiConfigured",true];
_unit setVariable ["DSDS_tacticalSkill",_skill];
if (!(_unit in (missionNamespace getVariable ["tws_is_Aim_fixed",[]]))) then {_unit setSkill _skill;};
if (isClass (configFile >> "CfgPatches" >> "tws_aimfix")) then {
    if (isNil "DSDS_aiCompatibilityQueue") then {DSDS_aiCompatibilityQueue=[];};
    DSDS_aiCompatibilityQueue pushBack [_unit,_skill];
    private _startWorker=false;
    isNil {if (!(missionNamespace getVariable ["DSDS_aiCompatibilityWorker",false])) then {DSDS_aiCompatibilityWorker=true;_startWorker=true;};};
    if (_startWorker) then {
        [] spawn {while {true} do {[] call DSDS_fnc_tickAICompatibility;sleep 0.5;};};
    };
};
