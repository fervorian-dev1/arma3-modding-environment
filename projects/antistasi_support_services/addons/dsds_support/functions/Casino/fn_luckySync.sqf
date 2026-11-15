params ["_actor",["_open",false],["_earned",false]];
if (isNull _actor || {!isPlayer _actor}) exitWith {};
private _p=[getPlayerUID _actor] call DSDS_fnc_luckyProfile;
if (_p getOrDefault ["nonce",""]=="") then {DSDS_casinoSequence=DSDS_casinoSequence+1;_p set ["nonce",format ["lucky:%1:%2",getPlayerUID _actor,DSDS_casinoSequence]];};
private _dealer=(missionNamespace getVariable ["DSDS_casinoDealers",[]]) select {(_x select 0)=="WHEEL"};
private _npc=if (_dealer isEqualTo []) then {objNull} else {(_dealer select 0) select 1};
private _holder=_actor getVariable ["owner",_actor];
["LUCKY",[_npc,_p get "tokens",_p get "cars",count (_p get "items"),_p get "gummies",_p get "spin",_p get "result",_p get "message",_p get "nonce",_holder getVariable ["moneyX",0],_open,_earned]] remoteExecCall ["DSDS_fnc_casinoClient",_actor];
