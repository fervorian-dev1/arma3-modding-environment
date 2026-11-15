params ["_class","_pos","_direction"];
if (!isServer || {isRemoteExecuted} || {!isClass (configFile >> "CfgVehicles" >> _class)} || {count _pos<2}) exitWith {false};
if (!isNull (missionNamespace getVariable ["DSDS_casinoBuilding",objNull])) exitWith {true};
private _faces=["B_female_bun_01","B_female_bun_02","B_female_bun_03","B_female_bun_04"] select {isClass (configFile >> "CfgFaces" >> "Man_A3" >> _x)};
if (_faces isEqualTo []) exitWith {diag_log "[DSDS Casino] Timberwolf female head models unavailable; enable required character mod.";false};
private _building=createVehicle [_class,_pos,[],0,"CAN_COLLIDE"];
if (isNull _building) exitWith {false};
_building setDir _direction;_building setPosATL [_pos select 0,_pos select 1,0];_building setVectorUp [0,0,1];_building allowDamage false;
// Remove only prior casino-owned auxiliaries when restoring a deleted building.
{private _u=_x select 1;private _g=group _u;deleteVehicle _u;if (!isNull _g && {units _g isEqualTo []}) then {deleteGroup _g;};} forEach (missionNamespace getVariable ["DSDS_casinoDealers",[]]);
{deleteVehicle _x;} forEach (missionNamespace getVariable ["DSDS_casinoProps",[]]);
private _nodes=_building buildingPos -1;
private _ranked=_nodes apply {[_x select 2,_x]};_ranked sort true;
private _selected=[];
{private _p=_x select 1;if ((_selected findIf {_x distance2D _p<3})<0) then {_selected pushBack _p;};} forEach _ranked;
private _pairs=[];private _props=[];private _group=createGroup [civilian,true];
private _games="true" configClasses (configFile >> "DSDS_Casino" >> "Games");
{
 private _i=_forEachIndex;private _cfg=_x;private _game=configName _cfg;
 private _p=if (_i<count _selected) then {_selected select _i} else {_building modelToWorld [(_i-count _selected)*3-6,-15,0]};
 private _npc=[_game,_p,_direction,_i,_group] call DSDS_fnc_casinoSpawnDealer;
 if (!isNull _npc) then {
  private _heading=_direction;
  {private _d=_direction+_x;private _end=AGLToASL (_p getPos [1.5,_d]);private _from=AGLToASL (_p vectorAdd [0,0,1]);_end=_end vectorAdd [0,0,1];if ((lineIntersectsSurfaces [_from,_end,_npc,objNull,true,1,"GEOM","NONE"]) isEqualTo []) exitWith {_heading=_d;};} forEach [0,90,180,270];
  _npc setDir _heading;_pairs pushBack [_game,_npc,_p,_heading,_i];
  private _table=createVehicle ["Land_TableBig_01_F",_p getPos [1.2,_heading],[],0,"CAN_COLLIDE"];
  if (!isNull _table) then {_table setDir _heading;_table setPosATL (_p getPos [1.2,_heading]);_table allowDamage false;_table enableSimulationGlobal false;_props pushBack _table;};
 };
} forEach _games;
if (count _pairs!=count _games) exitWith {{deleteVehicle (_x select 1);} forEach _pairs;{deleteVehicle _x;} forEach _props;deleteVehicle _building;deleteGroup _group;false};
{
 _x params ["_class","_offset","_dir"];
 if (isClass (configFile >> "CfgVehicles" >> _class)) then {private _o=createVehicle [_class,_building modelToWorld _offset,[],0,"CAN_COLLIDE"];if (!isNull _o) then {_o setDir (_direction+_dir);_o setPosATL (_building modelToWorld _offset);_o allowDamage false;_o enableSimulationGlobal false;_props pushBack _o;};};
} forEach [["Land_Sofa_01_F",[-4,-14,0],0],["Land_ArmChair_01_F",[-7,-14,0],90],["Land_ArmChair_01_F",[-1,-14,0],270],["Land_RattanTable_01_F",[-4,-12,0],0],["Land_RattanChair_01_F",[5,-14,0],0],["Land_RattanChair_01_F",[7,-14,0],0],["Land_RattanTable_01_F",[6,-12,0],0]];
DSDS_casinoBuilding=_building;DSDS_casinoDealers=_pairs;DSDS_casinoProps=_props;publicVariable "DSDS_casinoBuilding";publicVariable "DSDS_casinoDealers";
DSDS_casinoState set ["class",_class];DSDS_casinoState set ["position",_pos];DSDS_casinoState set ["direction",_direction];
if (getMarkerColor "DSDS_Casino"=="") then {createMarker ["DSDS_Casino",_pos];};"DSDS_Casino" setMarkerPos _pos;"DSDS_Casino" setMarkerType "mil_dot";"DSDS_Casino" setMarkerColor "ColorYellow";"DSDS_Casino" setMarkerText "Aurum Casino";
diag_log format ["[DSDS Casino] %1 created at %2 with %3 dealers.",_class,_pos,count _pairs];true
