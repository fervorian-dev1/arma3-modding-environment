if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_garageSlotsInit",false]}) exitWith {};
DSDS_garageSlotsInit=true;
if (isServer) then {[] spawn {
 waitUntil {sleep 0.2;missionNamespace getVariable ["serverInitDone",false] && {!isNil "A3A_saveTarget"}};
 private _saved=["DSDS_extraGarageSlots"] call A3A_fnc_returnSavedStat;
 if (isNil "_saved" || {!(_saved isEqualType 0)} || {!finite _saved}) then {_saved=0;};
 DSDS_extraGarageSlots=(floor _saved) max 0;publicVariable "DSDS_extraGarageSlots";
};};
[] spawn {
 waitUntil {sleep 0.2;!isNil "HR_GRG_VehCap"};
 // This is a native runtime variable (not a final CfgFunction); capture once.
 DSDS_nativeGarageCapacity=HR_GRG_VehCap;
 HR_GRG_VehCap={(call DSDS_nativeGarageCapacity)+(missionNamespace getVariable ["DSDS_extraGarageSlots",0])};
};
