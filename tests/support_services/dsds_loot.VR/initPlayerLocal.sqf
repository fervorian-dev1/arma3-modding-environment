[] spawn {
 waitUntil {sleep 0.2;!isNull player && {time>5}};
 DSDS_lootClientPasses=0;DSDS_lootClientFailures=0;
 private _assert={params ["_ok","_label"];if (_ok) then {DSDS_lootClientPasses=DSDS_lootClientPasses+1;} else {DSDS_lootClientFailures=DSDS_lootClientFailures+1;};diag_log format ["[LOOT CLIENT TEST] %1: %2",["FAIL","PASS"] select _ok,_label];};
 player allowDamage false;player addBackpack "B_Carryall_oli";
 {player addItem _x;} forEach ["DSDS_Marijuana","DSDS_Marijuana","DSDS_NicotineVape","DSDS_Cocaine","DSDS_Zyn","DSDS_GoldBullion"];
 private _before={_x=="DSDS_Marijuana"} count items player;
 ["DSDS_Marijuana"] call DSDS_fnc_lootConsume;
 private _deadline=diag_tickTime+10;
 waitUntil {sleep 0.1;((player getVariable ["DSDS_lootEffects",[0,0,0,0,0]]) select 0)>serverTime || {diag_tickTime>_deadline}};
 [((player getVariable ["DSDS_lootEffects",[0,0,0,0,0]]) select 0)>serverTime,"real player server handshake commits effect"] call _assert;
 [({_x=="DSDS_Marijuana"} count items player)==_before-1,"real owning-client inventory consumes exactly one item"] call _assert;
 sleep 0.3;
 private _state=player getVariable ["DSDS_lootLocal",createHashMap];
 [(_state getOrDefault ["blur",-1])>=0,"client creates its own blur handle"] call _assert;
 [abs (getCustomAimCoef player-(_state getOrDefault ["aimBase",1])*0.75)<0.001,"client applies reduced sway"] call _assert;
 private _token=player getVariable ["DSDS_lootLastToken",""];
 ["TAKE",player,[_token,"DSDS_Marijuana"]] call DSDS_fnc_lootClient;
 [({_x=="DSDS_Marijuana"} count items player)==_before-1,"duplicate consume token cannot remove another item"] call _assert;
 {
  sleep 1.2;
  private _class=_x;[_class] call DSDS_fnc_lootConsume;
  private _index=["DSDS_NicotineVape","DSDS_Cocaine","DSDS_Zyn"] find _class;
  _index=[1,2,4] select _index;
  private _deadline=diag_tickTime+8;
  waitUntil {sleep 0.1;((player getVariable ["DSDS_lootEffects",[0,0,0,0,0]]) select _index)>serverTime || {diag_tickTime>_deadline}};
  [!( _class in items player) && {((player getVariable ["DSDS_lootEffects",[0,0,0,0,0]]) select _index)>serverTime},"consume and server effect: "+_class] call _assert;
 } forEach ["DSDS_NicotineVape","DSDS_Cocaine","DSDS_Zyn"];
 sleep 1.2;
 ["DSDS_GoldBullion"] call DSDS_fnc_lootConsume;sleep 0.5;
 ["DSDS_GoldBullion" in items player,"gold is never consumable"] call _assert;
 [count (player getVariable ["DSDS_lootActions",[]])==11,"eleven self consume actions registered"] call _assert;
 diag_log format ["[LOOT CLIENT TEST] COMPLETE: %1 PASS, %2 FAIL",DSDS_lootClientPasses,DSDS_lootClientFailures];
};

