params ["_unit","_weapon","_muzzle","_mode","_ammo","_magazine","_projectile"];
if (!hasInterface || {!local _unit} || {!isPlayer _unit} || {isNil "DSDS_noiseQueue"}) exitWith {};
if (_weapon in ["Throw","Put"]) exitWith {
    if (isNull _projectile || {getNumber (configFile >> "CfgAmmo" >> _ammo >> "indirectHit") <= 0}) exitWith {};
    _projectile setVariable ["DSDS_noiseAmmo",_ammo];
    _projectile addEventHandler ["Explode",{
        params ["_projectile","_position"];
        if (!hasInterface || {isNull player} || {isNil "DSDS_noiseQueue"}) exitWith {};
        private _ammo = _projectile getVariable ["DSDS_noiseAmmo",""];
        private _key = "explosion:" + _ammo + str _position;
        DSDS_noiseQueue set [_key,[_ammo,"",_position,1,"explosion"]];
    }];
};
private _petros = missionNamespace getVariable ["petros",objNull];
if (isNull _petros || {_unit distance2D _petros > getNumber (configFile >> "DSDS_HQRaid" >> "radius")}) exitWith {};
private _suppressor = (_unit weaponAccessories _weapon) param [0,""];
private _position = getPosATL _unit;
private _key = _ammo + _suppressor + str [floor ((_position select 0)/10),floor ((_position select 1)/10)];
private _record = DSDS_noiseQueue getOrDefault [_key,[_ammo,_suppressor,_position,0,"shot"]];
_record set [3,(_record select 3) + 1];
DSDS_noiseQueue set [_key,_record];
