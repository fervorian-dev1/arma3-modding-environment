/* Manifest includes nested container contents, weapon attachments and loaded rounds. */
params ["_box"];
private _manifest=[];private _value=0;private _unsupported=[];
private _add={
    params ["_class","_section","_count"];
    if (_class != "" && {_count >= 0}) then {
        _manifest pushBack [_class,_section,_count];
        private _price=[_class,_section,true] call DSDS_fnc_fencePrice;
        if (_price <= 0) then {_unsupported pushBackUnique _class;};
        _value=_value+_price*_count;
    };
};
private _walk={
    params ["_container"];
    {
        private _weapon=_x;
        [_weapon param [0,""],"CfgWeapons",1] call _add;
        {[_weapon param [_x,""],"CfgWeapons",1] call _add;} forEach [1,2,3,6];
        {private _mag=_weapon param [_x,[]];if (count _mag >= 2) then {private _max=getNumber (configFile >> "CfgMagazines" >> (_mag select 0) >> "count");[_mag select 0,"CfgMagazines",((_mag select 1)/(_max max 1)) min 1] call _add;};} forEach [4,5];
    } forEach weaponsItemsCargo _container;
    {private _max=getNumber (configFile >> "CfgMagazines" >> (_x select 0) >> "count");[_x select 0,"CfgMagazines",((_x select 1)/(_max max 1)) min 1] call _add;} forEach magazinesAmmoCargo _container;
    private _items=getItemCargo _container;
    {[_x,"CfgWeapons",(_items select 1) select _forEachIndex] call _add;} forEach (_items select 0);
    private _packs=getBackpackCargo _container;
    {[_x,"CfgVehicles",(_packs select 1) select _forEachIndex] call _add;} forEach (_packs select 0);
    {[_x select 1] call _walk;} forEach everyContainer _container;
};
[_box] call _walk;
[_value,_manifest,_unsupported]
