params ["_entry"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _truck=_entry get "truck";private _id=_entry get "id";private _cargo=_entry get "cargo";
if (_entry get "complete") exitWith {
 if (serverTime<(_entry get "finishedAt")+120) exitWith {};
 private _assets=_entry get "assets";
 private _near=(allPlayers findIf {private _player=_x;((_assets get "vehicles") findIf {!isNull _x && {_x distance2D _player<1000}})>=0})>=0;
 if (_near) exitWith {};
 private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
 {
  private _vehicle=_x;
  // Never remove the loot truck, a captured vehicle, or a player-occupied asset.
  if (_vehicle!=_truck && {!isNull _vehicle} && {_vehicle getVariable ["ownerSide",sideUnknown]!=_rebels} && {(crew _vehicle findIf {isPlayer _x})<0}) then {
   {if (!isPlayer _x && {side group _x!=_rebels}) then {deleteVehicle _x;};} forEach crew _vehicle;deleteVehicle _vehicle;
  };
 } forEach (_assets get "vehicles");
 {if (!isNull _x && {!isPlayer _x} && {side group _x!=_rebels} && {vehicle _x!=_truck}) then {deleteVehicle _x;};} forEach (_assets get "units");
 {if (count units _x==0) then {deleteGroup _x;};} forEach (_assets get "groups");
 deleteMarker (_entry get "marker");[_id] call BIS_fnc_deleteTask;DSDS_debugMissions deleteAt _id;
};
if (!isNull _truck) then {(_entry get "marker") setMarkerPos getPosATL _truck;[_id,getPosATL _truck] call BIS_fnc_taskSetDestination;};
private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
private _claimed=!isNull _truck && {alive _truck} && {_truck getVariable ["ownerSide",sideUnknown]==_rebels || {!isNull driver _truck && {isPlayer driver _truck && {side group driver _truck==_rebels}}}};
if (_entry get "kind"=="SPECIAL") then {
 private _pool=_cargo get "pool";
 _claimed=_claimed || {((_cargo get "holders") findIf {!isNull _x && {_x isKindOf "CAManBase"} && {isPlayer _x} && {side group _x==_rebels} && {(items _x findIf {_x in _pool})>=0}})>=0};
};
private _failed=_entry get "kind"=="ISOTOPE" && {isNull _truck || {!alive _truck}};
if (!isNull _truck && {_truck distance2D (_entry get "destination")<90} && {_entry get "arrived"==0}) then {_entry set ["arrived",serverTime];};
_failed=_failed || {serverTime>(_entry get "deadline")} || {_entry get "arrived">0 && {serverTime>(_entry get "arrived")+180}};
if (_claimed || {_failed}) then {
 _entry set ["complete",true];_entry set ["finishedAt",serverTime];
 [_id,if (_claimed) then {"SUCCEEDED"} else {"FAILED"},true] call BIS_fnc_taskSetState;
 (_entry get "marker") setMarkerText (if (_claimed) then {"Recovered convoy"} else {"Convoy escaped / lost"});
 diag_log format ["[DSDS DEBUG] %1 complete: %2; loot truck/holders preserved.",_id,if (_claimed) then {"SUCCEEDED"} else {"FAILED"}];
};
