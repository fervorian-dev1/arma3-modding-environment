/* Optional adapter for the installed Antistasi Plus APIs. No hard dependency. */
params ["_crate"];
if (!isServer || {isNull _crate} || {_crate getVariable ["DSD_antistasiRegistered", false]}) exitWith {};
if (isNil "A3A_faction_reb" || {isNil "A3A_Logistics_fnc_addLoadAction"} || {isNil "A3A_Logistics_fnc_isLoadable"} || {isNil "jn_fnc_arsenal_cargoToArsenal"} || {isNil "A3A_fnc_arsenalManage"}) exitWith {};
_crate setVariable ["DSD_antistasiRegistered", true];
if ([_crate] call A3A_Logistics_fnc_isLoadable) then {
    [_crate] call A3A_Logistics_fnc_addLoadAction;
    diag_log "[DSD] Antistasi native load action registered for landed crate.";
} else {
    diag_log format ["[DSD] Crate %1 has no Antistasi cargo definition; HQ import still available if transported there.", typeOf _crate];
};
[_crate] spawn {
    params ["_crate"];
    while {!isNull _crate && {alive _crate} && {!(_crate getVariable ["DSD_arsenalImported", false])}} do {
        [_crate] call DSD_fnc_importAntistasiCrate;
        sleep 5;
    };
};
