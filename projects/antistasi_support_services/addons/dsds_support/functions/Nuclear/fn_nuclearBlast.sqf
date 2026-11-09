/* Server-only adapter to the installed ZEN Atomic Bomb event; no replacement simulation. */
params ["_position"];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsNuclearDispatch" || {!_dsdsNuclearDispatch}}} || {count _position!=3} || {(_position findIf {!(_x isEqualType 0) || {!finite _x}})>=0} || {isNil "zen_modules_fnc_moduleNukeLocal"}) exitWith {false};
["zen_modules_moduleNuke",[+_position,500,300,false]] call CBA_fnc_globalEvent;
DSDS_nuclearBlastCount=(missionNamespace getVariable ["DSDS_nuclearBlastCount",0])+1;
diag_log format ["[DSDS Mystic] Nuclear detonation %1 at ASL %2 using installed ZEN framework.",DSDS_nuclearBlastCount,_position];
true
