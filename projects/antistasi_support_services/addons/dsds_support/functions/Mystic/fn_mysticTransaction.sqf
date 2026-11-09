/* Atomic server entry. Prices, counts, classes and reward progress are never client supplied. */
params ["_op","_actor",["_args",[]]];
if (!isServer || {isNil "_dsdsAuthorizedPlayer"} || {_dsdsAuthorizedPlayer!=_actor} || {isNull _actor} || {!alive _actor}) exitWith {false};
private _s=missionNamespace getVariable ["DSDS_mysticState",createHashMap];
private _message={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_mysticClient",_actor];false};
if (!(_s getOrDefault ["loaded",false])) exitWith {["Speak with me again in a moment."] call _message};
private _uid=getPlayerUID _actor;if (_uid=="") then {_uid=_actor getVariable ["DSDS_testUID",""];};
if (_uid=="") exitWith {false};
private _npc=missionNamespace getVariable [if (_op=="LEAD") then {"DSDS_fence"} else {"DSDS_mystic"},objNull];
if (isNull _npc || {!alive _npc} || {_actor distance _npc>6} || {!isNull objectParent _actor}) exitWith {["Speak to me in person."] call _message};
if (_op=="LEAD") exitWith {
 if (!(_s get "lead")) exitWith {false};
 if (_s get "revealed") exitWith {["Mystic is already marked on your map."] call _message};
 if (count (_s get "position")<2) exitWith {["My associate cannot be reached just now."] call _message};
 private _price=getNumber (configFile >> "DSDS_Mystic" >> "leadPrice");
 if !([_actor,-_price] call DSDS_fnc_changeWallet) exitWith {["The location costs 92,235 personal credits."] call _message};
 _s set ["revealed",true];[] call DSDS_fnc_mysticSave;[] call DSDS_fnc_mysticPublish;
 ["Mystic is marked on your map."] call _message;true
};
if (_op=="OPEN") exitWith {
 private _first=!(_uid in (_s get "intros"));
 if (_first) then {(_s get "intros") pushBack _uid;[] call DSDS_fnc_mysticSave;};
 ["OPEN",[_first]] remoteExecCall ["DSDS_fnc_mysticClient",_actor];true
};
if (_op=="STASH") exitWith {["ISOTOPE_STASH",_actor] call DSDS_fnc_queueCustomMission;};
if (_op=="REWARD") exitWith {[_actor] call DSDS_fnc_nuclearClaim;};
if (!(_op in ["BUY","OFFER"])) exitWith {false};
if ((_actor getVariable ["DSDS_mysticPending",""])!="") exitWith {["One exchange at a time."] call _message};
private _amount=1;private _price=0;private _class="DSDS_Oswald";
if (_op=="OFFER") then {
 _class="DSDS_IndustrialIsotopes";_amount=({ _x==_class } count items _actor) min (40-(_s get "count"));
};
if (_op=="OFFER" && {(_s get "offeringToken")!=""}) exitWith {["Another offering is being counted. Try again shortly."] call _message};
if (_amount<=0) exitWith {[if (_s get "count">=40) then {"Mystic: You have kept your word."} else {"Bring industrial isotopes with you."}] call _message};
if (_op=="BUY") then {
 private _offers="true" configClasses (configFile >> "DSDS_Mystic" >> "Trinkets");
 if (_s getOrDefault ["nuclearUnlocked",false]) then {_offers append ("true" configClasses (configFile >> "DSDS_Mystic" >> "Nuclear"));};
 private _index=_args param [0,-1,[0]];
 if (_index>=0 && {_index==floor _index} && {_index<count _offers}) then {_class=getText ((_offers select _index) >> "item");_price=getNumber ((_offers select _index) >> "price");} else {_price=-1;};
};
if (_price<0 || {!(_class in ["DSDS_Oswald","DSDS_NuclearIED_Mag"]) && {_op=="BUY"}}) exitWith {false};
if (_op=="BUY" && {!(_actor canAdd _class)}) exitWith {["Make room for the purchase first."] call _message};
private _holder=_actor getVariable ["owner",_actor];
if (_price>0 && {!([_actor,-_price] call DSDS_fnc_changeWallet)}) exitWith {["You do not have enough personal credits."] call _message};
DSDS_mysticSequence=(missionNamespace getVariable ["DSDS_mysticSequence",0])+1;
private _token=format ["%1:M:%2",netId _actor,DSDS_mysticSequence];
private _before={_x==_class} count (items _actor+assignedItems _actor+magazines _actor);
private _expiry=serverTime+12;
(_s get "trades") set [_token,[_op,_actor,_uid,_holder,_amount,_before,_expiry,false,_price,_holder getVariable ["moneyX",0],_class]];
_actor setVariable ["DSDS_mysticPending",_token,true];
if (_op=="OFFER") then {_s set ["offeringToken",_token];};
[_actor,_token,_op,_amount,_expiry,_class] remoteExecCall ["DSDS_fnc_mysticInventory",owner _actor];
true
