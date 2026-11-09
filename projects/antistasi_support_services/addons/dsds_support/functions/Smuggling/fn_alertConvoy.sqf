params ["_truck"];
if (!isServer || {isRemoteExecuted} || {isNull _truck}) exitWith {false};
private _id=_truck getVariable ["DSDS_manifestID",""];
private _record=(missionNamespace getVariable ["DSDS_smugglingRecords",createHashMap]) getOrDefault [_id,createHashMap];
if (count _record==0 || {_record get "kind"!="SPECIAL"} || {_record get "alerted"} || {_record get "finished"}) exitWith {false};
_record set ["alerted",true];_record set ["last",getPosATL _truck];
[_record] spawn DSDS_fnc_convoyResponse;
true
