params ["_actor"];
if (!isServer || {isRemoteExecuted} || {isNull _actor} || {!isPlayer _actor}) exitWith {};
private _record=createHashMapFromArray [["id",format ["DSDS_CBRN_TEST_%1",floor serverTime]],["side",missionNamespace getVariable ["Occupants",west]],["attackers",createHashMapFromArray [[getPlayerUID _actor,serverTime]]]];
[_record] spawn DSDS_fnc_contaminationResponse;
