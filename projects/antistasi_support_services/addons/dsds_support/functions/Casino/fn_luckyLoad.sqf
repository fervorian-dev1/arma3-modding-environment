if (!isServer || {isRemoteExecuted}) exitWith {};
DSDS_luckyPlayers=createHashMap;DSDS_luckyQueue=[];
private _v=["DSDS_luckyState"] call A3A_fnc_returnSavedStat;
if (!isNil "_v" && {_v isEqualType []} && {count _v==2} && {_v select 0==1}) then {
 {if (_x isEqualType [] && {count _x==7}) then {
  _x params ["_uid","_tokens","_cars","_items","_gummies","_met","_spin"];
  if (_uid isEqualType "" && {_tokens isEqualType 0} && {finite _tokens} && {_cars isEqualType 0} && {finite _cars} && {_items isEqualType []} && {_gummies isEqualType 0} && {finite _gummies} && {_met isEqualType true} && {_spin isEqualType true}) then {
   private _p=[_uid] call DSDS_fnc_luckyProfile;
   _p set ["tokens",(floor _tokens max 0)+([0,1] select _spin)];_p set ["cars",floor _cars max 0];_p set ["items",_items];_p set ["gummies",floor _gummies max 0];_p set ["met",_met];
  };
 };} forEach (_v select 1);
};
// Commit cleared spin escrow now: repeated loads cannot refund it twice.
[] call DSDS_fnc_luckySave;
