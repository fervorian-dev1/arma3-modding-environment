params ["_op"];
if (!hasInterface) exitWith {};
disableSerialization;
private _display=findDisplay 88430;if (isNull _display) exitWith {};
private _args=[];
if (_op=="BUY") then {private _list=_display displayCtrl 1832;private _row=lbCurSel _list;if (_row>=0) then {_args=[_list lbValue _row];};};
[_op,player,_args] remoteExecCall ["DSDS_fnc_mysticRequest",2];
