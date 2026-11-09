/* Physical incapacity, deliberately independent of Antistasi's potentially stale flag. */
params ["_unit"];
if (isNull _unit || {!alive _unit}) exitWith {true};
private _anim=toLower animationState _unit;
lifeState _unit in ["INCAPACITATED","UNCONSCIOUS"] || {_unit getVariable ["ACE_isUnconscious",false]} || {(_anim find "unconscious")==0 && {(_anim find "unconsciousout")!=0}} || {_unit getVariable ["dam_ignore_injured0",false] && {(_anim find "pir_creep")==0 || {(_anim find "pir_medic_uncondition")==0} || {(_anim find "apanppne")==0}}}
