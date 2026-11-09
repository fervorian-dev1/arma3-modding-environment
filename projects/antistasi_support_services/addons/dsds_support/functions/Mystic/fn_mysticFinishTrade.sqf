params ["_token",["_ok",false]];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsMysticFinishAuthorized" || {!_dsdsMysticFinishAuthorized}}}) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
private _trades=_s getOrDefault ["trades",createHashMap];private _entry=_trades getOrDefault [_token,[]];
if (count _entry==0 || {_entry select 7}) exitWith {false};
_entry set [7,true];_entry params ["_op","_actor","_uid","_holder","_amount","_before","_expiry","_processing","_price",["_balanceAfter",0],["_deliveryClass","DSDS_Oswald"]];
private _class=if (_op=="BUY") then {_deliveryClass} else {"DSDS_IndustrialIsotopes"};
private _proof={if (isNull _actor) exitWith {false};private _after={_x==_class} count (items _actor+assignedItems _actor+magazines _actor);if (_op=="BUY") then {_after>=_before+1} else {_after<=_before-_amount}};
private _deadline=diag_tickTime+4;
if (_ok) then {waitUntil {sleep 0.05;call _proof || {diag_tickTime>_deadline} || {isNull _actor}};};
private _success=call _proof;
if (_op=="OFFER") then {_success=_success && _ok && {(_s get "offeringToken")==_token};};
if (_success && {_op=="OFFER"}) then {
 _s set ["count",((_s get "count")+_amount) min 40];_s set ["ready",_s get "count">=40];
 [] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;
 ["MESSAGE",[if (_s get "ready") then {"Mystic: You have kept your word."} else {format ["Mystic: %1 of forty. I remember every one.",_s get "count"]}]] remoteExecCall ["DSDS_fnc_mysticClient",_actor];
};
if (!_success) then {
 if (_price>0) then {
  if (!isNull _holder) then {_holder setVariable ["moneyX",(_holder getVariable ["moneyX",0])+_price,true];} else {
   if (!isNil "A3A_playerSaveData") then {private _data=A3A_playerSaveData getOrDefault [_uid,createHashMap];_data set ["moneyX",(_data getOrDefault ["moneyX",_balanceAfter])+_price];A3A_playerSaveData set [_uid,_data];};
  };
 };
 if (!isNull _actor) then {[_actor,_token,"ROLLBACK",_amount,0] remoteExecCall ["DSDS_fnc_mysticInventory",owner _actor];["MESSAGE",["The exchange could not be completed. Anything taken is being returned."]] remoteExecCall ["DSDS_fnc_mysticClient",_actor];};
};
if (!isNull _actor) then {_actor setVariable ["DSDS_mysticPending","",true];};
if ((_s get "offeringToken")==_token) then {_s set ["offeringToken",""];};
_trades deleteAt _token;
_success
