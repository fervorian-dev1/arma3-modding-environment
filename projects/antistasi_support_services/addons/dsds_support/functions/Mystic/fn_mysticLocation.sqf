/* One secluded, usable site per campaign. Altitude/privacy are scored, never map ownership. */
private _best=[];private _score=-1e12;
for "_i" from 1 to 200 do {
 private _seed=[150+random (worldSize-300),150+random (worldSize-300),0];
 if (!surfaceIsWater _seed && {getTerrainHeightASL _seed>5}) then {
  private _pos=[_seed,0,150,3,0,0.18,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
  if (_pos distance2D [0,0,0]>100 && {_pos select 0<worldSize-100} && {_pos select 1<worldSize-100} && {!surfaceIsWater _pos} && {(_pos isFlatEmpty [2,-1,0.2,5,0,false,objNull]) isNotEqualTo []} && {(allPlayers findIf {_x distance2D _pos<800})<0}) then {
   private _settlements=nearestLocations [_pos,["NameCityCapital","NameCity","NameVillage"],1300];
   private _roads=_pos nearRoads 500;
   private _buildings=count nearestObjects [_pos,["House"],250];
   private _value=(getTerrainHeightASL _pos)*3-300*(count _settlements)-30*_buildings-5*(count _roads);
   if (_value>_score) then {_best=_pos;_best set [2,0];_score=_value;};
  };
 };
};
_best
