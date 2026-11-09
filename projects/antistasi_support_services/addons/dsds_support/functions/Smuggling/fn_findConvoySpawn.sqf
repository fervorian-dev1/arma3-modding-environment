/* Empty, dry roadside clearing; no unsafe fallback into the requested point.
   Also usable on the native scheduler's HC. Pure search, no objects are spawned. */
params ["_class","_seed"];
if (!isClass (configFile >> "CfgVehicles" >> _class) || {!(_class isKindOf "LandVehicle")} || {count _seed<2}) exitWith {[]};
private _clearance=((sizeOf _class)*0.6) max 8 min 24;
private _result=[];
for "_attempt" from 1 to 35 do {
 private _pos=[_seed,5,180,_clearance,0,0.22,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
 if (_pos distance2D [0,0,0]>50 && {_pos distance2D _seed<=200} && {!surfaceIsWater _pos} && {(_pos nearRoads 80) isNotEqualTo []} && {(_pos nearEntities [["LandVehicle","Air","Ship","Man"],_clearance+5]) isEqualTo []} && {(nearestTerrainObjects [_pos,["TREE","SMALL TREE","ROCK","ROCKS","WALL","FENCE","BUILDING","HOUSE"],_clearance,false,true]) isEqualTo []}) then {
  private _empty=_pos findEmptyPosition [0,0,_class];
  if (_empty isNotEqualTo []) exitWith {_result=_empty;};
 };
};
_result
