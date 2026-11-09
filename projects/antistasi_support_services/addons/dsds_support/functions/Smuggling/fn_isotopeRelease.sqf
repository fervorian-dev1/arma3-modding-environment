params ["_truck"];
if (!isServer || {isRemoteExecuted} || {isNull _truck} || {_truck getVariable ["DSDS_cloudReleased",false]}) exitWith {false};
private _id=_truck getVariable ["DSDS_manifestID",""];
private _record=(missionNamespace getVariable ["DSDS_smugglingRecords",createHashMap]) getOrDefault [_id,createHashMap];
if (count _record==0 || {_record get "kind"!="ISOTOPE"} || {isNil "CBRN_fnc_spawnMist"}) exitWith {false};
_truck setVariable ["DSDS_cloudReleased",true,true];
private _cfg=configFile >> "DSDS_Smuggling";
private _cloud=[_id,getPosATL _truck,serverTime+getNumber (_cfg >> "cloudLifetime"),getNumber (_cfg >> "cloudRadius"),1];
if (isNil "DSDS_isotopeClouds") then {DSDS_isotopeClouds=[];};
DSDS_isotopeClouds pushBack _cloud;
// CWP's actual asphyxiant bomb class was verified from the installed cbrn_bombs config.
private _ammo="PHEN_FSPLUS_AsphyxiantBomb_Unguided";
private _bombs=0;
if (isClass (configFile >> "CfgAmmo" >> _ammo)) then {
 for "_i" from 0 to 2 do {
  private _pos=(getPosATL _truck) getPos [3+_i*3,_i*120];_pos set [2,2];
  private _bomb=createVehicle [_ammo,_pos,[],0,"CAN_COLLIDE"];
  if (!isNull _bomb) then {_bombs=_bombs+1;triggerAmmo _bomb;};
 };
};
_record set ["chemicalBombs",_bombs];_record set ["chemicalAmmo",_ammo];
_cloud remoteExecCall ["DSDS_fnc_chemicalCloud",0];
diag_log format ["[DSDS Chemical] %1: %2 native CWP bombs detonated; cloud %3m for %4s dispatched to clients.",_id,_bombs,_cloud select 3,getNumber (_cfg >> "cloudLifetime")];
_record set ["finished",true];
if (_record getOrDefault ["label",""]=="Industrial Isotopes") then {[_record] spawn DSDS_fnc_contaminationResponse;};
true
