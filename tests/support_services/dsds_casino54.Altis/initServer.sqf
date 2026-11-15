[] spawn {
 sleep 5;private _pass=0;private _fail=0;private _assert={params ['_ok','_label'];if(_ok)then{_pass=_pass+1;}else{_fail=_fail+1;};diag_log format ['[CASINO54 TERRAIN] %1 %2',['FAIL','PASS'] select _ok,_label];};
 DSDS_casinoState=createHashMap;DSDS_casinoProps=[];DSDS_casinoDealers=[];DSDS_casinoBuilding=objNull;
 private _plants=nearestTerrainObjects [[12000,18000,0],['TREE','SMALL TREE','BUSH'],3000,false,true];private _site=[];
 {private _p=getPosATL _x;private _plan=[_p,0] call DSDS_fnc_casinoSitePlan;if(_plan get 'error'=='' && {_plan get 'relief'>1.5}) exitWith {_site=_p;};if(_forEachIndex>500)exitWith{};} forEach _plants;
 [_site isNotEqualTo [],'find actual vegetated Altis hillside, relief >1.5m'] call _assert;
 if(_site isNotEqualTo [])then{
  private _before=getTerrainHeightASL _site;
  private _ok=['Land_Hangar_F',_site,0] call DSDS_fnc_casinoSpawn;sleep .5;
  [_ok && {abs(getPosATL DSDS_casinoBuilding select 2)<.05},'real forest hall grounded at ATL zero'] call _assert;
  [count DSDS_casinoHiddenPlants>0 && {({!isObjectHidden _x} count DSDS_casinoHiddenPlants)==0},'foliage and trees cleared globally'] call _assert;
  private _hidden=+DSDS_casinoHiddenPlants;private _original=+(DSDS_casinoState get 'padOriginal');
  [] call DSDS_fnc_casinoClear;sleep .3;
  [({isObjectHidden _x} count _hidden)==0,'packing restores every cleared plant'] call _assert;
  [abs(getTerrainHeightASL _site-_before)<.05 && {(_original findIf {abs(getTerrainHeightASL _x-(_x select 2))>.05})<0},'packing restores all altered terrain cells'] call _assert;
  private _protected=createVehicle ['C_Offroad_01_F',_site,[],0,'CAN_COLLIDE'];
  [([_site,0] call DSDS_fnc_casinoSitePlan) get 'error'!='','existing vehicle blocks placement instead of being deleted'] call _assert;deleteVehicle _protected;
 };
 diag_log format ['[CASINO54 TERRAIN] DONE %1 passes, %2 failures',_pass,_fail];
};
