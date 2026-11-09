/* Keep the installed factory/loadouts. On a player-hosted game, stagger
   scheduled hostile AI creation so a single spawn wave doesn't arrive at once.
   Unscheduled callers, civilians/rebels, dedicated servers and HCs stay synchronous. */
if (isNil "DSDS_nativeCreateUnit") then {
 private _path=getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "file")+"\fn_createUnit.sqf";
 if (fileExists _path) then {DSDS_nativeCreateUnit=compile preprocessFileLineNumbers _path;};
};
if (isNil "DSDS_nativeCreateUnit") exitWith {diag_log "[DSDS AI] Installed native unit factory unavailable; unit creation cancelled.";objNull};
private _group=_this param [0,grpNull];
if (isServer && {hasInterface} && {canSuspend} && {!isNull _group} && {side _group in [east,west,resistance]} && {!isNil "teamPlayer"} && {side _group!=teamPlayer} && {(side _group) getFriend teamPlayer<0.6}) then {
 private _reserved=false;
 while {!_reserved} do {
  // Reservation is atomic across concurrent scheduled reinforcement scripts.
  isNil {private _now=diag_tickTime;if (_now>=(missionNamespace getVariable ["DSDS_nextHostEnemySpawn",0])) then {DSDS_nextHostEnemySpawn=_now+0.05;_reserved=true;};};
  if (!_reserved) then {sleep 0.01;};
 };
};
_this call DSDS_nativeCreateUnit
