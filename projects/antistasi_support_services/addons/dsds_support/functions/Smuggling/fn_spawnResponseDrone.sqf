params ["_response","_class","_start","_target"];
if (!isServer || {isRemoteExecuted} || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {[objNull,grpNull]};
private _drone=createVehicle [_class,_start,[],0,"FLY"];
if (isNull _drone) exitWith {[objNull,grpNull]};
_drone setPosASL [_start select 0,_start select 1,(getTerrainHeightASL _start max 0)+450];
createVehicleCrew _drone;
private _group=createGroup [_response get "side",true];(crew _drone) joinSilent _group;
if (isNull driver _drone) exitWith {deleteVehicle _drone;deleteGroup _group;[objNull,grpNull]};
_drone setVariable ["ownerSide",_response get "side",true];_drone engineOn true;_drone setVelocityModelSpace [0,55,0];_drone flyInHeight 400;
{_drone removeWeapon _x;} forEach weapons _drone;
{_drone setPylonLoadout [_forEachIndex+1,"",true];} forEach getPylonMagazines _drone;
_group setVariable ["lambs_danger_disableGroupAI",true,true];_group setBehaviourStrong "CARELESS";_group setCombatMode "BLUE";
_group setVariable ["DSDS_noContactRetask",true,true];
private _orbit=_group addWaypoint [getPosATL _target,0];_orbit setWaypointType "LOITER";_orbit setWaypointLoiterRadius 600;_group setCurrentWaypoint _orbit;
(_response get "vehicles") pushBack _drone;(_response get "units") append crew _drone;(_response get "groups") pushBack _group;
[_drone,_group]
