/* Shared arrival episodes, not menu clicks or eight squadmates counted eight times.
   Optional observer/clock/roll inputs are trusted server fixture seams only. */
params [["_observers",allPlayers],["_now",serverTime],["_roll",random 1]];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _state=missionNamespace getVariable ["DSDS_fenceVisits",createHashMap];
if (count _state==0) then {
 _state=createHashMapFromArray [["count",0],["inside",false],["awaySince",-1],["rolled",0],["npc",objNull],["active",createHashMap],["retired",[]]];
 DSDS_fenceVisits=_state;
};
private _npc=missionNamespace getVariable ["DSDS_fence",objNull];
private _active=_state get "active";
if (count _active>0) then {
 private _owned=_active get "units";
 private _ended=_active getOrDefault ["ended",false];
 if (!_ended && {isNull _npc || {!alive _npc} || {_npc!=(_active get "npc")} || {_now>=(_active get "expires")} || {(_owned findIf {alive _x && {!captive _x} && {side group _x==(_active get "side")}})<0}}) then {_active set ["ended",true];_ended=true;};
 if (_ended) then {
  {_x setCombatMode "BLUE";} forEach (_active get "groups");
  {if (!isNull _x && {alive _x} && {!captive _x} && {side group _x==(_active get "side")}) then {_x doTarget objNull;_x doWatch objNull;};} forEach _owned;
  (_state get "retired") pushBack _active;_state set ["active",createHashMap];
 } else {
  private _targets=_observers select {alive _x && {!captive _x} && {side group _x in [missionNamespace getVariable ["teamPlayer",resistance],civilian]} && {_x distance _npc<80}};
  if (_targets isNotEqualTo []) then {
   if (!(_active get "engaged")) then {
    _active set ["engaged",true];{_x setCombatMode "RED";} forEach (_active get "groups");
    diag_log "[DSDS Fence] Overwatch ambush engaged visiting rebels.";
   };
   {private _unit=_x;if (alive _unit && {!captive _unit} && {side group _unit==(_active get "side")}) then {private _target=_targets select 0;{if (_unit distance2D _x<_unit distance2D _target) then {_target=_x;};} forEach _targets;_unit reveal [_target,2];_unit doTarget _target;_unit doFire _target;};} forEach _owned;
  };
 };
};
private _pending=[];
{if ([_x,_observers,1200] call DSDS_fnc_cleanupContaminationTick) then {_pending pushBack _x;};} forEach (_state get "retired");
_state set ["retired",_pending];
if (isNull _npc || {!alive _npc}) exitWith {_state set ["inside",false];_state set ["awaySince",-1];};
if (_npc!=(_state get "npc")) then {_state set ["npc",_npc];_state set ["inside",false];_state set ["awaySince",-1];};
private _visitors=_observers select {alive _x && {side group _x in [missionNamespace getVariable ["teamPlayer",resistance],civilian]}};
private _near=(_visitors findIf {_x distance _npc<80})>=0;
private _clear=(_visitors findIf {_x distance2D _npc<180})<0;
if (_near && {!(_state get "inside")}) then {
 _state set ["count",(_state get "count")+1];_state set ["inside",true];_state set ["awaySince",-1];
};
if (_state get "inside") then {
 if (!_clear) then {_state set ["awaySince",-1];} else {
  if (_state get "awaySince"<0) then {_state set ["awaySince",_now];};
  if (_now-(_state get "awaySince")>=60) then {_state set ["inside",false];};
 };
};
// One roll per completed distinct visit, only while no visitor is nearby.
private _count=_state get "count";
if (!(_state get "inside") && {_count>=3} && {_state get "rolled"<_count} && {count (_state get "active")==0} && {!(_state getOrDefault ["pending",false])} && {(_observers findIf {alive _x && {_x distance2D _npc<900}})<0}) then {
 _state set ["rolled",_count];
 if (_roll<0.4) then {_state set ["pending",true];[_state,_npc] spawn DSDS_fnc_spawnFenceAmbush;};
};
