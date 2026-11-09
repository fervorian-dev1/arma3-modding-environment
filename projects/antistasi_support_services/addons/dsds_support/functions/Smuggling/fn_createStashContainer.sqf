params ["_position"];
if (!isServer || {isRemoteExecuted}) exitWith {objNull};
private _urban=(nearestTerrainObjects [_position,["HOUSE"],110,false,true]) isNotEqualTo [];
private _class=if (_urban) then {selectRandom ["DSDS_StashGarbage","DSDS_StashPallet"]} else {"DSDS_StashSacks"};
if (!isClass (configFile >> "CfgVehicles" >> _class)) exitWith {objNull};
private _box=createVehicle [_class,_position,[],0,"NONE"];
if (isNull _box) exitWith {objNull};
_box setDir random 360;_box setVectorUp surfaceNormal _position;
clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
_box setVariable ["DSDS_contrabandStash",true,true];_box
