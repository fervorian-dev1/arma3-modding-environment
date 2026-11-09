/* Scheduled fulfilment; a failed spawn/boarding refunds the original wallet once. */
params ["_player","_holder","_offer","_box","_camp",["_uid",""],["_balanceAfter",0]];
_offer params ["_kind","_class","_section","_price"];
private _success=false;private _vehicle=objNull;
private _storedBoat=_kind=="VEHICLE" && {_class isKindOf "Ship"};
private _dsdsFenceDelivery=true;
private _wasPlayer=isPlayer _player;
private _plane=_kind == "VEHICLE" && {_class isKindOf "Plane"};
private _uav=_kind == "VEHICLE" && {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") > 0};
if (_kind == "GEAR") then {
    if (!isNull _box && {alive _box}) then {
        switch (_section) do {
            case "CfgVehicles": {_box addBackpackCargoGlobal [_class,1];};
            case "CfgMagazines": {_box addMagazineCargoGlobal [_class,1];};
            default {
                if (getNumber (configFile >> "CfgWeapons" >> _class >> "type") in [1,2,4]) then {
                    _box addWeaponCargoGlobal [_class,1];
                    private _mags=(compatibleMagazines [_class,"this"]) select {
                        getNumber (configFile >> "CfgMagazines" >> _x >> "scope")==2 && {[_x,"CfgMagazines"] call DSD_fnc_isSupplyAssetAllowed}
                    };
                    if ((_offer param [4,""])=="AA") then {_mags=_mags select {[_x,"CfgMagazines"] call DSDS_fnc_fenceIsAntiAir};};
                    private _declared=getArray (configFile >> "CfgWeapons" >> _class >> "magazines");
                    private _preferred=_mags select {_x in _declared};
                    if (_preferred isNotEqualTo []) then {_mags=_preferred;};
                    if (_mags isNotEqualTo []) then {_box addMagazineCargoGlobal [selectRandom _mags,5];};
                } else {_box addItemCargoGlobal [_class,1];};
            };
        };
        _success=true;
        _box setVariable ["DSDS_tradeRevision",1+(_box getVariable ["DSDS_tradeRevision",0]),true];
    };
} else {if (_storedBoat) then {
    _success=[_class,_uid] call DSDS_fnc_storeFenceBoat;
} else {
    private _pos=[];
    if (_plane) then {
        _pos=_camp getPos [2500,random 360];
        if ((_pos select 0) > 100 && {(_pos select 1) > 100} && {(_pos select 0) < worldSize-100} && {(_pos select 1) < worldSize-100}) then {
            private _dir=_pos getDir _camp;private _height=800;
            for "_d" from 0 to 8000 step 500 do {private _sample=_pos getPos [_d,_dir];_height=_height max ((getTerrainHeightASL _sample max 0)+800);};
            _pos set [2,_height];
        } else {_pos=[];};
    } else {
        if (_class isKindOf "Ship") then {
            _pos=[_camp,30,3000,15,2,0.2,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
        } else {_pos=[_camp,25,180,18,0,0.15,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;};
        if (_pos distance2D [0,0,0] < 10) then {_pos=[];};
    };
    if (_pos isNotEqualTo []) then {
        _vehicle=createVehicle [_class,_pos,[],0,if (_plane) then {"FLY"} else {"NONE"}];
        if (!isNull _vehicle && {alive _vehicle}) then {
            clearWeaponCargoGlobal _vehicle;clearMagazineCargoGlobal _vehicle;clearItemCargoGlobal _vehicle;clearBackpackCargoGlobal _vehicle;
            _vehicle setVariable ["ownerX",getPlayerUID _player,true];
            _vehicle setVariable ["DSDS_fencePurchase",true,true];
            _vehicle setVehicleLock "UNLOCKED";
            // Native black-market vehicle initialization; no map/faction ownership edits.
            if (!isNil "A3A_activePlayerCount" && {!isNil "A3A_vehicleResourceCosts"}) then {
                [_vehicle,teamPlayer] call A3A_fnc_AIVEHinit;
                [_vehicle,teamPlayer] call SCRT_fnc_misc_tryInitVehicle;
            };
            if (_plane) then {
                _vehicle enableSimulationGlobal false;
                _vehicle setPosASL _pos;_vehicle setDir (_pos getDir _camp);
            };
            if (_uav) then {
                // Ultimate's AIVEHinit already creates rebel UAV crew. Keep that crew
                // instead of creating an extra group or replacing native initialization.
                if (isNull driver _vehicle) then {(side group _player) createVehicleCrew _vehicle;};
                if (_plane) then {_vehicle enableSimulationGlobal true;_vehicle engineOn true;_vehicle setVelocityModelSpace [0,120,0];_vehicle flyInHeight 800;};
                _success=!isNull driver _vehicle;
            } else {
                if (_plane) then {
                    _vehicle setVariable ["DSDS_fenceBuyer",_player,true];
                    [_player,_vehicle,false] remoteExecCall ["DSDS_fnc_fenceBoard",_player];
                    private _deadline=diag_tickTime+20;
                    waitUntil {sleep 0.1;isNull _player || {!alive _player} || {_wasPlayer && {!isPlayer _player}} || {vehicle _player == _vehicle} || {diag_tickTime > _deadline}};
                    _success=!isNull _player && {alive _player} && {driver _vehicle == _player};
                    if (_success) then {
                        _vehicle enableSimulationGlobal true;
                        [_player,_vehicle,true] remoteExecCall ["DSDS_fnc_fenceBoard",_player];
                    };
                } else {_success=true;};
            };
        };
    };
};};
if (!_success) then {
    if (!isNull _vehicle && {crew _vehicle findIf {isPlayer _x} < 0}) then {{deleteVehicle _x;} forEach crew _vehicle;deleteVehicle _vehicle;};
    // Refund the captured holder, even after disconnect or a control-proxy change.
    if (!isNull _holder) then {
        // Captured holder is already the final ledger object; do not follow another owner proxy.
        _holder setVariable ["moneyX",(_holder getVariable ["moneyX",0])+_price,true];
    } else {
        if (_uid != "" && {!isNil "A3A_playerSaveData"}) then {
            private _data=A3A_playerSaveData getOrDefault [_uid,createHashMap];
            _data set ["moneyX",(_data getOrDefault ["moneyX",_balanceAfter])+_price];
            A3A_playerSaveData set [_uid,_data];
        };
    };
    diag_log format ["[DSDS Fence] Failed delivery %1; refund %2 to %3.",_class,_price,_holder];
};
if (!isNull _player) then {
    _player setVariable ["DSDS_fencePending",false];
    private _text=if (_success) then {if (_kind == "GEAR") then {"Purchase delivered to the community trade crate."} else {if (_storedBoat) then {"Boat added to your personal Antistasi garage."} else {format ["Vehicle delivered at grid %1. Save/garage it using normal Antistasi procedures.",mapGridPosition _vehicle]}}} else {"Delivery failed; purchase refunded to your original personal wallet."};
    ["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_player];
};
