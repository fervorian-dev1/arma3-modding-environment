params ["_hq",["_war",missionNamespace getVariable ["tierWar",1]]];
if (!isServer || {isRemoteExecuted}) exitWith {createHashMap};
private _faction = missionNamespace getVariable ["A3A_faction_occ",createHashMap];
private _side = missionNamespace getVariable ["Occupants",sideUnknown];
if (_side == sideUnknown || {count _faction == 0}) exitWith {createHashMap};
private _tier = if (_war < 5) then {0} else {if (_war < 8) then {1} else {2}};
private _validUnit = {
    params ["_type"];
    _type isEqualType "" && {_type != ""} && {isClass (configFile >> "CfgVehicles" >> _type) || {!isNil "A3A_customUnitTypes" && {(_type call {A3A_customUnitTypes getVariable [_this,[]]}) isNotEqualTo []}}}
};
private _role = {
    params ["_key"];
    private _value = _faction getOrDefault [_key,""];
    if (_value isEqualType []) then {_value = _value param [_tier,""];};
    if ([_value] call _validUnit) then {_value} else {""}
};
private _rifle = ["unitRifle"] call _role;
if (_rifle == "") exitWith {diag_log "[DSDS HQ] Occupier has no valid rifleman template; raid cancelled."; createHashMap};
private _pilot = ["unitPilot"] call _role; if (_pilot == "") then {_pilot = _rifle;};
private _crew = ["unitCrew"] call _role; if (_crew == "") then {_crew = _rifle;};
private _squads = [];
{
    private _squad = _x param [_tier,[]];
    if (_squad isEqualType []) then {_squads append (_squad select {[_x] call _validUnit});};
} forEach (_faction getOrDefault ["groupsTierAirborne",[]]);
if (_squads isEqualTo []) then {_squads = [_rifle];};
private _helis = ((_faction getOrDefault ["vehiclesHelisTransport",[]]) + (_faction getOrDefault ["vehiclesHelisLight",[]])) select {
    isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "Helicopter"} && {getNumber (configFile >> "CfgVehicles" >> _x >> "transportSoldier") >= 6}
};
if (_helis isEqualTo []) exitWith {diag_log "[DSDS HQ] Occupier has no transport helicopter with six cargo seats; no faction substitution."; createHashMap};
private _men = if (_war <= 3) then {20 + floor random 6} else {if (_war <= 6) then {30 + floor random 6} else {40 + floor random 11}};
private _vehicleCount = if (_war <= 3) then {1 + floor random 2} else {if (_war <= 6) then {2 + floor random 2} else {3 + floor random 3}};
private _bearing = random 360;
private _bases = (missionNamespace getVariable ["airportsX",[]]) select {!isNil "sidesX" && {sidesX getVariable [_x,sideUnknown] == _side}};
if (_bases isNotEqualTo []) then {private _nearest = [_bases,_hq] call BIS_fnc_nearestPosition; _bearing = _hq getDir markerPos _nearest;};
private _hidden = {
    params ["_position","_minimum"];
    (allPlayers findIf {alive _x && {_x distance2D _position < _minimum || {_x distance2D _position < 3000 && {([objNull,"VIEW"] checkVisibility [eyePos _x,ATLToASL (_position vectorAdd [0,0,2])]) > 0.1}}}}) == -1
};
private _walkable = {
    params ["_from"];
    private _ok = true;
    for "_j" from 0 to 20 do {if (surfaceIsWater (_from vectorAdd ((_hq vectorDiff _from) vectorMultiply (_j/20)))) exitWith {_ok = false;};};
    _ok
};
private _flights = []; private _pads = []; private _remaining = _men;
for "_i" from 0 to 9 do {
    if (_remaining <= 0) exitWith {};
    private _class = selectRandom _helis;
    private _capacity = (getNumber (configFile >> "CfgVehicles" >> _class >> "transportSoldier")) min (DSDS_raidConfig get "transportLoad");
    private _landing = [];
    for "_try" from 1 to 30 do {
        private _blacklist = _pads apply {[_x,90]};
        private _pos = [_hq,DSDS_raidConfig get "landingMin",DSDS_raidConfig get "landingMax",25,0,0.15,0,_blacklist,[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
        if ((_pos select 0) > 20 && {_pos distance2D _hq >= DSDS_raidConfig get "landingMin"} && {_pos distance2D _hq <= DSDS_raidConfig get "landingMax"} && {!surfaceIsWater _pos} && {[_pos] call _walkable} && {(_pads findIf {_x distance2D _pos < 90}) < 0}) exitWith {_landing = [_pos select 0,_pos select 1,0];};
    };
    if (_landing isEqualTo []) exitWith {};
    private _spawn = _landing getPos [DSDS_raidConfig get "approachDistance",_bearing + (_i - 2)*8]; _spawn set [2,180 + 30*(_i mod 3)];
    if (!([_spawn,1800] call _hidden)) exitWith {};
    private _count = _remaining min _capacity;
    _flights pushBack [_class,_landing,_spawn,_count]; _pads pushBack _landing; _remaining = _remaining - _count;
};
if (_remaining > 0) exitWith {diag_log "[DSDS HQ] Could not plan enough safe landing zones/hidden approaches; raid cancelled."; createHashMap};
private _trucks = _faction getOrDefault ["vehiclesTrucks",[]];
private _cars = _faction getOrDefault ["vehiclesLightUnarmed",[]];
private _armed = if (_war >= 4) then {_faction getOrDefault ["vehiclesLightArmed",[]]} else {_faction getOrDefault ["vehiclesMilitiaLightArmed",[]]};
private _groundTypes = (_trucks + _cars + _armed) select {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "LandVehicle"} && {!(_x isKindOf "Tank")} && {(_x in _trucks) || {getNumber (configFile >> "CfgVehicles" >> _x >> "armor") < 180}}};
private _ground = [];
private _roads = (_hq nearRoads 3000) select {_x distance2D _hq > 1600};
for "_i" from 1 to _vehicleCount do {
    if (_groundTypes isEqualTo []) exitWith {};
    private _position = [];
    for "_try" from 1 to 40 do {
        private _pos = if (_roads isNotEqualTo []) then {getPosATL selectRandom _roads} else {[_hq,1800,2800,8,0,0.3,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos};
        if ((_pos select 0) > 20 && {!surfaceIsWater _pos} && {[_pos] call _walkable} && {[_pos,1200] call _hidden} && {(_ground findIf {(_x select 1) distance2D _pos < 60}) < 0}) exitWith {_position = _pos;};
    };
    if (_position isNotEqualTo []) then {_ground pushBack [selectRandom _groundTypes,_position];};
};
createHashMapFromArray [["side",_side],["men",_men],["flights",_flights],["ground",_ground],["pilot",_pilot],["crew",_crew],["troops",_squads],["war",_war]]
