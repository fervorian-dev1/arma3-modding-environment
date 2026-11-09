params ["_side","_profile"];
private _native=missionNamespace getVariable [if (_side==missionNamespace getVariable ["Invaders",east]) then {"A3A_faction_inv"} else {"A3A_faction_occ"},createHashMap];
private _pool=(_native getOrDefault ["vehiclesLightArmed",[]])+(_native getOrDefault ["vehiclesMilitiaLightArmed",[]]);
if (_profile get "armor") then {{_pool append (_native getOrDefault [_x,[]]);} forEach ["vehiclesAPCs","vehiclesIFVs","vehiclesLightAPCs"];};
if (_profile get "heavy") then {{_pool append (_native getOrDefault [_x,[]]);} forEach ["vehiclesTanks","vehiclesLightTanks"];};
_pool=_pool select {_x isEqualType "" && {_x isKindOf "LandVehicle"}};
if (_pool isEqualTo []) then {_pool=[_side] call DSDS_fnc_convoyCargoTrucks;};
_pool
