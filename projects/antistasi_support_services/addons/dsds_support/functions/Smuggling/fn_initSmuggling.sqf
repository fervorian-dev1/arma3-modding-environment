if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_smugglingInitialized",false]}) exitWith {};
DSDS_smugglingInitialized=true;
if (isServer) then {DSDS_objectiveTrackQueue=[];};
if (isServer) then {DSDS_smugglingRecords=createHashMap;DSDS_isotopeClouds=[];DSDS_convoyUpgrades=[];DSDS_convoyAlerts=[];DSDS_isotopeDeaths=[];DSDS_nativeDefenseQueue=[];DSDS_nativeConvoys=createHashMap;};
[] call DSDS_fnc_initNativeConvoys;
if (!isNil "A3A_Events_fnc_addEventListener") then {
 ["AIVehInit","DSDS_RareConvoy",{
  params ["_vehicle","_side"];
  // These names are verified in Ultimate's native convoy/spawn worker. Fail closed
  // for other missions/versions instead of treating unrelated vehicles as convoys.
  if (isNil "_taskId" || {isNil "_convoyType"} || {isNil "_markName"}) exitWith {};
  _vehicle setVariable ["DSDS_convoyTask",_taskId,true];
  _vehicle setVariable ["DSDS_nativeConvoyTravel",true,true];
  private _driver=driver _vehicle;
  if (!isNull _driver) then {_driver setVariable ["lambs_danger_disableAI",true,true];(group _driver) setVariable ["lambs_danger_disableGroupAI",true,true];};
  if (!isNil "_textX") then {_vehicle setVariable ["DSDS_convoyBriefing",_textX];};
  if (!isNil "_mrkDest") then {_vehicle setVariable ["DSDS_convoyDestinationMarker",_mrkDest];};
  if (!isNull driver _vehicle) then {(group driver _vehicle) setVariable ["DSDS_convoyTask",true,true];};
  if (!(_convoyType in ["Ammunition","Fuel","Repair","Supplies","Money","Armor","Prisoners","Reinforcements"]) || {!(_markName in [localize "STR_marker_convoy_objective",localize "STR_marker_convoy_objective_space"])}) exitWith {};
  if (_vehicle getVariable ["DSDS_convoyConsidered",false]) exitWith {};
  // Scoped value exists only inside our trusted server native-worker adapter.
  if (isServer && {!isNil "_dsdsPetrosConvoySelection"}) then {
   private _bag=missionNamespace getVariable ["DSDS_petrosConvoyBag",[]];if (_bag isNotEqualTo [] && {!isNil "_dsdsConsumeConvoyRotation" && {_dsdsConsumeConvoyRotation}}) then {_bag deleteAt 0;};
   private _kind=_dsdsPetrosConvoySelection select 0;
   _vehicle setVariable ["DSDS_petrosConvoy",true];
   [_vehicle,_side,_taskId,_convoyType,_kind] call DSDS_fnc_convoyObserved;
  } else {if (isServer) then {[_vehicle,_side,_taskId,_convoyType] call DSDS_fnc_convoyObserved;} else {[_vehicle,_side,_taskId,_convoyType] remoteExecCall ["DSDS_fnc_convoyObserved",2];};};
 }] call A3A_Events_fnc_addEventListener;
};
if (isServer) then {[] spawn {
 private _nextMaintenance=0;private _nextWatchdog=0;
 while {true} do {
  private _tracks=+DSDS_objectiveTrackQueue;DSDS_objectiveTrackQueue=[];
  {_x spawn DSDS_fnc_trackConvoyObjective;} forEach _tracks;
  // Player/HC callbacks enqueue here so strict private workers run outside RPC context.
  private _ready=DSDS_convoyUpgrades select {(_x select 4)<=serverTime};
  DSDS_convoyUpgrades=DSDS_convoyUpgrades select {(_x select 4)>serverTime};
  {_x params ["_truck","_side","_task","_kind"];if (!isNull _truck && {alive _truck}) then {[_truck,_side,_task,_kind] call DSDS_fnc_upgradeConvoy;_truck setVariable ["DSDS_designationPending",false];};} forEach _ready;
  private _alerts=+DSDS_convoyAlerts;DSDS_convoyAlerts=[];
  {[_x] call DSDS_fnc_alertConvoy;} forEach _alerts;
  private _deaths=+DSDS_isotopeDeaths;DSDS_isotopeDeaths=[];
  {[_x] call DSDS_fnc_isotopeRelease;} forEach _deaths;
  // Watchdog is independent of object locality, MPKilled delivery and a remote killer.
  if (serverTime>=_nextWatchdog) then {_nextWatchdog=serverTime+5;{private _truck=_y get "truck";if (_y get "kind"=="ISOTOPE" && {!isNull _truck} && {!alive _truck} && {!(_truck getVariable ["DSDS_cloudReleased",false])}) then {[_truck] call DSDS_fnc_isotopeRelease;};} forEach DSDS_smugglingRecords;};
  private _defenses=DSDS_nativeDefenseQueue select {(_x select 3)<=serverTime};
  DSDS_nativeDefenseQueue=DSDS_nativeDefenseQueue select {(_x select 3)>serverTime};
  {
   _x params ["_truck","_side","_task"];
   if (!isNull _truck && {alive _truck} && {_truck getVariable ["ownerSide",_side]==_side}) then {
    private _id=_truck getVariable ["DSDS_manifestID",""];
    private _record=DSDS_smugglingRecords getOrDefault [_id,createHashMap];
    if (count _record==0) then {_record=createHashMapFromArray [["id",_task+"_GUARDS"],["truck",_truck],["side",_side],["task",_task],["kind","STANDARD"]];DSDS_nativeConvoys set [_task,_record];};
    [_record,true] spawn DSDS_fnc_convoyProtection;
   };
  } forEach _defenses;
  if (serverTime>=_nextMaintenance) then {
  _nextMaintenance=serverTime+5;
  {
   private _entry=DSDS_nativeConvoys get _x;private _truck=_entry get "truck";
   if (isNull _truck || {!alive _truck} || {!([_entry get "task"] call BIS_fnc_taskExists)} || {[_entry get "task"] call BIS_fnc_taskState in ["SUCCEEDED","FAILED","CANCELED"]}) then {DSDS_nativeConvoys deleteAt _x;};
  } forEach +(keys DSDS_nativeConvoys);
  {if (_y get "kind"=="SPECIAL" && {!(_y get "finished")}) then {[_y] call DSDS_fnc_pursuitTick;};} forEach DSDS_smugglingRecords;
  DSDS_isotopeClouds=DSDS_isotopeClouds select {(_x select 2)>serverTime};
  private _stash=missionNamespace getVariable ["DSDS_activeStash",createHashMap];
  if (count _stash>0 && {!(_stash get "complete")} && {{alive _x} count (_stash get "units")==0 || {isNull (_stash get "box") || {!alive (_stash get "box")}}}) then {
   private _success=!isNull (_stash get "box") && {alive (_stash get "box")};
   _stash set ["complete",true];[_stash get "id",if (_success) then {"SUCCEEDED"} else {"FAILED"},true] call BIS_fnc_taskSetState;
   (_stash get "marker") setMarkerText (if (_success) then {"Cleared "+(_stash getOrDefault ["title","Contraband Stash"])} else {"Destroyed "+(_stash getOrDefault ["title","Contraband Stash"])});
   {if (!isNil "A3A_fnc_groupDespawner") then {[_x] spawn A3A_fnc_groupDespawner;};} forEach (_stash get "groups");
  };
  };
  sleep 0.5;
 };
};};
if (hasInterface) then {[] spawn {
 if (!isNil "zen_custom_modules_fnc_register") then {
  ["Dynamic Supply Drops","Designate Special Convoy vehicle",{params ["_position","_vehicle"];if (isNull _vehicle || {!(_vehicle isKindOf "Car")}) exitWith {systemChat "Place this module on a convoy truck.";};["DESIGNATE",player,[_vehicle,"SPECIAL"]] remoteExecCall ["DSDS_fnc_smugglingRequest",2];}] call zen_custom_modules_fnc_register;
  ["Dynamic Supply Drops","Designate Isotope Convoy vehicle",{params ["_position","_vehicle"];if (isNull _vehicle || {!(_vehicle isKindOf "Car")}) exitWith {systemChat "Place this module on a convoy truck.";};["DESIGNATE",player,[_vehicle,"ISOTOPE"]] remoteExecCall ["DSDS_fnc_smugglingRequest",2];}] call zen_custom_modules_fnc_register;
 };
 private _previous=objNull;
 while {true} do {
  if (!isNull player && {player!=_previous}) then {
   if (!isNull _previous) then {{_previous removeEventHandler _x;} forEach (_previous getVariable ["DSDS_traceEH",[]]);};
   _previous=player;private _handlers=[];
   _handlers pushBack ["Take",player addEventHandler ["Take",{params ["_unit","_container","_item"];["TAKE",_unit,[_container,_item,_container getVariable ["DSDS_traceIDs",[]]]] remoteExecCall ["DSDS_fnc_smugglingRequest",2];}]];
   _handlers pushBack ["Put",player addEventHandler ["Put",{params ["_unit","_container","_item"];["PUT",_unit,[_container,_item,[]]] remoteExecCall ["DSDS_fnc_smugglingRequest",2];}]];
   player setVariable ["DSDS_traceEH",_handlers];["CLOUDS",player,[]] remoteExecCall ["DSDS_fnc_smugglingRequest",2];
  };
  sleep 1;
 };
};};
