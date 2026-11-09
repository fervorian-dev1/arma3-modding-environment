params [["_theme","",[""]]];
private _entries="true" configClasses (configFile >> "DSDS_SpecialCargo");
if (_entries isEqualTo []) exitWith {[]};
private _cfg=configFile >> "DSDS_SpecialCargo" >> _theme;
if (_theme=="" || {!isClass _cfg}) then {_cfg=selectRandom _entries;};
private _items=getArray (_cfg >> "items") select {isClass (configFile >> "CfgWeapons" >> _x) && {[_x,"CfgWeapons"] call DSD_fnc_isSupplyAssetAllowed}};
[configName _cfg,getText (_cfg >> "label"),_items]
