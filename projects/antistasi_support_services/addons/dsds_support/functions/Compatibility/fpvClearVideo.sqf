/* Prevent signal-noise postprocessing, retaining the native camera/telemetry. */
if (hasInterface && {!isNil "DB_fnc_fpv_ppfx_stop"}) then {call DB_fnc_fpv_ppfx_stop;};
DB_fpv_ppfx_input=1;DB_fpv_ppfx_prevQ=1;DB_fpv_ppfx_active=false;
