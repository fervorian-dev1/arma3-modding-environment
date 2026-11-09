params ["_control","_index"];
private _display = ctrlParent _control;
_display setVariable ["DSDS_origin",[]];
_display setVariable ["DSDS_destination",[]];
_display setVariable ["DSDS_quote",[]];
{deleteMarkerLocal _x;} forEach (_display getVariable ["DSDS_markers",[]]);
_display setVariable ["DSDS_markers",[]];
if ((_display getVariable ["DSDS_mode","SUPPORT"]) == "DEALER") exitWith {
    (_display displayCtrl 1712) ctrlSetText "Get offer";
    (_display displayCtrl 1701) ctrlSetText "Choose an unoccupied vehicle within 100 m. Value reflects its class, weapons, armor, utility and condition. Other players' personal vehicles are protected.";
    (_display displayCtrl 1751) ctrlSetText "Personal credit payment";
};
private _id = _control lbData _index;
private _catalogue = [] call DSDS_fnc_serviceCatalogue;
private _entry = _catalogue select {(_x select 0) == _id};
if (_entry isEqualTo []) exitWith {};
(_entry select 0) params ["","","_cost","_points"];
(_display displayCtrl 1751) ctrlSetText format ["Cost: %1 personal credits",_cost];
(_display displayCtrl 1701) ctrlSetText (if (_id == "PARADROP") then {"Click your landing destination, then request transport. You will board from your current location and parachute at the destination. Your backpack stays with you."} else {if (_points == 1) then {"Click the target on the map, then request support."} else {"Click the start of the support run, then its destination/target. Request support to confirm payment."}});
