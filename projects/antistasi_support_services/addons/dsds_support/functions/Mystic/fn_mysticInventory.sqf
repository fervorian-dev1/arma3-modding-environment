/* Only the server can request owning-machine inventory edits. No price or arbitrary class input. */
if (isRemoteExecuted && {remoteExecutedOwner!=2}) exitWith {false};
if (!isRemoteExecuted && {!isServer}) exitWith {false};
params ["_actor","_token","_op","_amount","_expiry",["_deliveryClass","DSDS_Oswald"]];
if !(_deliveryClass in ["DSDS_Oswald","DSDS_NuclearIED_Mag","DSDS_IndustrialIsotopes"]) exitWith {false};
if (isNull _actor || {!local _actor}) exitWith {false};
private _receipts=_actor getVariable ["DSDS_mysticReceipts",createHashMap];
private _receipt=_receipts getOrDefault [_token,[]];
if (_op=="ROLLBACK") exitWith {
 if (count _receipt>0 && {!(_receipt select 2)}) then {
  private _class=if (_receipt select 0=="BUY") then {_receipt param [4,"DSDS_Oswald"]} else {"DSDS_IndustrialIsotopes"};
  if (_receipt select 1) then {
   if (_receipt select 0=="BUY") then {if (_class=="DSDS_NuclearIED_Mag") then {_actor removeMagazine _class;} else {_actor removeItem _class;};} else {
    private _overflow=0;for "_i" from 1 to (_receipt select 3) do {if (_actor canAdd _class) then {_actor addItem _class;} else {_overflow=_overflow+1;};};
    if (_overflow>0) then {private _box=createVehicle ["GroundWeaponHolder_Scripted",getPosATL _actor,[],0,"NONE"];_box addItemCargoGlobal [_class,_overflow];};
   };
  };
  _receipt set [2,true];
 };
 true
};
if (!(_op in ["BUY","OFFER"]) || {_amount<1} || {_amount>40}) exitWith {false};
private _ok=false;
if (_receipt isNotEqualTo []) then {_ok=_receipt select 1;} else {
 private _npc=missionNamespace getVariable ["DSDS_mystic",objNull];
 if (alive _actor && {!isNull _npc} && {alive _npc} && {_actor distance _npc<=6} && {serverTime<=_expiry}) then {
  private _class=if (_op=="BUY") then {_deliveryClass} else {"DSDS_IndustrialIsotopes"};
  private _before={_x==_class} count (items _actor+assignedItems _actor+magazines _actor);
  if (_op=="BUY") then {if (_actor canAdd _class) then {if (_class=="DSDS_NuclearIED_Mag") then {_actor addMagazine _class;} else {_actor addItem _class;};_ok=({_x==_class} count (items _actor+assignedItems _actor+magazines _actor))==_before+1;};} else {
   if (({_x==_class} count items _actor)>=_amount) then {for "_i" from 1 to _amount do {_actor removeItem _class;};_ok=({_x==_class} count (items _actor+assignedItems _actor+magazines _actor))==_before-_amount;};
  };
 };
 _receipts set [_token,[_op,_ok,false,_amount,_deliveryClass]];_actor setVariable ["DSDS_mysticReceipts",_receipts];
};
if (isPlayer _actor) then {["ACK",_actor,[_token,_ok]] remoteExecCall ["DSDS_fnc_mysticRequest",2];};
_ok
