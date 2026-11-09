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
