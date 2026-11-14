/* First held airbase establishes the baseline; every extra halves request prices. */
private _held=0;
if (!isNil "sidesX" && {!isNull sidesX} && {!isNil "teamPlayer"}) then {
 private _airbases=(missionNamespace getVariable ["airportsX",[]]) arrayIntersect (missionNamespace getVariable ["airportsX",[]]);
 _held={sidesX getVariable [_x,sideUnknown]==teamPlayer} count _airbases;
};
private _factor=0.5^((_held-1) max 0);
("true" configClasses (configFile >> "DSDS_SupportActions")) apply {
 [configName _x,getText (_x >> "label"),(round (getNumber (_x >> "cost")*_factor)) max 1,getNumber (_x >> "points")]
}
