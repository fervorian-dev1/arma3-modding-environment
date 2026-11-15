params ["_pos","_dir"];
if !(_pos isEqualType [] && {count _pos in [2,3]} && {(_pos findIf {!(_x isEqualType 0) || {!finite _x}})<0} && {_dir isEqualType 0} && {finite _dir}) exitWith {"Invalid placement."};
if (count _pos==2) then {_pos=+_pos;_pos pushBack 0;};
if ((_pos select 0)<30 || {(_pos select 1)<30} || {(_pos select 0)>worldSize-30} || {(_pos select 1)>worldSize-30}) exitWith {"Choose a location within the map."};
private _h=getTerrainHeightASL _pos;private _ok=true;
{private _xOffset=_x;{private _p=_pos vectorAdd [_xOffset,_x,0];if (surfaceIsWater _p || {abs ((getTerrainHeightASL _p)-_h)>1.5}) then {_ok=false;};} forEach [-12,0,12];} forEach [-12,0,12];
if (!_ok) exitWith {"The hotel needs a flat, dry area about 30 metres across."};
if ((nearestTerrainObjects [_pos,["HOUSE","TREE","SMALL TREE","ROCK","ROCKS"],20,false,true]) isNotEqualTo []) exitWith {"Clear the site of buildings, trees and large rocks first."};
if ((nearestObjects [_pos,["House","AllVehicles"],20]) isNotEqualTo []) exitWith {"Keep people, vehicles and buildings at least 20 metres from the site."};
""
