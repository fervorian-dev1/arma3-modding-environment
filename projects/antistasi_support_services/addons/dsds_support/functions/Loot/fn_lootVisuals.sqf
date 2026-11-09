/* Only the affected player creates handles. Never alter another mod's PP or UI layers. */
params ["_unit",["_now",serverTime],["_clear",false]];
if (isRemoteExecuted || {!hasInterface}) exitWith {};
disableSerialization;
private _state=_unit getVariable ["DSDS_lootLocal",createHashMap];
private _handles=_state getOrDefault ["visuals",createHashMap];
private _tintDisplay=uiNamespace getVariable ["DSDS_contrabandTintDisplay",displayNull];
if (isNull _tintDisplay) then {{_handles deleteAt _x;} forEach ["Cocaine","Marijuana","Vape"];};
private _wanted=if (_clear || {!local _unit} || {_unit!=player} || {!alive _unit}) then {[]} else {[_unit,_now] call DSDS_fnc_lootVisualPlan};
private _keys=_wanted apply {_x select 0};
{
 if !(_x in _keys) then {
  if (_x=="Zyn") then {"DSDS_ZynOverlay" cutText ["","PLAIN",0];} else {private _handle=_handles get _x;if (_handle>=0) then {ppEffectDestroy _handle;};};
    if (_x in ["Cocaine","Marijuana","Vape"] && {!isNull _tintDisplay}) then {
     private _cfg=configFile >> "DSDS_ContrabandVisuals" >> _x;
      private _controlId=getNumber (_cfg >> "control");
      private _control=_tintDisplay displayCtrl _controlId;
     _control ctrlSetFade 1;_control ctrlCommit 0.2;
    };
  _handles deleteAt _x;
 };
} forEach (keys _handles);
{
 _x params ["_key","_expires"];
 private _cfg=configFile >> "DSDS_ContrabandVisuals" >> _key;
 if (_key=="Zyn") then {
  private _display=uiNamespace getVariable ["DSDS_zynDisplay",displayNull];
  if (isNull _display && {!(_key in _handles)}) then {
   "DSDS_ZynOverlay" cutRsc ["DSDS_ZynOverlay","PLAIN",0,false];
   _display=uiNamespace getVariable ["DSDS_zynDisplay",displayNull];
  };
  if (!isNull _display && {!(_key in _handles)}) then {
   private _control=_display displayCtrl 88520;
   _control ctrlEnable false;
   _control ctrlSetText getText (_cfg >> "texture");
   _control ctrlSetFade 1;_control ctrlCommit 0;
   _control ctrlSetFade (1-getNumber (_cfg >> "opacity"));
   _control ctrlCommit (getNumber (_cfg >> "fade") min (_expires-_now));
   _handles set [_key,-1];
  };
  // A mission UI reload may close our title. Recreate on the next tick, never each frame.
  if (isNull _display) then {_handles deleteAt _key;};
 } else {
  if !(_key in _handles) then {
     if (_key in ["Cocaine","Marijuana","Vape"]) then {
        if (isNull _tintDisplay) then {
         "DSDS_ContrabandTintOverlay" cutRsc ["DSDS_ContrabandTintOverlay","PLAIN",0,false];
         _tintDisplay=uiNamespace getVariable ["DSDS_contrabandTintDisplay",displayNull];
        };
        if (!isNull _tintDisplay) then {
         private _controlId=getNumber (_cfg >> "control");
         private _control=_tintDisplay displayCtrl _controlId;
         _control ctrlSetBackgroundColor getArray (_cfg >> "color");
         _control ctrlSetFade 1;_control ctrlCommit 0;
         _control ctrlSetFade 0;_control ctrlCommit (getNumber (_cfg >> "fade") min (_expires-_now));
         _handles set [_key,-2];
        };
     } else {
        private _handle=-1;private _priority=getNumber (_cfg >> "priority");
        private _limit=_priority+20;
        while {_handle<0 && {_priority<_limit}} do {_handle=ppEffectCreate [getText (_cfg >> "effect"),_priority];_priority=_priority+1;};
        if (_handle>=0) then {
         _handle ppEffectEnable true;
         private _neutral=[0,0,0,4.1,3.7,2.5,1.85,0,0,0,0,0.5,0.3,10,6];
         _handle ppEffectAdjust _neutral;_handle ppEffectCommit 0;
         _handle ppEffectAdjust getArray (_cfg >> "settings");
         _handle ppEffectCommit (getNumber (_cfg >> "fade") min (_expires-_now));
         _handles set [_key,_handle];
        };
   };
  };
 };
} forEach _wanted;
_state set ["visuals",_handles];
_unit setVariable ["DSDS_lootLocal",_state];
