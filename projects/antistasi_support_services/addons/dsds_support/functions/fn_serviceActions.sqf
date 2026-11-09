/* Compare actual local action labels, so native removeAllActions/respawns can be repaired. */
private _addOnce = {
    params ["_object","_text","_code",["_condition","alive _target && alive _this"],["_radius",6],["_priority",1.5]];
    if (isNull _object) exitWith {};
    if ((actionIDs _object findIf {((_object actionParams _x) param [0,""]) == _text}) >= 0) exitWith {};
    _object addAction [_text,_code,nil,_priority,true,true,"",_condition,_radius];
};
private _petros = missionNamespace getVariable ["petros",objNull];
[_petros,"Buy / equip Support Terminal (10,000 credits)",{["ISSUE",player,[]] remoteExecCall ["DSDS_fnc_serverRequest",2];},"alive _target && alive _this",5] call _addOnce;
[_petros,"Request PMC mechanic (1,000 credits)",{["HIRE",player,[]] remoteExecCall ["DSDS_fnc_serverRequest",2];},"alive _target && alive _this",5,1.4] call _addOnce;
[player,"Open Support Terminal",{["SUPPORT"] call DSDS_fnc_openTerminal;},"'DSDS_SupportTerminal' in assignedItems _this && alive _this",-1] call _addOnce;
[player,"Place PMC mechanic here",{["MOVE_END",player,[]] remoteExecCall ["DSDS_fnc_serverRequest",2];},"!isNil 'DSDS_mechanic' && {!isNull DSDS_mechanic} && {attachedTo DSDS_mechanic == _this}",-1,5] call _addOnce;
private _npc = missionNamespace getVariable ["DSDS_mechanic",objNull];
[_npc,"Sell a vehicle",{["DEALER"] call DSDS_fnc_openTerminal;},"alive _target && alive _this && isNull attachedTo _target"] call _addOnce;
[_npc,"Move PMC mechanic",{["MOVE_BEGIN",player,[]] remoteExecCall ["DSDS_fnc_serverRequest",2];},"alive _target && alive _this && isNull attachedTo _target",6,1.4] call _addOnce;
