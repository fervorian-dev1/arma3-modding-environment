// Dynamic Supply Drops v1.1.0 live bootstrap. Execute GLOBAL AND JIP in ZEN Execute Code.
// Keep the resulting ZEN module for late joiners; initialization is idempotent.
DSD_fnc_buildSupplyPools = {
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

};
DSD_fnc_cleanupSupplyAircraft = {
/* Give the transport time to fly away. Do not delete vehicles occupied by players. */
params ["_aircraft", "_crew", "_group", "_target"];
private _startTime = diag_tickTime;
waitUntil {
    sleep 2;
    isNull _aircraft || {diag_tickTime - _startTime > 420} || {
        diag_tickTime - _startTime > 90 && {alive _aircraft} && {_aircraft getVariable ["DSD_departing", false]} && {_aircraft distance2D _target > 3500}
    } || {!alive _aircraft && {diag_tickTime - _startTime > 120}}
};
if (!isNull _aircraft && {(crew _aircraft findIf {isPlayer _x}) != -1}) exitWith {
    diag_log "[DSD] Transport occupied by player; cleanup handed over to mission/Zeus.";
};
{if (!isNull _x && {!isPlayer _x}) then {deleteVehicle _x;};} forEach _crew;
if (!isNull _aircraft) then {deleteVehicle _aircraft;};
if (!isNull _group && {count units _group == 0}) then {deleteGroup _group;};
diag_log "[DSD] Transport and AI crew cleaned up.";

};
DSD_fnc_fillSupplyCrate = {
/* Server-only. Return manifest [cargo command kind, classname, quantity] or [] on failure. */
params ["_crate", "_selectionCount"];
if (!isServer || {isNull _crate}) exitWith {[]};
private _pools = [] call DSD_fnc_buildSupplyPools;
private _categories = ["AssaultRifle", "SubmachineGun", "SniperRifle", "MachineGun", "Handgun", "Attachment", "Optic", "Suppressor", "Magazine", "Grenade", "Explosive", "Medical", "Backpack", "Uniform", "Vest"];
private _manifest = [];
private _signature = "";
private _fresh = false;
for "_attempt" from 1 to 12 do {
    _manifest = [];
    private _used = [];
    private _add = {
        params ["_category", "_class", ["_quantity", 1]];
        if (_class == "" || {_class in _used} || {count _manifest >= _selectionCount}) exitWith {};
        private _kind = switch (_category) do {
            case "AssaultRifle"; case "SubmachineGun"; case "SniperRifle"; case "MachineGun"; case "Handgun": {"Weapon"};
            case "Magazine"; case "Grenade"; case "Explosive": {"Magazine"};
            case "Backpack": {"Backpack"};
            default {"Item"};
        };
        private _mags = [];
        if (_kind == "Weapon") then {_mags = [_class] call DSD_fnc_getSupplyMagazines;};
        // Reserve an ammunition slot when adding another weapon near the selection limit.
        if (_kind == "Weapon" && {(_mags arrayIntersect _used) isEqualTo []} && {count _manifest >= _selectionCount - 1}) exitWith {};
        _used pushBack _class;
        _manifest pushBack [_kind, _class, _quantity];
        if (_kind == "Weapon") then {
            if (_mags isNotEqualTo []) then {
                private _mag = selectRandom _mags;
                if (!(_mag in _used) && {count _manifest < _selectionCount}) then {
                    _used pushBack _mag;
                    _manifest pushBack ["Magazine", _mag, 1];
                };
            };
        };
    };
    // Every available category first, then randomized unique additions.
    {
        private _pool = _pools get _x;
        if (_pool isNotEqualTo []) then {
            [_x, selectRandom _pool, if (_x in ["Magazine", "Grenade", "Medical"]) then {2 + floor random 3} else {1}] call _add;
        };
    } forEach _categories;
    private _tries = 0;
    while {count _manifest < _selectionCount && {_tries < 2000}} do {
        private _category = selectRandom _categories;
        private _pool = (_pools get _category) - _used;
        if (_pool isNotEqualTo []) then {[_category, selectRandom _pool] call _add;};
        _tries = _tries + 1;
    };
    // Allocate five magazines per distinct weapon. Shared magazine classes accumulate
    // a separate five-magazine allowance for each weapon that selects them.
    private _required = createHashMap;
    {
        private _mags = [_x select 1] call DSD_fnc_getSupplyMagazines;
        private _index = _manifest findIf {(_x select 0) == "Magazine" && {(_x select 1) in _mags}};
        if (_index >= 0) then {
            private _class = (_manifest select _index) select 1;
            _required set [_class, (_required getOrDefault [_class, 0]) + 5];
        };
    } forEach (_manifest select {(_x select 0) == "Weapon"});
    {
        if ((_x select 0) == "Magazine") then {
            _x set [2, (_x select 2) max (_required getOrDefault [_x select 1, 0])];
        };
    } forEach _manifest;
    {_x set [2,(round ((_x select 2)*2.25)) max 1];} forEach _manifest;
    private _sorted = _manifest apply {str _x};
    _sorted sort true;
    _signature = str _sorted;
    if (!(_signature in DSD_manifestHistory)) exitWith {_fresh = true;};
};
if (!_fresh || {_manifest isEqualTo []}) exitWith {diag_log "[DSD] ERROR: Cannot generate a new unique manifest."; []};
clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;
{
    _x params ["_kind", "_class", "_quantity"];
    switch (_kind) do {
        case "Weapon": {_crate addWeaponCargoGlobal [_class, _quantity];};
        case "Magazine": {_crate addMagazineCargoGlobal [_class, _quantity];};
        case "Backpack": {_crate addBackpackCargoGlobal [_class, _quantity];};
        default {_crate addItemCargoGlobal [_class, _quantity];};
    };
} forEach _manifest;
DSD_manifestHistory pushBack _signature;
_crate setVariable ["DSD_manifest", _manifest, true];
diag_log format ["[DSD] Cargo: %1", _manifest];
_manifest

};
DSD_fnc_getSupplyMagazines = {
/* Primary ballistic ammunition only: exclude UGL smoke, flares, and signal pistols. */
params ["_weapon"];
if (isNil "DSD_ballisticMagazines") then {DSD_ballisticMagazines = createHashMap;};
if (!isNil {DSD_ballisticMagazines get _weapon}) exitWith {DSD_ballisticMagazines get _weapon};
private _result = (compatibleMagazines [_weapon, "this"]) select {
    private _mag = configFile >> "CfgMagazines" >> _x;
    private _ammo = configFile >> "CfgAmmo" >> getText (_mag >> "ammo");
    isClass _mag && {[_x, "CfgMagazines"] call DSD_fnc_isSupplyAssetAllowed} && {getNumber (_mag >> "scope") == 2} && {
        toLower getText (_ammo >> "simulation") in ["shotbullet", "shotspread"]
    }
};
DSD_ballisticMagazines set [_weapon, _result];
_result

};
DSD_fnc_importAntistasiCrate = {
/* Server-only native JNA import. Leave the empty container in its truck slot:
   deleting/detaching it here would corrupt Antistasi's Cargo/Nodes/seat/mass state. */
params ["_crate"];
if (!isServer || {isNull _crate} || {!alive _crate} || {!(_crate getVariable ["DSD_landed", false])} || {_crate getVariable ["DSD_arsenalImported", false]}) exitWith {false};
if (isNil "jn_fnc_arsenal_cargoToArsenal" || {isNil "A3A_fnc_arsenalManage"} || {isNil "jna_dataList"} || {isNil "server"} || {isNil "minWeaps"}) exitWith {false};
if (count jna_dataList < 27 || {isNull server}) exitWith {false};
private _arsenal = missionNamespace getVariable ["boxX", objNull];
if (isNull _arsenal || {_crate == _arsenal} || {_crate distance2D _arsenal > 20} || {abs ((getPosASL _crate select 2) - (getPosASL _arsenal select 2)) > 6}) exitWith {false};
private _carrier = attachedTo _crate;
if (!isNull _carrier && {!(_carrier isKindOf "LandVehicle")}) exitWith {false};
private _movingObject = if (isNull _carrier) then {_crate} else {_carrier};
if (abs speed _movingObject > 1 || {_movingObject getVariable ["LoadingCargo", false]}) exitWith {false};
private _imported = false;
// Native arsenal transfer and our once-only flag run together without scheduler interleaving.
isNil {
    if (!(_crate getVariable ["A3A_JNA_cargoToArsenal_busy", false]) && {!(_crate getVariable ["A3A_JNA_ammunitionTransfer_busy", false])} && {!(_arsenal getVariable ["A3A_JNA_cargoToArsenal_busy", false])} && {!(_crate getVariable ["DSD_arsenalImported", false])}) then {
        [_crate] call jn_fnc_arsenal_cargoToArsenal;
        private _empty = (weaponCargo _crate) isEqualTo [] && {magazineCargo _crate isEqualTo []} && {itemCargo _crate isEqualTo []} && {backpackCargo _crate isEqualTo []};
        if (_empty) then {
            _crate setVariable ["DSD_arsenalImported", true, true];
            // Reuse Antistasi's normal unlock thresholds and loadout accounting.
            [] call A3A_fnc_arsenalManage;
            _imported = true;
        };
    };
};
if (_imported) then {diag_log "[DSD] Crate cargo imported into Antistasi HQ arsenal; empty container retained for native logistics.";};
_imported

};
DSD_fnc_initSupplyDrops = {
/* PostInit on every machine. Also safe to call from the live bootstrap. */
if (isNil "CBA_fnc_addEventHandler") exitWith {
    diag_log "[DSD] ERROR: CBA is required; initialization aborted.";
};
// Invalidate v1.0 cached pools on a live upgrade; preserve existing drops/history.
if ((missionNamespace getVariable ["DSD_dataVersion", ""]) != "1.1.0") then {
    DSD_supplyPools = nil;
    DSD_ballisticMagazines = nil;
    DSD_allowedAssetCache = nil;
    DSD_dataVersion = "1.1.0";
};
if (isServer && {isNil "DSD_requestHandler"}) then {
    DSD_requestHandler = ["DSD_request", { _this call DSD_fnc_requestSupplyDrop; }] call CBA_fnc_addEventHandler;
    DSD_activeDrops = 0;
    DSD_manifestHistory = [];
};
if (!isNil "DSD_noticeHandler") then {
    ["DSD_notice", DSD_noticeHandler] call CBA_fnc_removeEventHandler;
    DSD_noticeHandler = nil;
};
if (hasInterface) then {
    [] call DSD_fnc_registerSupplyMenu;
};
diag_log "[DSD] Dynamic Supply Drops initialized (v1.1.0, DLC-free, silent, Antistasi integration).";

};
DSD_fnc_isSupplyAssetAllowed = {
/* Exclude official DLC assets, including DLC models reused by otherwise untagged classes.
   Ownership is deliberately ignored: everybody receives the same DLC-free cargo.
   Unknown/zero app IDs are mod content, not a purchase entitlement. */
params ["_class", ["_section", "CfgWeapons"]];
if (isNil "DSD_allowedAssetCache") then {DSD_allowedAssetCache = createHashMap;};
private _key = _section + ":" + _class;
if (!isNil {DSD_allowedAssetCache get _key}) exitWith {DSD_allowedAssetCache get _key};
private _cfg = configFile >> _section >> _class;
private _allowed = isClass _cfg;
if (_allowed) then {
    // Some official DLC reskins share a base-game model and have no asset restriction.
    // Still exclude them by the class's DLC tag and its registered official Steam app ID.
    private _tag = getText (_cfg >> "dlc");
    private _app = configFile >> "CfgMods" >> _tag >> "appId";
    private _appID = if (isNumber _app) then {getNumber _app} else {parseNumber getText _app};
    if (_tag != "" && {_appID > 0}) then {_allowed = false;};
};
if (_allowed) then {
    private _info = getAssetDLCInfo [_class, configFile >> _section];
    private _model = getText (_cfg >> "model");
    private _checks = [_info];
    if (_model != "") then {_checks pushBack (getAssetDLCInfo _model);};
    _allowed = (_checks findIf {
        (_x param [0, false]) && {!((_x param [4, "0"]) in ["", "0", "-1"])}
    }) == -1;
};
DSD_allowedAssetCache set [_key, _allowed];
_allowed

};
DSD_fnc_landSupplyCrate = {
/* Scheduled server descent monitor, bounded even if objects are removed by Zeus. */
params ["_requester", "_crate", "_chute", "_smoke"];
private _deadline = diag_tickTime + 600;
private _landed = false;
private _nextDiagnostic = diag_tickTime;
waitUntil {
    sleep 0.25;
    // Attached objects can retain a stale isTouchingGround state from creation.
    // Require actual terrain proximity, not that contact flag alone.
    _landed = !isNull _crate && {(getPosATL _crate select 2) < 1.3};
    if (!isNull _crate && {diag_tickTime > _nextDiagnostic}) then {
        diag_log format ["[DSD] Descent: crate %1m AGL, chute %2m AGL", round (getPosATL _crate select 2), if (isNull _chute) then {-1} else {round (getPosATL _chute select 2)}];
        _nextDiagnostic = diag_tickTime + 20;
    };
    _landed || {isNull _crate} || {isNull _chute} || {diag_tickTime > _deadline}
};
if (!_landed || {isNull _crate} || {surfaceIsWater getPosASL _crate}) exitWith {
    if (!isNull _crate) then {detach _crate; deleteVehicle _crate;};
    if (!isNull _chute) then {deleteVehicle _chute;};
    [_requester, "Drop failed: descent interrupted, timed out, or drifted into water. Temporary objects removed."] call DSD_fnc_notifySupplyDrop;
};
detach _crate;
_crate setVelocity [0, 0, 0];
if (!isNull _chute) then {deleteVehicle _chute;};
sleep 1;
if (isNull _crate) exitWith {};
_crate allowDamage true;
_crate setVariable ["DSD_landed", true, true];
_crate setVariable ["DSD_landingTime", diag_tickTime, true];
[_crate] call DSD_fnc_registerAntistasiCrate;
if (_smoke && {isClass (configFile >> "CfgAmmo" >> "SmokeShellGreen")}) then {
    private _marker = createVehicle ["SmokeShellGreen", (getPosATL _crate) vectorAdd [3, 0, 0.3], [], 0, "CAN_COLLIDE"];
    [_marker] spawn {params ["_marker"]; sleep 120; if (!isNull _marker) then {deleteVehicle _marker;};};
};
[_requester, format ["Supplies landed at grid %1. Crate remains until collected, destroyed, or removed by Zeus.", mapGridPosition getPosASL _crate]] call DSD_fnc_notifySupplyDrop;

};
DSD_fnc_notifySupplyDrop = {
/* Deliberately RPT-only: no call-in, inbound, release, or landing announcements. */
params ["_requester", "_message"];
diag_log ("[DSD] " + _message);

};
DSD_fnc_openSupplyDialog = {
params [["_positionASL", [], [[]]]];
if (!hasInterface || {isNull getAssignedCuratorLogic player}) exitWith {};
private _position = [_positionASL] call DSD_fnc_validateDropPosition;
if (_position isEqualTo []) exitWith {systemChat "[Dynamic Supply Drops] Select dry land inside the map.";};
private _aircraft = "B_Heli_Transport_01_F";
if (isClass (configFile >> "CfgVehicles" >> "RHS_C130J")) then {_aircraft = "RHS_C130J";};
[
    "Spawn Randomized Supply Drop",
    [
        ["EDIT", "Crate classname", ["B_supplyCrate_F"]],
        ["EDIT", "Aircraft classname", [_aircraft]],
        ["SLIDER", ["Unique cargo selections", "DLC-free gear. At least five compatible magazines per unique weapon; shared ammo allowances accumulate."], [20, 100, 50, 0]],
        ["SLIDER", "Drop altitude (metres AGL)", [150, 1000, 300, 0]],
        ["SLIDER", "Approach distance (metres)", [2000, 8000, 4000, 0]],
        ["CHECKBOX", "Smoke on landing", [true]]
    ],
    {
        params ["_values", "_position"];
        ["DSD_request", [player, _position, _values]] call CBA_fnc_serverEvent;
    }, {}, _position, "DSD_supplyOptions_v1"
] call zen_dialog_fnc_create;

};
DSD_fnc_registerAntistasiCrate = {
/* Optional adapter for the installed Antistasi Plus APIs. No hard dependency. */
params ["_crate"];
if (!isServer || {isNull _crate} || {_crate getVariable ["DSD_antistasiRegistered", false]}) exitWith {};
if (isNil "A3A_faction_reb" || {isNil "A3A_Logistics_fnc_addLoadAction"} || {isNil "A3A_Logistics_fnc_isLoadable"} || {isNil "jn_fnc_arsenal_cargoToArsenal"} || {isNil "A3A_fnc_arsenalManage"}) exitWith {};
_crate setVariable ["DSD_antistasiRegistered", true];
if ([_crate] call A3A_Logistics_fnc_isLoadable) then {
    [_crate] call A3A_Logistics_fnc_addLoadAction;
    diag_log "[DSD] Antistasi native load action registered for landed crate.";
} else {
    diag_log format ["[DSD] Crate %1 has no Antistasi cargo definition; HQ import still available if transported there.", typeOf _crate];
};
[_crate] spawn {
    params ["_crate"];
    while {!isNull _crate && {alive _crate} && {!(_crate getVariable ["DSD_arsenalImported", false])}} do {
        [_crate] call DSD_fnc_importAntistasiCrate;
        sleep 5;
    };
};

};
DSD_fnc_registerSupplyMenu = {
/* ZEN 1.15.1 public APIs; context callback element 0 is position ASL. */
if (!hasInterface || {missionNamespace getVariable ["DSD_menuRegistered", false]}) exitWith {};
if (isNil "zen_context_menu_fnc_createAction" || {isNil "zen_dialog_fnc_create"}) exitWith {
    diag_log "[DSD] ERROR: ZEN context menu/dialog APIs unavailable.";
};
private _folder = ["DSD_SupplyDrops", "Dynamic Supply Drops", "", {}, {true}] call zen_context_menu_fnc_createAction;
private _path = [_folder, [], 100] call zen_context_menu_fnc_addAction;
if (_path isEqualTo []) exitWith {diag_log "[DSD] ERROR: Menu registration failed.";};
private _action = ["DSD_SpawnRandom", "Spawn Randomized Supply Drop", "", {
    [_this select 0] call DSD_fnc_openSupplyDialog;
}, {true}] call zen_context_menu_fnc_createAction;
[_action, _path, 100] call zen_context_menu_fnc_addAction;
// Also expose the same position-based operation in the native Zeus modules tree.
["Dynamic Supply Drops", "Spawn Randomized Supply Drop", {
    [_this select 0] call DSD_fnc_openSupplyDialog;
}] call zen_custom_modules_fnc_register;
DSD_menuRegistered = true;

};
DSD_fnc_requestSupplyDrop = {
/* CBA server event: all persistent objects and global cargo are created on the server. */
if (!isServer) exitWith {};
params [["_requester", objNull, [objNull]], ["_position", [], [[]]], ["_options", [], [[]]]];
if (isNull _requester || {!isPlayer _requester} || {isNull getAssignedCuratorLogic _requester}) exitWith {
    diag_log "[DSD] Rejected request without an assigned player curator.";
};
private _target = [_position] call DSD_fnc_validateDropPosition;
if (_target isEqualTo []) exitWith {[_requester, "Invalid drop location: choose dry land inside the map."] call DSD_fnc_notifySupplyDrop;};
private _validated = [_options] call DSD_fnc_validateDropOptions;
if ((_validated select 0) != "") exitWith {[_requester, _validated select 0] call DSD_fnc_notifySupplyDrop;};
if (diag_tickTime < (_requester getVariable ["DSD_nextRequest", -1])) exitWith {[_requester, "Wait 10 seconds between requests."] call DSD_fnc_notifySupplyDrop;};
if (DSD_activeDrops >= 4) exitWith {[_requester, "Four deliveries are already active. Try again after one lands."] call DSD_fnc_notifySupplyDrop;};
_requester setVariable ["DSD_nextRequest", diag_tickTime + 10];
DSD_activeDrops = DSD_activeDrops + 1;
[_requester, "Delivery accepted; preparing transport."] call DSD_fnc_notifySupplyDrop;
[_requester, _target, _validated select 1] spawn DSD_fnc_runSupplyDelivery;

};
DSD_fnc_runSupplyDelivery = {
/* Scheduled on server. AI flies through the target toward an egress waypoint. */
params ["_requester", "_target", "_options"];
if (!isServer) exitWith {};
_options params ["_crateClass", "_airClass", "_count", "_altitude", "_distance", "_smoke"];
private _bearing = random 360;
private _start = [];
for "_i" from 0 to 35 do {
    private _candidate = _target getPos [_distance, _bearing + 180];
    if ((_candidate select 0) > 50 && {(_candidate select 1) > 50} && {(_candidate select 0) < worldSize - 50} && {(_candidate select 1) < worldSize - 50}) exitWith {_start = _candidate;};
    _bearing = _bearing + 10;
};
if (_start isEqualTo []) exitWith {
    [_requester, "No safe approach fits this map. Choose a shorter approach distance."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_start set [2, _altitude];
private _aircraft = createVehicle [_airClass, _start, [], 0, "FLY"];
if (isNull _aircraft) exitWith {
    [_requester, "Aircraft creation failed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_aircraft setDir _bearing;
_aircraft setPosATL _start;
createVehicleCrew _aircraft;
private _pilot = driver _aircraft;
private _crew = crew _aircraft;
private _group = group _pilot;
if (isNull _pilot || {isNull _group}) exitWith {
    {deleteVehicle _x;} forEach _crew;
    deleteVehicle _aircraft;
    if (!isNull _group) then {deleteGroup _group;};
    [_requester, "Aircraft has no working AI pilot; delivery aborted."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_group deleteGroupWhenEmpty true;
_group setBehaviourStrong "CARELESS";
_group setCombatMode "BLUE";
_group setSpeedMode "NORMAL";
{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"; _x setSkill 1;} forEach _crew;
_aircraft flyInHeight _altitude;
private _speed = if (_aircraft isKindOf "Plane") then {85} else {55};
_aircraft setVelocity [sin _bearing * _speed, cos _bearing * _speed, 0];
private _exit = _target getPos [6000, _bearing];
_exit set [2, _altitude];
private _inbound = +_target;
_inbound set [2, _altitude];
private _dropWP = _group addWaypoint [_inbound, 0];
_dropWP setWaypointType "MOVE";
_dropWP setWaypointCompletionRadius 80;
private _wp = _group addWaypoint [_exit, 0];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 300;
_group setCurrentWaypoint _dropWP;
// Independent watchdog ensures transport cleanup even when delivery fails.
[_aircraft, _crew, _group, _target] spawn DSD_fnc_cleanupSupplyAircraft;
[_requester, format ["%1 inbound. Drop requested at grid %2.", getText (configFile >> "CfgVehicles" >> _airClass >> "displayName"), mapGridPosition _target]] call DSD_fnc_notifySupplyDrop;
private _deadline = diag_tickTime + 240;
private _overTarget = false;
private _nextDiagnostic = diag_tickTime;
waitUntil {
    sleep 0.15;
    if (!isNull _aircraft && {diag_tickTime > _nextDiagnostic}) then {
        diag_log format ["[DSD] Flight: grid %1, distance %2m, altitude %3m AGL, speed %4km/h", mapGridPosition getPosASL _aircraft, round (_aircraft distance2D _target), round (getPosATL _aircraft select 2), round speed _aircraft];
        _nextDiagnostic = diag_tickTime + 20;
    };
    _overTarget = !isNull _aircraft && {_aircraft distance2D _target < 180} && {(getPosATL _aircraft select 2) > 80};
    _overTarget || {isNull _aircraft} || {!alive _aircraft} || {!alive _pilot} || {diag_tickTime > _deadline}
};
if (!_overTarget || {isNull _aircraft} || {!alive _aircraft} || {!alive _pilot}) exitWith {
    if (!isNull _aircraft) then {_aircraft setVariable ["DSD_departing", true];};
    [_requester, "Delivery aborted: aircraft lost or unable to reach the drop corridor within four minutes."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
// Release at the actual aircraft position; no teleporting the crate onto the target.
_aircraft setVariable ["DSD_departing", true];
_group setCurrentWaypoint _wp;
private _release = getPosASL _aircraft;
_release set [2, (_release select 2) - 12];
private _chute = createVehicle ["B_Parachute_02_F", ASLToATL _release, [], 0, "FLY"];
private _crate = createVehicle [_crateClass, ASLToATL _release, [], 0, "CAN_COLLIDE"];
if (isNull _chute || {isNull _crate}) exitWith {
    if (!isNull _chute) then {deleteVehicle _chute;};
    if (!isNull _crate) then {deleteVehicle _crate;};
    [_requester, "Crate/parachute creation failed; temporary objects removed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_crate allowDamage false;
_chute allowDamage false;
_chute setPosASL _release;
_crate attachTo [_chute, [0, 0, -4]];
_crate setVariable ["DSD_releaseTime", diag_tickTime, true];
_crate setVariable ["DSD_releaseAltitude", _release select 2, true];
private _velocity = velocity _aircraft;
_chute setVelocity [(_velocity select 0) * 0.1, (_velocity select 1) * 0.1, -4];
private _manifest = [_crate, _count] call DSD_fnc_fillSupplyCrate;
if (_manifest isEqualTo []) exitWith {
    detach _crate;
    deleteVehicle _crate;
    deleteVehicle _chute;
    [_requester, "Cargo generation failed; empty drop removed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
{_x addCuratorEditableObjects [[_crate], false];} forEach allCurators;
[_requester, "Supply crate released. Transport departing."] call DSD_fnc_notifySupplyDrop;
[_requester, _crate, _chute, _smoke] call DSD_fnc_landSupplyCrate;
DSD_activeDrops = 0 max (DSD_activeDrops - 1);

};
DSD_fnc_validateDropOptions = {
/* Return [error message, normalized options]. Never silently substitute invalid user classes. */
params [["_options", [], [[]]]];
if (count _options != 6) exitWith {["Invalid option count.", []]};
_options params ["_crate", "_aircraft", "_count", "_altitude", "_distance", "_smoke"];
if (!(_crate isEqualType "") || {!(_aircraft isEqualType "")} || {!(_smoke isEqualType true)}) exitWith {["Invalid option types.", []]};
if (([_count, _altitude, _distance] findIf {!(_x isEqualType 0) || {!finite _x}}) != -1) exitWith {["Numeric options must be finite numbers.", []]};
private _cfg = configFile >> "CfgVehicles";
if (!isClass (_cfg >> _crate) || {!(_crate isKindOf "ReammoBox_F")} || {getNumber (_cfg >> _crate >> "maximumLoad") <= 0}) exitWith {["Crate must be an existing ammo box with cargo capacity.", []]};
if (!isClass (_cfg >> _aircraft) || {!(_aircraft isKindOf "Air")} || {getNumber (_cfg >> _aircraft >> "isUav") == 1}) exitWith {["Aircraft must be an existing crewed aircraft.", []]};
private _crew = getText (_cfg >> _aircraft >> "crew");
if (!isClass (_cfg >> _crew)) exitWith {["Aircraft has no valid configured pilot.", []]};
if (!isClass (_cfg >> "B_Parachute_02_F")) exitWith {["Cargo parachute class unavailable.", []]};
if (_count < 20 || {_count > 100} || {_altitude < 150} || {_altitude > 1000} || {_distance < 2000} || {_distance > 8000}) exitWith {["Options outside supported limits (20-100 selections, 150-1000m altitude, 2000-8000m approach).", []]};
["", [_crate, _aircraft, round _count, _altitude, _distance, _smoke]]

};
DSD_fnc_validateDropPosition = {
/* Accept ASL from ZEN, discard click height, return terrain ASL. Reject sea/outside map. */
params [["_position", [], [[]]]];
if (count _position < 2 || {count _position > 3}) exitWith {[]};
if ((_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1) exitWith {[]};
_position params ["_xPos", "_yPos"];
if (_xPos < 50 || {_yPos < 50} || {_xPos > worldSize - 50} || {_yPos > worldSize - 50}) exitWith {[]};
if (surfaceIsWater [_xPos, _yPos]) exitWith {[]};
[_xPos, _yPos, getTerrainHeightASL [_xPos, _yPos]]

};
[] call DSD_fnc_initSupplyDrops;