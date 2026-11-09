if (!hasInterface) exitWith {};
[] spawn {
 waitUntil {sleep 0.1;!isNull player && {time>1}};sleep 3;
 private _passes=0;private _failures=0;
 private _assert={params ["_ok","_label"];if (_ok) then {_passes=_passes+1;} else {_failures=_failures+1;};diag_log format ["[RESCUE TEST] %1: %2",["FAIL","PASS"] select _ok,_label];};
 [isPlayer player && {local player} && {isServer},"real local player running actual owner/server RPC flow"] call _assert;
 [!isNil "Crawl0" && {!isNil "Uncondition0"},"installed PiR player injury routines are loaded"] call _assert;
 private _u=player;_u setPosATL [14000,16000,0];_u setDamage 0;
 // Teammate/PiR recovery can leave the native Antistasi flag/key handler stale.
 private _originalKeys=DSDS_nativeReviveKeys;DSDS_testRespawnKeys=0;DSDS_nativeReviveKeys={DSDS_testRespawnKeys=DSDS_testRespawnKeys+1;false};
 _u setDamage .35;_u setVariable ["incapacitated",true,true];_u setUnconscious true;sleep .5;
 [findDisplay 46,19,false,false,false] call SCRT_fnc_common_unconsciousEventHandler;
 [DSDS_testRespawnKeys==1,"genuine downed state retains native respawn key path"] call _assert;
 _u setUnconscious false;_u switchMove "AmovPercMstpSrasWrflDnon";_u setVariable ["dam_ignore_injured0",false,true];sleep .2;
 diag_log format ["[HOTFIX RECOVERY] before keys life=%1 anim=%2 pir=%3 physical=%4",lifeState _u,animationState _u,_u getVariable ["dam_ignore_injured0",false],[_u] call DSDS_fnc_physicalDownState];
 respawnMenu=(findDisplay 46) displayAddEventHandler ["KeyDown",SCRT_fnc_common_unconsciousEventHandler];
 [findDisplay 46,19,false,false,false] call SCRT_fnc_common_unconsciousEventHandler;
 [DSDS_testRespawnKeys==1,"recovered real player cannot dispatch stale R-to-respawn even with stale incapacitated flag"] call _assert;
 sleep 3;
 [!(_u getVariable ["incapacitated",true]) && {(missionNamespace getVariable ["respawnMenu",-1])<0},"owner monitor clears stale native incapacity and exactly its respawn handler"] call _assert;
 (findDisplay 46) displayRemoveEventHandler ["KeyDown",respawnMenu];
 [abs(damage _u-.35)<.01,"revive UI repair grants no free healing"] call _assert;
 DSDS_nativeReviveKeys=_originalKeys;_u setDamage 0;
 [([_u] call DSDS_fnc_lootDownState)==0,"healthy player does not need rescue"] call _assert;
 _u addItem "DSDS_Adrenaline";_u addItem "DSDS_Adrenaline";_u addItem "DSDS_Morphine";_u addItem "DSDS_Morphine";
 _u switchMove "AmovPpneMstpSrasWrflDnon";sleep 0.5;
 [([_u] call DSDS_fnc_lootRescueClass)=="","ordinary voluntary prone does not auto-consume either injector"] call _assert;
 private _ad={_x=="DSDS_Adrenaline"} count items _u;private _mo={_x=="DSDS_Morphine"} count items _u;
 _u setDamage 0.65;_u setUnconscious true;
 private _deadline=diag_tickTime+15;
 waitUntil {sleep 0.1;({_x=="DSDS_Adrenaline"} count items _u)<_ad || {diag_tickTime>_deadline}};
 sleep 1;
 [({_x=="DSDS_Adrenaline"} count items _u)==_ad-1,"automatic incapacitation consumes exactly one carried Adrenaline"] call _assert;
 [({_x=="DSDS_Morphine"} count items _u)==_mo,"same incapacitation does not waste Morphine as well"] call _assert;
 [alive _u && {lifeState _u!="INCAPACITATED"} && {damage _u<0.01},"Adrenaline returns the real player to full combat health/consciousness"] call _assert;
 [!isNil {(_u getVariable ["DSDS_stimEffects",createHashMap]) get "DSDS_Adrenaline"},"server confirms owner consumption and grants its effect ledger"] call _assert;
 sleep 6;
 {_u removeItem "DSDS_Adrenaline";} forEach [1,2];
 private _weapon=primaryWeapon _u;private _grenades={_x=="HandGrenade"} count magazines _u;
 _mo={_x=="DSDS_Morphine"} count items _u;
 private _oldCrawlChance=PiR_uncondition_crawl_K0;PiR_uncondition_crawl_K0=10; // Force the dangerous delayed branch in this isolated fixture.
 _u setDamage 0.55;_u setVariable ["dam_ignore_injured0",true,true];
 // Same player routine selected by PiR0; do not stub/replace native injury functions.
 [_u,"unconsciousrevivedefault",10,[_u,0],group _u,str side group _u,"","","",[],stance _u,0,getPosATL _u,0,[],[],[],[],[],[],"",0,leader _u,[],[],0,0,0,0,[0,0],[]] call Crawl0;
 _deadline=diag_tickTime+20;
 waitUntil {sleep 0.1;({_x=="DSDS_Morphine"} count items _u)<_mo || {diag_tickTime>_deadline}};
 [({_x=="DSDS_Morphine"} count items _u)==_mo-1,"native PiR forced-crawl episode automatically consumes one Morphine"] call _assert;
 sleep 25;
 diag_log format ["[RESCUE TEST] Crawl aftermath: alive=%1 life=%2 anim=%3 down=%4 weapon=%5",alive _u,lifeState _u,animationState _u,[_u] call DSDS_fnc_lootDownState,primaryWeapon _u];
 [alive _u && {lifeState _u!="INCAPACITATED"} && {([_u] call DSDS_fnc_lootDownState)==0},"PiR crawl callbacks do not knock the rescued player down again"] call _assert;
 [primaryWeapon _u==_weapon,"PiR returns the player's original rifle after crawl cleanup"] call _assert;
 [({_x=="HandGrenade"} count magazines _u)==_grenades,"PiR returns removed grenades without inventory duplication"] call _assert;
 [({_x=="DSDS_Morphine"} count items _u)==_mo-1,"one crawl episode does not repeatedly consume syringes"] call _assert;
 PiR_uncondition_crawl_K0=_oldCrawlChance;
 _u addItem "DSDS_Adrenaline";_ad={_x=="DSDS_Adrenaline"} count items _u;_mo={_x=="DSDS_Morphine"} count items _u;
 _u setDamage 0.6;_u setVariable ["dam_ignore_injured0",true,true];
 [_u,"unconsciousrevivedefault",10,[_u,0],getPosATL _u,objNull,[],objNull,objNull,[],[],objNull,0,objNull,[group _u,"MAIN"],grpNull,"",0,0,true,time+120,false,1,[0,0,0],str side group _u,[0,0,0],objNull,getPosATL _u,leader _u,[],[],[]] call Uncondition0;
 _deadline=diag_tickTime+20;
 waitUntil {sleep 0.1;({_x=="DSDS_Adrenaline"} count items _u)<_ad || {diag_tickTime>_deadline}};
 [({_x=="DSDS_Adrenaline"} count items _u)==_ad-1,"native PiR unconscious episode triggers carried Adrenaline automatically"] call _assert;
 sleep 25;
 diag_log format ["[RESCUE TEST] Unconscious aftermath: alive=%1 life=%2 anim=%3 down=%4",alive _u,lifeState _u,animationState _u,[_u] call DSDS_fnc_lootDownState];
 [alive _u && {lifeState _u!="INCAPACITATED"} && {([_u] call DSDS_fnc_lootDownState)==0},"native PiR unconscious/bleedout loop stays released after rescue"] call _assert;
 [({_x=="DSDS_Morphine"} count items _u)==_mo,"unconscious recovery preserves the other syringe"] call _assert;
 [primaryWeapon _u==_weapon && {({_x=="HandGrenade"} count magazines _u)==_grenades},"unconscious cleanup preserves weapons and restores removed throwables"] call _assert;
 [!(_u getVariable ["dam_conec_istorii0",true]) && {!(_u getVariable ["dam_uncondition_injured0",true])},"temporary PiR treatment-stop flags are cleared after recovery"] call _assert;
 {while {_x in items _u} do {_u removeItem _x;};} forEach ["DSDS_Adrenaline","DSDS_Morphine"];
 _u setDamage 0.6;_u setVariable ["dam_ignore_injured0",true,true];
 [_u,"unconsciousrevivedefault",10,[_u,0],getPosATL _u,objNull,[],objNull,objNull,[],[],objNull,0,objNull,[group _u,"MAIN"],grpNull,"",0,0,true,time+120,false,1,[0,0,0],str side group _u,[0,0,0],objNull,getPosATL _u,leader _u,[],[],[]] call Uncondition0;
 sleep 17;
 [alive _u && {lifeState _u=="INCAPACITATED"} && {([_u] call DSDS_fnc_lootRescueClass)==""},"a later native PiR knockdown cannot recover for free without another injector"] call _assert;
 diag_log format ["[RESCUE TEST] COMPLETE: %1 PASS, %2 FAIL",_passes,_failures];
 endMission (if (_failures==0) then {"END1"} else {"LOSER"});
};



