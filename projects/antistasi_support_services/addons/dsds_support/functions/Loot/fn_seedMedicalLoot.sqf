/* Private additive worker. No global loadout replacement, crate spawning or refill loop. */
params [["_object",objNull,[objNull]],["_source","",[""]]];
if (!isNull _object && {_object getVariable ["DSDS_manifestID",""]!=""}) exitWith {false};
if (!isServer || {isRemoteExecuted && {isNil "_dsdsMedicalAuthorized"}} || {isNull _object} || {!alive _object} || {_object getVariable ["DSDS_medicalLootSeeded",false]} || {!(_source in ["CONVOY","VEHICLE","MEDIC"])}) exitWith {false};
private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
if (_object getVariable ["ownerSide",sideUnknown]==_rebels || {_object isKindOf "CAManBase" && {isPlayer _object || {side group _object==_rebels}}} || {!(_object isKindOf "CAManBase") && {(crew _object findIf {isPlayer _x})>=0}}) exitWith {false};
if (_source=="MEDIC" && {!(_object isKindOf "CAManBase")} || {_source!="MEDIC" && {_object isKindOf "CAManBase" || {maxLoad _object<=0}}}) exitWith {false};
private _factions=missionNamespace getVariable ["A3A_faction_all",createHashMap];
if (_source=="MEDIC" && {!((_object getVariable ["unitType",""]) in (_factions getOrDefault ["Medics",[]]))}) exitWith {false};
private _medicalClasses=[];
{private _faction=missionNamespace getVariable [_x,createHashMap];_medicalClasses append (_faction getOrDefault ["vehiclesMedical",[]]);_medicalClasses append (_faction getOrDefault ["vehiclesCivMedical",[]]);} forEach ["A3A_faction_occ","A3A_faction_inv","A3A_faction_civ"];
if (_source=="VEHICLE" && {!(typeOf _object in _medicalClasses)}) exitWith {false};
private _pool=[] call DSDS_fnc_medicalPool;
if (_pool isEqualTo []) exitWith {diag_log "[DSDS Medical] No valid injector classes; native loot retained.";false};
private _cfg=configFile >> "DSDS_MedicalLoot";
_object setVariable ["DSDS_medicalLootSeeded",true,true];
if (_source=="MEDIC") exitWith {
    // Test override is private server code only, never an RPC argument.
    private _roll=if (!isRemoteExecuted && {!isNil "_dsdsMedicalRoll"}) then {_dsdsMedicalRoll} else {random 1};
    if (_roll>=getNumber (_cfg >> "medicChance")) exitWith {true};
    private _weighted=[];{_weighted append [_x,getNumber (_cfg >> "Weights" >> _x) max 1];} forEach _pool;
    private _class=selectRandomWeighted _weighted;
    private _containers=[backpackContainer _object,vestContainer _object,uniformContainer _object];
    private _index=_containers findIf {!isNull _x && {_x canAdd [_class,1]}};
    if (_index>=0) then {(_containers select _index) addItemCargoGlobal [_class,1];};
    true
};
private _prefix=if (_source=="CONVOY") then {"convoy"} else {"vehicle"};
private _min=(floor getNumber (_cfg >> (_prefix+"Min")) max 1) min 6;
private _max=(floor getNumber (_cfg >> (_prefix+"Max")) max _min) min 6;
private _count=_min+floor random (_max-_min+1);
private _dsdsLootAuthorized=true;
private _result=[_object,_count,"MEDICAL"] call DSDS_fnc_fillLootContainer;
diag_log format ["[DSDS Medical] %1 inventory supplemented: %2 (%3 selections), native cargo retained.",_source,typeOf _object,_count];
_result
