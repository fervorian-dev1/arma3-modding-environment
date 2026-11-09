/* Scheduled once: merged server config includes every loaded mod, no faction restriction. */
if (!isServer) exitWith {[]};
private _vehicles=[];
{
    private _name=configName _x;
    if ((_name isKindOf "LandVehicle" || {_name isKindOf "Air"} || {_name isKindOf "Ship"}) && {!(_name isKindOf "ParachuteBase")} && {getText (_x >> "model") != ""} && {[_name,"CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}) then {_vehicles pushBack _name;};
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));
private _pools=[] call DSD_fnc_buildSupplyPools;
private _gear=[];
DSDS_fenceItemPools=createHashMap;
{DSDS_fenceItemPools set [_x,[]];} forEach ["FPV","UAV","TERMINAL","AA","PREMIUM"];
DSDS_fenceItemRoles=createHashMap;
// Medical injectors are found as loot, never offered for purchase. Apply this
// exclusion to every discovery route, even if a later config makes one scope 2.
private _medicalGoods=("getText (_x >> 'lootPool') == 'MEDICAL'" configClasses (configFile >> "DSDS_FenceGoods")) apply {getText (_x >> "section")+":"+getText (_x >> "classname")};
private _register={
    params ["_class","_section","_role"];
    private _cfg=configFile >> _section >> _class;
    private _key=_section+":"+_class;
    if (_key in _medicalGoods || {!isClass _cfg} || {getNumber (_cfg >> "scope")!=2} || {!([_class,_section] call DSD_fnc_isSupplyAssetAllowed)}) exitWith {};
    private _old=DSDS_fenceItemRoles getOrDefault [_key,[]];
    if (_old isNotEqualTo []) then {
        private _oldRole=_old select 0;
        private _list=DSDS_fenceItemPools get _oldRole;
        private _index=_list findIf {(_x select 0)==_class && {(_x select 1)==_section}};
        if (_index>=0) then {_list deleteAt _index;};
    };
    private _modded=[_class,_section] call DSDS_fnc_fenceIsModded;
    (DSDS_fenceItemPools get _role) pushBack [_class,_section,_modded];
    DSDS_fenceItemRoles set [_key,[_role,_modded]];
    _gear pushBackUnique [_class,_section];
};
{
    private _section=if (_x=="Backpack") then {"CfgVehicles"} else {"CfgWeapons"};
    {[_x,_section,"PREMIUM"] call _register;} forEach (_pools getOrDefault [_x,[]]);
} forEach ["SniperRifle","MachineGun","Optic","Suppressor","Vest","Backpack"];
private _sideID=[east,west,resistance,civilian] find (missionNamespace getVariable ["teamPlayer",resistance]);
{
    private _name=configName _x;
    private _weaponType=getNumber (_x >> "type");
    private _type=if (_weaponType in [4,4096,131072]) then {(_name call BIS_fnc_itemType) param [1,""]} else {""};
    // Vehicle-mounted missile launchers can share BIS's subtype label. Only type 4
    // is a portable secondary weapon; never sell a vehicle weapon as inventory gear.
    if (_type in ["NVGoggles","LaserDesignator"]) then {[_name,"CfgWeapons","PREMIUM"] call _register;};
    if (_weaponType==4) then {
        private _aa=[_name,"CfgWeapons"] call DSDS_fnc_fenceIsAntiAir;
        private _magazines=(compatibleMagazines [_name,"this"]) select {
            getNumber (configFile >> "CfgMagazines" >> _x >> "scope")==2 && {[_x,"CfgMagazines"] call DSD_fnc_isSupplyAssetAllowed} && {!_aa || {[_x,"CfgMagazines"] call DSDS_fnc_fenceIsAntiAir}}
        };
        if (_magazines isNotEqualTo []) then {[_name,"CfgWeapons",if (_aa) then {"AA"} else {"PREMIUM"}] call _register;};
    };
    // Actual vanilla/compatible mod terminals. The Support Terminal is type 0, not 621.
    if (getNumber (_x >> "ItemInfo" >> "type")==621 && {isNumber (_x >> "ItemInfo" >> "side")} && {getNumber (_x >> "ItemInfo" >> "side") in [-1,_sideID]}) then {
        [_name,"CfgWeapons","TERMINAL"] call _register;
    };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons"));
// Portable UAV kits include zero-storage backpacks, omitted by ordinary supply pools.
{
    private _name=configName _x;
    if (_name isKindOf "Bag_Base") then {
        private _assembled=getText (_x >> "assembleInfo" >> "assembleTo");
        private _cfg=configFile >> "CfgVehicles" >> _assembled;
        if (isClass _cfg && {getNumber (_cfg >> "isUav")>0} && {getNumber (_cfg >> "side")==_sideID} && {[_assembled,"CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}) then {
            [_name,"CfgVehicles","UAV"] call _register;
        };
    };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));
// Verified against the installed ArmaFPV config and native item-deployment switch.
if (!isNil "DB_fnc_fpv_createUavOnItemCheck") then {
    {[_x,"CfgMagazines","FPV"] call _register;} forEach ["Item_Crocus_AT","Item_Crocus_AP","Item_Crocus_AT_TI","Item_Crocus_AP_TI"];
};
{
    private _name=getText (_x >> "classname");private _section=getText (_x >> "section");
    if (getNumber (_x >> "stock")==1 && {_section in ["CfgWeapons","CfgMagazines","CfgVehicles"]} && {_section!="CfgVehicles" || {_name isKindOf "Bag_Base"}}) then {[_name,_section,"PREMIUM"] call _register;};
} forEach ("true" configClasses (configFile >> "DSDS_FenceGoods"));
DSDS_fencePools=[_vehicles,_gear];
diag_log format ["[DSDS Fence] Discovered %1 vehicles and %2 items; roles %3.",count _vehicles,count _gear,(keys DSDS_fenceItemPools) apply {[_x,count (DSDS_fenceItemPools get _x)]}];
DSDS_fencePools
