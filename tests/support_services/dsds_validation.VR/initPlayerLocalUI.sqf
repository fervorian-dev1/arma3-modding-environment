[] spawn {
    waitUntil {sleep 0.2; !isNull player && {missionNamespace getVariable ["DSDS_uiReady",false]} && {side group player==resistance} && {player getVariable ["moneyX",0]==100000}};
    sleep 2;
    disableSerialization;
    // No campaign HUD exists in this isolated test mission.
    A3A_fnc_statistics={};
    DSDS_uiFailures=0;
    private _assert={params ["_ok","_name"];if (!_ok) then {DSDS_uiFailures=DSDS_uiFailures+1;};diag_log format ["[DSDS UI] %1: %2",["FAIL","PASS"] select _ok,_name];};
    removeAllAssignedItems player;
    player linkItem "DSDS_SupportTerminal";
    ["SUPPORT"] call DSDS_fnc_openTerminal;
    sleep 0.5;
    private _display=findDisplay 88400;
    [!isNull _display,"support dialog opens on real client"] call _assert;
    if (isNull _display) exitWith {diag_log "[DSDS UI] COMPLETE failures=1";};
    {
        private _control=_display displayCtrl _x;
        [!isNull _control && {ctrlShown _control} && {ctrlFade _control==0},format ["support control %1 actually visible",_x]] call _assert;
    } forEach [100,1750,1701,1751,1000,1712,1711,2];
    private _combo=_display displayCtrl 1750;
    [lbSize _combo==11,"all support choices populate on client"] call _assert;
    // First entry is smoke. Exercise real map conversion and mouse callback.
    private _map=_display displayCtrl 1000;
    _map ctrlMapAnimAdd [0,0.2,[5000,5000,0]]; ctrlMapAnimCommit _map;
    sleep 0.2;
    private _screen=_map ctrlMapWorldToScreen [5000,5000,0];
    [_map,0,_screen select 0,_screen select 1] call DSDS_fnc_terminalMapClick;
    [(_display getVariable ["DSDS_destination",[]]) distance2D [5000,5000,0]<5,"map click records support target"] call _assert;
    [] call DSDS_fnc_terminalSubmit;
    private _deadline=diag_tickTime+10;
    waitUntil {sleep 0.2; player getVariable ["moneyX",0]==95000 || {diag_tickTime>_deadline}};
    [player getVariable ["moneyX",0]==95000,"real client support submit passes authenticated RPC and charges personal money"] call _assert;
    player setPosATL [4003,4002,0];
    ["DEALER"] call DSDS_fnc_openTerminal;
    sleep 0.3;
    _display=findDisplay 88400;
    [!isNull _display,"dealer dialog opens on real client"] call _assert;
    [ctrlShown (_display displayCtrl 1750) && {ctrlFade (_display displayCtrl 1712)==0},"dealer choices and button are visible"] call _assert;
    [!ctrlShown (_display displayCtrl 1000),"dealer hides unnecessary map"] call _assert;
    _combo=_display displayCtrl 1750;
    private _vehicles=_display getVariable ["DSDS_vehicles",[]];
    private _index=_vehicles find DSDS_uiVehicle;
    [_index>=0,"dealer lists actual nearby vehicle"] call _assert;
    if (_index>=0) then {
        _combo lbSetCurSel _index;
        [] call DSDS_fnc_terminalSubmit;
        _deadline=diag_tickTime+10;
        waitUntil {sleep 0.2; (_display getVariable ["DSDS_quote",[]]) isNotEqualTo [] || {diag_tickTime>_deadline}};
        [(_display getVariable ["DSDS_quote",[]]) isNotEqualTo [],"real client receives server vehicle offer"] call _assert;
        [ctrlText (_display displayCtrl 1712)=="Confirm vehicle sale","quote changes button to sale confirmation"] call _assert;
        [] call DSDS_fnc_terminalSubmit;
        _deadline=diag_tickTime+10;
        waitUntil {sleep 0.2; isNull findDisplay 88400 || {diag_tickTime>_deadline}};
        [isNull findDisplay 88400 && {player getVariable ["moneyX",0]>95000},"real client confirms sale and receives personal payment"] call _assert;
    };
    closeDialog 0;
    diag_log format ["[DSDS UI] COMPLETE failures=%1",DSDS_uiFailures];
};
