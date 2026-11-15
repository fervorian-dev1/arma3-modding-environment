/* Wheel-only, scheduled HQ raid variant. Existing noise raid controller owns its lifecycle. */
params ["_uid",["_planOnly",false]];
if (!isServer || {isRemoteExecuted}) exitWith {createHashMap};
private _p=[_uid] call DSDS_fnc_luckyProfile;
private _fail={params ["_why"];if (!_planOnly) then {_p set ["tokens",(_p get "tokens")+1];_p set ["message","The raid could not deploy. Your token is returned."];[] call DSDS_fnc_luckySave;private _u=allPlayers select {getPlayerUID _x==_uid};if (_u isNotEqualTo []) then {[_u select 0] call DSDS_fnc_luckySync;};};diag_log ("[DSDS Wheel] Raid unavailable: "+_why);createHashMap};
private _petros=missionNamespace getVariable ["petros",objNull];
if (isNull _petros || {!alive _petros} || {isNil "DSDS_noise"} || {(DSDS_noise get "phase") in ["active","preparing"]} || {missionNamespace getVariable ["bigAttackInProgress",false]}) exitWith {["HQ missing or already under attack"] call _fail};
private _assets=[] call DSDS_fnc_responseAssets;private _air=_assets get "osprey";private _troop=_assets get "specialist";
private _side=missionNamespace getVariable ["Occupants",sideUnknown];private _rebels=missionNamespace getVariable ["teamPlayer",resistance];
if (_air=="" || {_troop==""} || {_side==sideUnknown} || {_side==_rebels} || {_side getFriend _rebels>=0.6}) exitWith {["No hostile Osprey/CBRN assets"] call _fail};
private _faction=[_side] call DSDS_fnc_smugglingFaction;if (count _faction==0) exitWith {["Faction pilot unavailable"] call _fail};
private _hq=getPosATL _petros;private _flights=[];private _pads=[];private _bearing=random 360;
for "_i" from 0 to 3 do {
 private _lz=[];
 for "_j" from 1 to 25 do {
  private _candidate=[_hq,180,500,25,0,0.15,0,_pads apply {[_x,100]},[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
  if (_candidate distance2D _hq>=180 && {_candidate distance2D _hq<=500} && {!surfaceIsWater _candidate} && {(_pads findIf {_x distance2D _candidate<100})<0} && {(allPlayers findIf {_x distance2D _candidate<45})<0}) then {
   private _walk=true;for "_step" from 0 to 16 do {if (surfaceIsWater (_candidate vectorAdd ((_hq vectorDiff _candidate) vectorMultiply (_step/16)))) exitWith {_walk=false;};};
   if (_walk) exitWith {_lz=_candidate;};
  };
 };
 if (_lz isEqualTo []) exitWith {};
 private _start=_hq getPos [900+_i*100,_bearing+_i*80];_start set [2,180+_i*45];
 if ((_start select 0)<30 || {(_start select 1)<30} || {(_start select 0)>worldSize-30} || {(_start select 1)>worldSize-30}) exitWith {};
 _flights pushBack [_air,_lz,_start,12 min getNumber (configFile >> "CfgVehicles" >> _air >> "transportSoldier")];_pads pushBack _lz;
};
if (count _flights!=4) exitWith {["Four clear nearby landing zones could not be found"] call _fail};
private _plan=createHashMapFromArray [["side",_side],["men",48],["flights",_flights],["ground",[]],["pilot",_faction get "pilot"],["crew",_faction get "crew"],["troops",[_troop]],["war",missionNamespace getVariable ["tierWar",1]]];
if (_planOnly) exitWith {_plan};
DSDS_noise set ["phase","active"];DSDS_noise set ["score",0];DSDS_noise set ["generation",(DSDS_noise get "generation")+1];
private _raid=createHashMapFromArray [["id",DSDS_noise get "generation"],["hq",_hq],["petros",_petros],["ended",false],["vehicles",[]],["units",[]],["groups",[]],["pads",[]],["infantry",[]],["landingsDone",0],["landingsTotal",0],["wheelRaid",true]];
DSDS_noise set ["raid",_raid];[_raid,_plan] spawn DSDS_fnc_runHQRaid;_plan
