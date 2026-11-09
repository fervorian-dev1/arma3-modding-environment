if (!isServer) exitWith {};
params [["_op","",[""]],["_actor",objNull,[objNull]],["_args",[],[[]]]];
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isNull _actor || {!isPlayer _actor} || {owner _actor!=_sender} || {!(missionNamespace getVariable ["serverInitDone",false])}) exitWith {};
if (_op=="ACK") exitWith {
 _args params [["_token","",[""]],["_ok",false,[true]]];
 private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
 private _entry=(_s getOrDefault ["trades",createHashMap]) getOrDefault [_token,[]];
 if (count _entry>0 && {(_entry select 1)==_actor}) then {[_token,_ok] spawn {params ["_token","_ok"];private _dsdsMysticFinishAuthorized=true;[_token,_ok] call DSDS_fnc_mysticFinishTrade;};};
};
if (!alive _actor || {!(side group _actor in [missionNamespace getVariable ["teamPlayer",resistance],civilian])}) exitWith {};
if (diag_tickTime<(_actor getVariable ["DSDS_mysticRate",0])) exitWith {};
_actor setVariable ["DSDS_mysticRate",diag_tickTime+0.35];
private _dsdsAuthorizedPlayer=_actor;
[_op,_actor,_args] call DSDS_fnc_mysticTransaction;
