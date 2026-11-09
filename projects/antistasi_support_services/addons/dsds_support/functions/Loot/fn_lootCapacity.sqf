/* Server owns physical container capacities; restore dropped/swapped gear promptly. */
params ["_unit",["_active",false]];
if (isRemoteExecuted) exitWith {};
if (!isServer || {isNull _unit}) exitWith {};
private _stim=[_unit] call DSDS_fnc_stimModifiers;
private _zyn=((_unit getVariable ["DSDS_lootEffects",[0,0,0,0,0]]) select 4)>serverTime;
private _factor=(_stim get "carry") max (if (_zyn) then {getNumber (configFile >> "DSDS_Consumables" >> "zynCapacity")} else {1});
// Preserve the old helper's explicit active flag for mission/test callers.
if (_active && {_factor<=1}) then {_factor=getNumber (configFile >> "DSDS_Consumables" >> "zynCapacity");};
private _current=if (_active && {alive _unit}) then {[uniformContainer _unit,vestContainer _unit,backpackContainer _unit] select {!isNull _x}} else {[]};
private _records=_unit getVariable ["DSDS_lootContainers",[]];
private _kept=[];
{
    _x params ["_container","_base","_last"];
    if (!isNull _container) then {
        private _actual=maxLoad _container;
        if (_container in _current) then {
            if (abs (_actual-_last)>0.01) then {_base=_actual;};
            private _next=round (_base*_factor) min 1000000;
            if (_actual!=_next) then {_container setMaxLoad _next;};
            _kept pushBack [_container,_base,_next];
        } else {
            if (abs (_actual-_last)<0.01) then {_container setMaxLoad _base;};
        };
    };
} forEach _records;
{
    private _container=_x;
    if (_kept findIf {(_x select 0)==_container}<0) then {
        private _base=maxLoad _container;
        private _next=round (_base*_factor) min 1000000;
        _container setMaxLoad _next;
        _kept pushBack [_container,_base,_next];
    };
} forEach _current;
_unit setVariable ["DSDS_lootContainers",_kept];
