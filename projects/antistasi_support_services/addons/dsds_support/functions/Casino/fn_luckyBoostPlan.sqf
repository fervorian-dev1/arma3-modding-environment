/* Pure traction-assist plan: a forward impulse, never a permanent config/speed edit. */
params ["_maxKph","_forwardMps","_uphill","_mass","_dt","_throttle"];
if (_maxKph<=0 || {_mass<=0} || {_dt<=0} || {_throttle<=0} || {_forwardMps< -0.5}) exitWith {0};
private _cap=(_maxKph/3.6)*1.35;
private _accel=0.35*(5+9.81*(_uphill max 0));
private _delta=(_accel*(_dt min 0.05)*(_throttle min 1)) min ((_cap-_forwardMps) max 0);
_mass*_delta
