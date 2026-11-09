params ["_truck"];
if (!isServer || {isRemoteExecuted} || {isNull _truck} || {_truck getVariable ["DSDS_salvaged",false]}) exitWith {objNull};
private _record=(missionNamespace getVariable ["DSDS_smugglingRecords",createHashMap]) getOrDefault [_truck getVariable ["DSDS_manifestID",""],createHashMap];
if (count _record==0 || {_record get "kind"!="SPECIAL"}) exitWith {objNull};
private _cargo=getItemCargo _truck;if ((_cargo select 0) isEqualTo []) exitWith {objNull};
private _pos=[getPosATL _truck,12,35,3,0,0.3,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
if (_pos distance2D [0,0,0]<10) exitWith {objNull};
private _box=createVehicle ["Box_NATO_Equip_F",_pos,[],0,"NONE"];if (isNull _box) exitWith {objNull};
clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
{_box addItemCargoGlobal [_x,(_cargo select 1) select _forEachIndex];} forEach (_cargo select 0);
clearItemCargoGlobal _truck;_truck setVariable ["DSDS_salvaged",true,true];
_box setVariable ["DSDS_traceIDs",[_record get "id"],true];(_record get "holders") pushBack _box;
if (!isNil "A3A_Logistics_fnc_addLoadAction") then {[_box] call A3A_Logistics_fnc_addLoadAction;};
_box
