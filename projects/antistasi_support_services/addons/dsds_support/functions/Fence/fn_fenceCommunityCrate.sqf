/* One live communal object. Never delete/replace a loaded or transported crate. */
params [["_create",false]];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer"}}) exitWith {objNull};
private _box=missionNamespace getVariable ["DSDS_fenceCommunityBox",objNull];
if (!isNull _box && {alive _box}) exitWith {_box};
if (!_create) exitWith {objNull};
private _npc=missionNamespace getVariable ["DSDS_fence",objNull];
if (isNull _npc || {!alive _npc}) exitWith {objNull};
private _pos=[getPosATL _npc,8,25,3,0,0.3,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
private _class=getText (configFile >> "DSDS_Fence" >> "crateClass");
if (_pos distance2D [0,0,0]<10 || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {objNull};
_box=createVehicle [_class,_pos,[],0,"NONE"];
if (isNull _box) exitWith {objNull};
clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
_box setVariable ["DSDS_communityTradeCrate",true,true];
_box setVariable ["DSDS_fenceBoxOwner","COMMUNITY",true];
_box setVariable ["DSDS_tradeRevision",0,true];
DSDS_fenceCommunityBox=_box;publicVariable "DSDS_fenceCommunityBox";
{_x addCuratorEditableObjects [[_box],false];} forEach allCurators;
_box
