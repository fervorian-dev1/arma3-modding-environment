if (isRemoteExecuted && {remoteExecutedOwner!=2}) exitWith {};
if (!hasInterface) exitWith {};
params ["_op",["_args",[]]];
if (_op=="MESSAGE") exitWith {systemChat (_args select 0);};
if (_op=="OPEN") exitWith {[_args param [0,false]] spawn DSDS_fnc_mysticOpen;};
