/* Scheduled, deduplicated retry worker. Never abandon near-player response assets. */
// Observer override is private server test support, never an RPC/UI parameter.
params ["_response",["_serverObservers",[]]];
if (!isServer || {isRemoteExecuted} || {!(_response getOrDefault ["ended",false])} || {_response getOrDefault ["cleanupStarted",false]}) exitWith {};
_response set ["cleanupStarted",true];
while {[_response,if (_serverObservers isEqualTo []) then {allPlayers} else {_serverObservers}] call DSDS_fnc_cleanupContaminationTick} do {sleep 30;};
diag_log format ["[DSDS CBRN] %1 cleanup complete after %2 passes: %3 units, %4 vehicles removed. Captured assets retained.",_response getOrDefault ["id","response"],_response getOrDefault ["cleanupPasses",0],(_response get "cleanupDeleted") select 0,(_response get "cleanupDeleted") select 1];
