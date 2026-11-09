params ["_unit",["_now",serverTime]];
private _result=createHashMapFromArray [["active",false],["aim",1],["move",1],["sprint",1],["regen",1],["cap",1],["recoil",1],["carry",1],["unlimited",false],["calm",false],["crash",false]];
private _recoveryBoost=1;private _recoveryPenalty=1;
{
    private _cfg=configFile >> "DSDS_Effects" >> _x;
    _y params ["_end","_crashEnd"];
    if (_crashEnd>_now) then {
        _result set ["active",true];
        if (_end>_now) then {
            {_result set [_x,(_result get _x)*getNumber (_cfg >> _x)];} forEach ["aim","move","recoil"];
            {_result set [_x,(_result get _x) max getNumber (_cfg >> _x)];} forEach ["carry","sprint"];
            _recoveryBoost=_recoveryBoost max getNumber (_cfg >> "regen");
            _result set ["cap",(_result get "cap") min getNumber (_cfg >> "cap")];
            if (getNumber (_cfg >> "unlimited")>0) then {_result set ["unlimited",true];};
            if (getNumber (_cfg >> "calm")>0) then {_result set ["calm",true];};
        } else {
            _result set ["crash",true];
            {_x params ["_key","_field"];_result set [_key,(_result get _key)*getNumber (_cfg >> _field)];} forEach [["aim","crashAim"],["move","crashMove"]];
            _recoveryPenalty=_recoveryPenalty*getNumber (_cfg >> "crashRegen");
            _result set ["cap",(_result get "cap") min getNumber (_cfg >> "crashCap")];
        };
    };
} forEach (_unit getVariable ["DSDS_stimEffects",createHashMap]);
_result set ["regen",_recoveryBoost*_recoveryPenalty];
_result
