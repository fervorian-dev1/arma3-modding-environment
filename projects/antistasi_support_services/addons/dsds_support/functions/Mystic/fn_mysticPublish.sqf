if (!isServer) exitWith {};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if (count _s==0) exitWith {};
DSDS_mysticInfo=[_s get "lead",_s get "revealed",_s get "count",40,_s get "ready",_s getOrDefault ["rewardState",""],_s getOrDefault ["nuclearUnlocked",false]];
publicVariable "DSDS_mysticInfo";
if (_s get "revealed" && {count (_s get "position")>=2}) then {
 if (getMarkerColor "DSDS_Mystic"=="") then {createMarker ["DSDS_Mystic",_s get "position"];};
 "DSDS_Mystic" setMarkerPos (_s get "position");"DSDS_Mystic" setMarkerType "mil_unknown";"DSDS_Mystic" setMarkerColor "ColorCIV";"DSDS_Mystic" setMarkerText "Mystic";
};
