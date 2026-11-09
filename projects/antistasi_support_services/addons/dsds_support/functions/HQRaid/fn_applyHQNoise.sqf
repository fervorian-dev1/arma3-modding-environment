params ["_unit","_position","_weight",["_kind","shot"]];
if (!isServer || {isNil "_dsdsNoiseAuthorizedUnit"} || {_dsdsNoiseAuthorizedUnit != _unit} || {isNil "DSDS_noise"} || {isNull _unit} || {!alive _unit}) exitWith {false};
if (!(missionNamespace getVariable ["serverInitDone",false]) || {DSDS_raidConfig get "enabled" == 0} || {DSDS_noise get "phase" != "quiet"}) exitWith {false};
if (missionNamespace getVariable ["bigAttackInProgress",false]) exitWith {false};
private _petros = missionNamespace getVariable ["petros",objNull];
if (isNull _petros || {!alive _petros} || {!isNull attachedTo _petros}) exitWith {false};
private _pos = [_position] call DSDS_fnc_validateServicePosition;
if (_pos isEqualTo [] || {_pos distance2D _petros > DSDS_raidConfig get "radius"}) exitWith {false};
if (_kind == "shot" && {_unit distance2D _pos > 75}) exitWith {false};
if (_weight <= 0 || {!finite _weight}) exitWith {false};
DSDS_noise set ["score",(DSDS_noise get "score") + _weight];
true
