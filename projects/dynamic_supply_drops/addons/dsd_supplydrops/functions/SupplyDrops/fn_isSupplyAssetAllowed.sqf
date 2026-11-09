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
