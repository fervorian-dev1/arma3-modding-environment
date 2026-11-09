/* One shuffled bag: each supported custom shipment and one ordinary mission.
   Consume only when the actual objective reaches AIVehInit, not on failed routes. */
params ["_args"];
if (!isServer || {isRemoteExecuted} || {count _args!=2}) exitWith {["",""]};
private _side=if ((missionNamespace getVariable ["sidesX",objNull]) getVariable [_args select 1,sideUnknown]==missionNamespace getVariable ["Occupants",west]) then {missionNamespace getVariable ["Occupants",west]} else {missionNamespace getVariable ["Invaders",east]};
private _trucks=[_side,"MEDICAL"] call DSDS_fnc_convoyCargoTrucks;
if (_trucks isEqualTo []) exitWith {diag_log "[DSDS Convoy] No suitable faction cargo truck; Petros keeps native mission.";["",""]};
private _supported=["SPECIAL","MEDICAL",""];
if (!isNil "CBRN_fnc_spawnMist" && {([_side] call DSDS_fnc_convoyDoorHelis) isNotEqualTo []}) then {_supported pushBack "ISOTOPE";};
private _bag=(missionNamespace getVariable ["DSDS_petrosConvoyBag",[]]) select {_x in _supported};
if (_bag isEqualTo []) then {_bag=_supported call BIS_fnc_arrayShuffle;};
DSDS_petrosConvoyBag=_bag;
private _kind=_bag select 0;
[_kind,if (_kind=="") then {""} else {selectRandom _trucks}]
