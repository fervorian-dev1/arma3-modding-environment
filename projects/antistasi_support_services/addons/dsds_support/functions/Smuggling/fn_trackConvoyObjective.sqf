params ["_truck","_task"];
if (!isServer || {isRemoteExecuted} || {isNull _truck} || {_task==""} || {_truck getVariable ["DSDS_objectiveTracked",false]}) exitWith {};
_truck setVariable ["DSDS_objectiveTracked",true];
private _name=_task+(if ((_task find "DSDS_DEBUG_")==0) then {"_POSITION"} else {"_DSDS_OBJECTIVE"});
if (markerType _name=="") then {createMarker [_name,getPosATL _truck];};_name setMarkerType "mil_objective";_name setMarkerColor "ColorOrange";
private _bound=objNull;private _lastPosition=[];private _lastTitle="";
while {!isNull _truck && {alive _truck} && {[_task] call BIS_fnc_taskExists} && {!(([_task] call BIS_fnc_taskState) in ["SUCCEEDED","FAILED","CANCELED"])}} do {
 // Native Money/Supplies objectives can be an unloadable logistics crate.
 // Remember it once found so the marker follows the goods after unloading too.
 private _subject=_truck getVariable ["DSDS_objectiveCargo",objNull];
 if (isNull _subject && {_truck getVariable ["DSDS_objectiveNativeType",""] in ["Money","Supplies"]} && {_truck getVariable ["DSDS_manifestID",""]==""} && {!isNil "A3A_Logistics_fnc_getCargo"}) then {
  private _cargo=_truck call A3A_Logistics_fnc_getCargo;
  if (_cargo isNotEqualTo []) then {_subject=_cargo select 0;_truck setVariable ["DSDS_objectiveCargo",_subject];};
 };
 if (isNull _subject) then {_subject=_truck;};
 private _position=getPosATL _subject;
 if (_lastPosition isEqualTo [] || {_position distance2D _lastPosition>1}) then {_name setMarkerPos _position;_lastPosition=_position;};
 if (markerAlpha _name!=1) then {_name setMarkerAlpha 1;};
 private _description=[_task] call BIS_fnc_taskDescription;
 private _title=_description param [1,"Convoy objective"];if (_title isEqualType []) then {_title=format _title;};
 if (_title!=_lastTitle) then {_name setMarkerText _title;_lastTitle=_title;};
 // A forced-known OBJECT destination follows itself. Rebinding every two
 // seconds needlessly republishes the task over the network.
 if (_subject!=_bound) then {[_task,[_subject,true]] call BIS_fnc_taskSetDestination;_bound=_subject;};
 sleep 2;
};
deleteMarker _name;
