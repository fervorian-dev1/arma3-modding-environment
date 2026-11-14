/* Server-only; create replacement before removing the old camp. */
if (!isServer) exitWith {false};
private _pos=[] call DSDS_fnc_fenceLocation;
if (_pos isEqualTo []) exitWith {diag_log "[DSDS Fence] No safe roadside camp found; keeping previous camp and retrying in five minutes.";false};
private _cfg=configFile >> "DSDS_Fence";
private _tentClass=getText (_cfg >> "tentClass"); private _npcClass=getText (_cfg >> "npcClass");
if (!isClass (configFile >> "CfgVehicles" >> _tentClass) || {!isClass (configFile >> "CfgVehicles" >> _npcClass)}) exitWith {diag_log "[DSDS Fence] Missing tent/NPC class; no camp spawned.";false};
private _tent=createVehicle [_tentClass,_pos,[],0,"CAN_COLLIDE"];
private _group=createGroup [civilian,true];
private _npc=_group createUnit [_npcClass,_pos,[],0,"NONE"];
if (isNull _tent || {isNull _npc}) exitWith {deleteVehicle _tent;deleteVehicle _npc;deleteGroup _group;false};
_tent setDir random 360; _tent setVectorUp surfaceNormal _pos;
_npc setPosATL (_tent modelToWorld [0,0,0]);
removeAllWeapons _npc;removeAllItems _npc;removeAllAssignedItems _npc;
_npc disableAI "PATH";_npc setUnitPos "UP";_npc setBehaviour "CARELESS";_npc setName "The Fence";
_npc setVariable ["DSDS_fenceNPC",true,true];
[_npc,"FIXED"] call DSDS_fnc_configureAddonAI;
private _old=missionNamespace getVariable ["DSDS_fence",objNull];
private _oldTent=missionNamespace getVariable ["DSDS_fenceTent",objNull];
DSDS_fence=_npc;DSDS_fenceTent=_tent;
private _stock=[] call DSDS_fnc_fenceBuildStock;
DSDS_fenceStock=_stock;
DSDS_fenceGeneration=(missionNamespace getVariable ["DSDS_fenceGeneration",0])+1;
publicVariable "DSDS_fence";publicVariable "DSDS_fenceStock";publicVariable "DSDS_fenceGeneration";
// Preserve the shared inventory and move the same crate to the new camp.
private _community=missionNamespace getVariable ["DSDS_fenceCommunityBox",objNull];
if (!isNull _community && {alive _community}) then {
 detach _community;
 private _carrier=isVehicleCargo _community;
 if (!isNull _carrier) then {_carrier setVehicleCargo objNull;};
 {ropeDestroy _x;} forEach ropes _community;
 private _cratePos=[_pos,8,25,3,0,0.3,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
 if (_cratePos distance2D [0,0,0]<=10) then {_cratePos=_tent modelToWorld [5,0,0];};
 if (_cratePos distance2D [0,0,0]>10) then {_community setPosATL _cratePos;_community setVelocity [0,0,0];};
};
private _oldGroup=group _old;
// Let a visiting player finish leaving the former tent before deleting it.
[_old,_oldTent,_oldGroup] spawn {
    params ["_old","_tent","_group"];
    deleteVehicle _old;deleteGroup _group;
    waitUntil {sleep 5;allPlayers findIf {_x distance2D _tent < 25} < 0};
    deleteVehicle _tent;
};
if (getMarkerColor "DSDS_Fence" == "") then {createMarker ["DSDS_Fence",_pos];};
"DSDS_Fence" setMarkerPos _pos;"DSDS_Fence" setMarkerType "mil_unknown";"DSDS_Fence" setMarkerColor "ColorCIV";"DSDS_Fence" setMarkerText "The Fence";
["FENCE_ALERT",[mapGridPosition _pos]] remoteExecCall ["DSDS_fnc_clientService",0];
diag_log format ["[DSDS Fence] Rotation %1 at %2, %3 offers.",DSDS_fenceGeneration,_pos,count _stock];
true
