/* Internal unscheduled server transaction. The authenticated entry point supplies the scope guard. */
params ["_operation","_player","_args"];
if (!isServer || {isNil "_dsdsAuthorizedPlayer"} || {_dsdsAuthorizedPlayer != _player}) exitWith {false};
private _message = {
    params ["_text"];
    ["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_player];
};
private _petros = missionNamespace getVariable ["petros",objNull];
if (_operation in ["ISSUE","HIRE"] && {isNull _petros || {!alive _petros} || {_player distance _petros > 6}}) exitWith {false};
switch (_operation) do {
 case "GARAGE_SLOT": {
  private _box=missionNamespace getVariable ["vehicleBox",objNull];
  if (isNull _box || {_player distance _box>6} || {isNil "DSDS_extraGarageSlots"} || {isNil "HR_GRG_VehCap"}) exitWith {false};
  if (serverTime<(_player getVariable ["DSDS_garageBuyNext",0])) exitWith {false};
  _player setVariable ["DSDS_garageBuyNext",serverTime+1];
  if !([_player,-800] call DSDS_fnc_changeWallet) exitWith {["An additional shared garage slot costs 800 personal credits."] call _message;false};
  DSDS_extraGarageSlots=DSDS_extraGarageSlots+1;publicVariable "DSDS_extraGarageSlots";
  ["DSDS_extraGarageSlots",DSDS_extraGarageSlots] call A3A_fnc_setStatVariable;
  [format ["Garage expanded by one slot. Shared capacity: %1.",call HR_GRG_VehCap]] call _message;true
 };
 case "TRAVEL": {
  private _flag=missionNamespace getVariable ["flagX",objNull];
  if (isNull _flag || {_player distance _flag>6}) exitWith {["Request friendly travel at the HQ flag."] call _message;false};
  private _friend=_args param [0,objNull,[objNull]];
  if (isNull _friend || {_friend==_player} || {side group _friend!=teamPlayer} || {!isNull objectParent _player} || {_player getVariable ["DSDS_travelPending",false]} || {!([_player] call DSDS_fnc_travelSafe)} || {!([_friend] call DSDS_fnc_travelSafe)}) exitWith {["Travel requires a safe, conscious friendly and an on-foot requester outside combat."] call _message;false};
  if (serverTime<(_player getVariable ["DSDS_travelNext",0])) exitWith {false};
  if (!([_player,-350] call DSDS_fnc_changeWallet)) exitWith {["Travel costs 350 personal credits."] call _message;false};
  _player setVariable ["DSDS_travelPending",true,true];_player setVariable ["DSDS_travelNext",serverTime+30];
  DSDS_jobSequence=DSDS_jobSequence+1;private _id=str DSDS_jobSequence;
  private _holder=_player getVariable ["owner",_player];
  DSDS_jobs set [_id,createHashMapFromArray [["player",_player],["friend",_friend],["holder",_holder],["uid",getPlayerUID _player],["balanceAfter",_holder getVariable ["moneyX",0]],["cost",350],["type","PARADROP"],["fastTravel",true],["target",getPosATL _friend],["origin",getPosATL _friend],["state","paid"]]];
  [_id] spawn DSDS_fnc_runFriendlyTravel;true
 };
    case "ISSUE": {
        if ("DSDS_SupportTerminal" in assignedItems _player) exitWith {["Your Support Terminal is already equipped."] call _message; false};
        if (((getUnitLoadout _player select 9) param [1,""]) != "") exitWith {["Stow your GPS/UAV terminal first. No credits were charged."] call _message; false};
        // Equipping an already owned terminal is free; only new items are purchased.
        if ("DSDS_SupportTerminal" in items _player) exitWith {["ISSUE",[]] remoteExecCall ["DSDS_fnc_clientService",_player]; true};
        if (_player getVariable ["DSDS_terminalPending",false]) exitWith {false};
        if (!([_player,-10000] call DSDS_fnc_changeWallet)) exitWith {["A Support Terminal costs 10,000 personal credits."] call _message; false};
        _player setVariable ["DSDS_terminalPending",true];
        ["ISSUE",[]] remoteExecCall ["DSDS_fnc_clientService",_player];
        [_player,_player getVariable ["owner",_player]] spawn {
            params ["_player","_holder"];
            private _deadline = diag_tickTime + 30;
            waitUntil {sleep 0.25; isNull _player || {"DSDS_SupportTerminal" in (assignedItems _player + items _player)} || {diag_tickTime > _deadline}};
            private _delivered = !isNull _player && {"DSDS_SupportTerminal" in (assignedItems _player + items _player)};
            if (!_delivered && {!isNull _holder}) then {
                _holder setVariable ["moneyX",(_holder getVariable ["moneyX",0]) + 10000,true];
                if (!isNull _player) then {["MESSAGE",["Terminal delivery failed; your 10,000 credits were returned."]] remoteExecCall ["DSDS_fnc_clientService",_player];};
            };
            if (!isNull _player) then {_player setVariable ["DSDS_terminalPending",false];};
        };
        true
    };
    case "HIRE": {
        private _existing = missionNamespace getVariable ["DSDS_mechanic",objNull];
        if (!isNull _existing && {alive _existing}) exitWith {["The PMC mechanic is already available."] call _message; false};
        if (!([_player,-1000] call DSDS_fnc_changeWallet)) exitWith {["Hiring the mechanic costs 1,000 personal credits."] call _message; false};
        private _position = _petros getPos [3,getDir _petros + 90];
        private _npc = [_position,getDir _petros] call DSDS_fnc_createMechanic;
        if (isNull _npc) exitWith {[_player,1000] call DSDS_fnc_changeWallet; ["Mechanic could not deploy; credits returned. A valid free mod rifle is required."] call _message; false};
        [] call DSDS_fnc_persistMechanic;
        ["PMC mechanic hired. Speak to him to sell vehicles or move him."] call _message;
        true
    };
    case "MOVE_BEGIN": {[_player,true] call DSDS_fnc_moveMechanic};
    case "MOVE_END": {[_player,false] call DSDS_fnc_moveMechanic};
    case "QUOTE"; case "SELL": {
        private _vehicle = _args param [0,objNull,[objNull]];
        private _error = [_player,_vehicle] call DSDS_fnc_validateVehicleSale;
        if (_error != "") exitWith {[_error] call _message; false};
        private _price = [_vehicle] call DSDS_fnc_vehicleValue;
        if (_operation == "QUOTE") exitWith {
            _player setVariable ["DSDS_quote",[_vehicle,_price,diag_tickTime + 90]];
            ["QUOTE",[_vehicle,_price]] remoteExecCall ["DSDS_fnc_clientService",_player]; true
        };
        private _quote = _player getVariable ["DSDS_quote",[]];
        if (count _quote != 3 || {(_quote select 0) != _vehicle} || {diag_tickTime > (_quote select 2)} || {_price != (_quote select 1)}) exitWith {["Offer expired or vehicle condition changed. Get a new offer."] call _message; false};
        _player setVariable ["DSDS_quote",[]];
        private _sold = [_player,_vehicle,_price] call DSDS_fnc_sellMechanicVehicle;
        if (_sold) then {["SOLD",[_price]] remoteExecCall ["DSDS_fnc_clientService",_player];};
        _sold
    };
    case "SUPPORT": {
        private _id = _args param [0,"",[""]];
        if (!("DSDS_SupportTerminal" in assignedItems _player)) exitWith {false};
        private _entry = ([] call DSDS_fnc_serviceCatalogue) select {(_x select 0) == _id};
        if (_entry isEqualTo []) exitWith {false};
        private _cost = ((_entry select 0) select 2) max 1;
        private _origin = [_args param [1,[]]] call DSDS_fnc_validateServicePosition;
        private _target = [_args param [2,[]]] call DSDS_fnc_validateServicePosition;
        if (_origin isEqualTo [] || {_target isEqualTo []}) exitWith {false};
        if (_id == "SUPPLY" && {surfaceIsWater _target}) exitWith {["Choose dry land for a supply crate."] call _message; false};
        if (!([_player,-_cost] call DSDS_fnc_changeWallet)) exitWith {[format ["This contract costs %1 personal credits.",_cost]] call _message; false};
        DSDS_jobSequence = DSDS_jobSequence + 1;
        private _jobID = str DSDS_jobSequence;
        private _holder = _player getVariable ["owner",_player];
        private _job = createHashMapFromArray [["player",_player],["holder",_holder],["uid",getPlayerUID _player],["balanceAfter",_holder getVariable ["moneyX",0]],["cost",_cost],["type",_id],["origin",_origin],["target",_target],["state","paid"]];
        DSDS_jobs set [_jobID,_job];
        [_jobID] spawn DSDS_fnc_runSupportContract;
        true
    };
    default {false};
}
