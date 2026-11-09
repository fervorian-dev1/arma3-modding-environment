params ["_player","_vehicle","_price"];
if (isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer" || {_dsdsAuthorizedPlayer != _player}}) exitWith {false};
if (!isServer || {isNull _vehicle} || {_vehicle getVariable ["DSDS_selling",false]}) exitWith {false};
// Native JNA conversion includes nested containers, attachments and loaded rounds.
if (isNil "jn_fnc_arsenal_cargoToArsenal" || {isNil "jn_fnc_arsenal_cargoToArray"} || {isNil "jna_dataList"} || {isNil "server"} || {isNull server} || {isNil "boxX"} || {isNull boxX}) exitWith {false};
if (_vehicle getVariable ["A3A_JNA_cargoToArsenal_busy",false] || {_vehicle getVariable ["A3A_JNA_ammunitionTransfer_busy",false]}) exitWith {false};
if (!([_player,0] call DSDS_fnc_changeWallet)) exitWith {false};
_vehicle setVariable ["DSDS_selling",true];
private _cargo = _vehicle call jn_fnc_arsenal_cargoToArray;
if ((_cargo findIf {_x isNotEqualTo []}) >= 0) then {
    [_vehicle] call jn_fnc_arsenal_cargoToArsenal;
    // Apply the campaign's normal unlock thresholds without changing faction state.
    [] call A3A_fnc_arsenalManage;
};
if (!([_player,_price] call DSDS_fnc_changeWallet)) exitWith {_vehicle setVariable ["DSDS_selling",false]; false};
if (!isNil "staticsToSave") then {staticsToSave = staticsToSave - [_vehicle]; publicVariable "staticsToSave";};
deleteVehicle _vehicle;
diag_log format ["[DSDS] Vehicle sale paid %1 credits to %2.",_price,getPlayerUID _player];
true
