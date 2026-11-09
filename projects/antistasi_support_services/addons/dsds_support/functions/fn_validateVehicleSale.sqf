params ["_player","_vehicle"];
private _npc = missionNamespace getVariable ["DSDS_mechanic",objNull];
if (isNull _npc || {!alive _npc} || {!isNull attachedTo _npc}) exitWith {"The PMC mechanic must be alive and placed."};
if (isNull _player || {_player distance _npc > 6}) exitWith {"Speak to the mechanic in person."};
if (isNull _vehicle || {!(_vehicle isKindOf "AllVehicles")} || {_vehicle isKindOf "Man"}) exitWith {"Select a vehicle."};
if (_vehicle distance2D _npc > 100) exitWith {"Bring the vehicle within 100 m of the mechanic."};
if (crew _vehicle isNotEqualTo []) exitWith {"Everyone must leave the vehicle before sale."};
if (ropeAttachedObjects _vehicle isNotEqualTo [] || {!isNull ropeAttachedTo _vehicle} || {!isNull getSlingLoad _vehicle} || {getVehicleCargo _vehicle isNotEqualTo []} || {!isNull isVehicleCargo _vehicle}) exitWith {"Unload or disconnect transported vehicles before sale."};
if (!isNull attachedTo _vehicle || {attachedObjects _vehicle isNotEqualTo []} || {(_vehicle getVariable ["Cargo",[]]) isNotEqualTo []} || {_vehicle getVariable ["LoadingCargo",false]}) exitWith {"Unload attached cargo before selling the vehicle."};
if (_vehicle getVariable ["DSDS_serviceVehicle",false]) exitWith {"Contractor service aircraft are not for sale."};
if (_vehicle getVariable ["DSDS_selling",false] || {_vehicle getVariable ["A3A_sellVehicle_inProgress",false]}) exitWith {"This vehicle is already being sold."};
if (_vehicle in [missionNamespace getVariable ["boxX",objNull],missionNamespace getVariable ["vehicleBox",objNull]]) exitWith {"HQ assets are protected."};
private _owner = _vehicle getVariable ["ownerX",""];
if (_owner isEqualType "" && {_owner != ""} && {_owner != getPlayerUID _player}) exitWith {"This vehicle belongs to another player."};
if ([_vehicle] call DSDS_fnc_vehicleValue <= 0) exitWith {"That object is not a vehicle."};
""
