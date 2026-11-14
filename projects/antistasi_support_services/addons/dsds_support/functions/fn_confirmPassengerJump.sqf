/* Scheduled server helper: require the actual replicated parachute and matching owner outcome. */
params ["_unit","_aircraft","_fallback",["_chuteClass","Steerable_Parachute_F"]];
if (!isServer || {isNull _unit} || {!alive _unit}) exitWith {false};
DSDS_jumpSequence=(missionNamespace getVariable ["DSDS_jumpSequence",0])+1;
private _token=format ["%1:jump:%2",netId _unit,DSDS_jumpSequence];
_unit setVariable ["DSDS_jumpToken",_token,true];_unit setVariable ["DSDS_jumpOutcome",[],true];
[_unit,_aircraft,_token,_fallback,_chuteClass] remoteExecCall ["DSDS_fnc_jumpSupportPassenger",owner _unit];
private _until=diag_tickTime+8;
waitUntil {sleep 0.1;!alive _unit || {((_unit getVariable ["DSDS_jumpOutcome",[]]) param [0,""])==_token} || {diag_tickTime>_until}};
private _result=_unit getVariable ["DSDS_jumpOutcome",[]];
private _ok=alive _unit && {(_result param [0,""])==_token} && {_result param [1,false]};
if (_ok) then {
 _until=diag_tickTime+2;
 waitUntil {sleep 0.05;(vehicle _unit isKindOf "ParachuteBase" && {driver vehicle _unit==_unit}) || {!alive _unit} || {diag_tickTime>_until}};
 _ok=alive _unit && {vehicle _unit isKindOf "ParachuteBase"} && {driver vehicle _unit==_unit};
};
if (!_ok) then {
 _unit setVariable ["DSDS_jumpToken","",true];
 [_unit,_aircraft,_fallback] remoteExecCall ["DSDS_fnc_travelClient",owner _unit];
 diag_log format ["[DSDS Travel] Parachute handoff failed for %1; returning to departure point.",netId _unit];
};
_ok
