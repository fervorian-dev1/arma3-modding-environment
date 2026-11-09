/* Antistasi's native respawn calculation reads this setting on the player's machine. */
if (isRemoteExecuted) exitWith {false};
private _changed=(missionNamespace getVariable ["deathPenalty",-1]) isNotEqualTo 0;
deathPenalty=0;
if (isServer && {_changed}) then {publicVariable "deathPenalty";};
true
