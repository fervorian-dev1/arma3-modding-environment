/* Antistasi's moneyX/owner ledger, executed atomically by the server request handler. */
params ["_player","_delta"];
if (isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer" || {_dsdsAuthorizedPlayer != _player}}) exitWith {false};
if (!isServer || {isNull _player} || {!(_delta isEqualType 0)} || {!finite _delta}) exitWith {false};
private _holder = _player getVariable ["owner",_player];
if (isNull _holder) exitWith {false};
private _balance = _holder getVariable ["moneyX",0];
if (!(_balance isEqualType 0) || {!finite _balance} || {_balance + _delta < 0}) exitWith {false};
_holder setVariable ["moneyX",_balance + _delta,true];
if (_delta != 0) then {
    private _sequence = (_holder getVariable ["DSDS_walletSequence",0]) + 1;
    _holder setVariable ["DSDS_walletSequence",_sequence];
    ["WALLET",[_holder,_balance + _delta,_sequence]] remoteExecCall ["DSDS_fnc_clientService",_player];
    diag_log format ["[DSDS] Personal wallet: delta=%1 before=%2 after=%3 sequence=%4",_delta,_balance,_balance + _delta,_sequence];
};
true
