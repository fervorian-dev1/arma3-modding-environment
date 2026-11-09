/* Native campaign-qualified storage; normal Antistasi saves flush this additional key. */
if (!isServer || {isNil "A3A_saveTarget"} || {isNil "A3A_fnc_setStatVariable"}) exitWith {false};
private _npc = missionNamespace getVariable ["DSDS_mechanic",objNull];
private _state = [1,false];
if (!isNull _npc && {alive _npc}) then {
    _state = [1,true,getPosATL _npc,getDir _npc,getUnitLoadout _npc];
};
["DSDS_mechanicState",_state] call A3A_fnc_setStatVariable;
true
