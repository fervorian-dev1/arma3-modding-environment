/* Validate the actual native route point. Never scatter a convoy off its route. */
params ["_class","_position"];
if (!isClass (configFile >> "CfgVehicles" >> _class) || {count _position<3}) exitWith {false};
if (!isOnRoad _position) exitWith {false};
if ((_position nearEntities [["LandVehicle","Air","Ship"],12]) isNotEqualTo []) exitWith {false};
(_position findEmptyPosition [0,0,_class]) isNotEqualTo []
