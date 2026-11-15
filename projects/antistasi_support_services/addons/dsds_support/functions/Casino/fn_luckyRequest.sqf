/* Called only inside casinoRequest's authenticated player/dealer scope. */
params ["_op","_actor","_dealer","_args"];
if (!isServer || {isNil "_dsdsAuthorizedPlayer"} || {_dsdsAuthorizedPlayer!=_actor} || {isNil "DSDS_luckyPlayers"}) exitWith {};
private _uid=getPlayerUID _actor;private _p=[_uid] call DSDS_fnc_luckyProfile;
if (_op=="OPEN") exitWith {
 if (!alive _dealer) exitWith {};
 // Refresh on every opening: older campaigns retain the original introduction in their saved message.
 _p set ["met",true];_p set ["message","Roxie: Sweetheart, I have ex-boyfriends all over the occupying army. Kill one of them and I might give you a token as a thank-you. Bring your tokens back to me and take a spin. Finally, a relationship that pays off."];[] call DSDS_fnc_luckySave;
 [_actor,true] call DSDS_fnc_luckySync;
};
if (_op=="READ") exitWith {if (serverTime>=(_actor getVariable ["DSDS_luckyReadAt",0])) then {_actor setVariable ["DSDS_luckyReadAt",serverTime+0.5];[_actor] call DSDS_fnc_luckySync;};};
if (!alive _dealer || {!(_op in ["SPIN","BUY_GUMMIES","CLAIM_CAR","CLAIM_ITEM"])} || {(_args param [0,"",[""]])!=(_p getOrDefault ["nonce",""])} || {_p getOrDefault ["nonce",""]==""}) exitWith {};
DSDS_casinoSequence=DSDS_casinoSequence+1;_p set ["nonce",format ["lucky:%1:%2",_uid,DSDS_casinoSequence]];
private _message="";
switch (_op) do {
 case "SPIN": {
  if ((_p get "spin") isNotEqualTo []) exitWith {};
  if (_p get "tokens"<1) exitWith {_message="Roxie: No token, no teasing the wheel, sweetheart.";};
  _p set ["tokens",(_p get "tokens")-1];_p set ["spin",[serverTime,serverTime+7]];_p set ["message","Roxie: Round and round. Rather like my love life."];
 };
 case "BUY_GUMMIES": {
  if (_p get "gummies">=50) exitWith {_message="Collect your candy first, darling.";};
  if !([_actor,-150] call DSDS_fnc_changeWallet) exitWith {_message="The gummy bears cost 150 personal credits.";};
  private _holder=_actor getVariable ["owner",_actor];["player_"+_uid+"_moneyX",_holder getVariable ["moneyX",0]] call A3A_fnc_setStatVariable;
  _p set ["gummies",(_p get "gummies")+1];DSDS_luckyQueue pushBack [_uid,"ITEM"];
  _message="Your gummy bears will be in Roxie's collection crate outside the casino.";
 };
 case "CLAIM_CAR": {
  if (_p get "cars"<1) exitWith {_message="No Hellcat waiting for you yet.";};
  if !(_p getOrDefault ["delivery",false]) then {_p set ["delivery",true];DSDS_luckyQueue pushBack [_uid,"CAR"];};
 };
 case "CLAIM_ITEM": {if !(_p getOrDefault ["delivery",false]) then {_p set ["delivery",true];DSDS_luckyQueue pushBack [_uid,"ITEM"];};};
};
if (_message!="") then {_p set ["message",_message];};[] call DSDS_fnc_luckySave;[_actor] call DSDS_fnc_luckySync;
