/* One bounded queue replaces one sleeping script per addon AI. Accuracy Fix
   keeps its aiming values; only restore the same previous tactical skills. */
if (!isServer || {isRemoteExecuted}) exitWith {};
private _queue=missionNamespace getVariable ["DSDS_aiCompatibilityQueue",[]];
private _fixed=missionNamespace getVariable ["tws_is_Aim_fixed",[]];
for "_i" from 1 to (8 min count _queue) do {
 private _entry=_queue deleteAt 0;_entry params ["_unit","_skill"];
 if (!isNull _unit && {alive _unit}) then {
  if (_unit in _fixed) then {
   {_unit setSkill [_x,_skill];} forEach ["general","commanding","courage","spotDistance","spotTime","reloadSpeed"];
   _unit setVariable ["DSDS_aiAccuracyIntegrated",true];
  } else {_queue pushBack _entry;};
 };
};
DSDS_aiCompatibilityQueue=_queue;
