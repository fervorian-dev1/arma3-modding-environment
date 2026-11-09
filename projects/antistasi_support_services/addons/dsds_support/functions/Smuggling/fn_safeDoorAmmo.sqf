/* Only small-arms kinetic bullets: no HE, rockets, missiles, grenades or cannon rounds. */
params ["_magazine"];
private _cfg=configFile >> "CfgMagazines" >> _magazine;
if (!isClass _cfg) exitWith {false};
private _ammo=configFile >> "CfgAmmo" >> getText (_cfg >> "ammo");
isClass _ammo && {toLower getText (_ammo >> "simulation")=="shotbullet"} && {getNumber (_ammo >> "indirectHit")==0} && {getNumber (_ammo >> "indirectHitRange")==0} && {getNumber (_ammo >> "explosive")==0} && {getNumber (_ammo >> "hit")>0} && {getNumber (_ammo >> "hit")<=35}
