params ["_ammo",["_suppressor",""],["_kind","shot"]];
private _cfg = configFile >> "CfgAmmo" >> _ammo;
if (!isClass _cfg) exitWith {0};
private _simulation = toLower getText (_cfg >> "simulation");
if (_kind == "explosion") exitWith {if (getNumber (_cfg >> "indirectHit") > 0) then {40} else {0}};
if (_simulation in ["shotsmokex","shotsmoke","shotilluminating","shotcm","shotmine"] || {(_simulation find "flare") >= 0}) exitWith {0};
if (getNumber (_cfg >> "indirectHit") > 0 || {getNumber (_cfg >> "hit") >= 40}) exitWith {15};
if (!(_simulation in ["shotbullet","shotshell"])) exitWith {0};
private _coef = configFile >> "CfgWeapons" >> _suppressor >> "ItemInfo" >> "AmmoCoef" >> "audibleFire";
if (_suppressor != "" && {isNumber _coef} && {getNumber _coef < 1}) exitWith {0.1};
1
