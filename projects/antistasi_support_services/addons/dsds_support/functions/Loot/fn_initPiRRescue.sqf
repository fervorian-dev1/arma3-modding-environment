/* Keep native player revive and PiR medical supplies; restore PiR AI injuries.
   Runs before mission startup and again at postInit. No injury EH removal. */
if (isRemoteExecuted) exitWith {};
private _apply={
 if (isNil "PiR_injuriplayer_on" && {!fileExists "\PiR\Functions\PiRinit.sqf"}) exitWith {};
 PiR_injuriplayer_on=false;
 PiR_injuriAI_on=true;
};
call _apply;
if (missionNamespace getVariable ["DSDS_nativeReviveBridge",false]) exitWith {};
DSDS_nativeReviveBridge=true;
["CBA_settingsInitialized",_apply] call CBA_fnc_addEventHandler;
[] spawn {
 waitUntil {sleep 0.2;!isNil "A3A_faction_reb"};
 while {true} do {
  // Player medical authority stays native; AI retains PiR hit/knockdown reactions.
  // Enforce both independent switches after hosted/server/JIP settings sync.
  if (!isNil "PiR_injuriplayer_on") then {
   PiR_injuriplayer_on=false;PiR_injuriAI_on=true;
   private _faks=+(A3A_faction_reb getOrDefault ["firstAidKits",[]]);
   private _kits=+(A3A_faction_reb getOrDefault ["mediKits",[]]);
   {
    if (isClass (configFile >> "CfgWeapons" >> _x)) then {_faks pushBackUnique _x;};
   } forEach ((missionNamespace getVariable ["PiR_changeIFAK",[]])+["PiR_bint"]);
   {
    if (isClass (configFile >> "CfgWeapons" >> _x)) then {_kits pushBackUnique _x;};
   } forEach ((missionNamespace getVariable ["PiR_changeMedKit",[]])+["PiR_apteka"]);
   A3A_faction_reb set ["firstAidKits",_faks];
   A3A_faction_reb set ["mediKits",_kits];
  };
  sleep 5;
 };
};

if (hasInterface) then {[] spawn {
 private _old=objNull;private _action=-1;
 while {true} do {
  if (!isNull player && {player!=_old}) then {
   if (!isNull _old && {_action>=0}) then {_old removeAction _action;};_old=player;
   _action=player addAction ["Treat yourself",{[] spawn DSDS_fnc_selfTreat;},nil,1.6,true,true,"","alive _this && lifeState _this != 'INCAPACITATED' && isNull objectParent _this && (damage _this > 0.001 || {(((getAllHitPointsDamage _this) param [2,[]]) findIf {_x>0.01})>=0}) && !(_this getVariable ['DSDS_selfTreatBusy',false]) && {(({_x in items _this} count ((missionNamespace getVariable ['PiR_changeMedKit',[]])+(missionNamespace getVariable ['PiR_changeIFAK',[]])+['PiR_apteka','PiR_bint']))>0)}",2];
  };
  sleep 1;
 };
};};
