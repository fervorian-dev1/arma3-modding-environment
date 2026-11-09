/* Runtime discovery also supports RKSL's protected PBO without guessing its class names. */
private _cfg=configFile >> "CfgVehicles";
private _uavs="getNumber (_x >> 'scope')==2 && {getNumber (_x >> 'isUav')==1} && {(toLower getText (_x >> 'displayName') find 'watchkeeper')>=0 || {(toLower configName _x find 'wk450')>=0}}" configClasses _cfg;
private _ospreys="getNumber (_x >> 'scope')==2 && {getNumber (_x >> 'vtol')>0} && {getNumber (_x >> 'transportSoldier')>=20} && {(toLower getText (_x >> 'displayName') find 'osprey')>=0}" configClasses _cfg;
private _specialists="getNumber (_x >> 'scope')==2 && {getText (_x >> 'uniformClass')=='U_B_CBRN_Suit_01_Wdl_F'} && {getText (_x >> 'faction')=='BLU_W_F'}" configClasses _cfg;
private _osprey="";
if (_ospreys isNotEqualTo []) then {
 private _transport=_ospreys select {(toLower configName _x find '_transport_')>=0 && {(toLower configName _x find '_viv_')<0}};
 _osprey=configName ((_transport+_ospreys) select 0);
 if (isClass (_cfg >> "UK3CB_B_Osprey_USMC_WD") && {getNumber (_cfg >> "UK3CB_B_Osprey_USMC_WD" >> "scope")==2}) then {_osprey="UK3CB_B_Osprey_USMC_WD";};
};
createHashMapFromArray [["drone",if (_uavs isEqualTo []) then {""} else {configName (_uavs select 0)}],["osprey",_osprey],["specialist",if (_specialists isEqualTo []) then {""} else {configName (_specialists select 0)}]]
