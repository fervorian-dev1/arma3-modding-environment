if (!isServer || {isRemoteExecuted}) exitWith {};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if ((_s getOrDefault ["rewardState",""])=="armed") then {
 private _actor=missionNamespace getVariable ["DSDS_nuclearWearer",objNull];
 if (isNull _actor) then {private _uid=_s getOrDefault ["rewardUID",""];private _i=allPlayers findIf {getPlayerUID _x==_uid};if (_i>=0) then {_actor=allPlayers select _i;DSDS_nuclearWearer=_actor;};};
 if (!isNull _actor) then {
  _actor setVariable ["DSDS_nuclearVest",true,true];
  if (!alive _actor) then {[_actor] call DSDS_fnc_nuclearDetonateVest;} else {
   private _prop=missionNamespace getVariable ["DSDS_nuclearChest",objNull];
   if (isNull _prop) then {private _model=getText (configFile >> "CfgAmmo" >> "IEDUrbanSmall_Remote_Ammo" >> "model");_prop=createSimpleObject [_model,getPosASL _actor,false];DSDS_nuclearChest=_prop;};
   if (!isNull _prop && {attachedTo _prop!=_actor}) then {_prop attachTo [_actor,[0,0.18,0],"Spine3",true];_prop setVectorDirAndUp [[0,0,1],[0,-1,0]];};
  };
 } else {private _prop=missionNamespace getVariable ["DSDS_nuclearChest",objNull];if (!isNull _prop) then {deleteVehicle _prop;DSDS_nuclearChest=objNull;};};
};
if ((_s getOrDefault ["rewardState",""])!="armed") then {private _prop=missionNamespace getVariable ["DSDS_nuclearChest",objNull];if (!isNull _prop) then {deleteVehicle _prop;DSDS_nuclearChest=objNull;};};
// Track authoritative mine position/owner for authenticated local Explode reports.
private _mines=missionNamespace getVariable ["DSDS_nuclearMines",createHashMap];
{_y params ["_mine","_position","_owner","_expiry"];if (!isNull _mine) then {_y set [1,getPosASL _mine];_y set [2,owner _mine];_y set [3,diag_tickTime+30];} else {if (diag_tickTime>_expiry) then {_mines deleteAt _x;};};} forEach _mines;
