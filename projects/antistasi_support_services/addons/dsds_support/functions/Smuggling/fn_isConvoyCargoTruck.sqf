params ["_class",["_side",missionNamespace getVariable ["Occupants",west]]];
private _cfg=configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg || {!(_class isKindOf "Car")} || {getNumber (_cfg >> "maximumLoad")<900} || {getNumber (_cfg >> "transportAmmo")>0} || {getNumber (_cfg >> "transportFuel")>0} || {getNumber (_cfg >> "transportRepair")>0}) exitWith {false};
private _faction=missionNamespace getVariable [if (_side==missionNamespace getVariable ["Invaders",east]) then {"A3A_faction_inv"} else {"A3A_faction_occ"},createHashMap];
!(_class in ((_faction getOrDefault ["vehiclesAmmoTrucks",[]])+(_faction getOrDefault ["vehiclesFuelTrucks",[]])+(_faction getOrDefault ["vehiclesRepairTrucks",[]])))
