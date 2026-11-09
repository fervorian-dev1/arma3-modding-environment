params ["_player","_manifest"];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer" || {_dsdsAuthorizedPlayer!=_player}}}) exitWith {false};
if ((_manifest findIf {(_x select 0)=="DSDS_IndustrialIsotopes" && {(_x select 1)=="CfgWeapons"} && {(_x select 2)>0}})<0) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
private _new=!(_s getOrDefault ["lead",missionNamespace getVariable ["DSDS_mysticPendingLead",false]]);
if (!_new) exitWith {false};
DSDS_mysticPendingLead=true;
if (count _s>0) then {_s set ["lead",true];[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;};
["MESSAGE",["The Fence: I have an associate who takes a particular interest in goods like these. This nuclear material is not easy to move. For 92,235 credits, I can tell you where to find Mystic."]] remoteExecCall ["DSDS_fnc_mysticClient",_player];
true
