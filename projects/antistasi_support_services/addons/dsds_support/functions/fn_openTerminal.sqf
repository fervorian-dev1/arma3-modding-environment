params [["_mode","SUPPORT"]];
if (!hasInterface || {!alive player}) exitWith {};
if (_mode == "SUPPORT" && {!("DSDS_SupportTerminal" in assignedItems player)}) exitWith {hint "Equip your Support Terminal in the GPS slot.";};
if (_mode == "DEALER" && {isNull DSDS_mechanic || {player distance DSDS_mechanic > 6}}) exitWith {};
disableSerialization;
if (!createDialog "DSDS_SupportTerminalDialog") exitWith {hint "Support menu could not open. Check that Antistasi Support Services is enabled."; diag_log "[DSDS] Failed to create support/dealer dialog.";};
private _display = findDisplay 88400;
_display setVariable ["DSDS_mode",_mode];
private _combo = _display displayCtrl 1750;
lbClear _combo;
if (_mode=="TRAVEL") exitWith {
 (_display displayCtrl 100) ctrlSetText "Travel to friendlies | 350 credits";
 (_display displayCtrl 1000) ctrlShow false;(_display displayCtrl 1711) ctrlShow false;
 (_display displayCtrl 1712) ctrlSetText "Travel";
 private _friends=allUnits select {_x!=player && {side group _x==side group player} && {[_x] call DSDS_fnc_travelSafe}};
 _display setVariable ["DSDS_travelFriends",_friends];
 {private _i=_combo lbAdd format ["%1 | %2",name _x,mapGridPosition _x];_combo lbSetValue [_i,_forEachIndex];} forEach _friends;
 (_display displayCtrl 1701) ctrlSetText "Cargo-plane insertion near the selected friendly. Both players must be outside combat; no hostile troops within 150 m. Your backpack is retained.";
 (_display displayCtrl 1751) ctrlSetText "Cost: 350 personal credits";
 if (_friends isEqualTo []) then {(_display displayCtrl 1712) ctrlEnable false;};
 _combo lbSetCurSel 0;
};
if (_mode == "SUPPORT") then {
    {
        _x params ["_id","_label","_cost"];
        private _index = _combo lbAdd format ["%1 | %2 credits",_label,_cost];
        _combo lbSetData [_index,_id];
    } forEach ([] call DSDS_fnc_serviceCatalogue);
} else {
    (_display displayCtrl 100) ctrlSetText "PMC Mechanic | Vehicle Dealer";
    private _vehicles = (nearestObjects [DSDS_mechanic,["AllVehicles"],100]) select {!(_x isKindOf "Man") && {_x != DSDS_mechanic}};
    _display setVariable ["DSDS_vehicles",_vehicles];
    {
        private _index = _combo lbAdd format ["%1 (%2 m)",getText (configOf _x >> "displayName"),round (_x distance DSDS_mechanic)];
        _combo lbSetValue [_index,_forEachIndex];
    } forEach _vehicles;
    (_display displayCtrl 1000) ctrlShow false;
    (_display displayCtrl 1711) ctrlShow false;
    if (_vehicles isEqualTo []) then {
        (_display displayCtrl 1701) ctrlSetText "No vehicles within 100 m. Bring a vehicle near the mechanic and reopen this menu.";
        (_display displayCtrl 1712) ctrlEnable false;
    };
};
_combo lbSetCurSel 0;
