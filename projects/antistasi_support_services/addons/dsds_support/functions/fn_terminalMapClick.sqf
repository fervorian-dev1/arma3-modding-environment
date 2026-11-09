params ["_map","_button","_xPos","_yPos"];
if (_button != 0) exitWith {false};
private _display = ctrlParent _map;
if ((_display getVariable ["DSDS_mode","SUPPORT"]) != "SUPPORT") exitWith {false};
private _position = [_map ctrlMapScreenToWorld [_xPos,_yPos]] call DSDS_fnc_validateServicePosition;
if (_position isEqualTo []) exitWith {true};
private _combo = _display displayCtrl 1750;
private _id = _combo lbData (lbCurSel _combo);
private _points = getNumber (configFile >> "DSDS_SupportActions" >> _id >> "points");
private _origin = _display getVariable ["DSDS_origin",[]];
if (_origin isEqualTo [] || {(_display getVariable ["DSDS_destination",[]]) isNotEqualTo []}) then {
    {deleteMarkerLocal _x;} forEach (_display getVariable ["DSDS_markers",[]]);
    _display setVariable ["DSDS_origin",_position];
    _display setVariable ["DSDS_destination",if (_points == 1) then {_position} else {[]}];
    private _name = "DSDS_local_origin";
    createMarkerLocal [_name,_position]; _name setMarkerTypeLocal "hd_start";
    _display setVariable ["DSDS_markers",[_name]];
} else {
    _display setVariable ["DSDS_destination",_position];
    private _name = "DSDS_local_target";
    createMarkerLocal [_name,_position]; _name setMarkerTypeLocal "hd_destroy";
    (_display getVariable ["DSDS_markers",[]]) pushBack _name;
};
true
