if (isRemoteExecuted || {missionNamespace getVariable ["DSDS_deathMoneyInitialized",false]}) exitWith {};
DSDS_deathMoneyInitialized=true;
[] call DSDS_fnc_applyDeathMoney;
// Covers parameters received during startup/JIP; never rewrites a wallet balance.
DSDS_deathMoneyPV="deathPenalty" addPublicVariableEventHandler {deathPenalty=0;};
DSDS_deathMoneyRespawn=addMissionEventHandler ["EntityRespawned",{
    params ["_newUnit"];
    if (_newUnit isKindOf "CAManBase" && {local _newUnit}) then {[] call DSDS_fnc_applyDeathMoney;};
}];
// Save loading/setup can publish the selected parameter after addon postInit.
[] spawn {while {true} do {[] call DSDS_fnc_applyDeathMoney;sleep 1;};};
