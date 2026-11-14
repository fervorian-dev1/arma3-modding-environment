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
