params ["_heli"];
if (!isServer || {isRemoteExecuted} || {isNull _heli} || {!(_heli isKindOf "Helicopter")} || {(crew _heli findIf {isPlayer _x})>=0}) exitWith {false};
{_heli setPylonLoadout [_x select 0,"",true];} forEach getAllPylonsInfo _heli;
private _armed=false;
{
 private _path=_x;
 private _cfg=[typeOf _heli,_path] call BIS_fnc_turretConfig;
 private _allowed=if (_path isEqualTo [-1] || {getNumber (_cfg >> "isCopilot")>0} || {getNumber (_cfg >> "stabilizedInAxes")>0}) then {[]} else {(_heli magazinesTurret _path) select {[_x] call DSDS_fnc_safeDoorAmmo}};
 {if (!(_x in _allowed)) then {_heli removeMagazinesTurret [_x,_path];};} forEach (_heli magazinesTurret _path);
 {
  private _compatible=compatibleMagazines [_x,"this"];
  if ((_compatible arrayIntersect _allowed) isEqualTo []) then {_heli removeWeaponTurret [_x,_path];};
 } forEach (_heli weaponsTurret _path);
 private _gunner=_heli turretUnit _path;
 private _loaded=(magazinesAllTurrets _heli) findIf {(_x select 1) isEqualTo _path && {(_x select 2)>0} && {(_x select 0) in _allowed}};
 if (_loaded>=0 && {(_heli weaponsTurret _path) isNotEqualTo []} && {!isNull _gunner} && {alive _gunner}) then {_armed=true;};
} forEach ([[-1]]+allTurrets [_heli,false]);
_heli setVariable ["DSDS_doorEscort",true,true];_armed
