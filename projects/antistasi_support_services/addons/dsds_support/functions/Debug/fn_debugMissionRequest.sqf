/* Curator-owned, whitelisted mission starts only: no arbitrary function/class/price input. */
if (!isServer) exitWith {};
params [["_kind","",[""]],["_actor",objNull,[objNull]],["_position",[],[[]]]];
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isNull _actor || {!isPlayer _actor} || {!alive _actor} || {owner _actor!=_sender} || {isNull getAssignedCuratorLogic _actor} || {!(missionNamespace getVariable ["serverInitDone",false])}) exitWith {diag_log "[DSDS DEBUG] Unauthorized mission request rejected.";};
if (diag_tickTime<(_actor getVariable ["DSDS_debugRate",0])) exitWith {};
private _pos=[_position] call DSD_fnc_validateDropPosition;
if (_pos isEqualTo []) exitWith {["MESSAGE",["Select a dry land location near roads."]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
_actor setVariable ["DSDS_debugRate",diag_tickTime+5];
private _dsdsAuthorizedPlayer=_actor;
[_kind,_actor,ASLToATL _pos,true] call DSDS_fnc_queueCustomMission;
