/* CBA server event: all persistent objects and global cargo are created on the server. */
if (!isServer) exitWith {};
params [["_requester", objNull, [objNull]], ["_position", [], [[]]], ["_options", [], [[]]]];
if (isNull _requester || {!isPlayer _requester} || {isNull getAssignedCuratorLogic _requester}) exitWith {
    diag_log "[DSD] Rejected request without an assigned player curator.";
};
private _target = [_position] call DSD_fnc_validateDropPosition;
if (_target isEqualTo []) exitWith {[_requester, "Invalid drop location: choose dry land inside the map."] call DSD_fnc_notifySupplyDrop;};
private _validated = [_options] call DSD_fnc_validateDropOptions;
if ((_validated select 0) != "") exitWith {[_requester, _validated select 0] call DSD_fnc_notifySupplyDrop;};
if (diag_tickTime < (_requester getVariable ["DSD_nextRequest", -1])) exitWith {[_requester, "Wait 10 seconds between requests."] call DSD_fnc_notifySupplyDrop;};
if (DSD_activeDrops >= 4) exitWith {[_requester, "Four deliveries are already active. Try again after one lands."] call DSD_fnc_notifySupplyDrop;};
_requester setVariable ["DSD_nextRequest", diag_tickTime + 10];
DSD_activeDrops = DSD_activeDrops + 1;
[_requester, "Delivery accepted; preparing transport."] call DSD_fnc_notifySupplyDrop;
[_requester, _target, _validated select 1] spawn DSD_fnc_runSupplyDelivery;
