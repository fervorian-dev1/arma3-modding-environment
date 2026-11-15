if (!isServer || {isRemoteExecuted}) exitWith {objNull};
private _old=missionNamespace getVariable ["DSDS_luckyPickup",objNull];if (!isNull _old && {alive _old}) exitWith {_old};
private _hotel=missionNamespace getVariable ["DSDS_casinoBuilding",objNull];if (isNull _hotel) exitWith {objNull};
private _front=(((boundingBoxReal _hotel) select 0) select 1)-9;
private _pos=_hotel modelToWorld [16,_front,0];_pos set [2,0];
if (surfaceIsWater _pos || {(nearestObjects [_pos,["House","AllVehicles"],2]) isNotEqualTo []}) exitWith {objNull};
private _box=createVehicle ["Box_NATO_Equip_F",_pos,[],0,"NONE"];if (isNull _box) exitWith {objNull};
clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
_box allowDamage false;_box setVariable ["DSDS_luckyPickup",true,true];DSDS_casinoProps pushBack _box;DSDS_luckyPickup=_box;
_box
