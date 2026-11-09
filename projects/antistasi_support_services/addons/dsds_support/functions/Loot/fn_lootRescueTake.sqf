/* Called by the existing server-origin client dispatcher. Also usable locally by owned test actors. */
params ["_unit","_token","_class"];
if (isMultiplayer && {isRemoteExecuted} && {remoteExecutedOwner!=2}) exitWith {false};
if (isNull _unit || {!local _unit} || {!alive _unit} || {!(_class in ["DSDS_Adrenaline","DSDS_Morphine"])}) exitWith {false};
private _receipts=_unit getVariable ["DSDS_autoRescueReceipts",createHashMap];
if (!isNil {_receipts get _token}) exitWith {_receipts get _token};
private _ok=false;
if (([_unit] call DSDS_fnc_lootDownState)>0 && {_class in items _unit} && {serverTime>=(_unit getVariable ["DSDS_autoRescueUntil",0])}) then {
 private _before={_x==_class} count items _unit;
 _unit removeItem _class;_ok=({_x==_class} count items _unit)==_before-1;
 if (_ok) then {_unit setVariable ["DSDS_autoRescueUntil",serverTime+5,true];_ok=[_unit] call DSDS_fnc_lootRecover;};
};
_receipts set [_token,_ok];_unit setVariable ["DSDS_autoRescueReceipts",_receipts];
_ok
