/* Config init follows CBA's native placed-explosive pattern; each owner hooks only once. */
params ["_mine"];
if (isNull _mine || {typeOf _mine!="DSDS_NuclearIED_Ammo"}) exitWith {};
if (isServer && {!(_mine getVariable ["DSDS_nuclearSpent",false])}) then {
 private _id=netId _mine;private _map=missionNamespace getVariable ["DSDS_nuclearMines",createHashMap];
 if (_id!="0:0" && {isNil {_map get _id}}) then {_map set [_id,[_mine,getPosASL _mine,owner _mine,diag_tickTime+30]];DSDS_nuclearMines=_map;};
};
if (_mine getVariable ["DSDS_nuclearHook",false]) exitWith {};
_mine setVariable ["DSDS_nuclearHook",true];
_mine addEventHandler ["Explode",{
 params ["_mine","_position"];
 if (local _mine) then {[netId _mine,getPosASL _mine] remoteExecCall ["DSDS_fnc_nuclearIEDReport",2];};
}];
