if (!isServer || {isRemoteExecuted} || {isNil "DSDS_casinoState"}) exitWith {};
private _old=DSDS_casinoState getOrDefault ["padOriginal",[]];private _applied=DSDS_casinoState getOrDefault ["padApplied",[]];private _restore=[];
{
 private _now=getTerrainHeightASL _x;private _expected=(_applied param [_forEachIndex,_x]) select 2;
 // Do not overwrite a subsequent terrain edit made by another system.
 if (abs (_now-_expected)<0.05) then {_restore pushBack _x;};
} forEach _old;
if (_restore isNotEqualTo []) then {setTerrainHeight [_restore,false];};
{if (!isNull _x) then {_x hideObjectGlobal false;};} forEach (missionNamespace getVariable ["DSDS_casinoHiddenPlants",[]]);
DSDS_casinoHiddenPlants=[];DSDS_casinoState set ["padOriginal",[]];DSDS_casinoState set ["padApplied",[]];
{if (!isNull _x && {isNull attachedTo _x} && {isNull isVehicleCargo _x}) then {private _p=getPosATL _x;_p set [2,0];_x setPosATL _p;};} forEach (missionNamespace getVariable ["DSDS_casinoProps",[]]);
