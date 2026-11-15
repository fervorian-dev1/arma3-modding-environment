/* Engine-only server event. Never exposed through RemoteExec. */
params ["_victim","_killer",["_instigator",objNull],["_roll",-1]];
if (!isServer || {isRemoteExecuted} || {isNil "DSDS_luckyPlayers"} || {isNull _victim} || {alive _victim} || {!(_victim isKindOf "CAManBase")} || {_victim getVariable ["DSDS_luckyKillCounted",false]}) exitWith {false};
_victim setVariable ["DSDS_luckyKillCounted",true];
if (isNull _instigator && {!isNull _killer}) then {_instigator=(UAVControl vehicle _killer) param [0,objNull];};
if (isNull _instigator) then {_instigator=if (isPlayer _killer) then {_killer} else {if (!isNull _killer && {_killer isKindOf "LandVehicle"}) then {driver _killer} else {objNull}};};
private _rebels=missionNamespace getVariable ["teamPlayer",resistance];private _side=side group _victim;
if (isNull _instigator || {!isPlayer _instigator} || {side group _instigator!=_rebels} || {_victim==_instigator} || {!(_side in [missionNamespace getVariable ["Occupants",west],missionNamespace getVariable ["Invaders",east]])} || {_side==_rebels} || {_side getFriend _rebels>=0.6} || {getPlayerUID _instigator==""}) exitWith {false};
if !(_roll isEqualType 0) then {_roll=-1;};
if (_roll<0) then {_roll=random 1;};
if (_roll>=getNumber (configFile >> "DSDS_LuckyWheel" >> "tokenChance")) exitWith {false};
private _p=[getPlayerUID _instigator] call DSDS_fnc_luckyProfile;_p set ["tokens",(_p get "tokens")+1];[] call DSDS_fnc_luckySave;
[_instigator,false,true] call DSDS_fnc_luckySync;true
