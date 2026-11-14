/* Only authenticated Fence/Zeus handlers may enqueue from a remote context. */
params ["_kind","_actor",["_position",[]],["_debug",false]];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer" || {_dsdsAuthorizedPlayer!=_actor}}} || {isNull _actor} || {!alive _actor}) exitWith {false};
private _entry=configFile >> "DSDS_DebugMissions" >> _kind;
if (!isClass _entry || {isNil {missionNamespace getVariable getText (_entry >> "handler")}}) exitWith {false};
private _isStash=_kind in ["STASH","ISOTOPE_STASH"];
if (!_debug && {!_isStash}) exitWith {false};
private _message={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_actor];false};
if (_isStash && {missionNamespace getVariable ["DSDS_stashPending",false]}) exitWith {["A stash lead is already being checked."] call _message};
if (_debug && {!_isStash} && {(_kind find "TOOL_")!=0} && {({!(_x get "complete")} count (values DSDS_debugMissions))+({!((_x select 0) in ["STASH","ISOTOPE_STASH"])} count DSDS_missionQueue)>=3}) exitWith {["Finish an active convoy before requesting another."] call _message};
if (_isStash) then {DSDS_stashPending=true;};
DSDS_missionQueue pushBack [_kind,_actor,_position,_debug];
if (_kind!="CONTAMINATION" && {(_kind find "TOOL_")!=0}) then {[format ["%1: preparing mission; its location will be marked on the map.",getText (_entry >> "displayName")]] call _message;};
true
