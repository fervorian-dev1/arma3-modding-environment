/* Scheduled on server. AI flies through the target toward an egress waypoint. */
params ["_requester", "_target", "_options"];
if (!isServer) exitWith {};
_options params ["_crateClass", "_airClass", "_count", "_altitude", "_distance", "_smoke"];
private _bearing = random 360;
private _start = [];
for "_i" from 0 to 35 do {
    private _candidate = _target getPos [_distance, _bearing + 180];
    if ((_candidate select 0) > 50 && {(_candidate select 1) > 50} && {(_candidate select 0) < worldSize - 50} && {(_candidate select 1) < worldSize - 50}) exitWith {_start = _candidate;};
    _bearing = _bearing + 10;
};
if (_start isEqualTo []) exitWith {
    [_requester, "No safe approach fits this map. Choose a shorter approach distance."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_start set [2, _altitude];
private _aircraft = createVehicle [_airClass, _start, [], 0, "FLY"];
if (isNull _aircraft) exitWith {
    [_requester, "Aircraft creation failed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_aircraft setDir _bearing;
_aircraft setPosATL _start;
createVehicleCrew _aircraft;
private _pilot = driver _aircraft;
private _crew = crew _aircraft;
private _group = group _pilot;
if (isNull _pilot || {isNull _group}) exitWith {
    {deleteVehicle _x;} forEach _crew;
    deleteVehicle _aircraft;
    if (!isNull _group) then {deleteGroup _group;};
    [_requester, "Aircraft has no working AI pilot; delivery aborted."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_group deleteGroupWhenEmpty true;
_group setBehaviourStrong "CARELESS";
_group setCombatMode "BLUE";
_group setSpeedMode "NORMAL";
{_x disableAI "TARGET"; _x disableAI "AUTOTARGET"; _x setSkill 1;} forEach _crew;
_aircraft flyInHeight _altitude;
private _speed = if (_aircraft isKindOf "Plane") then {85} else {55};
_aircraft setVelocity [sin _bearing * _speed, cos _bearing * _speed, 0];
private _exit = _target getPos [6000, _bearing];
_exit set [2, _altitude];
private _inbound = +_target;
_inbound set [2, _altitude];
private _dropWP = _group addWaypoint [_inbound, 0];
_dropWP setWaypointType "MOVE";
_dropWP setWaypointCompletionRadius 80;
private _wp = _group addWaypoint [_exit, 0];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 300;
_group setCurrentWaypoint _dropWP;
// Independent watchdog ensures transport cleanup even when delivery fails.
[_aircraft, _crew, _group, _target] spawn DSD_fnc_cleanupSupplyAircraft;
[_requester, format ["%1 inbound. Drop requested at grid %2.", getText (configFile >> "CfgVehicles" >> _airClass >> "displayName"), mapGridPosition _target]] call DSD_fnc_notifySupplyDrop;
private _deadline = diag_tickTime + 240;
private _overTarget = false;
private _nextDiagnostic = diag_tickTime;
waitUntil {
    sleep 0.15;
    if (!isNull _aircraft && {diag_tickTime > _nextDiagnostic}) then {
        diag_log format ["[DSD] Flight: grid %1, distance %2m, altitude %3m AGL, speed %4km/h", mapGridPosition getPosASL _aircraft, round (_aircraft distance2D _target), round (getPosATL _aircraft select 2), round speed _aircraft];
        _nextDiagnostic = diag_tickTime + 20;
    };
    _overTarget = !isNull _aircraft && {_aircraft distance2D _target < 180} && {(getPosATL _aircraft select 2) > 80};
    _overTarget || {isNull _aircraft} || {!alive _aircraft} || {!alive _pilot} || {diag_tickTime > _deadline}
};
if (!_overTarget || {isNull _aircraft} || {!alive _aircraft} || {!alive _pilot}) exitWith {
    if (!isNull _aircraft) then {_aircraft setVariable ["DSD_departing", true];};
    [_requester, "Delivery aborted: aircraft lost or unable to reach the drop corridor within four minutes."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
// Release at the actual aircraft position; no teleporting the crate onto the target.
_aircraft setVariable ["DSD_departing", true];
_group setCurrentWaypoint _wp;
private _release = getPosASL _aircraft;
_release set [2, (_release select 2) - 12];
private _chute = createVehicle ["B_Parachute_02_F", ASLToATL _release, [], 0, "FLY"];
private _crate = createVehicle [_crateClass, ASLToATL _release, [], 0, "CAN_COLLIDE"];
if (isNull _chute || {isNull _crate}) exitWith {
    if (!isNull _chute) then {deleteVehicle _chute;};
    if (!isNull _crate) then {deleteVehicle _crate;};
    [_requester, "Crate/parachute creation failed; temporary objects removed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
_crate allowDamage false;
_chute allowDamage false;
_chute setPosASL _release;
_crate attachTo [_chute, [0, 0, -4]];
_crate setVariable ["DSD_releaseTime", diag_tickTime, true];
_crate setVariable ["DSD_releaseAltitude", _release select 2, true];
private _velocity = velocity _aircraft;
_chute setVelocity [(_velocity select 0) * 0.1, (_velocity select 1) * 0.1, -4];
private _manifest = [_crate, _count] call DSD_fnc_fillSupplyCrate;
if (_manifest isEqualTo []) exitWith {
    detach _crate;
    deleteVehicle _crate;
    deleteVehicle _chute;
    [_requester, "Cargo generation failed; empty drop removed."] call DSD_fnc_notifySupplyDrop;
    DSD_activeDrops = 0 max (DSD_activeDrops - 1);
};
{_x addCuratorEditableObjects [[_crate], false];} forEach allCurators;
[_requester, "Supply crate released. Transport departing."] call DSD_fnc_notifySupplyDrop;
[_requester, _crate, _chute, _smoke] call DSD_fnc_landSupplyCrate;
DSD_activeDrops = 0 max (DSD_activeDrops - 1);
