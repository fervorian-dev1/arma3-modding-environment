/* Internal server entry also usable by mission authors/tests to designate a convoy truck. */
params ["_truck","_side","_task",["_kind","SPECIAL"],["_theme",""]];
if (!isServer || {isRemoteExecuted} || {isNull _truck} || {!alive _truck} || {!(_truck isKindOf "Car")} || {_truck getVariable ["DSDS_manifestID",""]!=""} || {!(_kind in ["SPECIAL","ISOTOPE","MEDICAL"])}) exitWith {createHashMap};
if (maxLoad _truck<=0 || {crew _truck findIf {isPlayer _x}>=0} || {(_truck getVariable ["ownerSide",sideUnknown]) isEqualTo (missionNamespace getVariable ["teamPlayer",resistance])}) exitWith {createHashMap};
if (_kind=="ISOTOPE" && {isNil "CBRN_fnc_spawnMist"}) exitWith {diag_log "[DSDS] Isotope convoy requires Chemical Warfare PLUS; ordinary convoy retained.";createHashMap};
if (_kind=="ISOTOPE" && {!([typeOf _truck,_side] call DSDS_fnc_isConvoyCargoTruck)}) exitWith {diag_log "[DSDS] Isotope cargo requires a cargo/medical truck, never an ammo/fuel/repair truck.";createHashMap};
if (_kind=="ISOTOPE" && {([_side] call DSDS_fnc_convoyDoorHelis) isEqualTo []}) exitWith {diag_log "[DSDS] No kinetic door-gun transport available for isotope escort; ordinary convoy retained.";createHashMap};
DSDS_smugglingSequence=(missionNamespace getVariable ["DSDS_smugglingSequence",0])+1;
private _id=format ["DSDS_CARGO_%1",DSDS_smugglingSequence];
private _record=createHashMapFromArray [["id",_id],["kind",_kind],["truck",_truck],["task",_task],["side",_side],["alerted",false],["finished",false],["last",getPosATL _truck],["holders",[_truck]],["vehicles",[]],["units",[]],["groups",[]],["spotters",[]],["created",serverTime]];
if (isNil "DSDS_smugglingRecords") then {DSDS_smugglingRecords=createHashMap;};
DSDS_smugglingRecords set [_id,_record];
_truck setVariable ["DSDS_manifestID",_id,true];_truck setVariable ["DSDS_traceIDs",[_id],true];
clearWeaponCargoGlobal _truck;clearMagazineCargoGlobal _truck;clearItemCargoGlobal _truck;clearBackpackCargoGlobal _truck;
if (_kind=="SPECIAL") then {
 private _selection=[_theme] call DSDS_fnc_specialConvoyPool;
 _selection params ["_themeID","_themeLabel","_pool"];
 _record set ["theme",_themeID];_record set ["themeLabel",_themeLabel];_truck setVariable ["DSDS_cargoTheme",_themeID,true];
 _record set ["pool",_pool];
 { _truck addItemCargoGlobal [_x,round (2.25*(if (_x=="DSDS_GoldBullion") then {1} else {1+floor random 4}))];} forEach _pool;
 _truck addMPEventHandler ["MPHit",{if (isServer) then {[_this select 0] call DSDS_fnc_alertConvoy;};}];
 _truck addMPEventHandler ["MPKilled",{if (isServer) then {private _truck=_this select 0;[_truck] call DSDS_fnc_alertConvoy;[_truck] spawn {params ["_truck"];sleep 3;[_truck] call DSDS_fnc_salvageConvoy;};};}];
 if (_task!="") then {[_task,["Intercept this rare high-value shipment. Its escorts can call a large response force; spotting helicopters will track stolen goods until neutralized.","Special Convoy",""]] call BIS_fnc_taskSetDescription;};
} else {if (_kind=="MEDICAL") then {
 _record set ["label","Medical Supplies"];
 _truck lockInventory false;[_truck] remoteExecCall ["DSDS_fnc_isotopeInventory",0,_truck];
 _truck addItemCargoGlobal ["FirstAidKit",round (2.25*(20+floor random 11))];_truck addItemCargoGlobal ["Medikit",5];
 [_truck,8+floor random 5,"MEDICAL"] call DSDS_fnc_fillLootContainer;
 _record set ["pool",["FirstAidKit","Medikit"]+([] call DSDS_fnc_medicalPool)];
 _truck addMPEventHandler ["MPKilled",{if (isServer) then {[_this select 0,_this param [1,objNull],_this param [2,objNull]] call DSDS_fnc_convoyHit;};}];
 if (_task!="") then {[_task,["Intercept the medical shipment. Attacking it will provoke a substantial military escalation in this region.","Medical Convoy",""]] call BIS_fnc_taskSetDescription;};
} else {
 private _label=selectRandom ["Medical Isotopes","Industrial Isotopes"];
 _record set ["label",_label];_truck setVariable ["DSDS_isotopeLabel",_label,true];_truck lockInventory false;
 [_truck] remoteExecCall ["DSDS_fnc_isotopeInventory",0,_truck];
 _truck addItemCargoGlobal [if (_label=="Medical Isotopes") then {"DSDS_MedicalIsotopes"} else {"DSDS_IndustrialIsotopes"},14];
 _record set ["chemicalRewards",[_truck] call DSDS_fnc_fillChemicalCargo];
 _record set ["pool",["DSDS_MedicalIsotopes","DSDS_IndustrialIsotopes"]];
 _truck addMPEventHandler ["MPKilled",{if (isServer) then {[_this select 0,_this param [1,objNull],_this param [2,objNull]] call DSDS_fnc_convoyHit;DSDS_isotopeDeaths pushBackUnique (_this select 0);};}];
 if (_task!="") then {[_task,["Intercept the sealed isotope shipment intact. Destroying the truck releases a very large hazardous contamination cloud.",_label+" Convoy",""]] call BIS_fnc_taskSetDescription;};
};};
_truck addMPEventHandler ["MPHit",{if (isServer) then {[_this select 0,_this param [1,objNull],_this param [3,objNull]] call DSDS_fnc_convoyHit;};}];
if (_task!="") then {
 private _brief=_truck getVariable ["DSDS_convoyBriefing",""];
 if (_brief!="") then {private _description=[_task] call BIS_fnc_taskDescription;private _body=_description select 0;if (_body isEqualType []) then {_body=format _body;};[_task,[_brief+"<br/><br/>"+_body,_description select 1,_truck getVariable ["DSDS_convoyDestinationMarker",_description select 2]]] call BIS_fnc_taskSetDescription;};
};
[_record,(_task find "CONVOY")==0] spawn DSDS_fnc_convoyProtection;
diag_log format ["[DSDS] %1 convoy attached to %2 (%3).",_kind,_task,typeOf _truck];
_record
