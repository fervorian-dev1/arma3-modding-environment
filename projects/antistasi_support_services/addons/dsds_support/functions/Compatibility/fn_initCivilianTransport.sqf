/* Extend only native rebel HQ civilian purchase lists. No ambient/faction selection edits. */
if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_civilTransportInit",false]}) exitWith {};
DSDS_civilTransportInit=true;
if (isServer) then {[] spawn {
 waitUntil {sleep 1;missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_faction_reb"} && {!isNil "server"}};
 private _candidates=[];
 {
  private _class=configName _x;
  if (getNumber (_x >> "scope")==2 && {getNumber (_x >> "side")==3} && {_class isKindOf "Car"} && {getNumber (_x >> "isUav")==0} && {getNumber (_x >> "transportSoldier")>=1} && {[_class,"CfgVehicles"] call DSD_fnc_isSupplyAssetAllowed}) then {
   private _armed=false;
   private _check={
    params ["_cfg"];
    {
     private _ammo=configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo");
     if (getNumber (_ammo >> "hit")>0 || {getNumber (_ammo >> "indirectHit")>0}) then {_armed=true;};
    } forEach getArray (_cfg >> "magazines");
    {[_x] call _check;} forEach ("true" configClasses (_cfg >> "Turrets"));
   };
   [_x] call _check;
   if (!_armed) then {_candidates pushBack [-(getNumber (_x >> "maxSpeed")),_class];};
  };
 } forEach ("true" configClasses (configFile >> "CfgVehicles"));
 _candidates sort true;
 private _cars=[];private _names=[];
 {
  _x params ["_negativeSpeed","_class"];
  private _cfg=configFile >> "CfgVehicles" >> _class;
  private _name=toLower getText (_cfg >> "displayName");
  if !(_name in _names) then {
   _names pushBack _name;_cars pushBack _class;
   private _existing=server getVariable [_class,0];
   if (_existing<=0) then {
    private _market=[_class,true] call DSDS_fnc_vehicleShopPrice;
    if (_market>0) then {_market=_market/0.4;};
    private _price=if (_market>0) then {_market} else {round (600+((-_negativeSpeed) max 60)*8)};
    server setVariable [_class,_price,true];
   };
  };
  if (count _cars>=30) exitWith {};
 } forEach _candidates;
 DSDS_civilTransportAdditions=_cars;publicVariable "DSDS_civilTransportAdditions";
};};
// PublicVariable initial state is sent to JIP clients; apply to each local template copy.
[] spawn {
 waitUntil {sleep 1;!isNil "A3A_faction_reb" && {!isNil "DSDS_civilTransportAdditions"}};
 private _cars=+(A3A_faction_reb getOrDefault ["vehiclesCivCar",[]]);
 {_cars pushBackUnique _x;} forEach DSDS_civilTransportAdditions;
 A3A_faction_reb set ["vehiclesCivCar",_cars];
};
