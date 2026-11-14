/* Owner-local, scheduled deployment. Never treat leaving the aircraft as proof of success. */
if (isRemoteExecuted && {isMultiplayer} && {remoteExecutedOwner!=2}) exitWith {false};
params ["_unit","_aircraft",["_token",""],["_fallback",[]],["_chuteClass","Steerable_Parachute_F"]];
if (!local _unit || {!alive _unit} || {vehicle _unit!=_aircraft && {!(isNull objectParent _unit && {getPosATL _unit select 2>10})}}) exitWith {false};
[_unit,_aircraft,_token,_fallback,_chuteClass] spawn {
 params ["_unit","_aircraft","_token","_fallback","_chuteClass"];
 if (!local _unit || {!alive _unit} || {vehicle _unit!=_aircraft && {!(isNull objectParent _unit && {getPosATL _unit select 2>10})}}) exitWith {};
 // The authenticated server callback carries the token; object-variable replication may arrive later.
 if (_token!="") then {_unit setVariable ["DSDS_jumpToken",_token];};
 if (_fallback isEqualTo []) then {_fallback=_unit getVariable ["DSDS_boardOrigin",[]];};
 private _wasDamage=isDamageAllowed _unit;
 _unit allowDamage false;
 private _position=if (vehicle _unit==_aircraft) then {(getPosASL _aircraft) vectorAdd [0,0,-15]} else {(getPosASL _unit) vectorAdd [0,0,-3]};
 private _chute=objNull;
 if (isClass (configFile >> "CfgVehicles" >> _chuteClass) && {_chuteClass isKindOf "ParachuteBase"}) then {_chute=createVehicle [_chuteClass,ASLToATL _position,[],0,"FLY"];};
 private _ok=false;
 if (!isNull _chute) then {
  _chute disableCollisionWith _aircraft;_chute setPosASL _position;_chute setVelocity [0,0,-3];
  unassignVehicle _unit;moveOut _unit;
  private _until=diag_tickTime+2;
  waitUntil {
   if (local _unit && {alive _unit} && {vehicle _unit!=_chute}) then {_unit assignAsDriver _chute;_unit moveInDriver _chute;};
   sleep 0.05;
   vehicle _unit==_chute || {!alive _unit} || {!local _unit} || {diag_tickTime>_until} || {_token!="" && {(_unit getVariable ["DSDS_jumpToken",""])!=_token}}
  };
  _ok=alive _unit && {vehicle _unit==_chute} && {driver _chute==_unit} && {_token=="" || {(_unit getVariable ["DSDS_jumpToken",""])==_token}};
 };
 if (!_ok) then {
  if (alive _unit && {local _unit}) then {unassignVehicle _unit;moveOut _unit;if (_fallback isNotEqualTo []) then {_unit setPosATL _fallback;_unit setVelocity [0,0,0];};};
  if (!isNull _chute && {crew _chute isEqualTo []}) then {deleteVehicle _chute;};
  _unit setVariable ["DSDS_jumpOutcome",[_token,false],true];
  if (local _unit) then {_unit allowDamage _wasDamage;};
 } else {
  _unit setVariable ["DSDS_parachute",_chute,true];
  _unit setVariable ["DSDS_jumpOutcome",[_token,true],true];
  sleep 1;
  if (local _unit) then {_unit allowDamage _wasDamage;};
  // Do not eject passengers two metres above ground. Let the parachute touch down.
  private _until=diag_tickTime+600;
  waitUntil {sleep 0.1;!alive _unit || {isNull _chute} || {vehicle _unit!=_chute} || {isTouchingGround _chute} || {(getPosATL _chute select 2)<0.35 && {abs (velocity _chute select 2)<3}} || {diag_tickTime>_until}};
  if (!isNull _chute && {vehicle _unit==_chute} && {alive _unit}) then {
   if (diag_tickTime>_until) then {_unit allowDamage false;unassignVehicle _unit;moveOut _unit;if (_fallback isNotEqualTo []) then {_unit setPosATL _fallback;_unit setVelocity [0,0,0];};_unit allowDamage _wasDamage;} else {unassignVehicle _unit;moveOut _unit;};
  };
  sleep 1;
  if (!isNull _chute && {crew _chute isEqualTo []}) then {deleteVehicle _chute;};
 };
};
true
