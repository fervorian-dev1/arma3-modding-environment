if (!hasInterface) exitWith {};
[] spawn {
 waitUntil {sleep .1;!isNull player && {time>1}};sleep 3;
 private _passes=0;private _failures=0;
 private _assert={params ["_ok","_label"];if (_ok) then {_passes=_passes+1;} else {_failures=_failures+1;};diag_log format ["[HOST SPAWN TEST] %1: %2",["FAIL","PASS"] select _ok,_label];};
 [isServer && {hasInterface} && {isPlayer player},"real player host executes native spawn entry"] call _assert;
 teamPlayer=side group player;Occupants=west;Invaders=east;
 A3A_faction_occ=createHashMapFromArray [["faces",["WhiteHead_01"]],["voices",["Male01ENG"]],["firstNames",["Test"]],["lastNames",["Soldier"]]];A3A_faction_inv=A3A_faction_occ;A3A_faction_reb=A3A_faction_occ;A3A_faction_civ=A3A_faction_occ;
 private _friend=west getFriend teamPlayer;west setFriend [teamPlayer,0];player setCaptive true;
 private _logicGroup=createGroup sideLogic;A3A_customUnitTypes=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
 private _enemy=createGroup west;private _friendly=createGroup teamPlayer;
 private _position=(getPosATL player) getPos [250,0];private _created=[];
 // Warm up the factory/model before measuring scheduling; keep the whole group.
 private _warm=[_enemy,"B_Soldier_F",_position,[],20,"NONE"] call A3A_fnc_createUnit;_created pushBack _warm;
 [!isNull _warm && {!isNil "DSDS_nativeCreateUnit"},"adapter loads actual installed native unit factory"] call _assert;
 _warm disableAI "PATH";_warm setCaptive true;
 private _loadout=getUnitLoadout _warm;
 A3A_customUnitTypes setVariable ["DSDS_perf_type",[[_loadout],[],[],"B_Soldier_F"]];
 private _born=[];private _started=diag_tickTime;
 for "_i" from 0 to 11 do {
  private _u=[_enemy,"DSDS_perf_type",_position getPos [_i*3,90],[],0,"NONE",createHashMap] call A3A_fnc_createUnit;
  _born pushBack (DSDS_nextHostEnemySpawn-.05);_created pushBack _u;_u disableAI "PATH";_u setCaptive true;
 };
 private _elapsed=diag_tickTime-_started;
 [count (_created select {!isNull _x})==13,"all requested hostile units still spawn; none culled"] call _assert;
 [_elapsed>=.5,"host enemy wave is spread over time instead of a creation burst"] call _assert;
 private _gap=true;for "_i" from 1 to 11 do {if ((_born select _i)-(_born select (_i-1))<.045) then {_gap=false;};};
 [_gap,"concurrent-safe pacing preserves minimum enemy creation interval"] call _assert;
 [((_created select [1]) findIf {_x getVariable ["unitType",""]!="DSDS_perf_type" || {primaryWeapon _x!=(_loadout select 0 select 0)}})<0,"registered custom loadout/type and armed units preserved"] call _assert;
 DSDS_perfConcurrent=[];private _workers=[];DSDS_perfReservationTimes=[];DSDS_perfOriginalFactory=DSDS_nativeCreateUnit;
 DSDS_nativeCreateUnit={DSDS_perfReservationTimes pushBack diag_tickTime;_this call DSDS_perfOriginalFactory;};
 for "_job" from 1 to 2 do {_workers pushBack ([_enemy,_position] spawn {params ["_g","_p"];for "_i" from 1 to 3 do {private _u=[_g,"B_Soldier_F",_p,[],25,"NONE"] call A3A_fnc_createUnit;_u setCaptive true;_u disableAI "PATH";DSDS_perfConcurrent pushBack [DSDS_nextHostEnemySpawn-.05,_u];};});};
 waitUntil {sleep .1;(_workers findIf {!scriptDone _x})<0};
 [count DSDS_perfConcurrent==6,"concurrent reinforcement workers preserve every requested unit"] call _assert;
 DSDS_nativeCreateUnit=DSDS_perfOriginalFactory;
 private _times=+DSDS_perfReservationTimes;_times sort true;
 private _spaced=true;for "_i" from 1 to 5 do {if ((_times select _i)-(_times select (_i-1))<.045) then {_spaced=false;};};
 [_spaced,"two concurrent enemy workers share the host spawn budget"] call _assert;
 _created append (DSDS_perfConcurrent apply {_x select 1});
 DSDS_nextHostEnemySpawn=diag_tickTime+3;_started=diag_tickTime;
 private _f=[_friendly,"I_Soldier_F",_position,[],10,"NONE"] call A3A_fnc_createUnit;_created pushBack _f;
 [diag_tickTime-_started<2 && {!isNull _f},"friendly AI bypass enemy throttle"] call _assert;
 _started=diag_tickTime;private _sync=objNull;
 isNil {_sync=[_enemy,"B_Soldier_F",_position,[],10,"NONE"] call A3A_fnc_createUnit;};_created pushBack _sync;
 [diag_tickTime-_started<2 && {!isNull _sync},"unscheduled native caller remains synchronous and cannot sleep"] call _assert;
 DSDS_nextHostEnemySpawn=0;
 // A single compatibility queue processes at most eight entries per pass.
 private _oldFixed=+(missionNamespace getVariable ["tws_is_Aim_fixed",[]]);private _queueUnits=[];
 DSDS_aiCompatibilityWorker=true;DSDS_aiCompatibilityQueue=[];
 for "_i" from 1 to 12 do {private _u=[_friendly,"I_Soldier_F",_position,[],20,"NONE"] call A3A_fnc_createUnit;_queueUnits pushBack _u;_created pushBack _u;[_u,"COMBAT",.72] call DSDS_fnc_configureAddonAI;};
 isNil {
  tws_is_Aim_fixed append _queueUnits;{_x setSkill ["aimingAccuracy",.123];} forEach _queueUnits;
  [count DSDS_aiCompatibilityQueue==12,"one shared queue holds all compatibility work"] call _assert;
  [] call DSDS_fnc_tickAICompatibility;
  [count DSDS_aiCompatibilityQueue==4,"compatibility pass processes eight and defers remaining work"] call _assert;
  [] call DSDS_fnc_tickAICompatibility;
  [DSDS_aiCompatibilityQueue isEqualTo [],"next compatibility pass drains remaining work"] call _assert;
  [(_queueUnits findIf {!(_x getVariable ["DSDS_aiAccuracyIntegrated",false]) || {abs ((_x skill "commanding")-.72)>.01}})<0,"same tactical skills restored after Accuracy Fix"] call _assert;
  [(_queueUnits findIf {abs ((_x skill "aimingAccuracy")-.123)>.01})<0,"Accuracy Fix aiming values are not overwritten"] call _assert;
 };
 tws_is_Aim_fixed=_oldFixed;DSDS_aiCompatibilityWorker=false;
 private _automatic=[_friendly,"I_Soldier_F",_position,[],10,"NONE"] call A3A_fnc_createUnit;_created pushBack _automatic;
 tws_is_Aim_fixed pushBack _automatic;_automatic setSkill ["aimingAccuracy",.123];
 [_automatic,"COMBAT",.72] call DSDS_fnc_configureAddonAI;[_automatic,"COMBAT",.72] call DSDS_fnc_configureAddonAI;
 [DSDS_aiCompatibilityWorker && {count DSDS_aiCompatibilityQueue==1},"normal configuration starts one worker and duplicate configuration does not enqueue twice"] call _assert;
 private _deadline=diag_tickTime+4;waitUntil {sleep .1;_automatic getVariable ["DSDS_aiAccuracyIntegrated",false] || {diag_tickTime>_deadline}};
 [_automatic getVariable ["DSDS_aiAccuracyIntegrated",false] && {abs ((_automatic skill "aimingAccuracy")-.123)<.01},"actual background worker processes queued unit and preserves aiming"] call _assert;
 tws_is_Aim_fixed=_oldFixed;
 diag_log format ["[HOST SPAWN TEST] Paced 12-unit elapsed %1s, reservation timestamps %2. This is scheduling evidence, NOT an FPS benchmark.",_elapsed,_born];
 {deleteVehicle _x;} forEach _created;deleteGroup _enemy;deleteGroup _friendly;deleteVehicle A3A_customUnitTypes;deleteGroup _logicGroup;west setFriend [teamPlayer,_friend];
 diag_log format ["[HOST SPAWN TEST] COMPLETE: %1 PASS, %2 FAIL",_passes,_failures];
 endMission (if (_failures==0) then {"END1"} else {"LOSER"});
};



