params ["_jobID","_fulfilled",["_reason",""]];
if (isRemoteExecuted && {isNil "_dsdsContractJob" || {_dsdsContractJob != _jobID}}) exitWith {false};
if (!isServer || {isNil {DSDS_jobs get _jobID}}) exitWith {false};
private _job = DSDS_jobs get _jobID;
if ((_job get "state") in ["fulfilled","refunded"]) exitWith {false};
if (_fulfilled) then {_job set ["state","fulfilled"];} else {
    _job set ["state","refunded"];
    private _holder = _job get "holder";
    if (!isNull _holder) then {
        _holder setVariable ["moneyX",(_holder getVariable ["moneyX",0]) + (_job get "cost"),true];
    } else {
        if (!isNil "A3A_playerSaveData") then {
            private _uid = _job getOrDefault ["uid",""];
            private _data = A3A_playerSaveData getOrDefault [_uid,createHashMap];
            _data set ["moneyX",(_data getOrDefault ["moneyX",_job getOrDefault ["balanceAfter",0]]) + (_job get "cost")];
            A3A_playerSaveData set [_uid,_data];
        };
    };
    ["MESSAGE",["Support could not deploy; your credits were returned. " + _reason]] remoteExecCall ["DSDS_fnc_clientService",_job get "player"];
};
diag_log format ["[DSDS] Contract %1: %2 (%3)",_jobID,_job get "state",_reason];
true
