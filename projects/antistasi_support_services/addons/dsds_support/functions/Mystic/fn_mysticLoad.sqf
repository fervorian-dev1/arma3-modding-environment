if (!isServer || {isRemoteExecuted}) exitWith {false};
private _lead=missionNamespace getVariable ["DSDS_mysticPendingLead",false];
private _s=createHashMapFromArray [["loaded",true],["position",[]],["direction",random 360],["lead",_lead],["revealed",false],["count",0],["intros",[]],["ready",false],["dead",false],["respawnAt",0],["spawned",false],["trades",createHashMap],["offeringToken",""],["corpses",[]],["rewardState",""],["rewardUID",""],["nuclearUnlocked",false]];
private _saved=[];
if (!isNil "A3A_saveTarget" && {!isNil "A3A_fnc_returnSavedStat"} && {(missionNamespace getVariable ["A3A_saveData",createHashMap]) getOrDefault ["startType",""]=="load"}) then {
 private _value=["DSDS_mysticState"] call A3A_fnc_returnSavedStat;
 if (!isNil "_value" && {_value isEqualType []}) then {_saved=_value;};
};
if (count _saved>=10 && {_saved select 0==1}) then {
 _saved params ["_version","_position","_direction","_available","_revealed","_count","_intros","_ready","_dead","_remaining",["_rewardState",""],["_rewardUID",""],["_nuclearUnlocked",false]];
 if (_position isEqualType [] && {count _position>=2} && {(_position findIf {!(_x isEqualType 0) || {!finite _x}})<0} && {_direction isEqualType 0} && {_available isEqualType true} && {_revealed isEqualType true} && {_count isEqualType 0} && {_intros isEqualType []} && {_ready isEqualType true} && {_dead isEqualType true} && {_remaining isEqualType 0}) then {
  _s set ["position",_position];_s set ["direction",_direction];_s set ["lead",_lead || _available];_s set ["revealed",_revealed];
  _s set ["count",(floor _count max 0) min 40];_s set ["ready",_count>=40];_s set ["intros",_intros select {_x isEqualType ""}];
  if (_rewardState in ["","armed","detonated"] && {_rewardUID isEqualType ""} && {_nuclearUnlocked isEqualType true}) then {_s set ["rewardState",_rewardState];_s set ["rewardUID",_rewardUID];_s set ["nuclearUnlocked",_nuclearUnlocked];};
  _s set ["dead",_dead];_s set ["respawnAt",if (_dead) then {serverTime+(_remaining max 0 min 1800)} else {0}];
 };
};
DSDS_mysticState=_s;
[] call DSDS_fnc_mysticPublish;
true
