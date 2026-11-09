/* Fictional gameplay toxicity. Only a server-confirmed consumed narcotic adds a dose. */
params ["_unit","_class",["_now",serverTime]];
if (!isServer || {isNull _unit} || {!alive _unit} || {isRemoteExecuted && {isNil "_dsdsLootAuthorized"}}) exitWith {""};
private _cfg=configFile >> "DSDS_Consumables";
private _weight=switch (_class) do {case "DSDS_Marijuana": {getNumber (_cfg >> "marijuanaDose")};case "DSDS_Cocaine": {getNumber (_cfg >> "cocaineDose")};default {getNumber (configFile >> "DSDS_Effects" >> _class >> "toxicity")};};
if (_weight<=0) exitWith {""};
private _window=getNumber (_cfg >> "doseWindow");
private _doses=(_unit getVariable ["DSDS_lootDoses",[]]) select {(_x select 0)>_now-_window && {(_x select 0)<=_now}};
_doses pushBack [_now,_weight,_class];
_unit setVariable ["DSDS_lootDoses",_doses];
private _load=0;{_load=_load+(_x select 1);} forEach _doses;
private _hasCocaine=_doses findIf {(_x select 2)=="DSDS_Cocaine" || {getNumber (configFile >> "DSDS_Effects" >> (_x select 2) >> "dangerous")>0}}>=0;
private _over=+(_unit getVariable ["DSDS_lootOverdose",[0,0]]);
if (_hasCocaine && {_load>=getNumber (_cfg >> "overdoseThreshold")}) exitWith {
    _over set [0,(_over select 0) max (_now+getNumber (_cfg >> "sicknessDuration"))];
    // Extra doses cannot postpone an already pending overdose.
    if ((_over select 1)<=0) then {_over set [1,_now+getNumber (_cfg >> "overdoseDelay")];};
    _unit setVariable ["DSDS_lootOverdose",_over,true];
    "You took too much. Something is very wrong."
};
if (!_hasCocaine && {_load>=getNumber (_cfg >> "sicknessThreshold")}) exitWith {
    _over set [0,(_over select 0) max (_now+getNumber (_cfg >> "sicknessDuration"))];
    _unit setVariable ["DSDS_lootOverdose",_over,true];
    "You feel sick and unsteady."
};
if (_load>=getNumber (_cfg >> "warningThreshold")) exitWith {"Your heart is racing. You should stop."};
""
