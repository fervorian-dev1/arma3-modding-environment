/* Player-local entry; inventory is removed only after server authorization. */
params [["_class","",[""]]];
if (isRemoteExecuted || {!(_class in ([] call DSDS_fnc_consumableClasses))}) exitWith {};
if (!hasInterface || {isNull player} || {!alive player} || {!(isNull objectParent player)} || {lifeState player=="INCAPACITATED"}) exitWith {};
if (!(_class in items player) || {diag_tickTime<(player getVariable ["DSDS_lootBusy",0])}) exitWith {};
player setVariable ["DSDS_lootBusy",diag_tickTime+10];
["BEGIN",player,[_class]] remoteExecCall ["DSDS_fnc_lootRequest",2];
