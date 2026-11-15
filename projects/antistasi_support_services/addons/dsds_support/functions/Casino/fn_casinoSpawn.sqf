params ["_class","_pos","_direction"];
if (!isServer || {isRemoteExecuted} || {!isClass (configFile >> "CfgVehicles" >> _class)} || {count _pos<2}) exitWith {false};
if (!isNull (missionNamespace getVariable ["DSDS_casinoBuilding",objNull])) exitWith {true};
if (!isClass (configFile >> "CfgFaces" >> "Man_A3" >> "B_female_bun_01")) exitWith {false};
if ((missionNamespace getVariable ["DSDS_casinoDealers",[]]) isNotEqualTo []) then {[] call DSDS_fnc_casinoClear;};
[] call DSDS_fnc_casinoRestoreSite;
if !([_pos,_direction] call DSDS_fnc_casinoPrepareSite) exitWith {false};
private _building=createVehicle [_class,_pos,[],0,"CAN_COLLIDE"];
if (isNull _building) exitWith {[] call DSDS_fnc_casinoRestoreSite;false};
_building setDir _direction;
private _box=boundingBoxReal _building;
_building setPosATL [_pos select 0,_pos select 1,0];_building setVectorUp [0,0,1];_building allowDamage false;
private _front=((_box select 0) select 1)-5;
private _pairs=[];private _props=+(missionNamespace getVariable ["DSDS_casinoProps",[]]);private _group=createGroup [civilian,true];
private _games="true" configClasses (configFile >> "DSDS_Casino" >> "Games");
{
 private _i=_forEachIndex;private _game=configName _x;
 // Two spacious rows inside the single-storey hall, clear of the doors/walls.
 private _point=_building modelToWorld [((_i mod 3)-1)*8,-8+16*floor (_i/3),0];_point set [2,0];
 // Use the actual walkable floor rather than the model-centre elevation.
 private _asl=ATLToASL _point;private _hits=lineIntersectsSurfaces [_asl vectorAdd [0,0,2],_asl vectorAdd [0,0,-2],objNull,objNull,true,8,"GEOM","NONE"];
 private _floor=_hits findIf {(_x select 2)==_building && {((_x select 1) select 2)>.7}};
 if (_floor>=0) then {_point=ASLToATL (((_hits select _floor) select 0) vectorAdd [0,0,.03]);};
 private _heading=_direction+180;
 private _npc=[_game,_point,_heading,_i,_group] call DSDS_fnc_casinoSpawnDealer;
 if (!isNull _npc) then {_pairs pushBack [_game,_npc,_point,_heading,_i];};
} forEach _games;
if (count _pairs!=count _games) exitWith {{deleteVehicle (_x select 1);} forEach _pairs;deleteVehicle _building;deleteGroup _group;[] call DSDS_fnc_casinoRestoreSite;false};
// Preserve the one collection crate and its contents during relocation.
{
 if (!isNull _x && {_x getVariable ["DSDS_luckyPickup",false]} && {isNull attachedTo _x} && {isNull isVehicleCargo _x}) then {
  private _point=_building modelToWorld [16,_front-3,0];_point set [2,0];_x setPosATL _point;
 };
} forEach _props;
// Grounded exterior decoration; never use model-centre Z or bounding-box depth.
{
 _x params ["_class","_offset","_turn"];
 if (isClass (configFile >> "CfgVehicles" >> _class)) then {
  private _point=_building modelToWorld [_offset select 0,_front+(_offset select 1),0];_point set [2,0];
  private _prop=createVehicle [_class,_point,[],0,"CAN_COLLIDE"];
  if (!isNull _prop) then {_prop setDir (_direction+_turn);_prop setPosATL _point;_prop allowDamage false;_prop enableSimulationGlobal false;_props pushBack _prop;};
 };
} forEach [["Land_Statue_03_F",[-15,-1],180],["Land_FlowerPot_01_F",[-12,-1],0],["Land_FlowerPot_01_F",[12,-1],0],["Land_Bench_F",[-15,-8],90],["Land_Bench_F",[15,-8],270]];
DSDS_casinoOwned=true;publicVariable "DSDS_casinoOwned";DSDS_casinoBuilding=_building;DSDS_casinoDealers=_pairs;DSDS_casinoProps=_props;
publicVariable "DSDS_casinoBuilding";publicVariable "DSDS_casinoDealers";
DSDS_casinoState set ["class",_class];DSDS_casinoState set ["position",_pos];DSDS_casinoState set ["direction",_direction];DSDS_casinoState set ["stored",false];
if (getMarkerColor "DSDS_Casino"=="") then {createMarker ["DSDS_Casino",_pos];};
"DSDS_Casino" setMarkerPos _pos;"DSDS_Casino" setMarkerType "mil_dot";"DSDS_Casino" setMarkerColor "ColorYellow";"DSDS_Casino" setMarkerText "Aurum Casino";true
