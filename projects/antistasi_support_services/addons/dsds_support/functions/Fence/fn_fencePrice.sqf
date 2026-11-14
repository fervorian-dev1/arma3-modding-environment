/* Sale values shared by stock and cargo; custom goods override the generic tiers. */
params ["_class",["_section","CfgWeapons"],["_customOnly",false]];
if (_class in ["DSDS_Morphine","DSDS_Adrenaline"]) exitWith {0};
private _cfg=configFile >> _section >> _class;
if (!isClass _cfg) exitWith {0};
private _custom=-1;
{
    if (getText (_x >> "classname") == _class && {getText (_x >> "section") == _section}) exitWith {_custom=getNumber (_x >> "sellValue");};
} forEach ("true" configClasses (configFile >> "DSDS_FenceGoods"));
if (_custom >= 0) exitWith {_custom};
if (_customOnly) exitWith {0};
private _roles=missionNamespace getVariable ["DSDS_fenceItemRoles",createHashMap];
private _role=(_roles getOrDefault [_section+":"+_class,[]]) param [0,""];
private _special=switch (_role) do {case "FPV":{1500};case "UAV":{2500};case "TERMINAL":{1250};case "AA":{3000};default {0};};
if (_special>0) exitWith {_special};
if (_section == "CfgVehicles") exitWith {if (_class isKindOf "Bag_Base") then {150} else {[_class] call DSDS_fnc_vehicleValue}};
if (_section == "CfgMagazines") exitWith {
    private _ammo=configFile >> "CfgAmmo" >> getText (_cfg >> "ammo");
    if (getNumber (_ammo >> "indirectHit") > 0) then {100} else {25}
};
private _type=(_class call BIS_fnc_itemType) param [1,""];
switch (_type) do {
    case "AssaultRifle"; case "Rifle"; case "SubmachineGun": {600};
    case "SniperRifle"; case "MachineGun": {1500};
    case "Launcher"; case "MissileLauncher"; case "RocketLauncher": {2000};
    case "Handgun": {250};
    case "NVGoggles": {1500};
    case "Binocular"; case "LaserDesignator": {700};
    case "AccessorySights": {400};
    case "AccessoryMuzzle": {300};
    case "Vest": {300};
    case "Uniform": {150};
    default {50};
}
