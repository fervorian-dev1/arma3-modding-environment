/* Server-side campaign arsenal sanitation. Native campaign saves persist the cleaned ledger. */
if (!isServer || {isRemoteExecuted}) exitWith {false};
private _blocked=["DSDS_AHJC", "DSDS_Cocaine", "DSDS_CutGems", "DSDS_GoldBullion", "DSDS_IndustrialIsotopes", "DSDS_IndustrialPlatinum", "DSDS_M11", "DSDS_Marijuana", "DSDS_MedicalIsotopes", "DSDS_Methamphetamine", "DSDS_Microchips", "DSDS_NicotineVape", "DSDS_OLB1", "DSDS_OLB2", "DSDS_PalladiumSponges", "DSDS_RoughGems", "DSDS_SiliconWafers", "DSDS_ValuableReceiver", "DSDS_Zyn", "DSDS_Oswald"];
private _unlocked=(missionNamespace getVariable ["DSDS_mysticState",createHashMap]) getOrDefault ["oswaldUnlocked",false];
if (_unlocked) then {_blocked=_blocked-["DSDS_Oswald"];};
private _changed=false;
{
 private _list=missionNamespace getVariable [_x,[]];
 if (_list isEqualType []) then {
  private _clean=_list-_blocked;
  if (_clean isNotEqualTo _list) then {missionNamespace setVariable [_x,_clean,true];_changed=true;};
 };
} forEach ["allWatches","unlockedWatches","lootBasicItem","unlockedItems","unlockedMagazines","unlockedWeapons","unlockedOptics","unlockedBackpacks","unlockedVests","unlockedUniforms","unlockedHeadgear","unlockedNVGs","unlockedGPS","unlockedMisc"];
if (!isNil "jna_dataList" && {!isNil "jn_fnc_arsenal"}) then {
 private _users=if (isNil "server") then {[]} else {server getVariable ["jna_playersInArsenal",[]]};
 _users=if (0 in _users) then {-2} else {_users-[2]};
 {
  private _index=_forEachIndex;
  {
   _x params ["_class","_amount"];
   if (_class in _blocked) then {
    private _remove=if (_amount==-1) then {-1} else {_amount max 1};
    ["UpdateItemRemove",[_index,_class,_remove,true]] call jn_fnc_arsenal;
    if (_users isNotEqualTo []) then {["UpdateItemRemove",[_index,_class,_remove,true]] remoteExecCall ["jn_fnc_arsenal",_users];};
    _changed=true;
   };
  } forEach +_x;
 } forEach +jna_dataList;
};
if (_unlocked && {!isNil "jna_dataList"} && {!isNil "jn_fnc_arsenal"}) then {
 private _index=["DSDS_Oswald"] call jn_fnc_arsenal_itemType;
 if (_index>=0 && {_index<count jna_dataList}) then {
  private _entries=jna_dataList select _index;
  if ((_entries findIf {(_x select 0)=="DSDS_Oswald" && {(_x select 1)==-1}})<0) then {
   ["UpdateItemAdd",[_index,"DSDS_Oswald",-1,true]] call jn_fnc_arsenal;
   private _users=if (isNil "server") then {[]} else {server getVariable ["jna_playersInArsenal",[]]};
   _users=if (0 in _users) then {-2} else {_users-[2]};
   if (_users isNotEqualTo []) then {["UpdateItemAdd",[_index,"DSDS_Oswald",-1,true]] remoteExecCall ["jn_fnc_arsenal",_users];};
   _changed=true;
  };
  private _watches=missionNamespace getVariable ["unlockedWatches",[]];
  if !("DSDS_Oswald" in _watches) then {_watches pushBack "DSDS_Oswald";missionNamespace setVariable ["unlockedWatches",_watches,true];};
 };
};
_changed
