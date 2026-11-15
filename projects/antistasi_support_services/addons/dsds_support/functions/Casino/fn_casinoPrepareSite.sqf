/* Reversible server-side grading and vegetation removal, only on the casino plot. */
params ["_pos","_dir"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
private _plan=[_pos,_dir,true] call DSDS_fnc_casinoSitePlan;
if (_plan get "error"!="") exitWith {false};
private _height=_plan get "height";private _cell=(getTerrainInfo select 2) max 1;
private _before=[];private _after=[];
for "_x" from (_cell*floor (((_pos select 0)-65)/_cell)) to ((_pos select 0)+65) step _cell do {
 for "_y" from (_cell*floor (((_pos select 1)-65)/_cell)) to ((_pos select 1)+65) step _cell do {
  private _dx=_x-(_pos select 0);private _dy=_y-(_pos select 1);
  private _lx=_dx*cos _dir-_dy*sin _dir;private _ly=_dx*sin _dir+_dy*cos _dir;
  private _edge=(0 max (abs _lx-20)) max (0 max ((abs (_ly+6))-36));
  if (_edge<8) then {
   private _old=getTerrainHeightASL [_x,_y];private _weight=1-(_edge/8);_weight=_weight*_weight*(3-2*_weight);
   _before pushBack [_x,_y,_old];_after pushBack [_x,_y,_old+(_height-_old)*_weight];
  };
 };
};
DSDS_casinoState set ["padOriginal",_before];DSDS_casinoState set ["padApplied",_after];
if (_after isNotEqualTo []) then {setTerrainHeight [_after,false];};
private _center=[(_pos select 0)-6*sin _dir,(_pos select 1)-6*cos _dir,0];
private _plants=(nearestTerrainObjects [_center,["TREE","SMALL TREE","BUSH"],65,false,true]) select {(getPosATL _x) inArea [_center,23,39,_dir,true] && {!isObjectHidden _x}};
DSDS_casinoHiddenPlants=_plants;{_x hideObjectGlobal true;} forEach _plants;true
