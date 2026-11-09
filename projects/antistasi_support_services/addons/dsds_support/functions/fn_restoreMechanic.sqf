if (!isServer || {isNil "A3A_saveTarget"}) exitWith {objNull};
private _state = ["DSDS_mechanicState"] call A3A_fnc_returnSavedStat;
if (isNil "_state" || {!(_state isEqualType [])} || {count _state < 5} || {!(_state select 1)}) exitWith {objNull};
private _position = [_state select 2] call DSDS_fnc_validateServicePosition;
if (_position isEqualTo []) exitWith {objNull};
_position set [2,(_state select 2) param [2,0]];
[_position,_state select 3,_state select 4] call DSDS_fnc_createMechanic
