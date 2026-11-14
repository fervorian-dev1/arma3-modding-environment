/* Presentation only: keep native attribution, punishment, damage and revive logic. */
if (!hasInterface || {isRemoteExecuted} || {missionNamespace getVariable ["DSDS_silentFFInitialized",false]}) exitWith {};
DSDS_silentFFInitialized=true;
DSDS_silentFFChatEH=addMissionEventHandler ["HandleChatMessage",{
 params ["_channel","_owner","_from","_text","_person","_name",["_strID",""],["_forcedDisplay",false],["_isPlayerMessage",false]];
 if (_isPlayerMessage || {_channel!=6}) exitWith {false};
 private _id=toLower _strID;
 private _body=toLower _text;
 // Engine system kill-feed reports; player-written chat is never filtered.
 (_body find "friendly fire")>=0 || {(_body find "friendly-fire")>=0} ||
 {(_id find "friendly")>=0 && {(_id find "kill")>=0 || {(_id find "fire")>=0}}} ||
 {(_id find "teamkill")>=0}
}];
// Antistasi uses a separate local hint queue for its friendly-fire warnings.
if (!isNil "A3A_fnc_customHint") then {
 DSDS_nativeCustomHint=A3A_fnc_customHint;
 A3A_fnc_customHint={
  private _heading=_this param [0,""];
  if (_heading isEqualTo (localize "STR_A3A_punishment_ff_notification")) exitWith {true};
  _this call DSDS_nativeCustomHint
 };
};
