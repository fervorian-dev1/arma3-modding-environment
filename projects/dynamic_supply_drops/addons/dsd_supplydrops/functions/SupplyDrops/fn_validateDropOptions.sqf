/* Return [error message, normalized options]. Never silently substitute invalid user classes. */
params [["_options", [], [[]]]];
if (count _options != 6) exitWith {["Invalid option count.", []]};
_options params ["_crate", "_aircraft", "_count", "_altitude", "_distance", "_smoke"];
if (!(_crate isEqualType "") || {!(_aircraft isEqualType "")} || {!(_smoke isEqualType true)}) exitWith {["Invalid option types.", []]};
if (([_count, _altitude, _distance] findIf {!(_x isEqualType 0) || {!finite _x}}) != -1) exitWith {["Numeric options must be finite numbers.", []]};
private _cfg = configFile >> "CfgVehicles";
if (!isClass (_cfg >> _crate) || {!(_crate isKindOf "ReammoBox_F")} || {getNumber (_cfg >> _crate >> "maximumLoad") <= 0}) exitWith {["Crate must be an existing ammo box with cargo capacity.", []]};
if (!isClass (_cfg >> _aircraft) || {!(_aircraft isKindOf "Air")} || {getNumber (_cfg >> _aircraft >> "isUav") == 1}) exitWith {["Aircraft must be an existing crewed aircraft.", []]};
private _crew = getText (_cfg >> _aircraft >> "crew");
if (!isClass (_cfg >> _crew)) exitWith {["Aircraft has no valid configured pilot.", []]};
if (!isClass (_cfg >> "B_Parachute_02_F")) exitWith {["Cargo parachute class unavailable.", []]};
if (_count < 20 || {_count > 100} || {_altitude < 150} || {_altitude > 1000} || {_distance < 2000} || {_distance > 8000}) exitWith {["Options outside supported limits (20-100 selections, 150-1000m altitude, 2000-8000m approach).", []]};
["", [_crate, _aircraft, round _count, _altitude, _distance, _smoke]]
