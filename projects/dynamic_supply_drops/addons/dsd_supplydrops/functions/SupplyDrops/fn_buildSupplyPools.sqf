/* Runtime discovery from the server's merged config, cached for this mission. */
if (!isNil "DSD_supplyPools") exitWith {DSD_supplyPools};
if (missionNamespace getVariable ["DSD_poolsBuilding", false]) exitWith {
    waitUntil {sleep 0.1; !isNil "DSD_supplyPools"};
    DSD_supplyPools
};
DSD_poolsBuilding = true;
private _pools = createHashMap;
private _categories = ["AssaultRifle", "SubmachineGun", "SniperRifle", "MachineGun", "Handgun", "Attachment", "Optic", "Suppressor", "Magazine", "Grenade", "Explosive", "Medical", "Backpack", "Uniform", "Vest"];
{_pools set [_x, []];} forEach _categories;
{
    private _name = configName _x;
    private _type = (_name call BIS_fnc_itemType) param [1, ""];
    private _pool = switch (_type) do {
        case "AccessoryPointer"; case "AccessoryBipod": {"Attachment"};
        case "AccessorySights": {"Optic"};
        case "AccessoryMuzzle": {
            private _coef = configFile >> "CfgWeapons" >> _name >> "ItemInfo" >> "AmmoCoef" >> "audibleFire";
            private _soundType = getNumber (configFile >> "CfgWeapons" >> _name >> "ItemInfo" >> "soundTypeIndex");
            if (_soundType == 1 && {isNumber _coef} && {getNumber _coef < 1}) then {"Suppressor"} else {"Attachment"}
        };
        case "FirstAidKit"; case "Medikit": {"Medical"};
        default {_type};
    };
    if (_pool in _categories) then {
        // Collapse pre-attached variants to their base weapon to avoid near-duplicate rifles.
        if (_pool in ["AssaultRifle", "SubmachineGun", "SniperRifle", "MachineGun", "Handgun"]) then {
            _name = _name call BIS_fnc_baseWeapon;
        };
        private _valid = [_name, "CfgWeapons"] call DSD_fnc_isSupplyAssetAllowed;
        if (_pool in ["AssaultRifle", "SubmachineGun", "SniperRifle", "MachineGun", "Handgun"]) then {
            _valid = _valid && {getNumber (configFile >> "CfgWeapons" >> _name >> "type") in [1, 2]} && {([_name] call DSD_fnc_getSupplyMagazines) isNotEqualTo []};
        };
        if (_valid) then {(_pools get _pool) pushBackUnique _name;};
    };
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons"));
// Throw/Put muzzle definitions identify usable inventory grenades and explosives.
{
    _x params ["_weapon", "_category"];
    {
        private _muzzle = configFile >> "CfgWeapons" >> _weapon >> _x;
        {
            if ([_x, "CfgMagazines"] call DSD_fnc_isSupplyAssetAllowed && {getNumber (configFile >> "CfgMagazines" >> _x >> "scope") == 2}) then {
                (_pools get _category) pushBackUnique _x;
            };
        } forEach getArray (_muzzle >> "magazines");
    } forEach getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");
} forEach [["Throw", "Grenade"], ["Put", "Explosive"]];
// Only personal small-arms ammunition, not aircraft/vehicle magazines.
{
    private _weapon = _x;
    {
        if (isClass (configFile >> "CfgMagazines" >> _x) && {getNumber (configFile >> "CfgMagazines" >> _x >> "scope") == 2}) then {
            (_pools get "Magazine") pushBackUnique _x;
        };
    } forEach ([_weapon] call DSD_fnc_getSupplyMagazines);
} forEach ((_pools get "AssaultRifle") + (_pools get "SubmachineGun") + (_pools get "SniperRifle") + (_pools get "MachineGun") + (_pools get "Handgun"));
{
    private _name = configName _x;
    if (_name isKindOf "Bag_Base" && {getNumber (_x >> "maximumLoad") > 0} && {[_name, "CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}) then {(_pools get "Backpack") pushBackUnique _name;};
} forEach ("getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgVehicles"));
// Optional ACE medical supplies, only when actually present. No ACE dependency.
{
    if ([_x, "CfgWeapons"] call DSD_fnc_isSupplyAssetAllowed) then {(_pools get "Medical") pushBackUnique _x;};
} forEach ["ACE_fieldDressing", "ACE_elasticBandage", "ACE_packingBandage", "ACE_quikclot", "ACE_morphine", "ACE_epinephrine", "ACE_tourniquet"];
{diag_log format ["[DSD] Pool %1: %2 classes", _x, count (_pools get _x)];} forEach _categories;
DSD_supplyPools = _pools;
DSD_poolsBuilding = false;
_pools
