[] spawn {
 sleep 3;DSDS_defensePasses=0;DSDS_defenseFailures=0;
 private _assert={params ["_ok","_text"];if (_ok) then {DSDS_defensePasses=DSDS_defensePasses+1;} else {DSDS_defenseFailures=DSDS_defenseFailures+1;};diag_log format ["[DEFENSE TEST] %1: %2",["FAIL","PASS"] select _ok,_text];};
 teamPlayer=resistance;Occupants=west;Invaders=east;tierWar=8;aggressionOccupants=0;aggressionInvaders=0;distanceSPWN=1500;
 A3A_faction_occ=createHashMapFromArray [["unitRifle",["B_Soldier_F","B_Soldier_F","B_Soldier_F"]],["unitPilot","B_Helipilot_F"],["unitCrew","B_crew_F"],["vehiclesTrucks",["B_Truck_01_transport_F"]],["vehiclesAmmoTrucks",["B_Truck_01_ammo_F"]],["vehiclesFuelTrucks",["B_Truck_01_fuel_F"]],["vehiclesRepairTrucks",["B_Truck_01_Repair_F"]],["vehiclesMedical",["B_Truck_01_medical_F"]],["vehiclesLightArmed",["B_MRAP_01_hmg_F"]],["vehiclesAPCs",["B_APC_Wheeled_01_cannon_F"]],["vehiclesTanks",["B_MBT_01_cannon_F"]],["vehiclesHelisTransport",["B_Heli_Transport_01_F"]],["vehiclesHelisLight",["B_Heli_Light_01_F"]]];
 A3A_faction_inv=A3A_faction_occ;A3A_faction_reb=createHashMapFromArray [["lootCrate","B_supplyCrate_F"]];A3A_faction_all=createHashMap;
 private _logicGroup=createGroup sideLogic;A3A_customUnitTypes=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
 // v3.4: paid-only Watch migration, authoritative marker and obstacle-aware spawn.
 [getNumber (configFile >> "CfgWeapons" >> "DSDS_Oswald" >> "scope")==1 && {getNumber (configFile >> "A3U" >> "forbiddenItems" >> "DSDS_Oswald" >> "unlimited")==0},"Oswald excluded from public Watch enumeration and unlimited unlocks"] call _assert;
 private _oldJna=missionNamespace getVariable ["jna_dataList",[]];jna_dataList=[];for "_i" from 0 to 26 do {jna_dataList pushBack [];};
 private _watchIndex=["DSDS_Oswald"] call jn_fnc_arsenal_itemType;
 jna_dataList set [_watchIndex,[["ItemWatch",-1],["DSDS_Oswald",-1]]];allWatches=["ItemWatch","DSDS_Oswald"];unlockedWatches=+allWatches;lootBasicItem=+allWatches;
 [] call DSDS_fnc_protectOswaldArsenal;
 [((jna_dataList select _watchIndex) findIf {(_x select 0)=="DSDS_Oswald"})<0 && {"ItemWatch" in allWatches} && {!("DSDS_Oswald" in unlockedWatches)},"legacy free Oswald unlock removed without touching normal Watch"] call _assert;
 jna_dataList set [_watchIndex,[["DSDS_Oswald",2]]];[] call DSDS_fnc_protectOswaldArsenal;
 [jna_dataList select _watchIndex isEqualTo [["DSDS_Oswald",2]],"finite deposited Oswald stock preserved"] call _assert;jna_dataList=_oldJna;
 private _probe=["B_Truck_01_transport_F",[14000,16000,0]] call DSDS_fnc_findConvoySpawn;
 [_probe isNotEqualTo [] && {!surfaceIsWater _probe} && {_probe distance2D [14000,16000,0]<200},"ground vehicle search returns open roadside clearing near requested route"] call _assert;
 if (_probe isNotEqualTo []) then {
  private _block=createVehicle ["Land_Cargo20_military_green_F",_probe,[],0,"CAN_COLLIDE"];
  private _second=["B_Truck_01_transport_F",_probe] call DSDS_fnc_findConvoySpawn;
  [_second isNotEqualTo [] && {_second distance2D _block>8},"occupied clearing is rejected in favor of another open position"] call _assert;deleteVehicle _block;
 };
 private _workerCode=str DSDS_nativeConvoyOriginal;
 [(_workerCode find "DSDS_fnc_isConvoyRoadSpawnClear")>=0 && {(_workerCode find "Objective cancelled: no safe clearing")>=0},"real native worker compiles safe spawn and clean objective-failure path"] call _assert;
 private _trackingTruck=createVehicle ["B_Truck_01_transport_F",[14000,16000,0],[],0,"NONE"];private _trackingTask="CONVOY_HOTFIX_TRACK";
 [[teamPlayer,civilian],_trackingTask,["Track truck","Tracked Convoy",""],getPosATL _trackingTruck,false,0,false,"truck",true] call BIS_fnc_taskCreate;
 [_trackingTruck,_trackingTask] spawn DSDS_fnc_trackConvoyObjective;sleep .3;
 private _marker=_trackingTask+"_DSDS_OBJECTIVE";
 [markerAlpha _marker==1 && {markerPos _marker distance2D _trackingTruck<1},"unknown objective gets visible global marker immediately"] call _assert;
 _trackingTruck setPosATL [14100,16100,0];sleep 2.5;
 [markerPos _marker distance2D _trackingTruck<1,"objective marker follows actual moving truck"] call _assert;
 private _trackedCrate=createVehicle ["B_supplyCrate_F",[14200,16200,0],[],0,"NONE"];_trackingTruck setVariable ["DSDS_objectiveCargo",_trackedCrate];sleep 2.5;
 [markerPos _marker distance2D _trackedCrate<1,"Money/Supplies marker follows actual objective cargo after unloading"] call _assert;
 deleteVehicle _trackedCrate;
 [_trackingTask,"SUCCEEDED",false] call BIS_fnc_taskSetState;sleep 2.5;
 [markerType _marker=="","terminal mission removes objective tracker"] call _assert;deleteVehicle _trackingTruck;[_trackingTask] call BIS_fnc_deleteTask;
 // Shared Fence visit episodes and a real two-team overwatch encounter.
 private _savedFence=missionNamespace getVariable ["DSDS_fence",objNull];private _savedTent=missionNamespace getVariable ["DSDS_fenceTent",objNull];
 private _testCamp=[[14000,16000,0],0,500,12,0,0.12,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
 private _civilGroup=createGroup civilian;private _fence=_civilGroup createUnit ["C_man_1",_testCamp,[],0,"NONE"];_fence disableAI "PATH";
 private _visitGroup=createGroup resistance;private _visitor=_visitGroup createUnit ["I_Soldier_F",(_testCamp getPos [5,90]),[],0,"NONE"];_visitor disableAI "PATH";_visitor allowDamage false;
 DSDS_fence=_fence;DSDS_fenceTent=objNull;DSDS_fenceVisits=createHashMap;
 [[_visitor],100,1] call DSDS_fnc_tickFenceVisits;private _visits=DSDS_fenceVisits;
 [_visits get "count"==1,"first Fence arrival counts one visit"] call _assert;
 [[_visitor],105,0] call DSDS_fnc_tickFenceVisits;[[_visitor,_visitor],110,0] call DSDS_fnc_tickFenceVisits;
 [_visits get "count"==1 && {count (_visits get "active")==0},"loitering and multiple squad members cannot inflate visits or trigger early ambush"] call _assert;
 _visitor setPosATL (_testCamp getPos [1000,90]);[[_visitor],120,1] call DSDS_fnc_tickFenceVisits;[[_visitor],179,1] call DSDS_fnc_tickFenceVisits;
 [_visits get "inside","less than sixty clear seconds does not rearm visit counter"] call _assert;
 [[_visitor],180,1] call DSDS_fnc_tickFenceVisits;
 _visitor setPosATL (_testCamp getPos [5,90]);[[_visitor],181,1] call DSDS_fnc_tickFenceVisits;
 [_visits get "count"==2,"return after departure counts second distinct visit"] call _assert;
 _visitor setPosATL (_testCamp getPos [1000,90]);[[_visitor],190,1] call DSDS_fnc_tickFenceVisits;[[_visitor],250,0] call DSDS_fnc_tickFenceVisits;
 [!(_visits getOrDefault ["pending",false]),"two visits cannot prepare snipers even on winning roll"] call _assert;
 _visitor setPosATL (_testCamp getPos [5,90]);[[_visitor],251,1] call DSDS_fnc_tickFenceVisits;
 _visitor setPosATL (_testCamp getPos [1000,90]);[[_visitor],260,1] call DSDS_fnc_tickFenceVisits;[[_visitor],320,1] call DSDS_fnc_tickFenceVisits;
 [_visits get "count"==3 && {_visits get "rolled"==3} && {!(_visits getOrDefault ["pending",false])},"third completed visit permits one intermittent roll, not guaranteed ambush"] call _assert;
 [[_visitor],325,0] call DSDS_fnc_tickFenceVisits;
 [!(_visits getOrDefault ["pending",false]),"remaining away cannot reroll repeatedly for same visit"] call _assert;
 // Actual installed faction role structure, with deterministic vanilla sniper loadout.
 A3A_faction_occ set ["groupTierSniper",[["B_sniper_F","B_Soldier_F"],["B_sniper_F","B_Soldier_F"],["B_sniper_F","B_Soldier_F"]]];
 private _friend=west getFriend resistance;west setFriend [resistance,0];
 _visitor setPosATL (_testCamp getPos [5,90]);[[_visitor],330,0] call DSDS_fnc_tickFenceVisits;
 _visitor setPosATL (_testCamp getPos [1500,90]);[[_visitor],340,0] call DSDS_fnc_tickFenceVisits;[[_visitor],400,0] call DSDS_fnc_tickFenceVisits;
 private _end=diag_tickTime+45;waitUntil {sleep .2;!(_visits getOrDefault ["pending",false]) || {diag_tickTime>_end}};
 private _ambush=_visits get "active";
 [count _ambush>0,"actual empty Fence camp prepares overwatch after later visit"] call _assert;
 if (count _ambush>0) then {
  [count (_ambush get "groups")==2 && {count (_ambush get "units")==8} && {((_ambush get "groups") findIf {count units _x!=4})<0},"exactly two teams of four real snipers"] call _assert;
  [((_ambush get "units") findIf {typeOf _x!="B_sniper_F" || {side group _x!=west}})<0,"native faction sniper role and occupying side retained"] call _assert;
  [((_ambush get "units") findIf {primaryWeapon _x=="" || {magazines _x isEqualTo []}})<0,"all eight snipers spawn with weapons and ammunition"] call _assert;
  [((_ambush get "groups") findIf {combatMode _x!="BLUE"})<0 && {!(_ambush get "engaged")},"snipers hold fire awaiting return"] call _assert;
  [((_ambush get "units") findIf {unitPos _x!="DOWN" || {simulationEnabled _x==false}})<0,"snipers remain prone with normal combat simulation"] call _assert;
  _visitor setPosATL (_testCamp getPos [5,90]);[[_visitor],401,0] call DSDS_fnc_tickFenceVisits;
  [_ambush get "engaged" && {((_ambush get "groups") findIf {combatMode _x!="RED"})<0},"returning visitor triggers silent live ambush"] call _assert;
  private _count=count (_ambush get "units");[[_visitor],402,0] call DSDS_fnc_tickFenceVisits;
  [count ((_visits get "active") get "units")==_count,"repeated visit ticks cannot stack sniper teams"] call _assert;
  private _protected=(_ambush get "units") select 0;_protected setCaptive true;
  DSDS_fence=objNull;[[_visitor],403,0] call DSDS_fnc_tickFenceVisits;
  [count (_visits get "active")==0 && {!isNull _protected},"camp disappearance retires encounter and preserves captured sniper"] call _assert;
  _visitor setPosATL [20000,20000,0];[[_visitor],404,0] call DSDS_fnc_tickFenceVisits;sleep .2;
  [((_ambush get "units") findIf {!isNull _x && {_x!=_protected}})<0 && {!isNull _protected},"distant owned snipers cleaned while captive remains"] call _assert;
  deleteVehicle _protected;{deleteGroup _x;} forEach (_ambush get "groups");
 };
 west setFriend [resistance,_friend];deleteVehicle _visitor;deleteGroup _visitGroup;deleteVehicle _fence;deleteGroup _civilGroup;
 DSDS_fence=_savedFence;DSDS_fenceTent=_savedTent;DSDS_fenceVisits=createHashMap;

 private _themes=[
 ["METALS",["DSDS_GoldBullion","DSDS_PalladiumSponges","DSDS_IndustrialPlatinum"]],
 ["TECH",["DSDS_SiliconWafers","DSDS_Microchips","DSDS_PalladiumSponges"]],
 ["JEWELRY",["DSDS_CutGems","DSDS_RoughGems","DSDS_GoldBullion"]]
 ];
 {
  _x params ["_theme","_expected"];
  private _truck=createVehicle ["B_Truck_01_transport_F",[13800+_forEachIndex*40,16000,0],[],0,"NONE"];
  private _record=[_truck,west,"","SPECIAL",_theme] call DSDS_fnc_upgradeConvoy;
  [count _record>0 && {(_record get "pool") isEqualTo _expected} && {_record get "theme"==_theme},"actual convoy selects requested subsection "+_theme] call _assert;
  private _classes=getItemCargo _truck select 0;
  [count _classes==3 && {(_classes findIf {!(_x in _expected)})<0} && {(_expected findIf {!(_x in _classes)})<0},"actual cargo contains precisely its three themed goods: "+_theme] call _assert;
  _record set ["finished",true];deleteVehicle _truck;
 } forEach _themes;
 {
  private _truck=createVehicle [_x,[13800,16100,0],[],0,"NONE"];clearItemCargoGlobal _truck;_truck addItemCargoGlobal ["FirstAidKit",4];
  [count ([_truck,west,"","ISOTOPE"] call DSDS_fnc_upgradeConvoy)==0 && {getItemCargo _truck isEqualTo [["FirstAidKit"],[4]]},"isotope conversion refuses specialized truck without deleting its cargo: "+_x] call _assert;
  deleteVehicle _truck;
 } forEach ["B_Truck_01_ammo_F","B_Truck_01_fuel_F","B_Truck_01_Repair_F"];
 private _last=0;
 {
  aggressionOccupants=_x;private _p=[west] call DSDS_fnc_convoyDefenseProfile;
  [_p get "groundEscorts">_last,"successively larger escort bands at aggression "+str _x] call _assert;_last=_p get "groundEscorts";
 } forEach [0,30,60,90];
 aggressionOccupants=90;aggressionInvaders=0;
 private _trucks=[west,"ISOTOPE"] call DSDS_fnc_convoyCargoTrucks;
 ["B_Truck_01_medical_F" in _trucks && {"B_Truck_01_transport_F" in _trucks} && {(_trucks findIf {!([_x,west] call DSDS_fnc_isConvoyCargoTruck)})<0},"isotope pool contains appropriate faction medical and cargo trucks only"] call _assert;
 private _airPool=[west] call DSDS_fnc_convoyDoorHelis;
 [count _airPool>0,"a loaded transport with genuine non-splash door-gun magazines is selected"] call _assert;
 diag_log format ["[DEFENSE TEST] Valid kinetic door-gun transports: %1",_airPool];
 private _gunRecord=createHashMapFromArray [["id","ARMED_TEST"],["side",west],["faction",[west] call DSDS_fnc_smugglingFaction],["units",[]],["groups",[]],["vehicles",[]]];
 private _gunSpawn=[_gunRecord,_airPool select 0,[13700,16100,180],0,true] call DSDS_fnc_smugglingVehicle;private _heli=_gunSpawn select 0;
 diag_log format ["[HOTFIX GUNS] Class %1 crew %2 mags %3",typeOf _heli,fullCrew _heli,magazinesAllTurrets _heli];
 private _unsafe=("getNumber (_x >> 'scope')==2" configClasses (configFile >> "CfgMagazines")) select {private _ammo=configFile >> "CfgAmmo" >> getText (_x >> "ammo");toLower getText (_ammo >> "simulation") in ["shotrocket","shotmissile"]};
 private _bad=configName (_unsafe select 0);_heli addMagazineTurret [_bad,[-1]];_heli addMagazineTurret [_bad,[0]];
 [[_heli] call DSDS_fnc_sanitizeConvoyHeli,"sanitizer retains functional door guns"] call _assert;
 private _safe=true;{if (((_heli magazinesTurret _x) findIf {!([_x] call DSDS_fnc_safeDoorAmmo)})>=0) then {_safe=false;};} forEach ([[-1]]+allTurrets [_heli,false]);
 [_safe && {(_heli weaponsTurret [-1]) isEqualTo []},"injected rocket magazines are removed from both pilot and door turret"] call _assert;
 {_heli setMagazineTurretAmmo [_x select 0,0,_x select 1];} forEach magazinesAllTurrets _heli;
 [!([_heli] call DSDS_fnc_sanitizeConvoyHeli),"empty magazines cannot pass the live armed escort check"] call _assert;
 {deleteVehicle _x;} forEach crew _heli;deleteVehicle _heli;
 // A normal native Money convoy receives defenses without changing its cargo or task.
 private _truck=createVehicle ["B_Truck_01_transport_F",[14000,16000,0],[],0,"NONE"];_truck setVariable ["ownerSide",west];clearItemCargoGlobal _truck;_truck addItemCargoGlobal ["FirstAidKit",4];
 private _taskId="CONVOY_DEFENSE_NATIVE";private _convoyType="Money";private _markName=localize "STR_marker_convoy_objective";
 [[teamPlayer,civilian],_taskId,["Original native objective","Native money convoy",""],getPosATL _truck,false,0,false,"truck",true] call BIS_fnc_taskCreate;
 ["AIVehInit",[_truck,west]] call A3A_Events_fnc_triggerEvent;
 private _index=DSDS_nativeDefenseQueue findIf {(_x select 0)==_truck};
 [_index>=0,"installed native AIVehInit registry recognizes ordinary Money convoy"] call _assert;
 if (_index>=0) then {(DSDS_nativeDefenseQueue select _index) set [3,serverTime];};
 private _deadline=diag_tickTime+30;waitUntil {sleep 0.25;(DSDS_nativeConvoys getOrDefault [_taskId,createHashMap]) getOrDefault ["coverReady",false] || {diag_tickTime>_deadline}};
 private _record=DSDS_nativeConvoys getOrDefault [_taskId,createHashMap];
 [count _record>0 && {_record getOrDefault ["coverReady",false]},"native convoy defense job actually completes"] call _assert;
 if (count _record>0) then {
  private _cover=_record getOrDefault ["cover",createHashMap];
  [count (_cover getOrDefault ["vehicles",[]])==0 && {(str DSDS_nativeConvoyOriginal find "_dsdsDefense get 'extraGround'")>=0},"high aggression adds escorts through native worker, not competing roadside groups"] call _assert;
  [getItemCargo _truck isEqualTo [["FirstAidKit"],[4]] && {_truck getVariable ["DSDS_manifestID",""]==""},"ordinary native convoy contents are never converted or overwritten"] call _assert;
  private _description=[_taskId] call BIS_fnc_taskDescription;private _title=_description select 1;if (_title isEqualType []) then {_title=format _title;};
  [_title=="Native money convoy","original native task description remains intact"] call _assert;
  _truck setVariable ["ownerSide",teamPlayer];
  {deleteVehicle _x;} forEach (_cover getOrDefault ["units",[]]);{deleteVehicle _x;} forEach (_cover getOrDefault ["vehicles",[]]);{deleteGroup _x;} forEach (_cover getOrDefault ["groups",[]]);
 };
 deleteVehicle _truck;[_taskId] call BIS_fnc_deleteTask;DSDS_nativeDefenseQueue=[];
 // Petros scheduler integration: production wrapper/queue and real native event registry.
 [missionNamespace getVariable ["DSDS_nativeConvoyAdapter",false],"installed Ultimate worker passes exact objective signature and compiles adapter"] call _assert;
 private _sideLogic=createGroup sideLogic;sidesX=_sideLogic createUnit ["Logic",[0,0,0],[],0,"NONE"];sidesX setVariable ["TEST_ORIGIN",west];
 DSDS_petrosConvoyBag=[];DSDS_petrosTestSeen=[];DSDS_petrosTestTrucks=[];DSDS_nextRareConvoy=serverTime+99999;
 private _worker=DSDS_nativeCargoConvoy;private _original=DSDS_nativeConvoyOriginal;
 // Controlled worker seam: actual mission loading/route travel are outside this fixture.
 // It recreates the verified worker's dynamic objective scope and event invocation.
 DSDS_nativeCargoConvoy={
  private _textX="Depart Test Base at 21:30, bound for Test Factory.";private _convoyType=_this param [2,"Money"];private _taskId="CONVOY_PETROS_"+str count DSDS_petrosTestSeen;
  private _markName=localize "STR_marker_convoy_objective";
  DSDS_petrosTestSeen pushBack [_dsdsPetrosConvoySelection select 0,_convoyType,isRemoteExecuted];
  private _class=_dsdsPetrosConvoySelection select 1;if (_class=="") then {_class="B_Truck_01_transport_F";};
  private _truck=createVehicle [_class,[14500+count DSDS_petrosTestSeen*60,16000,0],[],0,"NONE"];
  _truck setVariable ["ownerSide",west];clearItemCargoGlobal _truck;_truck addItemCargoGlobal ["FirstAidKit",4];
  [[teamPlayer,civilian],_taskId,["Original convoy","Original convoy",""],getPosATL _truck,false,0,false,"truck",true] call BIS_fnc_taskCreate;
  ["AIVehInit",[_truck,west]] call A3A_Events_fnc_triggerEvent;
  private _bag=+(missionNamespace getVariable ["DSDS_petrosConvoyBag",[]]);
  ["AIVehInit",[_truck,west]] call A3A_Events_fnc_triggerEvent;
  DSDS_petrosDuplicateSafe=_bag isEqualTo DSDS_petrosConvoyBag;
  DSDS_petrosTestTrucks pushBack [_truck,_taskId,_dsdsPetrosConvoySelection select 0];
 };
 DSDS_nativeConvoyOriginal={_this call DSDS_nativeCargoConvoy;};
 for "_i" from 1 to 4 do {
  ["TEST_DEST","TEST_ORIGIN"] remoteExec ["A3A_fnc_convoy",2];
  private _end=diag_tickTime+8;waitUntil {sleep .1;count DSDS_petrosTestSeen>=_i || {diag_tickTime>_end}};
 };
 private _kinds=DSDS_petrosTestSeen apply {_x select 0};
 [count _kinds==4 && {count (_kinds arrayIntersect _kinds)==4} && {(_kinds findIf {!(_x in ["SPECIAL","MEDICAL","ISOTOPE",""])})<0},"four Petros requests include each custom convoy and one ordinary convoy without rare cooldown blocking"] call _assert;
 [(DSDS_petrosTestSeen findIf {_x select 2})<0,"real scheduler RPC drains outside remote-execution context"] call _assert;
 [DSDS_petrosDuplicateSafe,"duplicate objective callback cannot consume another rotation entry"] call _assert;
 [(DSDS_petrosTestSeen findIf {(_x select 0)!="" && {(_x select 1)!="Ammunition"}})<0,"custom requests retain native capture/destroy cargo mission handling"] call _assert;
 {if ((_x select 3)>serverTime) then {_x set [3,serverTime+60];};} forEach DSDS_nativeDefenseQueue;
 private _end=diag_tickTime+45;waitUntil {sleep .25;({private _t=_x select 0;(_x select 2)=="" || {(DSDS_smugglingRecords getOrDefault [_t getVariable ["DSDS_manifestID",""],createHashMap]) getOrDefault ["coverInitialized",false]}} count DSDS_petrosTestTrucks)==4 || {diag_tickTime>_end}};
 {
  _x params ["_truck","_taskId","_kind"];
  private _r=DSDS_smugglingRecords getOrDefault [_truck getVariable ["DSDS_manifestID",""],createHashMap];
  if (_kind=="") then {[getItemCargo _truck isEqualTo [["FirstAidKit"],[4]],"ordinary Petros cargo remains intact"] call _assert;} else {
   diag_log format ["[BRIEF TEST] task=%1 saved=%2 actual=%3",_taskId,_truck getVariable ["DSDS_convoyBriefing","MISSING"],[_taskId] call BIS_fnc_taskDescription];
   [(str (([_taskId] call BIS_fnc_taskDescription) select 0)) find "21:30">=0,"custom cargo retains native departure and destination briefing"] call _assert;
   [count _r>0 && {_r get "kind"==_kind},"Petros objective receives actual "+_kind+" upgrade"] call _assert;
   [count (getItemCargo _truck select 0)>0,"Petros "+_kind+" has real inventory cargo"] call _assert;
   if (_kind=="ISOTOPE") then {[[typeOf _truck,west] call DSDS_fnc_isConvoyCargoTruck,"Petros isotopes use valid cargo truck, never ammo/fuel/repair vehicle"] call _assert;};
   _r set ["finished",true];
  };
  deleteVehicle _truck;[_taskId] call BIS_fnc_deleteTask;
 } forEach DSDS_petrosTestTrucks;
 DSDS_nativeConvoyOriginal={DSDS_petrosExplicit=_this;};DSDS_petrosExplicit=[];
 ["D","O","Supplies","attack"] call A3A_fnc_convoy;
 [DSDS_petrosExplicit isEqualTo ["D","O","Supplies","attack"],"explicit native attack calls delegate unchanged to original"] call _assert;
 DSDS_nativeConvoyOriginal=_original;DSDS_nativeCargoConvoy=_worker;
 deleteVehicle sidesX;deleteGroup _sideLogic;DSDS_nativeDefenseQueue=[];
 // Confirm successful containment queueing is silent, using the real queue function.
 private _actorGroup=createGroup resistance;private _actor=_actorGroup createUnit ["I_Soldier_F",[14500,16000,0],[],0,"NONE"];
 private _client=DSDS_fnc_clientService;DSDS_testMessages=[];DSDS_fnc_clientService={if (_this select 0=="MESSAGE") then {DSDS_testMessages pushBack (_this select 1);};};
 private _savedQueue=+DSDS_missionQueue;
 private _queued=false;isNil {_queued=["CONTAMINATION",_actor,[14500,16000,0],true] call DSDS_fnc_queueCustomMission;DSDS_missionQueue=_savedQueue;};
 sleep .5;
 [_queued && {DSDS_testMessages isEqualTo []},"Containment debug mission queues successfully with no launch notification"] call _assert;
 DSDS_fnc_clientService=_client;deleteVehicle _actor;deleteGroup _actorGroup;
 // Actual installed support transport: explicit rear cargo, crew locks and jump.
 private _passengerGroup=createGroup resistance;private _passenger=_passengerGroup createUnit ["I_Soldier_F",[14000,15000,0],[],0,"NONE"];
 private _job=createHashMapFromArray [["type","PARADROP"],["origin",[14000,15000,0]],["target",[15500,15000,0]],["player",_passenger]];
 private _flight=[_job] call DSDS_fnc_spawnSupportAircraft;
 [count _flight>0,"actual parachute support aircraft spawns"] call _assert;
 if (_flight isNotEqualTo []) then {
  private _plane=_flight select 0;private _pilot=driver _plane;
  private _slots=(fullCrew [_plane,"cargo",true]) apply {_x select 2};_slots sort false;
  [[_passenger,_plane] call DSDS_fnc_boardSupportPassenger,"actual passenger boards rear cargo"] call _assert;
  private _seat=(fullCrew [_plane,"cargo",false]) select {(_x select 0)==_passenger};
  [count _seat==1 && {(_seat select 0 select 2)==(_slots select 0)},"passenger uses highest-index cargo proxy, not an automatic front seat"] call _assert;
  [driver _plane==_pilot && {_pilot!=_passenger},"original AI pilot retained"] call _assert;
  [lockedDriver _plane,"parachute transport pilot seat is locked"] call _assert;
  [((allTurrets [_plane,true]) findIf {!(_plane lockedTurret _x)})<0,"all copilot/turret stations are locked"] call _assert;
  [[_passenger,_plane] call DSDS_fnc_jumpSupportPassenger,"cargo passenger still jumps into real parachute"] call _assert;
  private _chute=_passenger getVariable ["DSDS_parachute",objNull];
  [!isNull _chute && {vehicle _passenger==_chute},"jump places passenger in parachute rather than aircraft cockpit"] call _assert;
  moveOut _passenger;deleteVehicle _chute;{deleteVehicle _x;} forEach (_flight select 1);deleteVehicle _plane;deleteGroup (_flight select 2);
 };
 deleteVehicle _passenger;deleteGroup _passengerGroup;
 // Evaluate the actual adapted native payout expression, including above-floor scaling.
 private _code=str DSDS_nativeConvoyOriginal;private _prefix="[0,((5000*_bonus) max 70000)] remoteExec";
 private _at=_code find _prefix;
 [_at>=0,"native Money HQ-delivery reward contains requested minimum"] call _assert;
 if (_at>=0) then {
  private _expression=compile ((_code select [_at+3]) select [0,((_code select [_at+3]) find "] remoteExec")]);
  {private _bonus=_x select 0;[(call _expression)==(_x select 1),"actual Money payout at native bonus "+str _bonus] call _assert;} forEach [[0.5,70000],[1,70000],[20,100000]];
 };
 // Actual installed native road travel: two vehicles and native spacing/order.
 private _roads=[14500,16800,0] nearRoads 800;private _chain=[];
 for "_attempt" from 1 to 30 do {
  if (_roads isEqualTo []) exitWith {};
  private _road=selectRandom _roads;private _candidate=[_road];private _cursor=_road;
  for "_step" from 1 to 160 do {private _next=(roadsConnectedTo _cursor) select {!(_x in _candidate) && {!surfaceIsWater getPosATL _x}};if (_next isEqualTo []) exitWith {};_cursor=selectRandom _next;_candidate pushBack _cursor;if (_cursor distance2D _road>1800) exitWith {};};
  if (count _candidate>12 && {_cursor distance2D _road>1000}) exitWith {_chain=_candidate;};
 };
 [count _chain>12,"connected native road route found for actual driving check"] call _assert;
 if (count _chain>12) then {
  private _route=_chain apply {getPosATL _x};private _state=[];private _convoy=[];private _drivers=[];private _groups=[];
  for "_i" from 0 to 1 do {
   _state=[_route,if (_i==0) then {0} else {35},_state] call A3A_fnc_findPosOnRoute;
   private _spawn=[];
   for "_try" from 0 to 40 do {private _point=ASLToAGL (_state select 0);if (["B_Truck_01_transport_F",_point] call DSDS_fnc_isConvoyRoadSpawnClear) exitWith {_spawn=_point;};_state=[_route,15,_state] call A3A_fnc_findPosOnRoute;};
   if (_spawn isNotEqualTo []) then {
    private _v=createVehicle ["B_Truck_01_transport_F",_spawn vectorAdd [0,0,.5],[],0,"CAN_COLLIDE"];_v setVectorDirAndUp [_state select 1,vectorUp _v];_v allowDamage false;
    private _g=createGroup west;private _d=_g createUnit ["B_crew_F",_spawn,[],0,"NONE"];_d moveInDriver _v;_d allowDamage false;_d stop true;
    _g setVariable ["lambs_danger_disableGroupAI",true];_d setVariable ["lambs_danger_disableAI",true];
    _v setVariable ["DSDS_nativeConvoyTravel",true];_v setVariable ["ownerSide",west];_groups pushBack _g;_drivers pushBack _d;_convoy pushBack _v;
   };
  };
  [count _convoy==2,"two collision-checked trucks spawn on native route in sequence"] call _assert;
  if (count _convoy==2) then {
   reverse _convoy;private _starts=_convoy apply {getPosATL _x};private _initial=+_convoy;
   private _nativeRoute=_route select [_state select 2];
   private _movementRecord=createHashMapFromArray [["id","NATIVE_MOVE"],["truck",_convoy select 0],["side",west],["task",""],["kind","MEDICAL"]];
   private _oldAgg=aggressionOccupants;aggressionOccupants=0;[_movementRecord] spawn DSDS_fnc_convoyProtection;sleep .2;aggressionOccupants=_oldAgg;
   [!(_movementRecord getOrDefault ["cohesionStarted",false]),"addon does not start a competing pace/recovery controller for native convoy"] call _assert;
   sleep 2;
   [((_initial select 0) distance2D (_starts select 0))<3,"native stopped drivers remain parked before departure"] call _assert;
   {driver _x stop false;[_x,_nativeRoute,_convoy,30,true] spawn A3A_fnc_vehicleConvoyTravel;sleep 3;} forEach _initial;
   private _deadline=diag_tickTime+120;
   waitUntil {sleep 2;((_initial select 0) distance2D (_starts select 0)>100 && {(_initial select 1) distance2D (_starts select 1)>100}) || {diag_tickTime>_deadline}};
   [((_initial select 0) distance2D (_starts select 0))>100,"real native lead vehicle actually drives more than 100m after departure"] call _assert;
   [((_initial select 1) distance2D (_starts select 1))>100,"real native following vehicle actually drives more than 100m after departure"] call _assert;
   diag_log format ["[MOVEMENT TEST] Actual distances %1 speeds %2",_initial apply {_x distance2D (_starts select (_initial find _x))},_initial apply {speed _x}];
   _convoy resize 0;{deleteVehicle _x;} forEach _drivers;{deleteVehicle _x;} forEach _initial;
  } else {{deleteVehicle _x;} forEach _drivers;{deleteVehicle _x;} forEach _convoy;};
  {deleteGroup _x;} forEach _groups;
 };
 deleteVehicle A3A_customUnitTypes;deleteGroup _logicGroup;
 diag_log format ["[DEFENSE TEST] COMPLETE: %1 PASS, %2 FAIL",DSDS_defensePasses,DSDS_defenseFailures];
};

















