/* Six vehicles plus ten curated items. Reserved roles fall back without invalid classes. */
if (!isServer) exitWith {[]};
private _cfg=configFile >> "DSDS_Fence";
private _stock=[];
private _previous=(missionNamespace getVariable ["DSDS_fenceStock",[]]) select {_x select 0=="VEHICLE"};
private _previousClasses=_previous apply {_x select 1};
private _vehicles=(DSDS_fencePools select 0) select {!([_x,"CfgVehicles"] call DSDS_fnc_fenceIsAntiAir)};
private _allVehicles=+_vehicles;
private _fresh=_vehicles select {!(_x in _previousClasses)};
if (count _fresh>=6) then {_vehicles=_fresh;};
// Reserve varied vehicle families. Dedicated AA remains exclusively inventory gear.
{
    _x params ["_family","_filter"];
    private _chosen=_stock apply {_x select 1};
    private _pool=_vehicles select {_x call _filter && {!(_x in _chosen)}};
    if (_pool isEqualTo []) then {_pool=_allVehicles select {_x call _filter && {!(_x in _chosen)}};};
    if (_pool isNotEqualTo []) then {
        private _class=selectRandom _pool;_vehicles=_vehicles-[_class];
        _stock pushBack ["VEHICLE",_class,"CfgVehicles",([_class] call DSDS_fnc_vehicleValue)*getNumber (_cfg >> "vehicleMultiplier"),_family];
    };
} forEach [["GROUND",{_this isKindOf "Car"}],["ARMOR",{_this isKindOf "Tank"}],["HELI",{_this isKindOf "Helicopter"}],["PLANE",{_this isKindOf "Plane"}],["BOAT",{_this isKindOf "Ship"}]];
while {count _stock<6 && {_vehicles isNotEqualTo []}} do {
    private _class=_vehicles deleteAt floor random count _vehicles;
    _stock pushBack ["VEHICLE",_class,"CfgVehicles",([_class] call DSDS_fnc_vehicleValue)*getNumber (_cfg >> "vehicleMultiplier"),""];
};
private _selected=[];private _modded=0;
private _count=getNumber (_cfg >> "gearOffers");
private _target=getNumber (_cfg >> "moddedOffers");
private _take={
    params ["_category",["_preferModded",true]];
    private _candidates=(DSDS_fenceItemPools getOrDefault [_category,[]]) select {!((_x select 0) in _selected)};
    if (_preferModded) then {private _mods=_candidates select {_x select 2};if (_mods isNotEqualTo []) then {_candidates=_mods;};};
    if (_candidates isEqualTo []) exitWith {false};
    private _entry=selectRandom _candidates;
    _entry params ["_class","_section","_isModded"];
    _selected pushBack _class;if (_isModded) then {_modded=_modded+1;};
    _stock pushBack ["GEAR",_class,_section,([_class,_section] call DSDS_fnc_fencePrice)*getNumber (_cfg >> "gearMultiplier"),_category];
    true
};
// Missing optional mods/categories yield their slots to the remaining valid pools.
{if (count _selected<_count) then {[_x,true] call _take;};} forEach ["FPV","FPV","UAV","TERMINAL","AA","AA"];
while {count _selected<_count} do {
    private _all=[];
    { _all append ((DSDS_fenceItemPools get _x) select {!((_x select 0) in _selected)}); } forEach keys DSDS_fenceItemPools;
    if (_modded<_target) then {private _mods=_all select {_x select 2};if (_mods isNotEqualTo []) then {_all=_mods;};};
    if (_all isEqualTo []) exitWith {};
    private _entry=selectRandom _all;
    private _role=(DSDS_fenceItemRoles get ((_entry select 1)+":"+(_entry select 0))) select 0;
    // The filler candidate was already chosen with the quota in mind.
    _entry params ["_class","_section","_isModded"];
    _selected pushBack _class;if (_isModded) then {_modded=_modded+1;};
    _stock pushBack ["GEAR",_class,_section,([_class,_section] call DSDS_fnc_fencePrice)*getNumber (_cfg >> "gearMultiplier"),_role];
};
diag_log format ["[DSDS Fence] Stock: %1 vehicles, %2 items (%3 modded).",count (_stock select {_x select 0=="VEHICLE"}),count _selected,_modded];
_stock
