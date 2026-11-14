/* Server-only stash lifecycle, shared by maintenance and new-lead requests. */
params ["_stash"];
if (!isServer || {isRemoteExecuted} || {count _stash==0} || {_stash getOrDefault ["removed",false]}) exitWith {false};
private _box=_stash getOrDefault ["box",objNull];
private _destroyed=isNull _box || {!alive _box};
private _empty=!_destroyed && {((itemCargo _box) + (magazineCargo _box) + (weaponCargo _box) + (backpackCargo _box)) isEqualTo []};
private _cleared=((_stash getOrDefault ["units",[]]) findIf {alive _x})<0;
if (!(_stash getOrDefault ["complete",false]) && {_destroyed || {_empty} || {_cleared}}) then {
 _stash set ["complete",true];
 [_stash get "id",if (_destroyed) then {"FAILED"} else {"SUCCEEDED"},true] call BIS_fnc_taskSetState;
 (_stash get "marker") setMarkerText (if (_destroyed) then {"Destroyed stash"} else {"Cleared "+(_stash getOrDefault ["title","Contraband Stash"])});
 {if (!isNil "A3A_fnc_groupDespawner") then {[_x] spawn A3A_fnc_groupDespawner;};} forEach (_stash getOrDefault ["groups",[]]);
};
if (_empty || {_destroyed}) then {
 _stash set ["removed",true];
 deleteMarker (_stash get "marker");
 [_stash get "id"] call BIS_fnc_deleteTask;
 if (!isNull _box) then {deleteVehicle _box;};
 private _active=missionNamespace getVariable ["DSDS_activeStash",createHashMap];
 if ((_active getOrDefault ["id",""])==(_stash get "id")) then {DSDS_activeStash=createHashMap;};
};
_empty || {_destroyed}
