/* Pure calculation, shared by runtime and fixture. No additive stacking. */
params ["_ends",["_now",serverTime]];
_ends params ["_weedEnd","_vapeEnd","_cocaineEnd","_crashEnd","_zynEnd"];
private _cfg=configFile >> "DSDS_Consumables";
private _weed=_weedEnd>_now;private _vape=_vapeEnd>_now;
private _cocaine=_cocaineEnd>_now;private _crash=!_cocaine && {_crashEnd>_now};
private _zyn=_zynEnd>_now;
private _aim=1;private _movement=1;private _regen=1;private _cap=1;
if (_weed) then {_aim=_aim*getNumber (_cfg >> "marijuanaSway");_movement=getNumber (_cfg >> "marijuanaMovement");_cap=getNumber (_cfg >> "marijuanaStamina");};
if (_vape) then {_aim=_aim*getNumber (_cfg >> "vapeSway");_movement=_movement min getNumber (_cfg >> "vapeMovement");_regen=getNumber (_cfg >> "vapeRegen");_cap=_cap min getNumber (_cfg >> "vapeStamina");};
if (_cocaine) then {_aim=_aim*getNumber (_cfg >> "cocaineSway");_regen=_regen max getNumber (_cfg >> "cocaineRegen");};
if (_crash) then {_aim=_aim*getNumber (_cfg >> "crashSway");_movement=_movement min getNumber (_cfg >> "crashMovement");_cap=_cap min getNumber (_cfg >> "crashStamina");_regen=_regen*getNumber (_cfg >> "crashRegen");};
[_aim,_movement,_regen,_cap,_weed,_cocaine,_zyn,_crash]
