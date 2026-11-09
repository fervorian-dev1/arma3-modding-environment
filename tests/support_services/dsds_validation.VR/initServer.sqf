[] spawn {
    sleep 3;
    DSDS_testFailures = 0;
    private _assert = {
        params ["_condition","_name"];
        if (!_condition) then {DSDS_testFailures = DSDS_testFailures + 1;};
        diag_log format ["[DSDS TEST] %1: %2",["FAIL","PASS"] select _condition,_name];
    };
    {
        private _name = configName _x;
        [!isNil ("DSDS_fnc_" + _name),"registered function " + _name] call _assert;
        compile preprocessFileLineNumbers format ["\dsds_support\functions\fn_%1.sqf",_name];
    } forEach ("true" configClasses (configFile >> "CfgFunctions" >> "DSDS" >> "Services"));
    private _cfg = configFile >> "CfgWeapons" >> "DSDS_SupportTerminal";
    [getText (_cfg >> "model") == getText (configFile >> "CfgWeapons" >> "B_UavTerminal" >> "model"),"terminal inherits actual UAV terminal model"] call _assert;
    [getText (_cfg >> "simulation") == "ItemGPS","terminal uses GPS simulation, not UAV simulation"] call _assert;
    diag_log format ["[DSDS TEST] Terminal classification %1, model %2, itemInfoType %3","DSDS_SupportTerminal" call BIS_fnc_itemType,getText (_cfg >> "model"),getNumber (_cfg >> "ItemInfo" >> "type")];
    [isClass (configFile >> "DSDS_SupportTerminalDialog" >> "Controls" >> "Map"),"native Antistasi-style support dialog configured"] call _assert;
    teamPlayer = west; Occupants = east; Invaders = resistance;
    private _logicGroup = createGroup sideLogic;
    lootCrateUnlockedItems=false;
    server = _logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
    if (isClass (configFile >> "CfgPatches" >> "A3A_ultimate")) then {
        [_assert,_logicGroup] call compile preprocessFileLineNumbers "testUltimate.sqf";
    };
    A3A_saveTarget = [false,"DSDS_TEST_ISOLATED",worldName];
    A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_IND_Wps_F"],["vehiclesBasic",["B_G_Offroad_01_F"]]];
    A3A_faction_civ = createHashMapFromArray [["currencySymbol","credits"]];
    A3A_faction_occ=createHashMapFromArray [["surrenderCrate","Box_NATO_Ammo_F"],["name","Occupants"]];
    A3A_faction_inv=createHashMapFromArray [["surrenderCrate","Box_NATO_Ammo_F"],["name","Invaders"]];
    A3A_faction_riv=createHashMapFromArray [["surrenderCrate","Box_NATO_Ammo_F"],["name","Rivals"]];
    arrayMoney=[];arrayMoneyAmount=[];
    prestigeIsChanging=false;A3A_balancePlayerScale=1;gameMode=1;
    aggressionStackOccupants=[];aggressionStackInvaders=[];aggressionLevelOccupants=1;aggressionLevelInvaders=1;
    A3A_Reb_template="RHS_Test"; A3A_Inv_template="RHS_Test"; A3A_Occ_template="RHS_Test";
    unlockedWeapons=[];unlockedMagazines=[];unlockedItems=[];unlockedBackpacks=[];staticsToSave=[];
    minWeaps=-1; jna_dataList=[]; for "_i" from 0 to 26 do {jna_dataList pushBack [];};
    server setVariable ["jna_playersInArsenal",[]];
    private _group = createGroup west;
    private _buyer = _group createUnit ["B_Soldier_F",[4000,4000,0],[],0,"NONE"];
    petros = _group createUnit ["B_Soldier_F",[4002,4000,0],[],0,"NONE"];
    boxX=createVehicle ["B_supplyCrate_F",[6000,6000,0],[],0,"NONE"];
    clearWeaponCargoGlobal boxX;clearMagazineCargoGlobal boxX;clearItemCargoGlobal boxX;clearBackpackCargoGlobal boxX;
    _buyer setVariable ["moneyX",100000,true];
    _buyer disableAI "PATH"; petros disableAI "PATH";
    removeAllAssignedItems _buyer;
    private _dsdsAuthorizedPlayer = _buyer;
    _buyer setVariable ["moneyX",9999];
    [!(["ISSUE",_buyer,[]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX"==9999},"terminal purchase rejects insufficient personal funds"] call _assert;
    _buyer setVariable ["moneyX",20000];
    _buyer linkItem "ItemGPS";
    [!(["ISSUE",_buyer,[]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX"==20000},"occupied GPS slot never charges terminal purchase"] call _assert;
    removeAllAssignedItems _buyer;
    [["ISSUE",_buyer,[]] call DSDS_fnc_serviceTransaction,"new terminal purchase accepted"] call _assert;
    [_buyer getVariable "moneyX"==10000,"terminal costs exactly 10000 personal credits"] call _assert;
    [!(["ISSUE",_buyer,[]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX"==10000},"pending terminal delivery prevents duplicate charges"] call _assert;
    _buyer linkItem "DSDS_SupportTerminal";
    sleep 0.4;
    [!(["ISSUE",_buyer,[]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX"==10000},"existing terminal remains usable without repurchase"] call _assert;
    _buyer setVariable ["moneyX",100000];
    _buyer linkItem "DSDS_SupportTerminal";
    ["DSDS_SupportTerminal" in assignedItems _buyer,"terminal equips in assigned item slot"] call _assert;
    [(getUnitLoadout _buyer select 9 select 1) == "DSDS_SupportTerminal","terminal occupies normal GPS/UAV slot"] call _assert;
    [("DSDS_SupportTerminal" call BIS_fnc_itemType) isEqualTo ["Item","GPS"],"terminal is GPS-class equipment rather than UAV control equipment"] call _assert;
    private _catalogue = [] call DSDS_fnc_serviceCatalogue;
    [count _catalogue == 11,"all eleven native fire-support options copied"] call _assert;
    [(_catalogue findIf {(_x select 2) < 5000}) == -1,"every support contract costs at least 5000"] call _assert;
    {
        _x params ["_id","_expected"];
        [getNumber (configFile >> "DSDS_SupportActions" >> _id >> "cost")==_expected,"configured price " + _id] call _assert;
    } forEach [["HE",30000],["CLUSTER",40000],["NAPALM",40000],["CHEMICAL",50000],["SUPPLY",5000],["RECON",8000]];
    diag_log format ["[DSDS TEST] Catalogue: %1",_catalogue];
    [[_buyer,-5000] call DSDS_fnc_changeWallet,"personal credit debit accepted"] call _assert;
    [_buyer getVariable ["moneyX",0] == 95000,"debit uses native personal moneyX ledger"] call _assert;
    private _sequence = _buyer getVariable ["DSDS_walletSequence",0];
    [_sequence>0,"wallet change emits sequenced HUD refresh receipt"] call _assert;
    private _ownerWallet = _group createUnit ["B_Soldier_F",[4050,4050,0],[],0,"NONE"];
    _ownerWallet setVariable ["moneyX",90000];
    _buyer setVariable ["owner",_ownerWallet];
    [[_buyer,-10000] call DSDS_fnc_changeWallet && {_ownerWallet getVariable "moneyX"==80000} && {_buyer getVariable "moneyX"==95000},"terminal-sized debit uses real owner wallet, not controlled proxy"] call _assert;
    [[_buyer,-30000] call DSDS_fnc_changeWallet && {_ownerWallet getVariable "moneyX"==50000},"HE-sized debit subtracts exact configured price from owner wallet"] call _assert;
    [!([_buyer,-50001] call DSDS_fnc_changeWallet) && {_ownerWallet getVariable "moneyX"==50000},"owner wallet rejects overspend without partial deduction"] call _assert;
    _buyer setVariable ["owner",nil]; deleteVehicle _ownerWallet;
    [!([_buyer,-999999] call DSDS_fnc_changeWallet) && {_buyer getVariable ["moneyX",0] == 95000},"insufficient funds leave balance intact"] call _assert;
    ["HIRE",_buyer,[]] call DSDS_fnc_serverRequest;
    [isNull DSDS_mechanic,"RPC rejects a nonplayer transaction"] call _assert;
    _dsdsAuthorizedPlayer = _buyer;
    [["HIRE",_buyer,[]] call DSDS_fnc_serviceTransaction,"authenticated-scope hire transaction succeeds"] call _assert;
    private _npc = DSDS_mechanic;
    [!isNull _npc && {alive _npc},"mechanic actually spawned"] call _assert;
    if (!isNull _npc) then {
        [_buyer getVariable ["moneyX",0] == 94000,"mechanic hire costs exactly 1000"] call _assert;
        [uniform _npc == "DSDS_MechanicUniform" && {headgear _npc == "H_Cap_blk"} && {vest _npc == "V_TacVest_blk"},"black uniform, black vest, baseball cap equipped"] call _assert;
        [(primaryWeapon _npc find "rhs_") == 0,"mechanic carries installed mod rifle"] call _assert;
        [] call DSDS_fnc_serviceActions;
        private _petrosCount = count actionIDs petros;
        [] call DSDS_fnc_serviceActions;
        [count actionIDs petros == _petrosCount,"Petros service registration is idempotent"] call _assert;
        [!(_npc checkAIFeature "PATH") && {_npc checkAIFeature "AUTOTARGET"},"stationary AI retains target/self-defense capability"] call _assert;
        [!(["HIRE",_buyer,[]] call DSDS_fnc_serviceTransaction),"duplicate mechanic hire refused"] call _assert;
        [_buyer getVariable ["moneyX",0] == 94000,"duplicate hire does not charge twice"] call _assert;
        diag_log format ["[DSDS TEST] Mechanic textures %1",getObjectTextures _npc];
    };
    if (!isNull _npc) then {
        // Move/place without granting commander status or changing Petros.
        [_buyer,true] call DSDS_fnc_moveMechanic;
        [attachedTo _npc == _buyer,"mechanic can be moved by requester"] call _assert;
        _buyer setPosATL [4010,4000,0]; sleep 0.5;
        [_buyer,false] call DSDS_fnc_moveMechanic;
        [isNull attachedTo _npc && {!(_npc checkAIFeature "PATH")},"mechanic placement restores stationary AI"] call _assert;
        _buyer setPosATL ((_npc getPos [2,180]) vectorAdd [0,0,0]);
        private _position = getPosATL _npc;
        [] call DSDS_fnc_persistMechanic;
        saveMissionProfileNamespace;
        private _saved = ["DSDS_mechanicState"] call A3A_fnc_returnSavedStat;
        [!isNil "_saved" && {_saved select 1},"mechanic saved through native campaign-qualified storage"] call _assert;
        deleteVehicle _npc;
        DSDS_mechanic = objNull;
        sleep 0.25;
        _npc = [] call DSDS_fnc_restoreMechanic;
        [!isNull _npc && {_npc distance2D _position < 1},"mechanic restored at saved position without another hire charge"] call _assert;
        [headgear _npc == "H_Cap_blk" && {(primaryWeapon _npc find "rhs_") == 0},"restored mechanic retains clothing and mod weapon"] call _assert;
        _buyer setPosATL (_npc getPos [2,180]);
        private _civilian = ["C_Offroad_01_F"] call DSDS_fnc_vehicleValue;
        private _truck = ["B_Truck_01_transport_F"] call DSDS_fnc_vehicleValue;
        private _utility = ["B_Truck_01_ammo_F"] call DSDS_fnc_vehicleValue;
        private _armed = ["B_G_Offroad_01_armed_F"] call DSDS_fnc_vehicleValue;
        private _armor = ["B_APC_Wheeled_01_cannon_F"] call DSDS_fnc_vehicleValue;
        private _tank = ["B_MBT_01_cannon_F"] call DSDS_fnc_vehicleValue;
        private _heli = ["B_Heli_Transport_01_F"] call DSDS_fnc_vehicleValue;
        private _plane = ["B_Plane_CAS_01_F"] call DSDS_fnc_vehicleValue;
        diag_log format ["[DSDS TEST] Vehicle tiers civilian=%1 truck=%2 utility=%3 armed=%4 armor=%5 tank=%6 heli=%7 plane=%8",_civilian,_truck,_utility,_armed,_armor,_tank,_heli,_plane];
        [_civilian < _truck && {_truck <= _utility} && {_utility < _armed} && {_armed < _armor},"vehicle tiers favor military utility/armament/armor"] call _assert;
        [_tank > _armor && {_heli > _armor} && {_plane > _armor},"tanks, helicopters and planes are top-value tiers"] call _assert;
        private _modCars = "getNumber (_x >> 'scope') == 2 && {configName _x isKindOf 'Car'} && {(configName _x find 'rhs') == 0}" configClasses (configFile >> "CfgVehicles");
        [count _modCars > 0 && {[configName (_modCars select 0)] call DSDS_fnc_vehicleValue > 0},"modded vehicles priced without a classname whitelist"] call _assert;
        private _vehicle = createVehicle ["C_Offroad_01_F",_npc getPos [12,0],[],0,"NONE"];
        private _full = [_vehicle] call DSDS_fnc_vehicleValue;
        _vehicle setDamage 0.5;
        [[_vehicle] call DSDS_fnc_vehicleValue < _full,"damage reduces vehicle offer"] call _assert;
        _vehicle setDamage 0;
        server setVariable ["C_Offroad_01_F",100];
        [[_vehicle] call DSDS_fnc_vehicleValue <= 50,"store-price cap prevents buy/resell profit"] call _assert;
        server setVariable ["C_Offroad_01_F",nil];
        _vehicle setVariable ["ownerX","someone-else"];
        [[_buyer,_vehicle] call DSDS_fnc_validateVehicleSale != "","other players' personal vehicles protected"] call _assert;
        _vehicle setVariable ["ownerX",""];
        _vehicle setVariable ["DSDS_serviceVehicle",true];
        [[_buyer,_vehicle] call DSDS_fnc_validateVehicleSale != "","temporary contractor aircraft/vehicles cannot be resold"] call _assert;
        _vehicle setVariable ["DSDS_serviceVehicle",false];
        clearWeaponCargoGlobal _vehicle;clearMagazineCargoGlobal _vehicle;clearItemCargoGlobal _vehicle;clearBackpackCargoGlobal _vehicle;
        _vehicle addWeaponCargoGlobal ["arifle_MX_F",1];
        _vehicle addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag",5];
        _vehicle addItemCargoGlobal ["FirstAidKit",2];
        _vehicle addBackpackCargoGlobal ["B_AssaultPack_blk",1];
        private _bag=(everyContainer _vehicle) select 0 select 1;
        _bag addItemCargoGlobal ["ToolKit",1];
        private _beforeCrates = allMissionObjects "ReammoBox_F";
        private _beforeMoney = _buyer getVariable "moneyX";
        [["QUOTE",_buyer,[_vehicle]] call DSDS_fnc_serviceTransaction,"server provides vehicle quote"] call _assert;
        private _quote = _buyer getVariable ["DSDS_quote",[]];
        private _price = _quote param [1,0];
        [["SELL",_buyer,[_vehicle]] call DSDS_fnc_serviceTransaction,"confirmed vehicle sale succeeds"] call _assert;
        sleep 0.1;
        [isNull _vehicle && {_buyer getVariable "moneyX" == _beforeMoney + _price},"sale consumes one vehicle and credits exact personal offer"] call _assert;
        [((allMissionObjects "ReammoBox_F") - _beforeCrates) isEqualTo [],"loaded sale creates no arsenal/crate clutter"] call _assert;
        private _amount = {params ["_class"];private _index=_class call jn_fnc_arsenal_itemType; private _entry=(jna_dataList select _index) select {(_x select 0)==_class}; if (_entry isEqualTo []) then {0} else {(_entry select 0) select 1}};
        diag_log format ["[DSDS TEST] Imported MX=%1 magazineRounds=%2",["arifle_MX_F"] call _amount,["30Rnd_65x39_caseless_mag"] call _amount];
        [["arifle_MX_F"] call _amount==1 && {["30Rnd_65x39_caseless_mag"] call _amount>=150},"vehicle weapon and magazine rounds go directly to JNA"] call _assert;
        [["ToolKit"] call _amount==1 && {["B_AssaultPack_blk"] call _amount==1},"nested backpack contents reach JNA"] call _assert;
        [!(["SELL",_buyer,[_vehicle]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX" == _beforeMoney + _price},"repeat vehicle sale cannot pay twice"] call _assert;
        private _empty=createVehicle ["C_Offroad_01_F",_npc getPos [12,0],[],0,"NONE"];
        clearWeaponCargoGlobal _empty;clearMagazineCargoGlobal _empty;clearItemCargoGlobal _empty;clearBackpackCargoGlobal _empty;
        private _arsenalBefore=str jna_dataList;
        ["QUOTE",_buyer,[_empty]] call DSDS_fnc_serviceTransaction;
        [["SELL",_buyer,[_empty]] call DSDS_fnc_serviceTransaction,"empty vehicle sale succeeds"] call _assert;
        sleep 0.1;
        [isNull _empty && {str jna_dataList==_arsenalBefore} && {((allMissionObjects "ReammoBox_F") - _beforeCrates) isEqualTo []},"empty sale creates no crate and adds no phantom inventory"] call _assert;
        // Dead state is stored, so reloading does not resurrect a killed mechanic.
        _npc setDamage 1; sleep 0.1;
        private _deadState = ["DSDS_mechanicState"] call A3A_fnc_returnSavedStat;
        [!(_deadState select 1),"mechanic death persists as unavailable"] call _assert;
        [isNull ([] call DSDS_fnc_restoreMechanic),"killed mechanic does not respawn on restore"] call _assert;
    };
    // All original progression gates deliberately disabled in this test.
    supportPoints=0; bombRuns=0; airportsX=[]; supportCooldown=true; theBoss=petros;
    sidesX=_logicGroup createUnit ["Logic",[0,0,0],[],0,"NONE"];
    sidesX setVariable ["DSDS_TEST_AIRFIELD_STATE",east];
    createMarker ["DSDS_TEST_AIRFIELD_STATE",[1000,2000,0]];
    "DSDS_TEST_AIRFIELD_STATE" setMarkerColor "ColorEAST";
    private _factionsBefore=[A3A_Reb_template,A3A_Inv_template,A3A_Occ_template,str A3A_faction_reb,str A3A_faction_occ,str A3A_faction_inv];
    private _balance = _buyer getVariable "moneyX";
    [!(["SUPPORT",_buyer,["SUPPLY",[-1,10,0],[1,1,0]]] call DSDS_fnc_serviceTransaction) && {_buyer getVariable "moneyX" == _balance},"invalid support positions never debit credits"] call _assert;
    [["SUPPORT",_buyer,["SMOKE",[7000,7000,0],[7000,7000,0]]] call DSDS_fnc_serviceTransaction,"support accepted without commander, airports, radio, points or native cooldown"] call _assert;
    [_buyer getVariable "moneyX" == _balance - 5000,"paid support debits the configured personal price"] call _assert;
    private _smokeID = str DSDS_jobSequence;
    private _deadline = diag_tickTime + 25;
    waitUntil {sleep 0.25; ((DSDS_jobs get _smokeID) get "state") in ["fulfilled","refunded"] || {diag_tickTime > _deadline}};
    [((DSDS_jobs get _smokeID) get "state") == "fulfilled" && {((DSDS_jobs get _smokeID) getOrDefault ["roundsCreated",0]) == 5},"paid smoke support actually spawns five rounds"] call _assert;
    private _refundBefore = _buyer getVariable "moneyX";
    [_buyer,-5000] call DSDS_fnc_changeWallet;
    DSDS_jobs set ["test-refund",createHashMapFromArray [["player",_buyer],["holder",_buyer],["cost",5000],["state","paid"]]];
    ["test-refund",false,"isolated test failure"] call DSDS_fnc_finishSupportContract;
    ["test-refund",false,"duplicate failure"] call DSDS_fnc_finishSupportContract;
    [_buyer getVariable "moneyX" == _refundBefore,"failed support refunds exactly once"] call _assert;
    // Paid physical supply and vehicle deliveries use the unchanged shared supply helpers.
    [_buyer,400000] call DSDS_fnc_changeWallet;
    _buyer addBackpack "B_AssaultPack_blk";
    _buyer addItemToBackpack "FirstAidKit";
    private _backpack = backpack _buyer;
    private _backpackItems = backpackItems _buyer;
    private _loot = createVehicle ["GroundWeaponHolder",[6500,6500,0],[],0,"NONE"];
    _loot addWeaponCargoGlobal ["arifle_MX_F",1];_loot addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag",5];
    private _requests = [
        ["SUPPLY",[5000,5000,0],[5000,5000,0]],
        ["VEH_AIRDROP",[7000,5000,0],[7500,5000,0]],
        ["HE",[7000,7000,0],[7500,7000,0]],
        ["FLARE",[5500,5500,0],[5500,5500,0]],
        ["RECON",[6500,4000,0],[7000,4000,0]],
        ["CLUSTER",[6500,7500,0],[7000,7500,0]],
        ["NAPALM",[7000,3000,0],[7500,3000,0]],
        ["CHEMICAL",[4500,7000,0],[5000,7000,0]],
        ["LOOTHELI",[6000,6500,0],[6500,6500,0]],
        ["PARADROP",[7000,4500,0],[7800,4500,0]]
    ];
    isSupportMarkerPlacingLocked=true;
    supportMarkerOrigin="DSDS_commander_marker_preserve";
    createMarker [supportMarkerOrigin,[1000,1000,0]];
    private _ids = [];
    {
        [["SUPPORT",_buyer,_x] call DSDS_fnc_serviceTransaction,"paid " + (_x select 0) + " dispatch accepted"] call _assert;
        _ids pushBack str DSDS_jobSequence;
    } forEach _requests;
    _deadline = diag_tickTime + 360;
    waitUntil {sleep 1; (_ids findIf {!(((DSDS_jobs get _x) get "state") in ["fulfilled","refunded"])}) == -1 || {diag_tickTime > _deadline}};
    {
        private _job = DSDS_jobs get _x;
        [(_job get "state") == "fulfilled","physical " + (_job get "type") + " support fulfilled"] call _assert;
        if ((_job get "type") in ["HE","CLUSTER","NAPALM","CHEMICAL"]) then {
            [_job getOrDefault ["releaseSpeed",0]>1200,"supersonic release speed " + (_job get "type")] call _assert;
            [(_job getOrDefault ["aircraftClass",""]) find "RHS_T50"==0,"attack jet replaces transport " + (_job get "type")] call _assert;
            [_job getOrDefault ["afterburnerPhase",0]>0.9,"full afterburner on strike " + (_job get "type")] call _assert;
            [(_job getOrDefault ["releaseAltitude",0])>100 && {(_job get "releaseAltitude")<225},"low visible strike altitude " + (_job get "type")] call _assert;
        };
        if ((_job get "type") in ["SUPPLY","VEH_AIRDROP"]) then {
            private _payload = _job getOrDefault ["payload",objNull];
            [!isNull _payload && {_payload getVariable ["DSD_landed",false]},"physical " + (_job get "type") + " payload landed"] call _assert;
        };
        if ((_job get "type") == "LOOTHELI") then {
            ["arifle_MX_F" in weaponCargo (_job get "payload"),"loot helicopter recovered actual world inventory"] call _assert;
        };
    } forEach _ids;
    [supportPoints==0 && {bombRuns==0} && {supportCooldown} && {isSupportMarkerPlacingLocked} && {supportMarkerOrigin=="DSDS_commander_marker_preserve"},"paid contracts leave original commander support state intact"] call _assert;
    [backpack _buyer == _backpack && {backpackItems _buyer isEqualTo _backpackItems},"paradrop preserves passenger backpack and contents"] call _assert;
    [!isNull (_buyer getVariable ["DSDS_parachute",objNull]),"paradrop deploys a real steerable parachute"] call _assert;
    // Save an alive mechanic for a separate fresh-process restoration test.
    private _proofBuyer = _group createUnit ["B_Soldier_F",[4001,4000,0],[],0,"NONE"];
    _proofBuyer setVariable ["moneyX",10000];
    _dsdsAuthorizedPlayer = _proofBuyer;
    [["HIRE",_proofBuyer,[]] call DSDS_fnc_serviceTransaction,"a killed mechanic can be rehired for a new fee"] call _assert;
    [_proofBuyer getVariable "moneyX" == 9000,"rehire costs exactly 1000 personal credits"] call _assert;
    [] call DSDS_fnc_persistMechanic;
    saveMissionProfileNamespace;
    // Allow native chemical/napalm effects to execute their delayed server logic.
    sleep 150;
    [[A3A_Reb_template,A3A_Inv_template,A3A_Occ_template,str A3A_faction_reb,str A3A_faction_occ,str A3A_faction_inv] isEqualTo _factionsBefore && {sidesX getVariable "DSDS_TEST_AIRFIELD_STATE"==east} && {markerColor "DSDS_TEST_AIRFIELD_STATE"=="ColorEAST"},"factions, airfield ownership and map marker preserved through all services"] call _assert;
    diag_log format ["[DSDS TEST] COMPLETE failures=%1",DSDS_testFailures];
};
