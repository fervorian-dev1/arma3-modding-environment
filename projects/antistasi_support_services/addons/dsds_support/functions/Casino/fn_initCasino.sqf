if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_casinoInitialized",false]}) exitWith {};
DSDS_casinoInitialized=true;
if (hasInterface) then {addMissionEventHandler ["EachFrame",{[] call DSDS_fnc_luckyBoost;}];};
if (isServer) then {
 DSDS_luckyKilledEH=addMissionEventHandler ["EntityKilled",{_this call DSDS_fnc_luckyKill;}];
 DSDS_casinoOwned=false;publicVariable "DSDS_casinoOwned";DSDS_casinoBuilding=objNull;DSDS_casinoDealers=[];DSDS_casinoProps=[];DSDS_casinoSequence=0;DSDS_casinoBuildQueue=[];DSDS_casinoBuildLock=false;
 publicVariable "DSDS_casinoBuilding";publicVariable "DSDS_casinoDealers";
 [] spawn {
  waitUntil {sleep 1;missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_saveTarget"}};
  [] call DSDS_fnc_casinoLoad;private _restoreAt=0;
  while {true} do {
   if (!(DSDS_casinoState getOrDefault ["stored",false]) && {isNull DSDS_casinoBuilding} && {(DSDS_casinoState getOrDefault ["position",[]]) isNotEqualTo []} && {serverTime>=_restoreAt} && {!DSDS_casinoBuildLock}) then {
    _restoreAt=serverTime+30;[DSDS_casinoState get "class",DSDS_casinoState get "position",DSDS_casinoState get "direction"] call DSDS_fnc_casinoSpawn;
   };
   [] call DSDS_fnc_casinoTick;[] call DSDS_fnc_luckyTick;sleep 0.25;
  };
 };
};
if (hasInterface) then {[] spawn {
 private _lights=[];
 while {true} do {
  private _flag=missionNamespace getVariable ["flagX",objNull];
  if (!isNull _flag && {(actionIDs _flag findIf {((_flag actionParams _x) param [0,""])=="Buy casino (100,000 credits)"})<0}) then {
   _flag addAction ["Buy casino (100,000 credits)",{["BEGIN_BUILD",player,objNull,[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];},nil,1.4,true,true,"","alive _this && {!(missionNamespace getVariable ['DSDS_casinoOwned',false])}",5];
  };
  if (!isNull _flag && {(actionIDs _flag findIf {((_flag actionParams _x) param [0,""])=="Place / move casino"})<0}) then {
   _flag addAction ["Place / move casino",{["BEGIN_MOVE",player,objNull,[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];},nil,1.3,true,true,"","alive _this && {missionNamespace getVariable ['DSDS_casinoOwned',false]}",5];
  };
  {
   _x params ["_game","_npc"];
   if (!isNull _npc) then {
    _npc setSpeaker "NoVoice";_npc disableAI "RADIOPROTOCOL";
    if (face _npc!=(_npc getVariable ["DSDS_casinoFace",""])) then {_npc setFace (_npc getVariable ["DSDS_casinoFace","B_female_bun_01"]);};
    if (alive _npc && {(_lights findIf {(_x select 0)==_npc})<0}) then {
     private _light="#lightpoint" createVehicleLocal (getPosATL _npc);_light setLightColor [1,0.78,0.42];_light setLightAmbient [0.05,0.04,0.025];_light setLightBrightness 0.25;_light setLightDayLight false;_light setLightAttenuation [0,0,0,1,5,12];_light lightAttachObject [_npc,[0,0,2]];_lights pushBack [_npc,_light];
    };
    private _label="Play "+getText (configFile >> "DSDS_Casino" >> "Games" >> _game >> "label");
    if ((actionIDs _npc findIf {((_npc actionParams _x) param [0,""])==_label})<0) then {
     _npc addAction [_label,{params ["_npc","_actor"];["OPEN",_actor,_npc,[]] remoteExecCall ["DSDS_fnc_casinoRequest",2];},nil,1.5,true,true,"","alive _target && alive _this",5];
    };
   };
  } forEach (missionNamespace getVariable ["DSDS_casinoDealers",[]]);
  {if (isNull (_x select 0) || {!alive (_x select 0)}) then {deleteVehicle (_x select 1);};} forEach _lights;
  _lights=_lights select {!isNull (_x select 0) && {alive (_x select 0)}};
  sleep 2;
 };
};};
