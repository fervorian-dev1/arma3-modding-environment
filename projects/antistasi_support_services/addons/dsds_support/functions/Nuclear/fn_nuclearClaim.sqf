/* Called only by the authenticated Mystic transaction, never exposed as RPC. */
params ["_actor"];
if (!isServer || {isNil "_dsdsAuthorizedPlayer"} || {_dsdsAuthorizedPlayer!=_actor}) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if (!(_s getOrDefault ["ready",false]) || {(_s getOrDefault ["rewardState",""])!=""} || {(_actor getVariable ["DSDS_mysticPending",""])!=""} || {isNil "zen_modules_fnc_moduleNukeLocal"}) exitWith {false};
private _uid=getPlayerUID _actor;if (_uid=="") then {_uid=_actor getVariable ["DSDS_testUID",""];};
if (_uid=="" || {!alive _actor}) exitWith {false};
_s set ["rewardState","armed"];_s set ["rewardUID",_uid];DSDS_nuclearWearer=_actor;
_actor setVariable ["DSDS_nuclearVest",true,true];
[] call DSDS_fnc_nuclearTick;[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;
["MESSAGE",["Mystic: Stay still, child. Surrender doubt. Surrender fear. Surrender yourself. Embrace your enemy."]] remoteExecCall ["DSDS_fnc_mysticClient",_actor];
true
