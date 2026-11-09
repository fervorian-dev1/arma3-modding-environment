/* Configuration-based valuation: no vehicle classname whitelist. */
params ["_vehicleOrClass"];
private _class = if (_vehicleOrClass isEqualType "") then {_vehicleOrClass} else {typeOf _vehicleOrClass};
private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg || {!(_class isKindOf "AllVehicles")} || {_class isKindOf "Man"}) exitWith {0};
private _armed = false;
private _weapons = getArray (_cfg >> "weapons");
private _walk = {
    params ["_root"];
    {
        _weapons append getArray (_x >> "weapons");
        [_x >> "Turrets"] call _walk;
    } forEach ("true" configClasses _root);
};
[_cfg >> "Turrets"] call _walk;
{
    private _type = (_x call BIS_fnc_itemType) param [1,""];
    if (_type in ["MachineGun","Cannon","MissileLauncher","RocketLauncher","GrenadeLauncher","BombLauncher","Rifle","AssaultRifle"]) exitWith {_armed = true;};
} forEach _weapons;
private _armor = getNumber (_cfg >> "armor");
private _military = getNumber (_cfg >> "side") in [0,1,2];
private _utility = getNumber (_cfg >> "transportRepair") + getNumber (_cfg >> "transportAmmo") + getNumber (_cfg >> "transportFuel");
private _medical = getNumber (_cfg >> "attendant") > 0;
private _isTruck = _class isKindOf "Truck" || {_class isKindOf "Truck_F"} || {(toLower getText (_cfg >> "editorSubcategory") find "truck") >= 0};
private _base = switch (true) do {
    case (_class isKindOf "ParachuteBase"): {10};
    case (_class isKindOf "Plane"): {if (_armed) then {75000} else {50000}};
    case (_class isKindOf "Helicopter"): {if (_armed) then {45000} else {30000}};
    case (_class isKindOf "Tank"): {45000};
    case (_class isKindOf "Air"): {25000};
    case (_class isKindOf "StaticWeapon"): {4000};
    case (_class isKindOf "Ship"): {if (_armed) then {7000} else {1000}};
    // Truck armor values often describe durability, not an armored fighting vehicle.
    case (_isTruck): {if (_armed) then {7000} else {if (_utility > 0 || {_medical}) then {3500} else {if (_military) then {2500} else {1200}}}};
    case (_armor >= 300): {18000};
    case (_armor >= 120): {9000};
    case (_armed): {6000};
    case (_utility > 0 || {_medical}): {3500};
    case (_class isKindOf "Motorcycle"): {250};
    case (_class isKindOf "Car"): {if (_military) then {1800} else {500}};
    default {500};
};
private _condition = if (_vehicleOrClass isEqualType "") then {1} else {(1 - damage _vehicleOrClass) max 0.1};
private _value = _base * _condition;
if (_armed && {!(_class isKindOf "Air")}) then {_value = _value * 1.15;};
// Preserve sensible proportions within each tier, without trusting extreme mod config costs.
private _configCost = getNumber (_cfg >> "cost");
_value = _value * (0.9 + ((_configCost min 10000000) max 0) / 50000000);
// Prevent buying from Antistasi's vehicle store and immediately reselling at a profit.
private _purchase=[_class] call DSDS_fnc_vehicleShopPrice;
if (_purchase>0) then {_value=_value min (_purchase*0.5*_condition);};
10 max round _value
