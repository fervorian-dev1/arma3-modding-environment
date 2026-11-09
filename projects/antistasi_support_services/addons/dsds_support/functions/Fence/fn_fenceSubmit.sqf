params ["_operation"];
disableSerialization;
private _display=findDisplay 88410;
if (isNull _display) exitWith {};
private _control=_display displayCtrl 1750;
private _row=lbCurSel _control;
if (_operation=="BUY" && {_row<0}) exitWith {};
private _args=[];
if (_operation=="BUY") then {_args=[_display getVariable ["DSDS_generation",-1],_control lbValue _row];};
if (_operation == "SELL") then {
    private _quote=_display getVariable ["DSDS_sellQuote",[]];
    if (_quote isEqualTo []) then {_operation="QUOTE";} else {_args=_quote;_display setVariable ["DSDS_sellQuote",[]];};
    (_display displayCtrl 1713) ctrlSetText "Quote valuables / confirm sale";
};
[_operation,player,_args] remoteExecCall ["DSDS_fnc_fenceRequest",2];
if (_operation=="STASH") then {closeDialog 0;};
