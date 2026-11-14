if (isNil "DSDS_nativeBMVehiclePrice") then {DSDS_nativeBMVehiclePrice=compile preprocessFileLineNumbers "\x\A3A\addons\ultimate\functions\REINF\fn_blackMarketVehiclePrice.sqf";};
private _price=_this call DSDS_nativeBMVehiclePrice;
private _class=_this param [0,""];
if (isNil "_dsdsRawVehiclePricing" && {_class isKindOf "LandVehicle"} && {getNumber (configFile >> "CfgVehicles" >> _class >> "side")==3}) then {_price=(round (_price*0.4)) max 1;};
_price
