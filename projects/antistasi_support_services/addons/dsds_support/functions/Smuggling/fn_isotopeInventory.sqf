/* lockInventory has local effects; publish the unlock to every client, including JIP. */
if (isRemoteExecuted && {remoteExecutedOwner!=2}) exitWith {};
params [["_truck",objNull,[objNull]]];
if (!isNull _truck) then {_truck lockInventory false;};
