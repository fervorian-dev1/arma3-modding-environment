params ["_record","_class","_position",["_cargoCount",0],["_air",false],["_skill",0.65]];
if (!isServer || {isRemoteExecuted} || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {[objNull,grpNull,grpNull]};
private _faction=_record get "faction";private _side=_record get "side";
if (!_air) then {_position=[_class,_position] call DSDS_fnc_findConvoySpawn;};
if (_position isEqualTo []) exitWith {diag_log "[DSDS Convoy] Ground vehicle skipped: no open roadside spawn.";[objNull,grpNull,grpNull]};
private _vehicle=createVehicle [_class,_position,[],0,if (_air) then {"FLY"} else {"NONE"}];
if (isNull _vehicle) exitWith {[objNull,grpNull,grpNull]};
if (_air) then {_vehicle setPosASL [_position select 0,_position select 1,(getTerrainHeightASL _position max 0)+(_position param [2,180])];_vehicle engineOn true;_vehicle setVelocityModelSpace [0,45,0];};
_vehicle setVariable ["DSDS_response",_record get "id",true];
(_record get "vehicles") pushBack _vehicle;
private _crew=createGroup [_side,true];private _cargo=createGroup [_side,true];
(_record get "groups") append [_crew,_cargo];
private _type=if (_air) then {_faction get "pilot"} else {_faction get "crew"};
private _driver=[_crew,_type,_position,(_skill+0.05) min 0.95] call DSDS_fnc_smugglingUnit;
if (!isNull _driver) then {_driver moveInDriver _vehicle;(_record get "units") pushBack _driver;};
{
 private _gunner=[_crew,_type,_position,_skill] call DSDS_fnc_smugglingUnit;
 if (!isNull _gunner) then {_gunner moveInTurret [_vehicle,_x];if (vehicle _gunner==_vehicle) then {(_record get "units") pushBack _gunner;} else {deleteVehicle _gunner;};};
} forEach allTurrets [_vehicle,false];
for "_i" from 1 to (_cargoCount min (_vehicle emptyPositions "cargo")) do {
 private _unit=[_cargo,selectRandom (_faction get "troops"),_position,_skill] call DSDS_fnc_smugglingUnit;
 if (!isNull _unit) then {_unit moveInCargo _vehicle;if (vehicle _unit==_vehicle) then {(_record get "units") pushBack _unit;} else {deleteVehicle _unit;};};
};
_crew setBehaviourStrong "AWARE";_crew setCombatMode "RED";
if (_air) then {{[_x,"FLIGHT"] call DSDS_fnc_configureAddonAI;} forEach units _crew;};
_cargo setVariable ["DSDS_hunt",true];
if (missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_activePlayerCount"}) then {[_vehicle,_side] call A3A_fnc_AIVEHinit;} else {_vehicle setVariable ["ownerSide",_side,true];};
[_vehicle,_crew,_cargo]
