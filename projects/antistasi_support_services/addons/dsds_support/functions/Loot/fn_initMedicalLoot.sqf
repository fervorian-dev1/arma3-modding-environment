/* Installed Ultimate public events run on the AI's machine, including headless clients. */
if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_medicalLootInitialized",false]}) exitWith {};
DSDS_medicalLootInitialized=true;
if (getNumber (configFile >> "DSDS_MedicalLoot" >> "enabled")!=1 || {isNil "A3A_Events_fnc_addEventListener"}) exitWith {};
["AIVehInit","DSDS_MedicalVehicleLoot",{
    params ["_vehicle","_side"];
    private _context=[];
    private _source="VEHICLE";
    if (!isNil "_taskId" && {!isNil "_convoyType"} && {!isNil "_markName"} && {_convoyType=="Supplies"}) then {
        _source="CONVOY";_context=[_taskId,_convoyType,_markName];
    };
    if (isServer) then {[_vehicle,_side,_source,_context] call DSDS_fnc_medicalLootObserved;} else {[_vehicle,_side,_source,_context] remoteExecCall ["DSDS_fnc_medicalLootObserved",2];};
}] call A3A_Events_fnc_addEventListener;
["AIInit","DSDS_MedicalMedicLoot",{
    params ["_unit","_side"];
    if (isServer) then {[_unit,_side,"MEDIC"] call DSDS_fnc_medicalLootObserved;} else {[_unit,_side,"MEDIC"] remoteExecCall ["DSDS_fnc_medicalLootObserved",2];};
}] call A3A_Events_fnc_addEventListener;
