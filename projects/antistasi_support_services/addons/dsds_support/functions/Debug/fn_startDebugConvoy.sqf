/* Zeus starts the SAME native mission as Petros; cursor only selects a nearby
   native destination. No short cursor route, replacement convoy or custom driver. */
params ["_actor","_position",["_debug",true],["_kind","SPECIAL"]];
if (!isServer || {isRemoteExecuted} || {!_debug} || {!(_kind in ["SPECIAL","ISOTOPE","MEDICAL"])}) exitWith {};
private _message={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_actor];};
if (missionNamespace getVariable ["A3A_convoyInProgress",false]) exitWith {["A convoy is already active. Finish it before requesting another."] call _message;};
if (isNil "sidesX" || {isNil "spawner"} || {isNil "server"} || {isNil "garrison"} || {isNil "DSDS_nativeCargoConvoy"}) exitWith {["The Antistasi campaign must be initialized before starting a convoy."] call _message;};
if (_kind=="ISOTOPE" && {isNil "CBRN_fnc_spawnMist"}) exitWith {["Chemical Warfare PLUS is needed for isotope missions."] call _message;};
private _bases=(missionNamespace getVariable ["airportsX",[]])+(missionNamespace getVariable ["outposts",[]])+(missionNamespace getVariable ["milbases",[]]);
private _destinations=_bases+(missionNamespace getVariable ["resourcesX",[]])+(missionNamespace getVariable ["factories",[]])+(missionNamespace getVariable ["seaports",[]]);
_destinations=(_destinations arrayIntersect _destinations)-(missionNamespace getVariable ["blackListDest",[]]);
_destinations=[_destinations,[],{markerPos _x distance2D _position},"ASCEND"] call BIS_fnc_sortBy;
private _pair=[];
{
 private _side=sidesX getVariable [_x,sideUnknown];
 if (_side in [missionNamespace getVariable ["Occupants",west],missionNamespace getVariable ["Invaders",east]]) then {
  private _origin=[_x,_bases] call A3A_fnc_findBasesForConvoy;
  if (_origin!="") exitWith {_pair=[_x,_origin];};
 };
 if (_pair isNotEqualTo []) exitWith {};
} forEach _destinations;
if (_pair isEqualTo []) exitWith {["No eligible Antistasi convoy route is available near that area."] call _message;};
private _side=sidesX getVariable [_pair select 1,sideUnknown];
private _pool=[_side,_kind] call DSDS_fnc_convoyCargoTrucks;
if (_pool isEqualTo [] || {_kind=="ISOTOPE" && {([_side] call DSDS_fnc_convoyDoorHelis) isEqualTo []}}) exitWith {["This faction has no suitable truck/armed escort for that shipment."] call _message;};
private _dsdsPetrosConvoySelection=[_kind,selectRandom _pool];
private _dsdsConsumeConvoyRotation=false;
[_pair select 0,_pair select 1,"Ammunition"] call DSDS_nativeCargoConvoy;
