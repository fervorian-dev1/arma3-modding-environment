params ["_record"];
if (!isServer || {isRemoteExecuted} || {_record getOrDefault ["medicalAggressionApplied",false]}) exitWith {};
_record set ["medicalAggressionApplied",true];
private _side=_record get "side";private _position=getPosATL (_record get "truck");
if (!isNil "A3A_fnc_addAggression" && {missionNamespace getVariable ["serverInitDone",false]}) then {[_side,40,60,true] call A3A_fnc_addAggression;};
// Ultimate aggression is faction-wide; focus the immediate contact alert on this region.
{if (side _x==_side && {leader _x distance2D _position<5000}) then {
 private _targets=allPlayers select {getPlayerUID _x in (_record getOrDefault ["attackers",createHashMap])};
 [_x,"CONTACT",_targets] remoteExecCall ["DSDS_fnc_convoyLocal",groupOwner _x];
};} forEach allGroups;
diag_log format ["[DSDS Medical] %1 attacked: +40 native aggression for 60 minutes; regional contact alert at %2.",_record get "id",_position];
