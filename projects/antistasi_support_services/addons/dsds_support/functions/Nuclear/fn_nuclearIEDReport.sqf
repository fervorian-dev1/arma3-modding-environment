params [["_id","",[""]],["_position",[],[[]]]];
if (!isServer || {count _position!=3} || {(_position findIf {!(_x isEqualType 0) || {!finite _x}})>=0}) exitWith {false};
private _map=missionNamespace getVariable ["DSDS_nuclearMines",createHashMap];private _entry=_map getOrDefault [_id,[]];
if (count _entry==0) exitWith {false};
_entry params ["_mine","_last","_owner","_expiry"];
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (_sender!=(if (isNull _mine) then {_owner} else {owner _mine}) || {_position distance _last>30} || {diag_tickTime>_expiry} || {!isNull _mine && {alive _mine}}) exitWith {false};
if (!isNull _mine) then {_mine setVariable ["DSDS_nuclearSpent",true];};
_map deleteAt _id;
// The raw nuclear adapter stays private even though this validated callback is an RPC.
private _dsdsNuclearDispatch=true;
[_position] call DSDS_fnc_nuclearBlast;
true
