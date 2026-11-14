/* Native function override: retain native discounts, then apply civilian price reduction once. */
if (isNil "DSDS_nativeHQVehiclePrice") then {DSDS_nativeHQVehiclePrice=compile preprocessFileLineNumbers "\x\A3A\addons\core\functions\REINF\fn_vehiclePrice.sqf";};
private _dsdsRawVehiclePricing=true;
private _price=_this call DSDS_nativeHQVehiclePrice;
private _class=_this param [0,""];
if (_class isKindOf "LandVehicle" && {getNumber (configFile >> "CfgVehicles" >> _class >> "side")==3}) then {_price=(round (_price*0.4)) max 1;};
_price
