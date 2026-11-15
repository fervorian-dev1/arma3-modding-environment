if (!isServer || {isRemoteExecuted} || {isNil "DSDS_luckyPlayers"}) exitWith {};
if (DSDS_luckyQueue isNotEqualTo []) then {private _q=DSDS_luckyQueue deleteAt 0;_q call DSDS_fnc_luckyDeliver;};
{
 private _uid=_x;private _p=_y;private _spin=_p get "spin";
 if (_spin isNotEqualTo [] && {serverTime>=(_spin select 1)}) then {
  _p set ["spin",[]];private _index=[] call DSDS_fnc_luckyPick;
  [_uid,_index] call DSDS_fnc_luckyAward;
  [] call DSDS_fnc_luckySave;[] call DSDS_fnc_casinoSave;
  private _u=allPlayers select {getPlayerUID _x==_uid};if (_u isNotEqualTo []) then {[_u select 0] call DSDS_fnc_luckySync;};
 };
} forEach DSDS_luckyPlayers;
{
 if (alive _x && {_x getVariable ["DSDS_luckySynced",""]!=getPlayerUID _x} && {getPlayerUID _x!=""}) then {_x setVariable ["DSDS_luckySynced",getPlayerUID _x];[_x] call DSDS_fnc_luckySync;};
} forEach allPlayers;
