/* Cheapest actual native purchase price, without querying unknown classes (native logs errors).
   Plus: HQ server price + native seaport reduction.
   Ultimate 12: HQ price and nested black-market stock use shared diminishing discounts.
   No campaign price/faction tables are modified. Zero means unknown, never a made-up default. */
params ["_class",["_marketOnly",false]];
private _hq=0;
private _market=0;
if (!isNil "server" && {!isNull server}) then {
    private _value=server getVariable [_class,0];
    if (_value isEqualType 0 && {finite _value} && {_value>0}) then {_hq=_value;};
};
private _ultimate=isClass (configFile >> "CfgPatches" >> "A3A_ultimate");
if (_ultimate) then {
    private _stock=missionNamespace getVariable ["A3U_blackMarketStock",createHashMap];
    if (_stock isEqualType createHashMap) then {
        {
            if (_x isEqualType createHashMap) then {
                private _value=_x getOrDefault [_class,0];
                if (_value isEqualType 0 && {finite _value} && {_value>0}) then {
                    if (_market==0 || {_value<_market}) then {_market=_value;};
                };
            };
        } forEach values _stock;
    };
    private _seaports=0;private _resources=0;
    if (!isNil "sidesX" && {!isNull sidesX} && {!isNil "teamPlayer"}) then {
        _seaports={sidesX getVariable [_x,sideUnknown]==teamPlayer} count (missionNamespace getVariable ["seaports",[]]);
        _resources={sidesX getVariable [_x,sideUnknown]==teamPlayer} count (missionNamespace getVariable ["resourcesX",[]]);
    };
    private _factor=1/(1+_seaports*0.1+_resources*0.02);
    if (_hq>0) then {_hq=round (_hq*_factor);};
    if (_market>0) then {
        private _discount=(missionNamespace getVariable ["A3U_blackMarketDiscountVehicle",0])/10;
        _market=round (_market*_factor*(1-_discount));
    };
} else {
    if (_hq>0 && {!isNil "A3A_fnc_vehiclePrice"} && {!isNil "seaports"} && {!isNil "resourcesX"} && {!isNil "sidesX"}) then {
        private _native=[_class] call A3A_fnc_vehiclePrice;
        if (_native>0) then {_hq=_native;};
    };
};
if (_ultimate && {_class isKindOf "LandVehicle"} && {getNumber (configFile >> "CfgVehicles" >> _class >> "side")==3}) then {
 if (_hq>0) then {_hq=(round (_hq*0.4)) max 1;};
 if (_market>0) then {_market=(round (_market*0.4)) max 1;};
};
if (_marketOnly) exitWith {_market};
private _prices=[_hq,_market] select {_x>0};
if (_prices isEqualTo []) then {0} else {selectMin _prices}
