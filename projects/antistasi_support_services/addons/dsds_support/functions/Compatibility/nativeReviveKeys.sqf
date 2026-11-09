/* Ultimate's final key handler is redirected in config, with its installed
   implementation retained for genuine downed players. R is ordinary reload alive. */
if (!hasInterface || {isNull player}) exitWith {false};
if (!([player] call DSDS_fnc_physicalDownState)) exitWith {false};
if (isNil "DSDS_nativeReviveKeys") exitWith {false};
_this call DSDS_nativeReviveKeys
