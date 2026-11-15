if (!isServer || {isRemoteExecuted}) exitWith {objNull};
private _old=missionNamespace getVariable ["DSDS_luckyPickup",objNull];if (!isNull _old && {alive _old}) exitWith {_old};
private _hotel=missionNamespace getVariable ["DSDS_casinoBuilding",objNull];if (isNull _hotel) exitWith {objNull};
private _pos=[getPosATL _hotel,23,45,2,0,0.25,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
if (_pos distance2D _hotel<20 || {_pos distance2D _hotel>50} || {surfaceIsWater _pos}) exitWith {objNull};
private _box=createVehicle ["Box_NATO_Equip_F",_pos,[],0,"NONE"];if (isNull _box) exitWith {objNull};
clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
_box allowDamage false;_box setVariable ["DSDS_luckyPickup",true,true];DSDS_casinoProps pushBack _box;DSDS_luckyPickup=_box;
_box
