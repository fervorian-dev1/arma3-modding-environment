/* Server-only native JNA import. Leave the empty container in its truck slot:
   deleting/detaching it here would corrupt Antistasi's Cargo/Nodes/seat/mass state. */
params ["_crate"];
if (!isServer || {isNull _crate} || {!alive _crate} || {!(_crate getVariable ["DSD_landed", false])} || {_crate getVariable ["DSD_arsenalImported", false]}) exitWith {false};
if (isNil "jn_fnc_arsenal_cargoToArsenal" || {isNil "A3A_fnc_arsenalManage"} || {isNil "jna_dataList"} || {isNil "server"} || {isNil "minWeaps"}) exitWith {false};
if (count jna_dataList < 27 || {isNull server}) exitWith {false};
private _arsenal = missionNamespace getVariable ["boxX", objNull];
if (isNull _arsenal || {_crate == _arsenal} || {_crate distance2D _arsenal > 20} || {abs ((getPosASL _crate select 2) - (getPosASL _arsenal select 2)) > 6}) exitWith {false};
private _carrier = attachedTo _crate;
if (!isNull _carrier && {!(_carrier isKindOf "LandVehicle")}) exitWith {false};
private _movingObject = if (isNull _carrier) then {_crate} else {_carrier};
if (abs speed _movingObject > 1 || {_movingObject getVariable ["LoadingCargo", false]}) exitWith {false};
private _imported = false;
// Native arsenal transfer and our once-only flag run together without scheduler interleaving.
isNil {
    if (!(_crate getVariable ["A3A_JNA_cargoToArsenal_busy", false]) && {!(_crate getVariable ["A3A_JNA_ammunitionTransfer_busy", false])} && {!(_arsenal getVariable ["A3A_JNA_cargoToArsenal_busy", false])} && {!(_crate getVariable ["DSD_arsenalImported", false])}) then {
        [_crate] call jn_fnc_arsenal_cargoToArsenal;
        private _empty = (weaponCargo _crate) isEqualTo [] && {magazineCargo _crate isEqualTo []} && {itemCargo _crate isEqualTo []} && {backpackCargo _crate isEqualTo []};
        if (_empty) then {
            _crate setVariable ["DSD_arsenalImported", true, true];
            // Reuse Antistasi's normal unlock thresholds and loadout accounting.
            [] call A3A_fnc_arsenalManage;
            _imported = true;
        };
    };
};
if (_imported) then {diag_log "[DSD] Crate cargo imported into Antistasi HQ arsenal; empty container retained for native logistics.";};
_imported
