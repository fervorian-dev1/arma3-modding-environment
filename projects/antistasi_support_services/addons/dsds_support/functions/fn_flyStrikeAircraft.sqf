// Server-local, straight supersonic flyby; never install RHS's player HUD handler.
params ["_aircraft","_bearing","_altitudeASL","_speed"];
if (!isServer || {!local _aircraft}) exitWith {};
private _deadline = diag_tickTime + 150;
private _hasBurner = isClass (configOf _aircraft >> "AnimationSources" >> "afterburner_source");
private _direction = [sin _bearing,cos _bearing,0];
private _nextTerrain = 0;
_aircraft engineOn true;
if (_hasBurner) then {_aircraft animateSource ["afterburner_source",1,true];};
while {!isNull _aircraft && {alive _aircraft} && {alive driver _aircraft} && {local _aircraft} && {diag_tickTime < _deadline} && {{isPlayer _x} count crew _aircraft == 0}} do {
    _aircraft setAirplaneThrottle 1;
    if (diag_tickTime >= _nextTerrain) then {
        _altitudeASL = [getPosASL _aircraft,_bearing,_speed] call DSDS_fnc_strikeFlightAltitude;
        _nextTerrain = diag_tickTime + 0.25;
    };
    private _vertical = (-60 max ((_altitudeASL - (getPosASL _aircraft select 2)) * 2)) min 90;
    private _velocity = [(_direction select 0) * _speed,(_direction select 1) * _speed,_vertical];
    _aircraft setVectorDirAndUp [vectorNormalized _velocity,[0,0,1]];
    _aircraft setVelocity _velocity;
    if (_hasBurner) then {_aircraft animateSource ["afterburner_source",1];};
    sleep 0.05;
};
if (!isNull _aircraft && {_hasBurner}) then {_aircraft animateSource ["afterburner_source",0];};
