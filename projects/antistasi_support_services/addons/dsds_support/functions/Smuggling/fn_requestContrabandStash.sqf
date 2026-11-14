/* Scheduled server worker, reached through the non-remote request dispatcher. */
params ["_player",["_requested",[]],["_debug",false],["_variant","STASH"]];
if (!isServer || {isRemoteExecuted} || {isNull _player} || {!alive _player}) exitWith {DSDS_stashPending=false;};
private _industrial=_variant=="INDUSTRIAL";
private _title=if (_industrial) then {"Industrial Isotopes Stash"} else {"Contraband Stash"};
private _message={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_player];};
private _old=missionNamespace getVariable ["DSDS_activeStash",createHashMap];
[_old] call DSDS_fnc_cleanupContrabandStash;
if (count _old>0 && {!(_old get "complete")}) exitWith {[format ["The active stash is marked at grid %1.",mapGridPosition (_old get "box")]] call _message;DSDS_stashPending=false;};
if (!_debug && {serverTime<(missionNamespace getVariable ["DSDS_nextStash",0])}) exitWith {[if (_industrial) then {"No fresh isotope lead yet."} else {"No fresh contraband lead yet."}] call _message;DSDS_stashPending=false;};
private _faction=[] call DSDS_fnc_smugglingFaction;
if (count _faction==0) exitWith {["No suitable guards are available for this lead."] call _message;DSDS_stashPending=false;diag_log "[DSDS Stash] No valid faction infantry.";};
private _roads=if (_debug) then {_requested nearRoads 700} else {(_player nearRoads 6500) select {_x distance2D _player>1800}};
if (!_debug && {!isNil "respawnTeamPlayer"}) then {private _hq=markerPos respawnTeamPlayer;_roads=_roads select {_x distance2D _hq>1200};};
private _position=[];
for "_try" from 1 to 80 do {
 if (_roads isEqualTo []) exitWith {};
 private _road=selectRandom _roads;
 private _pos=[getPosATL _road,20,110,4,0,0.35,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
 if (_pos distance2D [0,0,0]>100 && {!surfaceIsWater _pos} && {!isOnRoad _pos} && {_debug || {(allPlayers findIf {_x distance2D _pos<900})<0}} && {([_pos] call DSD_fnc_validateDropPosition) isNotEqualTo []}) exitWith {_position=_pos;};
};
if (_position isEqualTo []) exitWith {["No safe roadside stash location was found. Try again elsewhere."] call _message;DSDS_stashPending=false;diag_log "[DSDS Stash] Position search failed.";};
DSDS_smugglingSequence=(missionNamespace getVariable ["DSDS_smugglingSequence",0])+1;
private _id=format ["DSDS_STASH_%1",DSDS_smugglingSequence];
private _box=[_position] call DSDS_fnc_createStashContainer;
if (isNull _box) exitWith {DSDS_stashPending=false;["The stash container could not be created. Nothing charged."] call _message;};
if (_industrial) then {
 private _item=configFile >> "CfgWeapons" >> "DSDS_IndustrialIsotopes";
 if (isClass _item) then {private _count=(floor ((maxLoad _box)/((getNumber (_item >> "ItemInfo" >> "mass")) max 1))) min 68;_box addItemCargoGlobal ["DSDS_IndustrialIsotopes",_count max 1];};
} else {
 {_box addItemCargoGlobal [_x,7];} forEach ["DSDS_Marijuana","DSDS_Cocaine","DSDS_Methamphetamine","DSDS_NicotineVape","DSDS_Zyn"];
 [_box,15,"STASH"] call DSDS_fnc_fillLootContainer;
};
private _units=[];private _groups=[];private _names=[];
for "_squad" from 0 to 2 do {
 private _group=createGroup [_faction get "side",true];_groups pushBack _group;
 private _name=[] call DSDS_fnc_generateGuardName;_group setGroupIdGlobal [_name];_names pushBack _name;
 for "_i" from 1 to (4+floor random 3) do {
  private _pos=[_position,15,75,2,0,0.4,0,[],[_position,_position]] call BIS_fnc_findSafePos;
  private _unit=[_group,selectRandom (_faction get "troops"),_pos,0.85] call DSDS_fnc_smugglingUnit;
  if (!isNull _unit) then {_units pushBack _unit;};
 };
 [_group,_position,100] call BIS_fnc_taskPatrol;_group setBehaviourStrong "AWARE";
};
if (count _units<8) exitWith {{deleteVehicle _x;} forEach _units;{deleteGroup _x;} forEach _groups;deleteVehicle _box;DSDS_stashPending=false;["The lead fell through; no mission was created."] call _message;};
private _marker=createMarker [_id,_position];_marker setMarkerType "mil_unknown";_marker setMarkerColor "ColorOrange";_marker setMarkerText _title;
private _description=format ["Recover %1 concealed among discarded bags or supplies. High-skill guard squads: %2.",if (_industrial) then {"industrial isotopes"} else {"contraband"},_names joinString ", "];
[[missionNamespace getVariable ["teamPlayer",resistance],civilian],_id,[_description,_title,_id],_position,false,0,true,"box",true] call BIS_fnc_taskCreate;
// Keep cleared but still stocked older locations under cleanup until emptied.
if (count _old>0 && {!(_old getOrDefault ["removed",false])}) then {
 private _retired=missionNamespace getVariable ["DSDS_retiredStashes",[]];
 _retired pushBack _old;DSDS_retiredStashes=_retired;
};
DSDS_activeStash=createHashMapFromArray [["title",_title],["id",_id],["box",_box],["units",_units],["groups",_groups],["names",_names],["marker",_marker],["complete",false],["debug",_debug]];
if (!_debug) then {DSDS_nextStash=serverTime+getNumber (configFile >> "DSDS_Smuggling" >> "stashCooldown");};
DSDS_stashPending=false;
diag_log format ["[DSDS Stash] %1 at %2: %3 guards, groups %4, container %5.",_id,_position,count _units,_names,typeOf _box];
[format ["%1 mission marked at grid %2. Guards: %3.",_title,mapGridPosition _position,_names joinString ", "]] call _message;
