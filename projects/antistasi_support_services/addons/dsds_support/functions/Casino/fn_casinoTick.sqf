if (!isServer || {isRemoteExecuted} || {isNil "DSDS_casinoState"}) exitWith {};
if (DSDS_casinoBuildQueue isNotEqualTo []) then {
 private _request=DSDS_casinoBuildQueue deleteAt 0;_request params ["_actor","_uid","_class","_pos","_dir","_price"];
 private _ok=([_pos,_dir] call DSDS_fnc_casinoValidateSite)=="";
 if (_ok) then {_ok=[_class,_pos,_dir] call DSDS_fnc_casinoSpawn;};
 if (!_ok) then {[_uid,_price] call DSDS_fnc_casinoCredit;};
 DSDS_casinoState set ["pendingBuild",[]];DSDS_casinoBuildLock=false;[] call DSDS_fnc_casinoSave;
 if (!isNull _actor) then {[if (_ok) then {"BUILT"} else {"BUILD_FAILED"},[]] remoteExecCall ["DSDS_fnc_casinoClient",_actor];};
};
{
 _x params ["_uid","_s"];
 if (_s getOrDefault ["phase","finished"]!="finished") then {
  private _cfg=configFile >> "DSDS_Casino" >> "Games" >> (_s get "game");private _handler=missionNamespace getVariable [getText (_cfg >> "handler"),{}];
  private _phase=_s get "phase";private _changed=false;
  if (_phase in ["spinning","dealing"] && {serverTime>=(_s getOrDefault ["due",0])}) then {[_s,"RESOLVE"] call _handler;_changed=true;};
  if (_s get "game"=="CRASH") then {[_s,"TICK"] call _handler;if (_s get "phase"=="finished") then {_changed=true;};};
  private _actor=_s get "actor";
  if (_s get "phase"!="finished" && {serverTime>(_s get "expires") || {isNull _actor} || {!alive _actor} || {_actor distance (_s get "dealer")>12} || {!isPlayer _actor}}) then {[_s,"TIMEOUT"] call _handler;_changed=true;};
  if (_changed) then {_s set ["revision",(_s get "revision")+1];[_s] call DSDS_fnc_casinoSettle;[] call DSDS_fnc_casinoSave;};
 } else {if (serverTime-(_s get "started")>1800) then {DSDS_casinoSessions deleteAt _uid;};};
} forEach ((keys DSDS_casinoSessions) apply {[_x,DSDS_casinoSessions get _x]});
{
 private _uid=_x;private _amount=DSDS_casinoCredits getOrDefault [_uid,0];
 if (_amount>0 && {(allPlayers findIf {getPlayerUID _x==_uid && {alive _x} && {!isNull (_x getVariable ["owner",objNull])} && {!isNil {(_x getVariable ["owner",objNull]) getVariable "moneyX"}}})>=0}) then {
  DSDS_casinoCredits deleteAt _uid;[_uid,_amount] call DSDS_fnc_casinoCredit;[] call DSDS_fnc_casinoSave;
 };
} forEach +(keys DSDS_casinoCredits);

private _changed=false;
{
 private _pair=_x;private _npc=_pair select 1;
 if (isNull _npc || {!alive _npc}) then {
  private _due=_pair param [5,0];
  if (_due==0) then {_due=serverTime+300;_pair set [5,_due];};
  if (serverTime>=_due) then {
   private _new=[_pair select 0,_pair select 2,_pair select 3,_pair select 4] call DSDS_fnc_casinoSpawnDealer;
   if (!isNull _new) then {
    if (!isNull _npc) then {private _g=group _npc;deleteVehicle _npc;if (units _g isEqualTo []) then {deleteGroup _g;};};
    _pair set [1,_new];_pair set [5,0];_changed=true;
   } else {_pair set [5,serverTime+30];};
  };
 };
} forEach (missionNamespace getVariable ["DSDS_casinoDealers",[]]);
if (_changed) then {publicVariable "DSDS_casinoDealers";};
