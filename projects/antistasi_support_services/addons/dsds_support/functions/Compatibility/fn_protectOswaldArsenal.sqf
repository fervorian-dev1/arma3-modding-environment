if (!isServer || {isRemoteExecuted}) exitWith {false};
private _changed=false;
{
 private _list=missionNamespace getVariable [_x,[]];
 if ("DSDS_Oswald" in _list) then {missionNamespace setVariable [_x,_list-["DSDS_Oswald"],true];_changed=true;};
} forEach ["allWatches","unlockedWatches","lootBasicItem"];
if (!isNil "jna_dataList" && {!isNil "jn_fnc_arsenal"}) then {
 private _watchIndex=["DSDS_Oswald"] call jn_fnc_arsenal_itemType;
 if (_watchIndex<0 || {_watchIndex>=count jna_dataList}) exitWith {_changed};
 {
  private _index=_watchIndex;
  if ((_x findIf {(_x select 0)=="DSDS_Oswald" && {(_x select 1)==-1}})>=0) then {
   ["UpdateItemRemove",[_index,"DSDS_Oswald",-1,true]] call jn_fnc_arsenal;
   private _users=if (isNil "server") then {[]} else {server getVariable ["jna_playersInArsenal",[]]};
   _users=if (0 in _users) then {-2} else {_users-[2]};
   if (_users isNotEqualTo []) then {["UpdateItemRemove",[_index,"DSDS_Oswald",-1,true]] remoteExecCall ["jn_fnc_arsenal",_users];};
   _changed=true;
  };
 } forEach [jna_dataList select _watchIndex];
};
_changed
