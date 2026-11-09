/* Owner-local recovery; follow PiR's successful-treatment flags, NOT its respawn initializer. */
params ["_unit"];
if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {false};
private _pir=_unit getVariable ["dam_ignore_injured0",false];
_unit setDamage 0;_unit setBleedingRemaining 0;_unit setFatigue 0;
_unit setVariable ["incapacitated",false,true];
if (!isNil "ace_medical_fnc_setUnconscious" && {_unit getVariable ["ACE_isUnconscious",false]}) then {[_unit,false,0,true] call ace_medical_fnc_setUnconscious;};
_unit setUnconscious false;
if (_pir) then {
 _unit setVariable ["DSDS_pirRescueUntil",serverTime+45,true];
 if (!(missionNamespace getVariable ["PiR_captive_on",true])) then {_unit setCaptive false;};
 { _unit setVariable [_x select 0,_x select 1,true]; } forEach [
 ["dam_conec_istorii0",true],["dam_uncondition_injured0",true],["dam_player_Crawl0",true],["dam_player_lecit0",true],
 ["dam_ignore_injured0",false],["dam_player_krovstoit0",true],["dam_player_krovstoitraz0",true],
 ["dam_puls_statys",1],["dam_dihanie_statys",1],["dam_krov_statys",5],["dam_ignore_HealEffect0",25],
 ["dam_ignore_CountPlayerEffect0",0],["dam_ignore_CountTimeEffect0",0]
 ];
 // PiR's queued crawl exit restores its own weapons/grenades; never replay a cached inventory.
 private _serial=(_unit getVariable ["DSDS_rescueSettleSerial",0])+1;_unit setVariable ["DSDS_rescueSettleSerial",_serial];
 [_unit,_serial] spawn {
  params ["_unit","_serial"];private _until=diag_tickTime+18;
  while {local _unit && {(_unit getVariable ["DSDS_rescueSettleSerial",0])==_serial} && {alive _unit} && {diag_tickTime<_until} && {damage _unit<0.05}} do {
   _unit setVariable ["dam_ignore_injured0",false,true];
   _unit setVariable ["dam_player_lecit0",true,true];
   _unit setVariable ["dam_player_Crawl0",true,true];
   _unit setVariable ["dam_conec_istorii0",true,true];
   _unit setVariable ["dam_uncondition_injured0",true,true];
   private _anim=toLower animationState _unit;
   if (lifeState _unit=="INCAPACITATED" || {(_anim find "unconscious")==0} || {(_anim find "pir_creep")==0} || {(_anim find "apanppne")==0}) then {_unit setUnconscious false;_unit switchMove "AmovPercMstpSrasWrflDnon";};
   sleep 0.2;
  };
  if (local _unit && {alive _unit} && {(_unit getVariable ["DSDS_rescueSettleSerial",0])==_serial}) then {
   _unit setVariable ["dam_player_lecit0",false,true];_unit setVariable ["dam_player_Crawl0",false,true];
   _unit setVariable ["dam_conec_istorii0",false,true];_unit setVariable ["dam_uncondition_injured0",false,true];
  };
 };
};
if (isNull objectParent _unit) then {_unit switchMove (if (primaryWeapon _unit!="") then {"AmovPercMstpSrasWrflDnon"} else {"AmovPercMstpSnonWnonDnon"});};
true
