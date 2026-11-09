/* Called by server MP events only. Attribute to actual player instigators, not bystanders. */
params ["_truck",["_source",objNull],["_instigator",objNull]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
private _record=DSDS_smugglingRecords getOrDefault [_truck getVariable ["DSDS_manifestID",""],createHashMap];
if (count _record==0) exitWith {false};
private _actor=_instigator;
if (isNull _actor || {!isPlayer _actor}) then {_actor=if (isPlayer _source) then {_source} else {effectiveCommander _source};};
if ((isNull _actor || {!isPlayer _actor}) && {!isNull _source} && {unitIsUAV vehicle _source}) then {
 private _operators=(UAVControl [vehicle _source,"gunner"])+(UAVControl [vehicle _source,"driver"]);
 private _index=_operators findIf {!isNull _x && {isPlayer _x}};
 if (_index>=0) then {_actor=_operators select _index;};
};
if (isNull _actor || {!isPlayer _actor} || {side group _actor!=missionNamespace getVariable ["teamPlayer",resistance]}) exitWith {false};
private _uid=getPlayerUID _actor;
if (_uid=="") exitWith {false};
private _attackers=_record getOrDefault ["attackers",createHashMap];_attackers set [_uid,serverTime];_record set ["attackers",_attackers];
_record set ["lastAttack",serverTime];
if (_record get "kind"=="MEDICAL" && {!(_record getOrDefault ["medicalAttacked",false])}) then {
 _record set ["medicalAttacked",true];
 [_record] spawn DSDS_fnc_medicalIncident;
};
true
