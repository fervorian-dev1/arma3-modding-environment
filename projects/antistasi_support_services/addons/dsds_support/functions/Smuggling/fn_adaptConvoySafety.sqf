/* Exact installed Ultimate worker anchors. Never partially patch an unknown version. */
params ["_source"];
private _replacements=[
 ["private _countX = round ((A3A_balancePlayerScale min 1.5) + random 0.5 + ([-0.75, 0.25] select _difficult));","private _countX = round ((A3A_balancePlayerScale min 1.5) + random 0.5 + ([-0.75, 0.25] select _difficult)); private _dsdsDefense=[_sideX] call DSDS_fnc_convoyDefenseProfile;_countX=_countX+(_dsdsDefense get 'extraGround');"],
 ["[_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;","if (_x!=_vehObj) then {[_x, _markNames#_forEachIndex, false] spawn A3A_fnc_inmuneConvoy;};"],
 ["private _veh = createVehicle [_vehType, ASLtoAGL (_pathState#0) vectorAdd [0,0,0.5]];",
 "private _safeSpawn=[];for '_dsdsTry' from 0 to 80 do {private _point=ASLtoAGL (_pathState#0);if ([_vehType,_point] call DSDS_fnc_isConvoyRoadSpawnClear) exitWith {_safeSpawn=_point;};_pathState=[_route,15,_pathState] call A3A_fnc_findPosOnRoute;}; if (_safeSpawn isEqualTo []) exitWith {diag_log '[DSDS Convoy] No clear native route spawn; vehicle skipped.';objNull}; private _veh = createVehicle [_vehType,_safeSpawn vectorAdd [0,0,0.5]];"],
 ["private _veh = [_typeVehEsc, _EscortText] call _fnc_spawnConvoyVehicle;","private _veh = [_typeVehEsc, _EscortText] call _fnc_spawnConvoyVehicle; if (isNull _veh) exitWith {};"],
 ["private _vehObj = [_typeVehObj, _objText] call _fnc_spawnConvoyVehicle;",
 "private _vehObj = [_typeVehObj, _objText] call _fnc_spawnConvoyVehicle; if (isNull _vehObj) exitWith {private _cleanupGroups=_soldiers apply {group _x}; {deleteVehicle _x;} forEach _soldiers;{deleteVehicle _x;} forEach _vehiclesX;{deleteGroup _x;} forEach (_cleanupGroups arrayIntersect _cleanupGroups);[_taskId,'CONVOY','FAILED'] call A3A_fnc_taskSetState;[_taskId,'CONVOY',60,true] spawn A3A_fnc_taskDelete;missionNamespace setVariable ['A3A_convoyInProgress',false,true];diag_log '[DSDS Convoy] Objective cancelled: no safe clearing.';};"]
];
if ((_replacements findIf {private _anchor=_x select 0;private _i=_source find _anchor;_i<0 || {((_source select [_i+count _anchor]) find _anchor)>=0}})>=0) exitWith {diag_log "[DSDS Convoy] Spawn safety signature changed; native worker retained for review.";_source};
{_x params ["_anchor","_replacement"];private _i=_source find _anchor;_source=(_source select [0,_i])+_replacement+(_source select [_i+count _anchor]);} forEach _replacements;
_source
