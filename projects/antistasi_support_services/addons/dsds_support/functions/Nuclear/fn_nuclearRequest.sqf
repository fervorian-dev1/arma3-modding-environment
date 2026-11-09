params [["_actor",objNull,[objNull]]];
if (!isServer || {isNull _actor} || {!isPlayer _actor} || {!alive _actor} || {owner _actor!=(if (isRemoteExecuted) then {remoteExecutedOwner} else {2})}) exitWith {};
private _dsdsNuclearDispatch=true;
[_actor] call DSDS_fnc_nuclearDetonateVest;
