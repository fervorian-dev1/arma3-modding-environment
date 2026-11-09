params ["_unit"];
if (!hasInterface || {isRemoteExecuted} || {_unit!=player} || {!local _unit} || {!alive _unit}) exitWith {false};
if ([_unit] call DSDS_fnc_physicalDownState) exitWith {_unit setVariable ["DSDS_consciousSince",nil];false};
private _since=_unit getVariable ["DSDS_consciousSince",diag_tickTime];
_unit setVariable ["DSDS_consciousSince",_since];
if (diag_tickTime-_since<2) exitWith {false};
// Let the original unconscious worker leave its loop and clean its own countdown
// and effects. Never heal, respawn, or remove unrelated display/mission handlers.
if (_unit getVariable ["incapacitated",false]) then {_unit setVariable ["incapacitated",false,true];};
if (!isNil "respawnMenu" && {respawnMenu>=0}) then {
 (findDisplay 46) displayRemoveEventHandler ["KeyDown",respawnMenu];
 // Original unconscious worker also removes this ID when it exits. Keep a
 // harmless numeric sentinel rather than making its later cleanup undefined.
 respawnMenu=-1;
};
true
