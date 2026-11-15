if (!isServer || {isNil "A3A_saveTarget"} || {isNil "A3A_fnc_setStatVariable"}) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if (!(_s getOrDefault ["loaded",false])) exitWith {false};
private _permanent=["DSDS_oswaldUnlocked"] call A3A_fnc_returnSavedStat;
if (_s getOrDefault ["oswaldUnlocked",false] || {!isNil "_permanent" && {_permanent isEqualTo true}}) then {_s set ["oswaldUnlocked",true];["DSDS_oswaldUnlocked",true] call A3A_fnc_setStatVariable;};
private _dead=_s getOrDefault ["dead",false];
private _data=[3,_s get "position",_s get "direction",_s get "lead",_s get "revealed",_s get "count",+(_s get "intros"),_s get "ready",_dead,if (_dead) then {((_s get "respawnAt")-serverTime) max 0} else {0},_s getOrDefault ["rewardState",""],_s getOrDefault ["rewardUID",""],_s getOrDefault ["nuclearUnlocked",false],_s getOrDefault ["oswaldUnlocked",false]];
["DSDS_mysticState",_data] call A3A_fnc_setStatVariable;
true
