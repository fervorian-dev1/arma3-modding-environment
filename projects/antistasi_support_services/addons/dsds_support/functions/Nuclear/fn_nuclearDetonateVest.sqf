params ["_actor"];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsNuclearDispatch" || {!_dsdsNuclearDispatch}}} || {isNull _actor}) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if ((_s getOrDefault ["rewardState",""])!="armed" || {_actor!=missionNamespace getVariable ["DSDS_nuclearWearer",objNull]} || {!(_actor getVariable ["DSDS_nuclearVest",false])}) exitWith {false};
private _position=getPosASL _actor;
// Consume before dispatch: death caused by this blast cannot recursively detonate it.
_s set ["rewardState","detonating"];
if (!([_position] call DSDS_fnc_nuclearBlast)) exitWith {_s set ["rewardState","armed"];diag_log "[DSDS Mystic] ZEN nuclear dispatch unavailable; reward remains armed.";false};
_s set ["rewardState","detonated"];_s set ["nuclearUnlocked",true];
_actor setVariable ["DSDS_nuclearVest",false,true];
private _prop=missionNamespace getVariable ["DSDS_nuclearChest",objNull];if (!isNull _prop) then {deleteVehicle _prop;};DSDS_nuclearChest=objNull;DSDS_nuclearWearer=objNull;
[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;
true
