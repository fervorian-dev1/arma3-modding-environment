/* Scheduled search, scoped to an authenticated placement token. No terrain edits here. */
params ["_actor","_token","_center"];
if (!isServer || {isRemoteExecuted} || {isNull _actor}) exitWith {};
private _best=[];private _score=1e12;
for "_i" from 0 to 159 do {
 private _pending=_actor getVariable ["DSDS_casinoBuildToken",[]];
 if (count _pending<4 || {(_pending select 0)!=_token} || {!alive _actor}) exitWith {};
 private _radius=150+floor (_i/20)*350;
 private _p=if (_i==0) then {+_center} else {_center getPos [40+random _radius,random 360]};_p set [2,0];
 if (!surfaceIsWater _p) then {
  private _d=45*floor random 8;private _plan=[_p,_d,true] call DSDS_fnc_casinoSitePlan;
  if (_plan get "error"=="") then {
   private _roads=_p nearRoads 220;private _value=(_plan get "relief")+(_p distance2D _center)/350+([4,0] select (_roads isNotEqualTo []));
   if (_value<_score) then {_best=[_p,_d];_score=_value;};
  };
 };
 if (_score<1.2) exitWith {};sleep 0.005;
};
private _pending=_actor getVariable ["DSDS_casinoBuildToken",[]];
if (count _pending>=4 && {(_pending select 0)==_token}) then {["SITE",[_token,_best]] remoteExecCall ["DSDS_fnc_casinoClient",_actor];};
_actor setVariable ["DSDS_casinoSearching",false];
