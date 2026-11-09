params ["_side"];
private _native=missionNamespace getVariable [if (_side==missionNamespace getVariable ["Invaders",east]) then {"A3A_faction_inv"} else {"A3A_faction_occ"},createHashMap];
private _preferred=(_native getOrDefault ["vehiclesHelisTransport",[]]) select {_x isEqualType ""};
private _key=str [_side,_preferred];
if (isNil "DSDS_doorHeliCache") then {DSDS_doorHeliCache=createHashMap;};
if (_key in DSDS_doorHeliCache) exitWith {DSDS_doorHeliCache get _key};
private _valid={
 params ["_class"];private _cfg=configFile >> "CfgVehicles" >> _class;
 if (!(_class isKindOf "Helicopter") || {getNumber (_cfg >> "transportSoldier")<6} || {getNumber (_cfg >> "isUav")>0}) exitWith {false};
 private _mags=[];
 private _walk={params ["_turrets"];{if (getNumber (_x >> "isCopilot")==0 && {getNumber (_x >> "stabilizedInAxes")==0}) then {_mags append getArray (_x >> "magazines");};[_x >> "Turrets"] call _walk;} forEach ("true" configClasses _turrets);};
 [_cfg >> "Turrets"] call _walk;
 (_mags findIf {[_x] call DSDS_fnc_safeDoorAmmo})>=0
};
private _pool=_preferred select {[_x] call _valid};
if (_pool isEqualTo []) then {
 // Prefer the selected template; fall back only to loaded transports on the same side.
 private _sideID=[east,west,resistance,civilian] find _side;
 {_pool pushBack configName _x;} forEach (format ["getNumber (_x >> 'scope')==2 && {getNumber (_x >> 'side')==%1}",_sideID] configClasses (configFile >> "CfgVehicles") select {[configName _x] call _valid});
};
DSDS_doorHeliCache set [_key,_pool];_pool
