/* Narrow server RPC. Consume handshake owns no wallet/faction/map operations. */
if (!isServer) exitWith {};
params [["_op","",[""]],["_unit",objNull,[objNull]],["_args",[],[[]]]];
private _sender=if (isMultiplayer && {isRemoteExecuted}) then {remoteExecutedOwner} else {if (local _unit) then {owner _unit} else {2}};
if (isNull _unit || {!isPlayer _unit} || {!alive _unit} || {owner _unit!=_sender}) exitWith {diag_log "[DSDS Loot] Unauthorized request rejected.";};
if (_op=="CACHE") exitWith {
    if (isNull getAssignedCuratorLogic _unit || {diag_tickTime<(_unit getVariable ["DSDS_cacheRate",0])}) exitWith {};
    private _pos=[_args] call DSD_fnc_validateDropPosition;
    if (_pos isEqualTo []) exitWith {};
    _unit setVariable ["DSDS_cacheRate",diag_tickTime+2];
    private _box=createVehicle ["Box_NATO_Equip_F",ASLToATL _pos,[],0,"NONE"];
    if (isNull _box) exitWith {diag_log "[DSDS Loot] Cache spawn failed.";};
    clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
    private _dsdsLootAuthorized=true;
    [_box,10] call DSDS_fnc_fillLootContainer;
    { _x addCuratorEditableObjects [[_box],false]; } forEach allCurators;
};
if (_op=="BEGIN" && {(_args param [0,""]) in ["DSDS_Adrenaline","DSDS_Morphine"]} && {([_unit] call DSDS_fnc_lootDownState)>0}) then {_op="RESCUE_BEGIN";};
private _limited=["DSDS_Morphine","DSDS_Adrenaline"];
private _uses=_unit getVariable ["DSDS_rescueUses",createHashMap];
if (_op=="BEGIN" && {(_args param [0,""]) in _limited} && {(_uses getOrDefault [_args select 0,0])>=2}) exitWith {};
if (_op=="RESCUE_BEGIN") exitWith {
    private _manual=_unit getVariable ["DSDS_lootPending",[]];
    if (_manual isNotEqualTo [] && {(_manual select 3)>diag_tickTime}) exitWith {};
    private _class=[_unit] call DSDS_fnc_lootRescueClass;
    if (_class=="") exitWith {};
    private _pending=_unit getVariable ["DSDS_adrenalineRescuePending",[]];
    if (_pending isNotEqualTo [] && {(_pending select 2)>diag_tickTime}) exitWith {};
    DSDS_lootSequence=(missionNamespace getVariable ["DSDS_lootSequence",0])+1;
    private _token=format ["%1:RESCUE:%2",netId _unit,DSDS_lootSequence];
    private _count={_x==_class} count items _unit;
    _unit setVariable ["DSDS_adrenalineRescuePending",[_token,_count,diag_tickTime+10,_class]];
    ["RESCUE_TAKE",_unit,[_token,_class]] remoteExecCall ["DSDS_fnc_lootClient",owner _unit];
};
if (_op=="RESCUE_ACK") exitWith {
    private _pending=_unit getVariable ["DSDS_adrenalineRescuePending",[]];
    private _token=_args param [0,"",[""]];
    if (_pending isEqualTo [] || {(_pending select 0)!=_token} || {(_pending select 2)<diag_tickTime}) exitWith {};
    _unit setVariable ["DSDS_adrenalineRescuePending",nil];
    if !(_args param [1,false,[true]]) exitWith {};
    private _before=_pending select 1;
    [_unit,_before,_pending select 3] spawn {
        params ["_unit","_before","_class"];
        private _deadline=diag_tickTime+4;
        waitUntil {sleep 0.05;isNull _unit || {!alive _unit} || {{_x==_class} count items _unit<_before} || {diag_tickTime>_deadline}};
        if (isNull _unit || {!alive _unit} || {{_x==_class} count items _unit>=_before}) exitWith {diag_log "[DSDS Loot] Adrenaline rescue consumption was not replicated; no stim effect granted.";};
        private _dsdsLootAuthorized=true;
        [_unit,_class,serverTime,-1,true] call DSDS_fnc_lootCommit;
    };
};
private _classes=[] call DSDS_fnc_consumableClasses;
if (_op=="BEGIN") exitWith {
    private _rescue=_unit getVariable ["DSDS_adrenalineRescuePending",[]];
    if (_rescue isNotEqualTo [] && {(_rescue select 2)>diag_tickTime}) exitWith {};
    private _class=_args param [0,"",[""]];
    if (!(_class in _classes) || {!(_class in items _unit)} || {!isNull objectParent _unit} || {lifeState _unit=="INCAPACITATED"}) exitWith {};
    if (((_unit getVariable ["DSDS_lootOverdose",[0,0]]) select 1)>0) exitWith {};
    private _pending=_unit getVariable ["DSDS_lootPending",[]];
    if (_pending isNotEqualTo [] && {(_pending select 3)>diag_tickTime}) exitWith {};
    DSDS_lootSequence=(missionNamespace getVariable ["DSDS_lootSequence",0])+1;
    private _token=format ["%1:%2",netId _unit,DSDS_lootSequence];
    private _count={_x==_class} count items _unit;
    _unit setVariable ["DSDS_lootPending",[_token,_class,_count,diag_tickTime+10]];
    ["TAKE",_unit,[_token,_class]] remoteExecCall ["DSDS_fnc_lootClient",owner _unit];
};
if (_op!="ACK") exitWith {};
private _pending=_unit getVariable ["DSDS_lootPending",[]];
if (_pending isEqualTo [] || {(_pending select 0)!=(_args param [0,"",[""]])} || {(_pending select 3)<diag_tickTime}) exitWith {};
// Consume nonce before scheduling replication wait; repeated acknowledgements cannot apply twice.
_unit setVariable ["DSDS_lootPending",[]];
if !(_args param [1,false,[true]]) exitWith {};
[_unit,_pending] spawn {
    params ["_unit","_pending"];
    _pending params ["_token","_class","_before"];
    private _deadline=diag_tickTime+4;
    waitUntil {sleep 0.05;isNull _unit || {!alive _unit} || {({_x==_class} count items _unit)<_before} || {diag_tickTime>_deadline}};
    if (isNull _unit || {!alive _unit}) exitWith {};
    if (({_x==_class} count items _unit)>=_before) exitWith {diag_log "[DSDS Loot] Consumption replication not confirmed; no effect granted.";};
    private _dsdsLootAuthorized=true;
    [_unit,_class] call DSDS_fnc_lootCommit;
};
