if (isNil "DSDS_nativeHQVehicleList") then {DSDS_nativeHQVehicleList=compile preprocessFileLineNumbers "\x\A3A\addons\scrt\UI\fn_ui_populateVehicleBox.sqf";};
private _list=_this call DSDS_nativeHQVehicleList;
_list select {(toLower (_x param [0,""]) find "dch18_ucg_")!=0}
