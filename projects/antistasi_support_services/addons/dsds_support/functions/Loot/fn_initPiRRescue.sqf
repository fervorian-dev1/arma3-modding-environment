/* Use Antistasi's native revive, retaining PiR inventory supplies.
   Runs before mission startup and again at postInit. No injury EH removal. */
if (isRemoteExecuted) exitWith {};
private _disable={
 if (isNil "PiR_injuriplayer_on" && {!fileExists "\PiR\Functions\PiRinit.sqf"}) exitWith {};
 PiR_injuriplayer_on=false;
 PiR_injuriAI_on=false;
};
call _disable;
if (missionNamespace getVariable ["DSDS_nativeReviveBridge",false]) exitWith {};
DSDS_nativeReviveBridge=true;
["CBA_settingsInitialized",_disable] call CBA_fnc_addEventHandler;
[] spawn {
 waitUntil {sleep 0.2;!isNil "A3A_faction_reb"};
 while {true} do {
  // Enforce after settings synchronization, including hosted/server/JIP machines.
  if (!isNil "PiR_injuriplayer_on") then {
   PiR_injuriplayer_on=false;PiR_injuriAI_on=false;
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
