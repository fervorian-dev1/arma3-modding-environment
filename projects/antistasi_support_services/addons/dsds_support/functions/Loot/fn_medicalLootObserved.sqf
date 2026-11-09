/* Server/HC-only entry; ordinary clients cannot turn owned assets into loot dispensers. */
params [["_object",objNull,[objNull]],["_side",sideUnknown,[sideUnknown]],["_source","",[""]],["_context",[],[[]]]];
if (!isServer) exitWith {false};
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (!(_sender in ([2]+(missionNamespace getVariable ["hcArray",[]]))) || {getNumber (configFile >> "DSDS_MedicalLoot" >> "enabled")!=1} || {isNull _object} || {!alive _object} || {_object getVariable ["DSDS_medicalLootConsidered",false]}) exitWith {false};
private _enemies=[missionNamespace getVariable ["Occupants",sideUnknown],missionNamespace getVariable ["Invaders",sideUnknown]] select {_x in [west,east,resistance] && {_x!=missionNamespace getVariable ["teamPlayer",resistance]}};
if (!(_side in _enemies) || {_object getVariable ["ownerSide",_side]!=_side}) exitWith {false};
private _valid=false;
switch (_source) do {
    case "CONVOY": {
        _context params [["_task","",[""]],["_type","",[""]],["_label","",[""]]];
        _valid=_object isKindOf "Car" && {(_task find "CONVOY")==0} && {_type=="Supplies"} && {_label in [localize "STR_marker_convoy_objective",localize "STR_marker_convoy_objective_space"]};
    };
    case "VEHICLE": {
        private _classes=[];
        {private _faction=missionNamespace getVariable [_x,createHashMap];_classes append (_faction getOrDefault ["vehiclesMedical",[]]);_classes append (_faction getOrDefault ["vehiclesCivMedical",[]]);} forEach ["A3A_faction_occ","A3A_faction_inv","A3A_faction_civ"];
        _valid=!(_object isKindOf "CAManBase") && {typeOf _object in _classes};
    };
    case "MEDIC": {
        private _factions=missionNamespace getVariable ["A3A_faction_all",createHashMap];
        _valid=_object isKindOf "CAManBase" && {!isPlayer _object} && {side group _object==_side} && {(_object getVariable ["unitType",""]) in (_factions getOrDefault ["Medics",[]])};
    };
};
if (!_valid || {_source!="MEDIC" && {maxLoad _object<=0 || {(crew _object findIf {isPlayer _x})>=0}}}) exitWith {false};
_object setVariable ["DSDS_medicalLootConsidered",true,true];
[_object,_source] spawn {
    params ["_object","_source"];
    // Native convoy/cargo setup completes before the additive inventory change.
    if (_source!="MEDIC") then {sleep (getNumber (configFile >> "DSDS_MedicalLoot" >> "initializationDelay") max 0);};
    private _dsdsMedicalAuthorized=true;
    [_object,_source] call DSDS_fnc_seedMedicalLoot;
};
true
