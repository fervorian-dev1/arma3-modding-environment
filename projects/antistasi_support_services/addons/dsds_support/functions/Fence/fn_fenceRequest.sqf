if (!isServer) exitWith {};
params [["_operation","",[""]],["_player",objNull,[objNull]],["_args",[],[[]]]];
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isNull _player || {!isPlayer _player} || {!alive _player} || {owner _player != _sender} || {!(missionNamespace getVariable ["serverInitDone",false])} || {isNil "teamPlayer"} || {!(side group _player in [teamPlayer,civilian])}) exitWith {diag_log "[DSDS Fence] Rejected unauthorized request.";};
if (diag_tickTime < (_player getVariable ["DSDS_fenceRate",0])) exitWith {};
_player setVariable ["DSDS_fenceRate",diag_tickTime+0.5];
private _dsdsAuthorizedPlayer=_player;
[_operation,_player,_args] call DSDS_fnc_fenceTransaction;
