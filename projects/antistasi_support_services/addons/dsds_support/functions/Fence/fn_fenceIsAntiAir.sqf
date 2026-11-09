/* Portable guided AA uses actual ammo airLock. Vehicles also include configured AA guns. */
params ["_class",["_section","CfgWeapons"]];
if (isNil "DSDS_fenceAACache") then {DSDS_fenceAACache=createHashMap;};
private _key=_section+":"+_class;
if (_key in DSDS_fenceAACache) exitWith {DSDS_fenceAACache get _key};
private _magAA={
    params ["_mag"];
    private _ammo=configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
    toLower getText (_ammo >> "simulation") == "shotmissile" && {getNumber (_ammo >> "airLock")>0} && {getNumber (_ammo >> "groundLock")==0}
};
private _answer=false;
switch (_section) do {
    case "CfgMagazines": {_answer=[_class] call _magAA;};
    case "CfgWeapons": {
        private _cfg=configFile >> "CfgWeapons" >> _class;
        private _purpose=toLower getText (_cfg >> "descriptionShort");
        // RHS's Javelin inherits Titan AA behaviour despite explicitly identifying
        // itself as anti-tank. Respect the asset's declared purpose first.
        if (["anti-tank","antitank","anti tank"] findIf {(_purpose find _x)>=0}>=0) exitWith {};
        // Classify the weapon's intended ammo, not universal magazine-well patches
        // that can make an AT launcher technically accept an AA missile.
        private _magazines=getArray (_cfg >> "magazines");
        if (_magazines isEqualTo []) then {_magazines=compatibleMagazines [_class,"this"];};
        _answer=(_magazines findIf {[_x] call _magAA})>=0;
    };
    case "CfgVehicles": {
        if (_class isKindOf "LandVehicle") then {
            private _cfg=configFile >> "CfgVehicles" >> _class;
            private _category=toLower getText (_cfg >> "editorSubcategory");
            _answer=(_category find "antiair")>=0 || {(_category find "_aa")>=0};
            private _walk={
                params ["_cfg"];
                if (getArray (_cfg >> "magazines") findIf {[_x] call _magAA}>=0) then {_answer=true;};
                {[_x] call _walk;} forEach ("true" configClasses (_cfg >> "Turrets"));
            };
            if (!_answer) then {[_cfg] call _walk;};
        };
    };
};
DSDS_fenceAACache set [_key,_answer];
_answer
