params [["_side",missionNamespace getVariable ["Occupants",sideUnknown]]];
private _faction=if (_side==missionNamespace getVariable ["Invaders",sideUnknown]) then {missionNamespace getVariable ["A3A_faction_inv",createHashMap]} else {missionNamespace getVariable ["A3A_faction_occ",createHashMap]};
if (_side==sideUnknown || {count _faction==0}) exitWith {createHashMap};
private _tier=if (missionNamespace getVariable ["tierWar",1]<5) then {0} else {if (tierWar<8) then {1} else {2}};
private _role={params ["_key"];private _v=_faction getOrDefault [_key,""];if (_v isEqualType []) then {_v=_v param [_tier,""];};if !(_v isEqualType "") exitWith {""};if (isClass (configFile >> "CfgVehicles" >> _v) || {!isNil "A3A_customUnitTypes" && {(_v call {A3A_customUnitTypes getVariable [_this,[]]}) isNotEqualTo []}}) then {_v} else {""}};
private _troops=(["unitRifle","unitMG","unitAT","unitMedic","unitGrenadier"] apply {[_x] call _role}) select {_x!=""};
if (_troops isEqualTo []) exitWith {createHashMap};
private _pilot=["unitPilot"] call _role;if (_pilot=="") then {_pilot=_troops select 0;};
private _crew=["unitCrew"] call _role;if (_crew=="") then {_crew=_troops select 0;};
private _helis=(_faction getOrDefault ["vehiclesHelisTransport",[]]) select {_x isEqualType "" && {_x isKindOf "Helicopter"} && {getNumber (configFile >> "CfgVehicles" >> _x >> "transportSoldier")>=6}};
private _scouts=((_faction getOrDefault ["vehiclesHelisLight",[]])+_helis) select {_x isEqualType "" && {_x isKindOf "Helicopter"}};
private _cars=((_faction getOrDefault ["vehiclesLightArmed",[]])+(_faction getOrDefault ["vehiclesMilitiaLightArmed",[]])) select {_x isEqualType "" && {_x isKindOf "Car"}};
private _trucks=(_faction getOrDefault ["vehiclesTrucks",[]]) select {_x isEqualType "" && {_x isKindOf "Car"}};
createHashMapFromArray [["side",_side],["troops",_troops],["pilot",_pilot],["crew",_crew],["helis",_helis],["scouts",_scouts],["cars",_cars],["trucks",_trucks]]
