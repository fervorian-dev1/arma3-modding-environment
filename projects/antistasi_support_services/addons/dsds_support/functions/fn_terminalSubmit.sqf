private _display = findDisplay 88400;
private _combo = _display displayCtrl 1750;
if ((_display getVariable ["DSDS_mode",""])=="TRAVEL") exitWith {
 private _friends=_display getVariable ["DSDS_travelFriends",[]];private _i=lbCurSel _combo;
 if (_i>=0 && {_i<count _friends}) then {["TRAVEL",player,[_friends select _i]] remoteExecCall ["DSDS_fnc_serverRequest",2];closeDialog 0;};
};
if ((_display getVariable ["DSDS_mode","SUPPORT"]) == "DEALER") exitWith {
    private _vehicles = _display getVariable ["DSDS_vehicles",[]];
    private _index = lbCurSel _combo;
    if (_index < 0 || {_index >= count _vehicles}) exitWith {};
    private _vehicle = _vehicles select _index;
    private _quote = _display getVariable ["DSDS_quote",[]];
    [if (_quote isEqualTo []) then {"QUOTE"} else {"SELL"},player,[_vehicle]] remoteExecCall ["DSDS_fnc_serverRequest",2];
};
private _origin = _display getVariable ["DSDS_origin",[]];
private _destination = _display getVariable ["DSDS_destination",[]];
if (_origin isEqualTo [] || {_destination isEqualTo []}) exitWith {hint "Select the required target/run points first.";};
private _id = _combo lbData (lbCurSel _combo);
["SUPPORT",player,[_id,_origin,_destination]] remoteExecCall ["DSDS_fnc_serverRequest",2];
closeDialog 0;
