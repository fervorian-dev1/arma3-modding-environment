if (!isServer) exitWith {false};
[] call DSDS_fnc_restoreCampaignData;
DSDS_casinoState=createHashMapFromArray [["class",""],["position",[]],["direction",0],["stored",false]];DSDS_casinoSessions=createHashMap;DSDS_casinoCredits=createHashMap;
private _v=["DSDS_casinoState"] call A3A_fnc_returnSavedStat;
if (!isNil "_v" && {_v isEqualType []} && {count _v>=6} && {(_v select 0) in [1,2,3]}) then {
 _v params ["_version","_class","_pos","_dir","_credits","_escrow"];
 DSDS_casinoState set ["stored",_v param [7,false]];DSDS_casinoState set ["padOriginal",_v param [8,[]]];DSDS_casinoState set ["padApplied",_v param [9,[]]];
 if (_class!="" && {!(_class in getArray (configFile >> "DSDS_Casino" >> "buildings"))}) then {_class=(getArray (configFile >> "DSDS_Casino" >> "buildings")) select 0;DSDS_casinoState set ["stored",true];};
 if (_class isEqualType "" && {_pos isEqualType []} && {_dir isEqualType 0}) then {DSDS_casinoState set ["class",_class];DSDS_casinoState set ["position",_pos];DSDS_casinoState set ["direction",_dir];};
 {if (_x isEqualType [] && {count _x==2} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType 0}) then {DSDS_casinoCredits set [_x select 0,(_x select 1) max 0];};} forEach _credits;
 // Restored active stakes are returned once, without replaying a half-completed round.
 {if (_x isEqualType [] && {count _x==2}) then {_x params ["_uid","_amount"];DSDS_casinoCredits set [_uid,(DSDS_casinoCredits getOrDefault [_uid,0])+_amount];};} forEach _escrow;
 private _build=_v param [6,[]];
 if (count _build==2) then {_build params ["_uid","_amount"];DSDS_casinoCredits set [_uid,(DSDS_casinoCredits getOrDefault [_uid,0])+_amount];};
};
DSDS_casinoOwned=(DSDS_casinoState get "class")!="";publicVariable "DSDS_casinoOwned";
[] call DSDS_fnc_casinoSave;[] call DSDS_fnc_luckyLoad;true
