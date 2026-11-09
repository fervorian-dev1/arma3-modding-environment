/* Preserve routes; cap the front's speed and recover immobile AI only out of player view. */
params ["_record"];
if (!isServer || {isRemoteExecuted} || {_record getOrDefault ["cohesionStarted",false]}) exitWith {};
_record set ["cohesionStarted",true];
private _truck=_record get "truck";private _side=_record get "side";private _task=_record getOrDefault ["task",""];
private _history=createHashMap;private _touched=[];
while {!isNull _truck && {alive _truck} && {_truck getVariable ["ownerSide",_side]==_side} && {(crew _truck findIf {isPlayer _x})<0} && {_task=="" || {!([_task] call BIS_fnc_taskExists) || {!([_task] call BIS_fnc_taskState in ["SUCCEEDED","FAILED","CANCELED"])}}}} do {
 private _members=+(_record getOrDefault ["members",[]]);
 private _cover=_record getOrDefault ["cover",createHashMap];_members append (_cover getOrDefault ["vehicles",[]]);
 if (_task!="") then {_members append (vehicles select {_x getVariable ["DSDS_convoyTask",""]==_task});};
 _members pushBackUnique _truck;
 _members=(_members arrayIntersect _members) select {!isNull _x && {_x isKindOf "LandVehicle"} && {alive _x} && {canMove _x} && {alive driver _x} && {lifeState driver _x!="INCAPACITATED"} && {(_x getVariable ["ownerSide",_side])==_side} && {(crew _x findIf {isPlayer _x})<0}};
 _record set ["cohesionMembers",_members];
 private _waypoint=waypointPosition [group driver _truck,currentWaypoint group driver _truck];
 if (_waypoint distance2D [0,0,0]<1) then {_waypoint=(getPosATL _truck) getPos [300,getDir _truck];};
 private _heading=if (_waypoint distance2D _truck>20) then {_truck getDir _waypoint} else {getDir _truck};
 private _axis=[sin _heading,cos _heading,0];private _origin=getPosATL _truck;
 private _progress=_members apply {((getPosATL _x) vectorDiff _origin) vectorDotProduct _axis};
 private _rear=if (_progress isEqualTo []) then {0} else {selectMin _progress};
 private _front=if (_progress isEqualTo []) then {0} else {selectMax _progress};
 private _widest=0;{private _a=_x;{_widest=_widest max (_a distance2D _x);} forEach _members;} forEach _members;
 private _nearest=if (_members isEqualTo []) then {0} else {selectMin (_members apply {_x distance2D _waypoint})};
 _record set ["cohesionSpread",_front-_rear];
 {
  private _vehicle=_x;_touched pushBackUnique _vehicle;
  if (!(_vehicle getVariable ["DSDS_cohesionHitEH",false])) then {
   _vehicle setVariable ["DSDS_cohesionHitEH",true];_vehicle setVariable ["DSDS_convoyObjective",_truck,true];_vehicle setVariable ["DSDS_cohesionRecord",_record];
   _vehicle addMPEventHandler ["MPHit",{if (isServer) then {((_this select 0) getVariable ["DSDS_cohesionRecord",createHashMap]) set ["lastAttack",serverTime];[(_this select 0) getVariable ["DSDS_convoyObjective",objNull],_this param [1,objNull],_this param [3,objNull]] call DSDS_fnc_convoyHit;};}];
  };
  private _ahead=(_progress select _forEachIndex)-_rear;
  private _hold=(_front-_rear)>300 && {_ahead>180};
  if (_widest>400 && {_vehicle distance2D _waypoint<_nearest+60}) then {_hold=true;};
  private _combat=serverTime<(_record getOrDefault ["lastAttack",-1000])+60;
  // Do not freeze ambushed vehicles in a kill zone. Escorts switch to their combat AI.
  if (_combat) then {_hold=false;};
  private _key=netId _vehicle;private _last=_history getOrDefault [_key,[getPosATL _vehicle,serverTime,0]];
  if (_vehicle distance2D (_last select 0)>5 || {_hold} || {_combat}) then {_last set [0,getPosATL _vehicle];_last set [1,serverTime];};
  private _recovery=[];
  if (!_hold && {!_combat} && {serverTime-(_last select 1)>60} && {(_last select 2)<3}) then {
   private _unseen=(allPlayers findIf {alive _x && {_x distance2D _vehicle<600 || {_x distance2D _vehicle<1500 && {[vehicle _x,"VIEW"] checkVisibility [eyePos _x,getPosASL _vehicle]>0.1}}}})<0;
   if (_unseen) then {
    private _roads=((getPosATL _vehicle) getPos [45,_heading]) nearRoads 80;
    _roads=_roads select {_x distance2D _vehicle>20 && {count ((getPosATL _x) nearEntities ["LandVehicle",18])==0}};
    if (_roads isNotEqualTo []) then {
     private _road=[_roads,_waypoint] call BIS_fnc_nearestPosition;_recovery=getPosATL _road;_recovery set [2,0.2];
     _last set [2,(_last select 2)+1];
     diag_log format ["[DSDS Convoy] Offscreen road recovery %1 (%2).",typeOf _vehicle,_last select 2];
    };
   };
   _last set [1,serverTime];
  };
  _history set [_key,_last];
  private _limit=if (_ahead>120) then {25} else {45};
  [_vehicle,"PACE",[_limit,_hold,_recovery]] remoteExecCall ["DSDS_fnc_convoyLocal",owner _vehicle];
  _vehicle setVariable ["DSDS_cohesionHold",_hold,true];
 } forEach _members;
 sleep 4;
};
{if (!isNull _x && {(crew _x findIf {isPlayer _x})<0}) then {[_x,"RESTORE"] remoteExecCall ["DSDS_fnc_convoyLocal",owner _x];_x setVariable ["DSDS_cohesionHold",false,true];};} forEach _touched;
_record set ["cohesionEnded",true];
