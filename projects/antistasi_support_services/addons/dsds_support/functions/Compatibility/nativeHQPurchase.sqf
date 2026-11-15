private _class=_this param [0,""];
if ((toLower _class find "dch18_ucg_")==0) exitWith {if (hasInterface) then {systemChat "The Hellcat is not sold through HQ purchases.";};false};
if (isNil "DSDS_nativeHQPurchase") then {DSDS_nativeHQPurchase=compile preprocessFileLineNumbers "\x\A3A\addons\core\functions\REINF\fn_addFiaVeh.sqf";};
_this call DSDS_nativeHQPurchase
