/* Money/object operations accept requests only from the actual owning player connection. */
if (!isServer) exitWith {};
params [["_operation","",[""]],["_player",objNull,[objNull]],["_args",[],[[]]]];
private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isNull _player || {!isPlayer _player} || {!alive _player} || {owner _player != _sender}) exitWith {diag_log "[DSDS] Rejected invalid/forged player request.";};
if (isNil "teamPlayer" || {!(side group _player in [teamPlayer,civilian])} || {!(missionNamespace getVariable ["serverInitDone",false])}) exitWith {};
private _dsdsAuthorizedPlayer = _player;
[_operation,_player,_args] call DSDS_fnc_serviceTransaction;
