params ["_group","_type","_position","_raid"];
if (!isServer || {isRemoteExecuted} || {isNull _group}) exitWith {objNull};
private _unit = [_group,_type,_position,[],0,"NONE"] call A3A_fnc_createUnit;
if (isNull _unit) exitWith {objNull};
[_unit] joinSilent _group;
[_unit,"COMBAT",0.35+0.025*(_raid getOrDefault ["war",1])] call DSDS_fnc_configureAddonAI;
_unit setVariable ["DSDS_raidID",_raid get "id",true];
_unit setVariable ["spawner",false];
_unit setVariable ["originalSide",side _group];
_unit setVariable ["A3A_resPool","attack"];
// Normal enemy combat rewards/damage; no garrison or resource-refund Deleted EH.
if (!isNil "A3A_activePlayerCount") then {
    _unit addEventHandler ["HandleDamage",A3A_fnc_handleDamageAAF];
    _unit addEventHandler ["Killed",A3A_fnc_enemyUnitKilledEH];
};
(_raid get "units") pushBack _unit;
_unit
