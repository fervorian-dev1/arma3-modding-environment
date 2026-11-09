if (!isServer) exitWith {};
params [["_unit",objNull,[objNull]],["_records",[],[[]]]];
if (isNull _unit || {!isPlayer _unit} || {!alive _unit} || {isNil "teamPlayer"} || {!(side group _unit in [teamPlayer,civilian])}) exitWith {};
if (isRemoteExecuted && {owner _unit != remoteExecutedOwner}) exitWith {diag_log "[DSDS HQ] Rejected forged noise reporter.";};
if (count _records > 64) exitWith {};
private _last = _unit getVariable ["DSDS_lastNoiseBatch",-100];
if (diag_tickTime - _last < 0.2) exitWith {};
_unit setVariable ["DSDS_lastNoiseBatch",diag_tickTime];
private _dsdsNoiseAuthorizedUnit = _unit;
{
    if (_x isEqualType [] && {count _x == 5}) then {
        _x params ["_ammo","_suppressor","_position","_count","_kind"];
        if (_ammo isEqualType "" && {_suppressor isEqualType ""} && {_position isEqualType []} && {_count isEqualType 0} && {finite _count} && {_kind in ["shot","explosion"]}) then {
            private _weight = [_ammo,_suppressor,_kind] call DSDS_fnc_noiseWeight;
            [_unit,_position,_weight * (0 max (50 min _count)),_kind] call DSDS_fnc_applyHQNoise;
        };
    };
} forEach _records;
