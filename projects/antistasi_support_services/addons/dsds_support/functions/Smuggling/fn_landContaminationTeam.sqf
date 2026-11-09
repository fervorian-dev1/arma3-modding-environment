/* One VTOL insertion. Never eject passengers in flight or teleport them to the target. */
params ["_response","_aircraft","_pilots","_troops","_target"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _origin=getPosATL _aircraft;
private _landing=[getPosATL _target,650,1100,25,0,0.15,0,[],[getPosATL _target,getPosATL _target]] call BIS_fnc_findSafePos;
if (_landing distance2D _target<500 || {surfaceIsWater _landing}) exitWith {diag_log "[DSDS CBRN] No safe Osprey LZ found; insertion aborted.";_response set ["landingFailed",true];};
private _pad=createVehicle ["Land_HelipadEmpty_F",_landing,[],0,"NONE"];
_response set ["pad",_pad];_response set ["landing",_landing];
_pilots setBehaviourStrong "CARELESS";_pilots setCombatMode "BLUE";
_aircraft flyInHeight 150;_aircraft limitSpeed 230;
private _wp=_pilots addWaypoint [_landing,0];_wp setWaypointType "MOVE";_wp setWaypointCompletionRadius 200;_pilots setCurrentWaypoint _wp;
private _deadline=serverTime+420;private _ordered=false;
waitUntil {
 sleep 1;
 if (!_ordered && {_aircraft distance2D _landing<700}) then {_ordered=_aircraft landAt [_pad,"GetOut"];};
 !alive _aircraft || {!alive driver _aircraft} || {serverTime>_deadline} || {_response getOrDefault ["ended",false]} || {_aircraft distance2D _landing<120 && {getPosATL _aircraft select 2<3} && {abs speed _aircraft<8}}
};
if (alive _aircraft && {getPosATL _aircraft select 2<3} && {abs speed _aircraft<8} && {!(_response getOrDefault ["ended",false])}) then {
 _troops leaveVehicle _aircraft;{unassignVehicle _x;doGetOut _x;} forEach units _troops;
 private _out=serverTime+30;
 waitUntil {sleep 1;serverTime>_out || {{vehicle _x==_aircraft} count units _troops==0} || {!alive _aircraft}};
 if (getPosATL _aircraft select 2<3) then {{if (alive _x && {vehicle _x==_aircraft}) then {moveOut _x;};} forEach units _troops;};
 _response set ["landed",true];
 _troops setBehaviourStrong "AWARE";_troops setCombatMode "RED";
 diag_log format ["[DSDS CBRN] Osprey landed; %1 woodland specialists deployed.",count units _troops];
} else {_response set ["landingFailed",true];diag_log "[DSDS CBRN] Osprey insertion failed; no midair disembark was forced.";};
if (alive _aircraft && {alive driver _aircraft} && {(crew _aircraft findIf {isPlayer _x})<0}) then {
 _aircraft landAt [_pad,"None"];
 private _exit=_pilots addWaypoint [_origin,0];_exit setWaypointType "MOVE";_pilots setCurrentWaypoint _exit;
};
sleep 90;
if (!isNull _pad) then {deleteVehicle _pad;};
