params [["_positionASL", [], [[]]]];
if (!hasInterface || {isNull getAssignedCuratorLogic player}) exitWith {};
private _position = [_positionASL] call DSD_fnc_validateDropPosition;
if (_position isEqualTo []) exitWith {systemChat "[Dynamic Supply Drops] Select dry land inside the map.";};
private _aircraft = "B_Heli_Transport_01_F";
if (isClass (configFile >> "CfgVehicles" >> "RHS_C130J")) then {_aircraft = "RHS_C130J";};
[
    "Spawn Randomized Supply Drop",
    [
        ["EDIT", "Crate classname", ["B_supplyCrate_F"]],
        ["EDIT", "Aircraft classname", [_aircraft]],
        ["SLIDER", ["Unique cargo selections", "DLC-free gear. At least five compatible magazines per unique weapon; shared ammo allowances accumulate."], [20, 100, 50, 0]],
        ["SLIDER", "Drop altitude (metres AGL)", [150, 1000, 300, 0]],
        ["SLIDER", "Approach distance (metres)", [2000, 8000, 4000, 0]],
        ["CHECKBOX", "Smoke on landing", [true]]
    ],
    {
        params ["_values", "_position"];
        ["DSD_request", [player, _position, _values]] call CBA_fnc_serverEvent;
    }, {}, _position, "DSD_supplyOptions_v1"
] call zen_dialog_fnc_create;
