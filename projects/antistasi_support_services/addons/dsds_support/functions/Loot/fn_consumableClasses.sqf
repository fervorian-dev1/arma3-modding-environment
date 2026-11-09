private _classes=["DSDS_Marijuana","DSDS_NicotineVape","DSDS_Cocaine","DSDS_Zyn"];
{private _name=configName _x;if (isClass (configFile >> "CfgWeapons" >> _name) && {getNumber (_x >> "duration")>0}) then {_classes pushBack _name;};} forEach ("true" configClasses (configFile >> "DSDS_Effects"));
_classes
