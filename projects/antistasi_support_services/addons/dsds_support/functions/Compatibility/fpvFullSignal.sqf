/* ArmaFPV-only signal adapter; no inventory, battery or damage changes. */
params ["_operator","_uav"];
if (isNull _operator || {isNull _uav} || {!alive _uav}) exitWith {0};
{_uav setVariable [_x select 0,_x select 1];} forEach [["DB_fpv_signalMaxDistance",1e12],["DB_fpv_signalObstacles",0],["DB_fpv_signalTerrainMask",0],["DB_fpv_inJammer",false],["DB_fpv_jammerFactor",0],["DB_fpv_jammerLowTime",0],["DB_fpv_isUAVsignalLost",false]];
1
