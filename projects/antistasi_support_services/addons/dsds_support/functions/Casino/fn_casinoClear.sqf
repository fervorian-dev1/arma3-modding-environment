/* Only casino-owned objects; retain prize cargo for relocation/collection. */
if (!isServer || {isRemoteExecuted}) exitWith {false};
{
 private _u=_x select 1;private _g=group _u;
 deleteVehicle _u;if (!isNull _g && {units _g isEqualTo []}) then {deleteGroup _g;};
} forEach (missionNamespace getVariable ["DSDS_casinoDealers",[]]);
private _keep=[];
{if (_x getVariable ["DSDS_luckyPickup",false]) then {_keep pushBack _x;} else {deleteVehicle _x;};} forEach (missionNamespace getVariable ["DSDS_casinoProps",[]]);
deleteVehicle (missionNamespace getVariable ["DSDS_casinoBuilding",objNull]);
DSDS_casinoBuilding=objNull;DSDS_casinoDealers=[];DSDS_casinoProps=_keep;
[] call DSDS_fnc_casinoRestoreSite;
publicVariable "DSDS_casinoBuilding";publicVariable "DSDS_casinoDealers";deleteMarker "DSDS_Casino";true
