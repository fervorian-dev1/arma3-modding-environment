[] spawn {
    sleep 3;
    DSDS_testFailures=0;
    private _assert={params ["_ok","_name"];if (!_ok) then {DSDS_testFailures=DSDS_testFailures+1;};diag_log format ["[DSDS REGRESSION] %1: %2",["FAIL","PASS"] select _ok,_name];};
    [getNumber (configFile >> "CfgVehicles" >> "DSDS_MechanicNPC" >> "side")==2,"mechanic config is Independent"] call _assert;
    [getText (configFile >> "CfgVehicles" >> "DSDS_MechanicNPC" >> "faction")=="IND_G_F","mechanic config uses FIA faction"] call _assert;
    private _dialog=configFile >> "DSDS_SupportTerminalDialog";
    {
        private _control=_dialog >> "Controls" >> _x;
        [getNumber (_control >> "fade")==0,"visible vanilla control " + _x] call _assert;
    } forEach ["Title","Options","Description","Cost","Map","Launch","Reset","Close"];
    [getNumber (_dialog >> "ControlsBackground" >> "Background" >> "fade")==0,"background is visible"] call _assert;
    [configName inheritsFrom (_dialog >> "Controls" >> "Launch")=="RscButton","buttons inherit vanilla Arma controls"] call _assert;
    [configName inheritsFrom (_dialog >> "Controls" >> "Map")=="RscMapControl","map inherits vanilla Arma control"] call _assert;
    // Deliberately stale teamPlayer: Petros's actual side must take precedence.
    teamPlayer=west;
    private _hqGroup=createGroup resistance;
    petros=_hqGroup createUnit ["I_G_Soldier_F",[4000,4000,0],[],0,"NONE"];
    petros allowDamage false; petros disableAI "PATH";
    private _npc=[[4003,4000,0],180] call DSDS_fnc_createMechanic;
    [side group _npc==resistance && {side group _npc==side group petros},"spawn joins Independent Petros despite stale WEST teamPlayer"] call _assert;
    [(side group petros) getFriend (side group _npc)>=0.6,"Petros and mechanic are friendly without diplomacy overrides"] call _assert;
    [!(_npc checkAIFeature "PATH") && {_npc checkAIFeature "AUTOTARGET"},"friendly mechanic remains stationary with self-defense enabled"] call _assert;
    private _loadout=getUnitLoadout _npc;
    deleteVehicle _npc; DSDS_mechanic=objNull;
    sleep 0.1;
    _npc=[[4003,4000,0],180,_loadout] call DSDS_fnc_createMechanic;
    [side group _npc==resistance,"restored-loadout creation retains Independent side"] call _assert;
    // Also verify the explicit join handles a non-Independent campaign correctly.
    private _petros=petros; petros=objNull;
    deleteVehicle _npc; DSDS_mechanic=objNull;
    sleep 0.1;
    _npc=[[4020,4000,0],180] call DSDS_fnc_createMechanic;
    [side group _npc==west,"explicit join handles WEST fallback despite Independent config"] call _assert;
    deleteVehicle _npc; DSDS_mechanic=objNull; petros=_petros; teamPlayer=resistance;
    sleep 0.1;
    _npc=[[4003,4000,0],180] call DSDS_fnc_createMechanic;
    _npc allowDamage false;
    if (!isClass (configFile >> "CfgPatches" >> "A3A_ultimate")) then {
        private _logicGroup=createGroup sideLogic;
        server=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
        sidesX=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
        seaports=["DSDS_PLUS_TEST_PORT"];resourcesX=[];
        sidesX setVariable ["DSDS_PLUS_TEST_PORT",teamPlayer];
        server setVariable ["C_Offroad_01_F",200];
        [["C_Offroad_01_F"] call DSDS_fnc_vehicleShopPrice==(["C_Offroad_01_F"] call A3A_fnc_vehiclePrice),"Plus native seaport discount retained"] call _assert;
        [["C_Offroad_01_F"] call DSDS_fnc_vehicleValue<=90,"Plus actual store-price cap retained"] call _assert;
        [["B_Plane_CAS_01_F"] call DSDS_fnc_vehicleShopPrice==0,"Plus unknown prices remain uncapped"] call _assert;
    };
    private _vehicle=createVehicle ["C_Offroad_01_F",[4010,4000,0],[],0,"NONE"];
    clearWeaponCargoGlobal _vehicle; clearMagazineCargoGlobal _vehicle; clearItemCargoGlobal _vehicle; clearBackpackCargoGlobal _vehicle;
    DSDS_uiVehicle=_vehicle; publicVariable "DSDS_uiVehicle";
    A3A_faction_civ=createHashMapFromArray [["currencySymbol","credits"]];
    // No save target: the production persistence loop never touches any campaign here.
    serverInitDone=true; publicVariable "serverInitDone";
    DSDS_uiReady=true; publicVariable "DSDS_uiReady";
    diag_log format ["[DSDS REGRESSION] COMPLETE failures=%1",DSDS_testFailures];
};
