/* Two four-sniper overwatch teams; no task/marker/player warning or faction changes. */
params ["_state","_npc"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _finish={_state set ["pending",false];};
private _side=missionNamespace getVariable ["Occupants",sideUnknown];
private _faction=missionNamespace getVariable ["A3A_faction_occ",createHashMap];
if (isNull _npc || {!alive _npc} || {_side==sideUnknown} || {_side getFriend (missionNamespace getVariable ["teamPlayer",resistance])>=0.6}) exitWith {call _finish;};
private _tier=if ((missionNamespace getVariable ["tierWar",1])<5) then {0} else {if (tierWar<8) then {1} else {2}};
// Ultimate's enemy templates register the sniper as the first member of this
// tiered pair, not the rebel-only unitSniper field.
private _pair=(_faction getOrDefault ["groupTierSniper",[]]) param [_tier,[]];
private _type=_pair param [0,_faction getOrDefault ["unitMilitiaSniper",_faction getOrDefault ["unitSniper",""]]];
if (!(_type isEqualType "") || {_type==""} || {!isClass (configFile >> "CfgVehicles" >> _type) && {isNil "A3A_customUnitTypes" || {(A3A_customUnitTypes getVariable [_type,[]]) isEqualTo []}}}) exitWith {diag_log "[DSDS Fence] Occupier has no registered sniper role; ambush skipped.";call _finish;};
private _tent=missionNamespace getVariable ["DSDS_fenceTent",objNull];
private _center=getPosATL _npc;
private _entrance=if (isNull _tent) then {_center} else {_tent modelToWorld [0,-8,0]};
private _targetEye=AGLToASL (_entrance vectorAdd [0,0,1.4]);
private _positions=[];private _bearing=random 360;private _safeCount=0;private _terrainCount=0;private _viewCount=0;
for "_team" from 0 to 1 do {
 private _best=[];private _bestHeight=-1e6;
 for "_attempt" from 1 to 90 do {
  private _seed=_center getPos [250+random 250,_bearing+_team*180-90+random 180];
  private _pos=[_seed,0,35,8,0,0.45,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
  private _eye=AGLToASL (_pos vectorAdd [0,0,0.7]);
  if (_pos distance2D _center>=220 && {_pos distance2D _center<=550}) then {_safeCount=_safeCount+1;if (!terrainIntersectASL [_eye,_targetEye]) then {_terrainCount=_terrainCount+1;if ((lineIntersectsSurfaces [_eye,_targetEye,_npc,_tent,true,1,"VIEW","NONE"]) isEqualTo []) then {_viewCount=_viewCount+1;};};};
  if (_pos distance2D _center>=220 && {_pos distance2D _center<=550} && {!surfaceIsWater _pos} && {(_positions findIf {_x distance2D _pos<100})<0} && {(allPlayers findIf {alive _x && {_x distance2D _pos<600 || {([objNull,"VIEW"] checkVisibility [eyePos _x,_eye])>0.1}}})<0} && {!terrainIntersectASL [_eye,_targetEye]} && {(lineIntersectsSurfaces [_eye,_targetEye,_npc,_tent,true,1,"VIEW","NONE"]) isEqualTo []}) then {
   private _height=getTerrainHeightASL _pos;
   if (_height>_bestHeight) then {_best=+_pos;_bestHeight=_height;};
  };
 };
 if (_best isNotEqualTo []) then {_positions pushBack _best;};
};
if (count _positions!=2 || {!alive _npc} || {_npc!=missionNamespace getVariable ["DSDS_fence",objNull]} || {(allPlayers findIf {alive _x && {_x distance2D _npc<900}})>=0}) exitWith {diag_log format ["[DSDS Fence] Overwatch skipped: pairs=%1 safe=%2 terrain=%3 view=%4 observers=%5 at %6.",count _positions,_safeCount,_terrainCount,_viewCount,count allPlayers,_center];call _finish;};
private _groups=[];private _units=[];
{
 private _group=createGroup [_side,true];_groups pushBack _group;
 for "_i" from 0 to 3 do {
  private _pos=_x getPos [_i*2,(_x getDir _center)+90];
  private _unit=[_group,_type,_pos,0.85] call DSDS_fnc_smugglingUnit;
  if (!isNull _unit) then {
   [_unit,"FIXED"] call DSDS_fnc_configureAddonAI;
   _unit setDir (_pos getDir _entrance);_unit setUnitPos "DOWN";_unit disableAI "PATH";
   _unit doWatch _entrance;_units pushBack _unit;
  };
 };
 _group setBehaviourStrong "AWARE";_group setCombatMode "BLUE";
} forEach _positions;
if (count _units!=8) exitWith {{deleteVehicle _x;} forEach _units;{deleteGroup _x;} forEach _groups;diag_log "[DSDS Fence] Incomplete sniper teams cancelled.";call _finish;};
private _record=createHashMapFromArray [["npc",_npc],["side",_side],["units",_units],["groups",_groups],["vehicles",[]],["ended",false],["engaged",false],["expires",serverTime+1800]];
_state set ["active",_record];call _finish;
diag_log format ["[DSDS Fence] Two four-sniper overwatch teams prepared after visit %1.",_state get "count"];
