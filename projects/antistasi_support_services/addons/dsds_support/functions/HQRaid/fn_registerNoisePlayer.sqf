params ["_unit"];
if (isNull _unit || {!local _unit} || {_unit getVariable ["DSDS_noiseEHInstalled",false]}) exitWith {};
_unit setVariable ["DSDS_noiseEHInstalled",true];
_unit addEventHandler ["FiredMan",{_this call DSDS_fnc_noiseFired;}];
