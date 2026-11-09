params ["_group","_type","_position",["_skill",0.65]];
if (!isServer || {isRemoteExecuted} || {isNull _group}) exitWith {objNull};
private _unit=if (!isNil "A3A_customUnitTypes") then {[_group,_type,_position,[],0,"NONE"] call A3A_fnc_createUnit} else {if (isClass (configFile >> "CfgVehicles" >> _type)) then {_group createUnit [_type,_position,[],0,"NONE"]} else {objNull}};
if (isNull _unit) exitWith {objNull};
[_unit] joinSilent _group;_unit allowFleeing 0;
[_unit,"COMBAT",_skill] call DSDS_fnc_configureAddonAI;
_unit setVariable ["spawner",false];_unit setVariable ["originalSide",side _group];
if (missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_activePlayerCount"}) then {
 _unit addEventHandler ["HandleDamage",A3A_fnc_handleDamageAAF];_unit addEventHandler ["Killed",A3A_fnc_enemyUnitKilledEH];
};
_unit
