if (!hasInterface || {isRemoteExecuted}) exitWith {};
private _v=vehicle player;
if (_v==player || {!local _v} || {driver _v!=player} || {!alive player} || {!alive _v} || {!(_v isKindOf "LandVehicle")} || {_v isKindOf "StaticWeapon"} || {!isEngineOn _v} || {!isTouchingGround _v} || {surfaceIsWater getPosATL _v} || {(crew _v findIf {alive _x && {(_x getVariable ["DSDS_gummyUntil",0])>serverTime}})<0}) exitWith {};
private _throttle=(inputAction "CarForward") max (inputAction "CarFastForward");
if (inputAction "CarBack">0.05 || {inputAction "CarHandBrake">0.05}) exitWith {};
private _dir=vectorDir _v;
private _impulse=[getNumber (configFile >> "CfgVehicles" >> typeOf _v >> "maxSpeed"),(velocityModelSpace _v) select 1,_dir select 2,getMass _v,diag_deltaTime,_throttle] call DSDS_fnc_luckyBoostPlan;
if (_impulse>0) then {_v addForce [_dir vectorMultiply _impulse,getCenterOfMass _v];};
