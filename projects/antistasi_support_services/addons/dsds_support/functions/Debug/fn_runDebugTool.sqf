/* Fixed curator-only commands, dispatched outside RPC context by trusted queue. */
params ["_actor","_position","_debug","_tool"];
if (!isServer || {isRemoteExecuted} || {!_debug} || {isNull getAssignedCuratorLogic _actor}) exitWith {};
private _tell={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
if ((_tool find "SUPPORT_")==0) exitWith {
 private _type=_tool select [8];
 if (!isClass (configFile >> "DSDS_SupportActions" >> _type)) exitWith {};
 DSDS_jobSequence=DSDS_jobSequence+1;private _id=str DSDS_jobSequence;
 private _holder=_actor getVariable ["owner",_actor];
 DSDS_jobs set [_id,createHashMapFromArray [["player",_actor],["holder",_holder],["uid",getPlayerUID _actor],["balanceAfter",_holder getVariable ["moneyX",0]],["cost",0],["type",_type],["origin",_position],["target",_position getPos [300,getDir _actor]],["state","paid"]]];
 [_id] spawn DSDS_fnc_runSupportContract;
};
switch (_tool) do {
 case "MYSTIC";case "MYSTIC_HERE": {
  private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
  if (!(_s getOrDefault ["loaded",false])) then {[] call DSDS_fnc_mysticLoad;_s=DSDS_mysticState;};
  private _pos=if (_tool=="MYSTIC_HERE") then {_position} else {_s getOrDefault ["position",[]]};
  if (count _pos<2 || {surfaceIsWater _pos}) then {_pos=_position;};
  private _safe=[_pos,0,30,2,0,0.5,0,[],[_pos,_pos]] call BIS_fnc_findSafePos;
  _safe set [2,0];
  private _oldNPC=missionNamespace getVariable ["DSDS_mystic",objNull];
  private _new=[_safe,_s getOrDefault ["direction",0]] call DSDS_fnc_mysticSpawn;
  if (isNull _new) exitWith {["Mystic could not be created; see server log."] call _tell;};
  // mysticSpawn publishes the new object; remove only the former tagged vendor.
  if (!isNull _oldNPC && {_oldNPC!=_new}) then {private _g=group _oldNPC;deleteVehicle _oldNPC;if (count units _g==0) then {deleteGroup _g;};};
  _s set ["position",_safe];_s set ["dead",false];_s set ["respawnAt",0];_s set ["spawned",true];
  [] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;
  [format ["Mystic restored at grid %1.",mapGridPosition _new]] call _tell;
 };
 case "MYSTIC_REVEAL": {private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];if (count _s>0) then {_s set ["lead",true];_s set ["revealed",true];[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;};};
 case "FENCE": {[] call DSDS_fnc_fenceRotate;};
 case "FENCE_CRATE": {private _dsdsAuthorizedPlayer=_actor;private _box=[true] call DSDS_fnc_fenceCommunityCrate;private _npc=missionNamespace getVariable ["DSDS_fence",objNull];if (!isNull _box && {!isNull _npc} && {isNull attachedTo _box} && {isNull isVehicleCargo _box}) then {_box setPosATL (_npc modelToWorld [5,0,0]);};};
 case "MECHANIC": {private _previous=missionNamespace getVariable ["DSDS_mechanic",objNull];DSDS_mechanic=objNull;private _new=[_position,0] call DSDS_fnc_createMechanic;if (!isNull _new) then {if (!isNull _previous && {_previous!=_new}) then {private _g=group _previous;deleteVehicle _previous;if (count units _g==0) then {deleteGroup _g;};};[] call DSDS_fnc_persistMechanic;} else {DSDS_mechanic=_previous;publicVariable "DSDS_mechanic";};};
 case "ARSENAL": {[] call DSDS_fnc_protectOswaldArsenal;["Arsenal restrictions and purchased unlocks reapplied."] call _tell;};
 case "TERMINAL": {["ISSUE",[]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
 case "LOOT";case "MEDICAL_LOOT": {
  private _box=createVehicle ["Box_NATO_Equip_F",_position,[],0,"NONE"];
  if (!isNull _box) then {clearItemCargoGlobal _box;clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearBackpackCargoGlobal _box;
  private _dsdsLootAuthorized=true;[_box,10,if (_tool=="LOOT") then {"COMMON"} else {"MEDICAL"}] call DSDS_fnc_fillLootContainer;};
 };
 case "RAID": {if (!isNil "DSDS_noise" && {!isNil "petros"} && {alive petros} && {DSDS_noise get "phase"!="active"}) then {DSDS_noise set ["hq",getPosATL petros];DSDS_noise set ["phase","preparing"];DSDS_noise set ["dueAt",diag_tickTime];DSDS_noise set ["expiresAt",diag_tickTime+900];[] call DSDS_fnc_tickHQNoise;};};
 case "RAID_RESET": {if (!isNil "DSDS_noise" && {DSDS_noise get "phase"!="active"}) then {DSDS_noise set ["phase","quiet"];DSDS_noise set ["score",0];DSDS_noise set ["readyAt",0];};};
 case "STATUS": {private _npc=missionNamespace getVariable ["DSDS_mystic",objNull];[format ["Mystic: %1, alive %2, position %3. HQ raid: %4. See RPT for state dump.",!isNull _npc,alive _npc,getPosATL _npc,(missionNamespace getVariable ["DSDS_noise",createHashMap]) getOrDefault ["phase","not initialized"]]] call _tell;diag_log format ["[DSDS STATUS] Mystic=%1 state=%2 HQ=%3",_npc,missionNamespace getVariable ["DSDS_mysticState",createHashMap],missionNamespace getVariable ["DSDS_noise",createHashMap]];};
};
