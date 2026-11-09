params ["_side",["_kind","SPECIAL"]];
private _native=missionNamespace getVariable [if (_side==missionNamespace getVariable ["Invaders",east]) then {"A3A_faction_inv"} else {"A3A_faction_occ"},createHashMap];
private _excluded=(_native getOrDefault ["vehiclesAmmoTrucks",[]])+(_native getOrDefault ["vehiclesFuelTrucks",[]])+(_native getOrDefault ["vehiclesRepairTrucks",[]]);
private _trucks=+(_native getOrDefault ["vehiclesTrucks",[]]);
if (_kind in ["ISOTOPE","MEDICAL"]) then {_trucks=(_native getOrDefault ["vehiclesMedical",[]])+_trucks;};
_trucks=(_trucks select {_x isEqualType ""}) arrayIntersect (_trucks select {_x isEqualType ""});
_trucks select {[_x,_side] call DSDS_fnc_isConvoyCargoTruck}
