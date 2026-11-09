if (missionNamespace getVariable ["DSDS_mysticInitialized",false]) exitWith {};
DSDS_mysticInitialized=true;
if (isServer) then {
 DSDS_mystic=objNull;publicVariable "DSDS_mystic";
 DSDS_oswaldVehicles=[];publicVariable "DSDS_oswaldVehicles";
 [] spawn {
  waitUntil {sleep 1;missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_saveTarget"}};
  [] call DSDS_fnc_mysticLoad;
  while {true} do {[] call DSDS_fnc_mysticTick;sleep 1;};
 };
 [] spawn {
  while {true} do {private _protected=[] call DSDS_fnc_oswaldAircraft;if (_protected isNotEqualTo (missionNamespace getVariable ["DSDS_oswaldVehicles",[]])) then {DSDS_oswaldVehicles=_protected;publicVariable "DSDS_oswaldVehicles";};sleep 0.2;};
 };
};
DSDS_oswaldLocalWorker=[] spawn {while {true} do {[] call DSDS_fnc_oswaldTick;sleep 0.05;};};
if (hasInterface) then {[] spawn {
 while {true} do {
  private _npc=missionNamespace getVariable ["DSDS_mystic",objNull];
  if (!isNull _npc && {actionIDs _npc findIf {((_npc actionParams _x) param [0,""])=="Speak to Mystic"}<0}) then {
   _npc addAction ["Speak to Mystic",{["OPEN",player,[]] remoteExecCall ["DSDS_fnc_mysticRequest",2];},nil,1.5,true,true,"","alive _target && alive _this",6];
  };
  disableSerialization;
  private _display=findDisplay 88410;
  if (!isNull _display) then {private _info=missionNamespace getVariable ["DSDS_mysticInfo",[false,false,0,40,false]];(_display displayCtrl 1717) ctrlShow ((_info select 0) && {!(_info select 1)});};
  [] call DSDS_fnc_mysticRefresh;
  sleep 1;
 };
};};
