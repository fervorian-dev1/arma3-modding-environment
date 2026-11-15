params [["_plugins",createHashMap]];
if (!isServer || {isRemoteExecuted} || {isNil "A3A_saveTarget"}) exitWith {};
private _target=str (A3A_saveTarget select [0,3]);
if (_this isEqualTo [] && {missionNamespace getVariable ["DSDS_campaignRestoredFor",""]==_target}) exitWith {};
if (_this isEqualTo []) then {private _v=["saveDataPlugins"] call A3A_fnc_returnSavedStat;if (!isNil "_v") then {_plugins=_v;};};
if (_plugins isEqualType []) then {_plugins=createHashMapFromArray _plugins;};
if !(_plugins isEqualType createHashMap) exitWith {};
private _payload=_plugins getOrDefault ["DSDS_SupportServices",[]];
if (count _payload==2 && {_payload select 0==1}) then {
 {if (_x isEqualType [] && {count _x==2} && {(_x select 0) isEqualType ""} && {((_x select 0) find "DSDS_")==0}) then {_x call A3A_fnc_setStatVariable;};} forEach (_payload select 1);
};
DSDS_campaignRestoredFor=_target;
