[] spawn {
 sleep 3;private _passes=0;private _failures=0;
 private _assert={params ["_ok","_label"];if (_ok) then {_passes=_passes+1;} else {_failures=_failures+1;};diag_log format ["[NUCLEAR TEST] %1: %2",["FAIL","PASS"] select _ok,_label];};
 {private _fn=configName _x;[!isNil ("DSDS_fnc_"+_fn),"registered "+_fn] call _assert;} forEach ("true" configClasses (configFile >> "CfgFunctions" >> "DSDS" >> "Nuclear"));
 [!isNil "zen_modules_fnc_moduleNukeLocal","installed ZEN native atomic framework available"] call _assert;
 [getNumber (configFile >> "DSDS_Mystic" >> "Nuclear" >> "IED" >> "price")==174000,"nuclear IED price exactly 174000"] call _assert;
 [getText (configFile >> "CfgMagazines" >> "DSDS_NuclearIED_Mag" >> "ammo")=="DSDS_NuclearIED_Ammo","real explosive magazine references registered custom ammo"] call _assert;
 ["DSDS_NuclearIED_Mag" in getArray (configFile >> "CfgWeapons" >> "Put" >> "DSDS_NuclearMuzzle" >> "magazines"),"native Put muzzle accepts the IED"] call _assert;
 [getText (configFile >> "CfgAmmo" >> "DSDS_NuclearIED_Ammo" >> "model")==getText (configFile >> "CfgAmmo" >> "IEDUrbanSmall_Remote_Ammo" >> "model"),"IED retains native model"] call _assert;
 private _tex=getTextureInfo getText (configFile >> "CfgMagazines" >> "DSDS_NuclearIED_Mag" >> "picture");[count _tex>=2 && {_tex select 0==512},"supplied nuclear thumbnail loads"] call _assert;
 teamPlayer=resistance;A3A_saveTarget=[false,"DSDS_NUCLEAR_VALIDATION",worldName];A3A_saveData=createHashMapFromArray [["startType","new"]];[] call DSDS_fnc_mysticLoad;private _s=DSDS_mysticState;_s set ["position",[14000,16000,0]];
 [(_s get "rewardState")=="" && {!(_s get "nuclearUnlocked")},"fresh campaign has no vest or nuclear stock"] call _assert;
 private _civ=createGroup civilian;DSDS_mystic=_civ createUnit ["C_man_1",[14000,16000,0],[],0,"NONE"];DSDS_mystic enableSimulationGlobal false;
 private _group=createGroup resistance;private _actor=_group createUnit ["I_G_Soldier_F",[14001,16000,0],[],0,"NONE"];_actor disableAI "ALL";_actor allowDamage false;_actor setVariable ["DSDS_testUID","NUCLEAR_ACTOR"];_actor addBackpack "B_Carryall_oli";
 private _logicGroup=createGroup sideLogic;private _holder=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];_holder setVariable ["moneyX",500000];_actor setVariable ["owner",_holder];
 private _tx={params ["_op","_unit",["_args",[]]];private _dsdsAuthorizedPlayer=_unit;[_op,_unit,_args] call DSDS_fnc_mysticTransaction};
 [!(["REWARD",_actor] call _tx),"cannot claim before forty offerings"] call _assert;
 [!(["BUY",_actor,[1]] call _tx) && {_holder getVariable "moneyX"==500000},"nuclear offer cannot be bought before the vest detonates"] call _assert;
 _s set ["count",40];_s set ["ready",true];
 [] call DSDS_fnc_mysticSave;private _old=["DSDS_mysticState"] call A3A_fnc_returnSavedStat;
 ["DSDS_mysticState",_old select [0,10]] call A3A_fnc_setStatVariable;A3A_saveData set ["startType","load"];[] call DSDS_fnc_mysticLoad;_s=DSDS_mysticState;
 [_s get "count"==40 && {_s get "ready"} && {(_s get "rewardState")==""} && {!(_s get "nuclearUnlocked")},"old v2.6 ten-field campaign saves retain progress and expose the new reward"] call _assert;

 [["REWARD",_actor] call _tx,"reward claim succeeds after shared forty"] call _assert;
 [(_s get "rewardState")=="armed" && {_actor getVariable ["DSDS_nuclearVest",false]} && {!isNull DSDS_nuclearChest},"claim bolts a real chest prop to the bound player"] call _assert;
 [attachedTo DSDS_nuclearChest==_actor,"device is attached to character rather than removable inventory"] call _assert;
 [!(["REWARD",_actor] call _tx),"shared reward cannot be claimed twice"] call _assert;
 detach DSDS_nuclearChest;[] call DSDS_fnc_nuclearTick;[attachedTo DSDS_nuclearChest==_actor,"detaching the chest device is repaired by the server"] call _assert;
 deleteVehicle DSDS_nuclearChest;[] call DSDS_fnc_nuclearTick;[!isNull DSDS_nuclearChest && {attachedTo DSDS_nuclearChest==_actor},"removing chest prop makes it return"] call _assert;
 [] call DSDS_fnc_mysticSave;A3A_saveData set ["startType","load"];[] call DSDS_fnc_mysticLoad;_s=DSDS_mysticState;
 [(_s get "rewardState")=="armed" && {_s get "rewardUID"=="NUCLEAR_ACTOR"},"armed reward owner persists through native saved-stat restore"] call _assert;
 DSDS_nuclearWearer=_actor;
 private _victim=createVehicle ["Land_CanisterFuel_F",[14010,16000,0],[],0,"NONE"];
 private _before=missionNamespace getVariable ["DSDS_nuclearBlastCount",0];
 [[_actor] call DSDS_fnc_nuclearDetonateVest,"manual vest detonation dispatches native ZEN atomic event"] call _assert;
 [(_s get "rewardState")=="detonated" && {_s get "nuclearUnlocked"},"first actual dispatch unlocks shared nuclear stock"] call _assert;
 [!([_actor] call DSDS_fnc_nuclearDetonateVest) && {DSDS_nuclearBlastCount==_before+1},"repeat request cannot produce a duplicate nuclear blast"] call _assert;
 sleep 3;
 [!alive _victim,"real ZEN server destruction destroys nearby damageable prop"] call _assert;
 // Recreate killed Mystic at test site, preserve god-mode test actor for inventory assertions.
 if (!alive DSDS_mystic) then {deleteVehicle DSDS_mystic;DSDS_mystic=_civ createUnit ["C_man_1",[14000,16000,0],[],0,"NONE"];};DSDS_mystic allowDamage false;_actor setPosATL [14001,16000,0];
 diag_log format ["[NUCLEAR TEST] Purchase context: alive=%1 distance=%2 canAdd=%3 pending=%4 state=%5",alive _actor,_actor distance DSDS_mystic,_actor canAdd "DSDS_NuclearIED_Mag",_actor getVariable ["DSDS_mysticPending",""],_s get "nuclearUnlocked"];
 [["BUY",_actor,[1]] call _tx,"unlocked native IED purchase is accepted"] call _assert;
 private _token=_actor getVariable ["DSDS_mysticPending",""];sleep 0.3;private _worker=[_token,true] spawn DSDS_fnc_mysticFinishTrade;waitUntil {sleep 0.1;scriptDone _worker};
 ["DSDS_NuclearIED_Mag" in magazines _actor,"owning-machine inventory RPC delivers a real explosive magazine"] call _assert;
 [_holder getVariable "moneyX"==326000,"purchase deducts exactly 174000 personal credits"] call _assert;
 // Actual placement and touch-off: no fabricated direct report of an explosion.
 _actor setPosATL [14100,16000,0];
 _actor enableAI "ANIM";_actor fire ["DSDS_NuclearMuzzle","DSDS_NuclearMuzzle","DSDS_NuclearIED_Mag"];
 sleep 2;
 private _mines=allMines select {typeOf _x=="DSDS_NuclearIED_Ammo"};
 [count _mines==1 && {!("DSDS_NuclearIED_Mag" in magazines _actor)},"native Put action places the bought IED and consumes its magazine"] call _assert;
 private _mine=_mines param [0,objNull];
 if (!isNull _mine) then {
  diag_log format ["[NUCLEAR TEST] Mine context: id=%1 owner=%2 hook=%3 registry=%4",netId _mine,owner _mine,_mine getVariable ["DSDS_nuclearHook",false],keys DSDS_nuclearMines];
  [[netId _mine,[14100,16000,0]] call DSDS_fnc_nuclearIEDReport==false,"an intact mine cannot be spoofed into a detonation"] call _assert;
  _before=DSDS_nuclearBlastCount;
  _actor action ["TouchOff",_actor];sleep 4;
  [isNull _mine || {!alive _mine},"native Touch Off action detonates the IED"] call _assert;
  [DSDS_nuclearBlastCount==_before+1,"native IED explosion dispatches exactly one nuclear effect"] call _assert;
 };
 // Deletion/defusal must not create an atomic blast.
 _before=DSDS_nuclearBlastCount;private _deleted=createVehicle ["DSDS_NuclearIED_Ammo",[4000,4000,0],[],0,"NONE"];sleep 0.5;deleteVehicle _deleted;sleep 1;
 [DSDS_nuclearBlastCount==_before,"deleting an intact IED does not create nuclear detonation"] call _assert;
 // Exercise the real EntityKilled fallback after restoring an armed persisted reward.
 _s set ["rewardState","armed"];_s set ["nuclearUnlocked",false];DSDS_nuclearWearer=_actor;_actor setVariable ["DSDS_nuclearVest",true,true];_actor setPosATL [5000,5000,0];_actor allowDamage true;_before=DSDS_nuclearBlastCount;_actor setDamage 1;sleep 2;
 [DSDS_nuclearBlastCount==_before+1 && {_s get "nuclearUnlocked"},"actual wearer death triggers one nuclear blast and unlock"] call _assert;
 [] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticLoad;_s=DSDS_mysticState;
 [(_s get "rewardState")=="detonated" && {_s get "nuclearUnlocked"},"spent reward and nuclear stock persist through campaign restore"] call _assert;
 {if (!isNull _x) then {deleteVehicle _x;};} forEach [_actor,DSDS_mystic,_holder,_victim];
 diag_log format ["[NUCLEAR TEST] COMPLETE: %1 PASS, %2 FAIL",_passes,_failures];
};
