/* Public RPC is limited to owned player inventory events and read-only cloud replay. */
if (!isServer) exitWith {};
params [["_op","",[""]],["_actor",objNull,[objNull]],["_args",[],[[]]]];
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (isNull _actor || {!isPlayer _actor} || {!alive _actor} || {owner _actor!=_sender}) exitWith {};
if (_op=="DESIGNATE") exitWith {
 if (isNull getAssignedCuratorLogic _actor || {diag_tickTime<(_actor getVariable ["DSDS_designateRate",0])}) exitWith {};
 _args params [["_vehicle",objNull,[objNull]],["_kind","",[""]]];
 if (isNull _vehicle || {!(_vehicle isKindOf "Car")} || {!alive _vehicle} || {!(_kind in ["SPECIAL","ISOTOPE"])} || {_vehicle getVariable ["DSDS_manifestID",""]!=""} || {_vehicle getVariable ["DSDS_designationPending",false]}) exitWith {};
 if (maxLoad _vehicle<=0 || {crew _vehicle findIf {isPlayer _x}>=0} || {(_vehicle getVariable ["ownerSide",sideUnknown]) isEqualTo (missionNamespace getVariable ["teamPlayer",resistance])} || {(_vehicle getVariable ["ownerX",""]) isNotEqualTo ""}) exitWith {["MESSAGE",["Choose an enemy convoy truck with cargo space and no players aboard."]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
 if (_kind=="ISOTOPE" && {isNil "CBRN_fnc_spawnMist"}) exitWith {["MESSAGE",["Chemical Warfare PLUS is required for an isotope convoy."]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
 _actor setVariable ["DSDS_designateRate",diag_tickTime+5];
 private _side=side group driver _vehicle;
 if (!(_side in [missionNamespace getVariable ["Occupants",sideUnknown],missionNamespace getVariable ["Invaders",sideUnknown]]) || {_side==sideUnknown}) then {_side=missionNamespace getVariable ["Occupants",west];};
 _vehicle setVariable ["DSDS_designationPending",true];
 // Existing designation helper remains separate from full DEBUG mission starters.
 DSDS_convoyUpgrades pushBack [_vehicle,_side,"",_kind,serverTime];
};
if (_op=="CLOUDS") exitWith {{if ((_x select 2)>serverTime) then {_x remoteExecCall ["DSDS_fnc_chemicalCloud",owner _actor];};} forEach (missionNamespace getVariable ["DSDS_isotopeClouds",[]]);};
if !(_op in ["TAKE","PUT"]) exitWith {};
_args params [["_container",objNull,[objNull]],["_item","",[""]],["_reported",[],[[]]]];
if (!isNull _container && {_actor distance _container>15}) exitWith {};
private _ids=if (_op=="TAKE") then {if (isNull _container) then {_reported} else {_container getVariable ["DSDS_traceIDs",[]]}} else {_actor getVariable ["DSDS_traceIDs",[]]};
{
 private _record=(missionNamespace getVariable ["DSDS_smugglingRecords",createHashMap]) getOrDefault [_x,createHashMap];
 if (count _record>0 && {!(_record get "finished")} && {_record get "kind"=="SPECIAL"} && {_item in (_record get "pool")} && {!isNull _container || {_actor distance2D (_record get "last")<25}}) then {
  [_record,_op,_actor,_container,_item] spawn {
   params ["_record","_op","_actor","_container","_item"];private _target=if (_op=="TAKE") then {_actor} else {_container};
   if (isNull _target) exitWith {};
   private _deadline=diag_tickTime+3;
   waitUntil {sleep 0.05;isNull _target || {_item in (if (_target isKindOf "CAManBase") then {items _target} else {itemCargo _target})} || {diag_tickTime>_deadline}};
   if (isNull _target || {!(_item in (if (_target isKindOf "CAManBase") then {items _target} else {itemCargo _target}))}) exitWith {};
   (_record get "holders") pushBackUnique _target;
   private _tags=_target getVariable ["DSDS_traceIDs",[]];_tags pushBackUnique (_record get "id");_target setVariable ["DSDS_traceIDs",_tags,true];
   if (_target isKindOf "CAManBase") then {{if (!isNull _x) then {_x setVariable ["DSDS_traceIDs",_tags,true];};} forEach [uniformContainer _target,vestContainer _target,backpackContainer _target];};
   _record set ["last",getPosATL _target];DSDS_convoyAlerts pushBackUnique (_record get "truck");
  };
 };
} forEach _ids;
