/* 0 healthy, 1 PiR forced crawl, 2 unconscious/incapacitated. Ordinary prone is healthy. */
params ["_unit"];
if (isNull _unit || {!alive _unit}) exitWith {0};
if (_unit getVariable ["incapacitated",false] || {_unit getVariable ["ACE_isUnconscious",false]} || {lifeState _unit in ["INCAPACITATED","UNCONSCIOUS"]}) exitWith {2};
private _anim=toLower animationState _unit;
private _pir=_unit getVariable ["dam_ignore_injured0",false];
if (_pir && {(_anim find "unconscious")==0 || {(_anim find "pir_medic_uncondition")==0}}) exitWith {2};
if (_pir && {(_anim find "pir_creep")==0 || {(_anim find "apanppne")==0} || {_unit getVariable ["dam_player_Crawl0",false]}}) exitWith {1};
0
