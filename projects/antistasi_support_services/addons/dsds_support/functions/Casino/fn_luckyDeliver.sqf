params ["_uid","_kind"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _p=[_uid] call DSDS_fnc_luckyProfile;_p set ["delivery",false];
private _players=allPlayers select {alive _x && {getPlayerUID _x==_uid}};if (_players isEqualTo []) exitWith {};
private _actor=_players select 0;private _hotel=missionNamespace getVariable ["DSDS_casinoBuilding",objNull];
if (isNull _hotel || {_actor distance2D _hotel>50}) exitWith {_p set ["message","Return to Roxie to collect your rewards."];[_actor] call DSDS_fnc_luckySync;};
if (_kind=="CAR") then {
 if (_p get "cars">0) then {
  private _classes=getArray (configFile >> "DSDS_LuckyWheel" >> "hellcats");_classes=_classes select {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "Car"} && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope")==2}};
  if (_classes isEqualTo []) exitWith {_p set ["message","Enable Dodge Charger SRT Hellcat 2018 to collect your car. Your prize is saved."];};
  private _pos=[getPosATL _hotel,30,85,7,0,0.2,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
  if (_pos distance2D _hotel<25 || {_pos distance2D _hotel>90} || {surfaceIsWater _pos} || {(nearestObjects [_pos,["House","AllVehicles"],7]) isNotEqualTo []}) exitWith {_p set ["message","Clear some space outside the casino. Your car prize is saved."];};
  private _v=createVehicle [selectRandom _classes,_pos,[],0,"NONE"];
  if (!isNull _v) then {
   _v setDir (getDir _hotel);_v setVariable ["ownerX",_uid,true];_v setVehicleLock "UNLOCKED";
   if (!isNil "A3A_activePlayerCount" && {!isNil "A3A_vehicleResourceCosts"}) then {[_v,teamPlayer] call A3A_fnc_AIVEHinit;[_v,teamPlayer] call SCRT_fnc_misc_tryInitVehicle;};_v setVariable ["ownerSide",missionNamespace getVariable ["teamPlayer",resistance],true];_v setVariable ["DSDS_luckyOwner",_uid,true];
   clearWeaponCargoGlobal _v;clearMagazineCargoGlobal _v;clearItemCargoGlobal _v;clearBackpackCargoGlobal _v;
   _p set ["cars",(_p get "cars")-1];_p set ["message",format ["Your Hellcat is parked outside at grid %1.",mapGridPosition _v]];
   { _x addCuratorEditableObjects [[_v],false];} forEach allCurators;
  } else {_p set ["message","Delivery failed. Your car prize is saved."];};
 };
} else {
 if ((_p get "items") isNotEqualTo [] || {_p get "gummies">0}) then {
  private _box=[] call DSDS_fnc_luckyCrate;
  if (isNull _box) exitWith {_p set ["message","No clear collection site outside. Your items are saved; try Collect again."];};
  private _items=_p get "items";
  if (_items isNotEqualTo []) then {
   private _reward=_items select 0;_reward params ["_section","_class"];
   if (isClass (configFile >> _section >> _class)) then {
    if (_section=="CfgVehicles") then {_box addBackpackCargoGlobal [_class,1];} else {if (getNumber (configFile >> _section >> _class >> "type") in [1,2,4]) then {_box addWeaponCargoGlobal [_class,1];} else {_box addItemCargoGlobal [_class,1];};};
    _items deleteAt 0;_p set ["items",_items];
   };
  };
  if (_p get "gummies">0) then {_box addItemCargoGlobal ["DSDS_GummyBears",_p get "gummies"];_p set ["gummies",0];};
  _p set ["message",format ["Collected goods are in Roxie's crate outside, grid %1.",mapGridPosition _box]];
 };
};
[] call DSDS_fnc_luckySave;[_actor] call DSDS_fnc_luckySync;
