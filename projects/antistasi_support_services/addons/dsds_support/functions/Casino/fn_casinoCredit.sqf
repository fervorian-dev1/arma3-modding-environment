params ["_uid","_amount"];
if (!isServer || {!(_amount isEqualType 0)} || {!finite _amount} || {_amount<0}) exitWith {false};
private _units=allPlayers select {getPlayerUID _x==_uid && {alive _x}};private _credited=false;
if (_units isNotEqualTo []) then {
 private _u=_units select 0;private _holder=_u getVariable ["owner",objNull];
 if (!isNull _holder && {!isNil {_holder getVariable "moneyX"}}) then {
  private _dsdsAuthorizedPlayer=_u;
  _credited=[_u,_amount] call DSDS_fnc_changeWallet;
  if (_credited && {!isNil "A3A_saveTarget"}) then {["player_"+_uid+"_moneyX",_holder getVariable ["moneyX",0]] call A3A_fnc_setStatVariable;};
 };
};
if (!_credited) then {DSDS_casinoCredits set [_uid,(DSDS_casinoCredits getOrDefault [_uid,0])+_amount];};
_credited
