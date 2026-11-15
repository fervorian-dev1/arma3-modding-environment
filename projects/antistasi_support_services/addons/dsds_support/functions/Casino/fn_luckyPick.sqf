params [["_roll",-1]];
if (_roll<0) then {_roll=random 10000;};
private _rows="true" configClasses (configFile >> "DSDS_LuckyWheel" >> "Rewards");
private _limit=0;private _found=count _rows-1;
{_limit=_limit+getNumber (_x >> "weight");if (_roll<_limit) exitWith {_found=_forEachIndex;};} forEach _rows;
_found
