/* Read-only footprint analysis. Vegetation is removable; buildings/roads are not. */
params ["_pos","_dir",["_ignoreOwned",false]];
private _result=createHashMapFromArray [["error","Invalid placement."]];
if !(_pos isEqualType [] && {count _pos in [2,3]} && {(_pos findIf {!(_x isEqualType 0) || {!finite _x}})<0} && {_dir isEqualType 0} && {finite _dir}) exitWith {_result};
_pos=[_pos select 0,_pos select 1,0];
if ((_pos select 0)<70 || {(_pos select 1)<70} || {(_pos select 0)>worldSize-70} || {(_pos select 1)>worldSize-70}) exitWith {_result set ["error","Choose a site away from the edge of the map."];_result};
private _world={params ["_x","_y"];[(_pos select 0)+_x*cos _dir+_y*sin _dir,(_pos select 1)-_x*sin _dir+_y*cos _dir,0]};
private _heights=[];private _wet=false;
{private _xOffset=_x;{private _p=[_xOffset,_x] call _world;if (surfaceIsWater _p) then {_wet=true;};_heights pushBack getTerrainHeightASL _p;} forEach [-42,-20,0,30];} forEach [-20,0,20];
if (_wet) exitWith {_result set ["error","The casino footprint must be on dry land."];_result};
_heights sort true;private _relief=(_heights select (count _heights-1))-(_heights select 0);
if (_relief>8) exitWith {_result set ["error","This hillside is too steep. Use Find suitable location to choose nearby ground."];_result};
private _center=[0,-6] call _world;
private _inside={params ["_object",["_margin",0]];(getPosATL _object) inArea [_center,20+_margin,36+_margin,_dir,true]};
private _ignore=if (_ignoreOwned) then {[missionNamespace getVariable ["DSDS_casinoBuilding",objNull]]+((missionNamespace getVariable ["DSDS_casinoDealers",[]]) apply {_x select 1})+(missionNamespace getVariable ["DSDS_casinoProps",[]])} else {[]};
private _blocked=(nearestTerrainObjects [_center,["HOUSE","ROCK","ROCKS","WALL","FENCE"],80,false,true]) select {[_x,8] call _inside};
_blocked append (((nearestObjects [_center,["House","AllVehicles"],70])-_ignore) select {[_x,8] call _inside});
if (_blocked isNotEqualTo []) exitWith {_result set ["error","Keep existing structures, rocks, people and vehicles outside the casino plot."];_result};
if (((_center nearRoads 60) findIf {[_x,1] call _inside})>=0) exitWith {_result set ["error","Choose land beside the road, rather than over the road itself."];_result};
_result set ["error",""];_result set ["position",_pos];_result set ["direction",_dir];_result set ["height",_heights select floor (count _heights/2)];_result set ["relief",_relief];
_result
