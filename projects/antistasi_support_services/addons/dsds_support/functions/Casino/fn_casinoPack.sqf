if (!isServer || {isRemoteExecuted} || {isNil "DSDS_casinoState"} || {missionNamespace getVariable ["DSDS_casinoBuildLock",false]}) exitWith {false};
// Developer packing cancels table stakes fairly; spin rewards still resolve normally.
{if (_y getOrDefault ["phase","finished"]!="finished") then {[_y,_y get "bet","Table closed; stake returned."] call DSDS_fnc_casinoFinishRound;[_y] call DSDS_fnc_casinoSettle;};} forEach DSDS_casinoSessions;
[] call DSDS_fnc_casinoClear;
DSDS_casinoState set ["stored",true];[] call DSDS_fnc_casinoSave;true
