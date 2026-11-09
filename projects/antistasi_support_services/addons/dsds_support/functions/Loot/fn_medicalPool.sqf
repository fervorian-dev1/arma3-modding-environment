/* Explicit medical tag keeps narcotics/industrial valuables out of medical loot. */
private _pool=[];
{
    private _class=getText (_x >> "classname");
    if (getText (_x >> "lootPool")=="MEDICAL" && {getText (_x >> "section")=="CfgWeapons"} && {isClass (configFile >> "CfgWeapons" >> _class)} && {getNumber (configFile >> "DSDS_Effects" >> _class >> "duration")>0} && {[_class,"CfgWeapons"] call DSD_fnc_isSupplyAssetAllowed}) then {
        _pool pushBackUnique _class;
    };
} forEach ("true" configClasses (configFile >> "DSDS_FenceGoods"));
_pool
