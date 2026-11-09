if (isMultiplayer && {isRemoteExecuted} && {remoteExecutedOwner!=2}) exitWith {};
params ["_op","_unit","_args"];
if (!hasInterface || {_unit!=player} || {!local _unit}) exitWith {};
if (_op=="MESSAGE") exitWith {_unit setVariable ["DSDS_lootBusy",0];systemChat (_args select 0);};
if (_op=="RESCUE_TAKE") exitWith {
 _args params [["_token","",[""]],["_class","DSDS_Adrenaline",[""]]];
 private _ok=[_unit,_token,_class] call DSDS_fnc_lootRescueTake;
 ["RESCUE_ACK",_unit,[_token,_ok]] remoteExecCall ["DSDS_fnc_lootRequest",2];
};
if (_op!="TAKE" || {!alive _unit}) exitWith {};
_args params ["_token","_class"];
if (_token==(_unit getVariable ["DSDS_lootLastToken",""])) exitWith {};
_unit setVariable ["DSDS_lootLastToken",_token];
private _before={_x==_class} count items _unit;
private _ok=false;
if (_before>0 && {isNull objectParent _unit} && {lifeState _unit!="INCAPACITATED"}) then {
    _unit removeItem _class;
    _ok=({_x==_class} count items _unit)==_before-1;
};
_unit setVariable ["DSDS_lootBusy",diag_tickTime+1];
["ACK",_unit,[_token,_ok]] remoteExecCall ["DSDS_fnc_lootRequest",2];
