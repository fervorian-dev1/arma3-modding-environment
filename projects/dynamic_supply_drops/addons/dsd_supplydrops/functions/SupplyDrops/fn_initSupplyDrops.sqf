/* PostInit on every machine. Also safe to call from the live bootstrap. */
if (isNil "CBA_fnc_addEventHandler") exitWith {
    diag_log "[DSD] ERROR: CBA is required; initialization aborted.";
};
// Invalidate v1.0 cached pools on a live upgrade; preserve existing drops/history.
if ((missionNamespace getVariable ["DSD_dataVersion", ""]) != "1.1.0") then {
    DSD_supplyPools = nil;
    DSD_ballisticMagazines = nil;
    DSD_allowedAssetCache = nil;
    DSD_dataVersion = "1.1.0";
};
if (isServer && {isNil "DSD_requestHandler"}) then {
    DSD_requestHandler = ["DSD_request", { _this call DSD_fnc_requestSupplyDrop; }] call CBA_fnc_addEventHandler;
    DSD_activeDrops = 0;
    DSD_manifestHistory = [];
};
if (!isNil "DSD_noticeHandler") then {
    ["DSD_notice", DSD_noticeHandler] call CBA_fnc_removeEventHandler;
    DSD_noticeHandler = nil;
};
if (hasInterface) then {
    [] call DSD_fnc_registerSupplyMenu;
};
diag_log "[DSD] Dynamic Supply Drops initialized (v1.1.0, DLC-free, silent, Antistasi integration).";
