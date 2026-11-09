[] spawn {
    sleep 3;
    private _bootstrap = isNil "DSD_fnc_initSupplyDrops";
    if (_bootstrap) then {call compile preprocessFileLineNumbers "LIVE_BOOTSTRAP.sqf";};
    DSD_testFailures = 0;
    private _assert = {
        params ["_condition", "_label"];
        if (!_condition) then {DSD_testFailures = DSD_testFailures + 1;};
        diag_log format ["[DSD TEST] %1: %2", ["FAIL", "PASS"] select _condition, _label];
    };
    private _names = ["initSupplyDrops", "registerSupplyMenu", "openSupplyDialog", "validateDropPosition", "validateDropOptions", "requestSupplyDrop", "notifySupplyDrop", "buildSupplyPools", "isSupplyAssetAllowed", "getSupplyMagazines", "fillSupplyCrate", "runSupplyDelivery", "landSupplyCrate", "cleanupSupplyAircraft", "registerAntistasiCrate", "importAntistasiCrate"];
    { [!isNil ("DSD_fnc_" + _x), "registered function " + _x] call _assert; } forEach _names;
    // Force the engine parser to inspect every function body, including client-only functions.
    if (!_bootstrap) then {{
        private _text = preprocessFileLineNumbers format ["\dsd_supplydrops\functions\SupplyDrops\fn_%1.sqf", _x];
        compile _text;
        [count _text > 0, "readable SQF " + _x] call _assert;
    } forEach _names;};
    private _handler = DSD_requestHandler;
    DSD_noticeHandler = ["DSD_notice",{}] call CBA_fnc_addEventHandler;
    DSD_dataVersion = "1.0.0";
    DSD_supplyPools = createHashMapFromArray [["legacy","DLC gear"]];
    [] call DSD_fnc_initSupplyDrops;
    [DSD_requestHandler == _handler, "initialization does not duplicate server handler"] call _assert;
    [isNil "DSD_supplyPools" && {DSD_dataVersion == "1.1.0"},"live upgrade discards obsolete gear pools"] call _assert;
    [isNil "DSD_noticeHandler","live upgrade removes legacy client notification handler"] call _assert;
    [[[]] call DSD_fnc_validateDropPosition isEqualTo [], "empty position rejected"] call _assert;
    [[[-10,4000,0]] call DSD_fnc_validateDropPosition isEqualTo [], "outside map rejected"] call _assert;
    [[["bad",4000,0]] call DSD_fnc_validateDropPosition isEqualTo [], "nonnumeric position rejected"] call _assert;
    private _target = [[4000,4000,0]] call DSD_fnc_validateDropPosition;
    [count _target == 3, "valid VR position accepted"] call _assert;
    private _options = ["B_supplyCrate_F", "RHS_C130J", 50, 300, 4000, true];
    [(([_options] call DSD_fnc_validateDropOptions) select 0) == "", "RHS C-130 and default crate valid"] call _assert;
    private _bad = +_options;
    _bad set [0,"DSD_missing_crate"];
    [(([_bad] call DSD_fnc_validateDropOptions) select 0) != "", "invalid crate rejected"] call _assert;
    _bad = +_options;
    _bad set [1,"B_Soldier_F"];
    [(([_bad] call DSD_fnc_validateDropOptions) select 0) != "", "non-aircraft rejected"] call _assert;
    _bad = +_options;
    _bad set [2,1000];
    [(([_bad] call DSD_fnc_validateDropOptions) select 0) != "", "oversized cargo request rejected"] call _assert;
    private _before = DSD_activeDrops;
    [objNull, _target, _options] call DSD_fnc_requestSupplyDrop;
    [DSD_activeDrops == _before, "unauthorized request rejected"] call _assert;
    private _pools = [] call DSD_fnc_buildSupplyPools;
    { [count (_pools get _x) > 0, "nonempty category " + _x] call _assert; } forEach keys _pools;
    [!(["arifle_AK12_F"] call DSD_fnc_isSupplyAssetAllowed), "Apex rifle excluded even when owned"] call _assert;
    [!(["srifle_DMR_02_F"] call DSD_fnc_isSupplyAssetAllowed), "Marksmen rifle excluded"] call _assert;
    [["arifle_MX_SW_khk_F"] call DSD_fnc_isSupplyAssetAllowed, "free platform MX variant retained (no DLC tag or entitlement)"] call _assert;
    [!(["B_Carryall_ghex_F","CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed), "Apex backpack reskin excluded"] call _assert;
    {
        private _class = _x;
        private _section = if (_class == "B_Carryall_ghex_F") then {"CfgVehicles"} else {"CfgWeapons"};
        private _tag = getText (configFile >> _section >> _class >> "dlc");
        diag_log format ["[DSD TEST] DLC metadata %1: tag=%2, appID=%3, assetInfo=%4", _class, _tag, getNumber (configFile >> "CfgMods" >> _tag >> "appId"), getAssetDLCInfo [_class, configFile >> _section]];
    } forEach ["arifle_MX_SW_khk_F","B_Carryall_ghex_F","rhs_weap_m4a1"];
    [["arifle_MX_F"] call DSD_fnc_isSupplyAssetAllowed, "base-game MX retained"] call _assert;
    [["rhs_weap_m4a1"] call DSD_fnc_isSupplyAssetAllowed, "free RHS weapon retained"] call _assert;
    private _dlcFree = true;
    {
        private _category = _x;
        private _section = if (_category == "Backpack") then {"CfgVehicles"} else {if (_category in ["Magazine", "Grenade", "Explosive"]) then {"CfgMagazines"} else {"CfgWeapons"}};
        if (((_pools get _category) findIf {!([_x, _section] call DSD_fnc_isSupplyAssetAllowed)}) != -1) then {_dlcFree = false;};
    } forEach keys _pools;
    [_dlcFree, "all discovered gear pools exclude official DLC"] call _assert;
    DSD_testNotices = 0;
    private _noticeEH = ["DSD_notice", {DSD_testNotices = DSD_testNotices + 1;}] call CBA_fnc_addEventHandler;
    private _recipient = createVehicle ["B_Soldier_F",[4050,4050,0],[],0,"NONE"];
    [_recipient,"Silent delivery notification test"] call DSD_fnc_notifySupplyDrop;
    [DSD_testNotices == 0, "delivery notifier sends no client event"] call _assert;
    ["DSD_notice",_noticeEH] call CBA_fnc_removeEventHandler;
    deleteVehicle _recipient;
    private _crate = createVehicle ["B_supplyCrate_F", [4100,4000,0], [], 0, "CAN_COLLIDE"];
    private _first = [_crate,50] call DSD_fnc_fillSupplyCrate;
    [count _first == 50, "50 unique cargo entries generated"] call _assert;
    [count ((_first apply {_x select 1}) arrayIntersect (_first apply {_x select 1})) == count _first, "no duplicate classnames"] call _assert;
    private _valid = true;
    {
        _x params ["_kind", "_class", "_qty"];
        private _cfgName = switch (_kind) do {case "Weapon"; case "Item": {"CfgWeapons"}; case "Magazine": {"CfgMagazines"}; default {"CfgVehicles"};};
        if (!isClass (configFile >> _cfgName >> _class) || {_qty < 1} || {_kind != "Magazine" && {_qty > 4}} || {!([_class,_cfgName] call DSD_fnc_isSupplyAssetAllowed)}) then {_valid = false;};
    } forEach _first;
    [_valid, "every manifest class exists and quantities are bounded"] call _assert;
    private _matching = true;
    private _allocations = createHashMap;
    {
        private _mags = [_x select 1] call DSD_fnc_getSupplyMagazines;
        private _cargoClasses = _first apply {_x select 1};
        private _index = _first findIf {(_x select 0) == "Magazine" && {(_x select 1) in _mags}};
        if (_index < 0) then {_matching = false;} else {
            private _entry = _first select _index;
            private _mag = _entry select 1;
            private _required = (_allocations getOrDefault [_mag,0]) + 5;
            _allocations set [_mag,_required];
            if ((_entry select 2) < _required) then {_matching = false;};
        };
    } forEach (_first select {(_x select 0) == "Weapon"});
    [_matching, "five ballistic magazines allocated per unique weapon, shared allowances accumulate"] call _assert;
    private _second = [_crate,50] call DSD_fnc_fillSupplyCrate;
    [_first isNotEqualTo _second && {count DSD_manifestHistory == 2}, "successive manifests differ"] call _assert;
    [(weaponCargo _crate) isNotEqualTo [] && {magazineCargo _crate isNotEqualTo []} && {itemCargo _crate isNotEqualTo []} && {backpackCargo _crate isNotEqualTo []}, "all four cargo kinds populated in engine"] call _assert;
    deleteVehicle _crate;
    private _antistasi = !isNil "A3A_Logistics_fnc_canLoad";
    if (_antistasi) then {
        // Isolated fixture: use real installed logistics/JNA functions without campaign startup/save access.
        A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_IND_Wps_F"]];
        private _logicGroup = createGroup sideLogic;
        server = _logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
        [!isNull server,"isolated Antistasi server logic is initialized"] call _assert;
        server setVariable ["jna_playersInArsenal",[]];
        jna_dataList = [];
        for "_i" from 0 to 26 do {jna_dataList pushBack [];};
        minWeaps = -1;
        boxX = createVehicle ["B_supplyCrate_F",[6000,6000,0],[],0,"CAN_COLLIDE"];
        clearWeaponCargoGlobal boxX; clearMagazineCargoGlobal boxX; clearItemCargoGlobal boxX; clearBackpackCargoGlobal boxX;
    };
    // Exercise the actual AI flight / parachute / landing path, without bypassing flight logic.
    DSD_activeDrops = DSD_activeDrops + 1;
    private _flight = [objNull, _target, _options] spawn DSD_fnc_runSupplyDelivery;
    private _deadline = diag_tickTime + 900;
    waitUntil {sleep 1; scriptDone _flight || {diag_tickTime > _deadline}};
    [scriptDone _flight, "delivery script terminates"] call _assert;
    private _landed = (allMissionObjects "ReammoBox_F") select {_x getVariable ["DSD_landed", false]};
    [count _landed == 1, "C-130 delivery lands exactly one populated crate"] call _assert;
    if (_landed isNotEqualTo []) then {
        private _box = _landed select 0;
        [(_box getVariable ["DSD_landingTime",0]) - (_box getVariable ["DSD_releaseTime",0]) > 10, "crate descends physically for over ten seconds"] call _assert;
        [(getPosATL _box select 2) < 3, "landed crate is at terrain level"] call _assert;
    };
    [DSD_activeDrops == 0, "active delivery counter released"] call _assert;
    [count (allMissionObjects "B_Parachute_02_F") == 0, "parachute removed after landing"] call _assert;
    if (_antistasi && {_landed isNotEqualTo []}) then {[_assert,_landed select 0] call compile preprocessFileLineNumbers "testAntistasi.sqf";};
    private _cleanupDeadline = diag_tickTime + 430;
    waitUntil {sleep 1; count (vehicles select {_x isKindOf "RHS_C130J"}) == 0 || {diag_tickTime > _cleanupDeadline}};
    [count ((vehicles select {_x isKindOf "RHS_C130J"})) == 0, "departing aircraft cleaned up"] call _assert;
    diag_log format ["[DSD TEST] COMPLETE failures=%1", DSD_testFailures];
};
