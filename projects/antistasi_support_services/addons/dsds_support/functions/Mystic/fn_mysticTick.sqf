params [["_now",serverTime]];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
if (!(_s getOrDefault ["loaded",false])) exitWith {};
private _npc=missionNamespace getVariable ["DSDS_mystic",objNull];
if (count (_s get "position")==0 && {_now>=(_s getOrDefault ["locateAfter",0])}) then {
 _s set ["locateAfter",_now+60];_s set ["position",[] call DSDS_fnc_mysticLocation];
 if (count (_s get "position")>0) then {[] call DSDS_fnc_mysticSave;} else {diag_log "[DSDS Mystic] No suitable private site; retrying later.";};
};
if (_s get "spawned" && {isNull _npc || {!alive _npc}} && {!(_s get "dead")}) then {
 _s set ["dead",true];_s set ["respawnAt",_now+getNumber (configFile >> "DSDS_Mystic" >> "respawnDelay")];
 if (!isNull _npc) then {(_s get "corpses") pushBack _npc;};
 [] call DSDS_fnc_mysticSave;
};
if (count (_s get "position")>0 && {isNull _npc || {!alive _npc}} && {!(_s get "dead") || {_now>=(_s get "respawnAt")}}) then {
 private _new=[_s get "position",_s get "direction"] call DSDS_fnc_mysticSpawn;
 if (!isNull _new) then {_s set ["spawned",true];_s set ["dead",false];_s set ["respawnAt",0];[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;};
};
{private _body=_x;if (!isNull _body && {(allPlayers findIf {_x distance2D _body<100})<0}) then {private _group=group _body;deleteVehicle _body;if (count units _group==0) then {deleteGroup _group;};};} forEach (_s get "corpses");
_s set ["corpses",(_s get "corpses") select {!isNull _x}];
{if (serverTime>(_y select 6) && {!(_y select 7)}) then {[_x,false] spawn DSDS_fnc_mysticFinishTrade;};} forEach (_s get "trades");
if (_now>=(_s getOrDefault ["saveAfter",0])) then {_s set ["saveAfter",_now+30];[] call DSDS_fnc_mysticSave;};
