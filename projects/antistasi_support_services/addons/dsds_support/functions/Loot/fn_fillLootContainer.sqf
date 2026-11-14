/* Server mission extension point. Adds portable valuables without clearing existing cargo. */
params [["_box",objNull,[objNull]],["_count",10,[0]],["_mode","COMMON",[""]]];
if (isRemoteExecuted && {isNil "_dsdsLootAuthorized"}) exitWith {false};
if (!isServer || {isNull _box} || {_box isKindOf "CAManBase"} || {maxLoad _box<=0}) exitWith {false};
private _pool=switch (_mode) do {
 case "MEDICAL": {[] call DSDS_fnc_medicalPool};
 case "SPECIAL": {private _selection=[] call DSDS_fnc_specialConvoyPool;_box setVariable ["DSDS_cargoTheme",_selection select 0,true];_selection select 2};
 case "STASH": {["DSDS_Marijuana","DSDS_Cocaine","DSDS_Methamphetamine","DSDS_NicotineVape","DSDS_Zyn"]};
 default {["DSDS_Marijuana","DSDS_NicotineVape","DSDS_Cocaine","DSDS_Zyn","DSDS_GoldBullion","DSDS_RoughGems","DSDS_CutGems","DSDS_Methamphetamine"]};
};
if (_pool isEqualTo []) exitWith {false};
_count=round (_count*2.25);
private _used=createHashMap;
for "_i" from 1 to ((floor _count max 1) min 113) do {
    private _class="";
    if (_mode=="MEDICAL") then {
        // Rare OLB variants, at most two of any injector in one addition.
        private _weighted=[];
        {if ((_used getOrDefault [_x,0])<5) then {_weighted append [_x,getNumber (configFile >> "DSDS_MedicalLoot" >> "Weights" >> _x) max 1];};} forEach _pool;
        if (_weighted isNotEqualTo []) then {_class=selectRandomWeighted _weighted;};
    } else {_class=selectRandom _pool;};
    if (_class=="") exitWith {};
    if (_mode!="MEDICAL" || {_box canAdd [_class,1]}) then {
        _box addItemCargoGlobal [_class,1];_used set [_class,(_used getOrDefault [_class,0])+1];
    };
};
true
