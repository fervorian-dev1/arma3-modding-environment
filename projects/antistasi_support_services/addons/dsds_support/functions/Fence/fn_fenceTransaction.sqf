/* Atomic unscheduled entry: never trust prices, manifests or classnames from clients. */
params ["_operation","_player","_args"];
if (!isServer || {isNil "_dsdsAuthorizedPlayer"} || {_dsdsAuthorizedPlayer != _player}) exitWith {false};
private _npc=missionNamespace getVariable ["DSDS_fence",objNull];
private _message={params ["_text"];["MESSAGE",[_text]] remoteExecCall ["DSDS_fnc_clientService",_player];false};
if (isNull _npc || {!alive _npc} || {_player distance _npc > 6}) exitWith {["Speak to The Fence in person."] call _message};
private _uid=getPlayerUID _player;
// Test actors may use an explicit isolated key; the public handler still requires isPlayer.
if (_uid == "") then {_uid=_player getVariable ["DSDS_testUID",""];};
if (_uid == "") exitWith {false};
if (_player getVariable ["DSDS_fencePending",false]) exitWith {["Your previous delivery is still pending."] call _message};
private _box=[false] call DSDS_fnc_fenceCommunityCrate;
switch (_operation) do {
    case "STASH": {
        ["STASH",_player] call DSDS_fnc_queueCustomMission
    };
    case "BOX": {
        _box=[true] call DSDS_fnc_fenceCommunityCrate;
        if (isNull _box) exitWith {["No safe space for a trade crate. Nothing charged."] call _message};
        [format ["Community trade crate: grid %1, %2 m away. Everyone shares it; the first confirmed sale pays the seller.",mapGridPosition _box,round (_player distance _box)]] call _message;
        true
    };
    case "QUOTE"; case "SELL": {
        if (isNull _box || {!alive _box} || {_box distance2D _npc > 40} || {!isNull attachedTo _box} || {!isNull isVehicleCargo _box} || {!isNull ropeAttachedTo _box}) exitWith {["Place the community trade crate within 40 m of The Fence."] call _message};
        private _cargo=[_box] call DSDS_fnc_fenceCargoValue;
        _cargo params ["_value","_manifest","_unsupported"];
        if (_unsupported isNotEqualTo []) exitWith {["The Fence buys only registered custom valuables. Remove ordinary equipment, ammunition and containers from the trade crate before selling. Everything has been kept."] call _message};
        if (_manifest isEqualTo [] || {_value <= 0}) exitWith {["The community crate has no valuable contents. Another player may already have sold them."] call _message};
        if (_operation == "QUOTE") exitWith {
            private _quote=[_box,_value,_manifest,diag_tickTime+60,_box getVariable ["DSDS_tradeRevision",0]];
            _player setVariable ["DSDS_fenceQuote",_quote];
            ["FENCE_QUOTE",[_value]] remoteExecCall ["DSDS_fnc_clientService",_player];
            true
        };
        private _quote=_player getVariable ["DSDS_fenceQuote",[]];
        if (count _quote != 5 || {diag_tickTime > (_quote select 3)} || {_box != (_quote select 0)} || {_value != (_quote select 1)} || {_manifest isNotEqualTo (_quote select 2)} || {(_quote select 4)!=_box getVariable ["DSDS_tradeRevision",0]} || {_args isNotEqualTo [_value]}) exitWith { _player setVariable ["DSDS_fenceQuote",nil];["Contents changed or quote expired. Request a fresh quote."] call _message};
        if !([_player,_value] call DSDS_fnc_changeWallet) exitWith {["Wallet unavailable; goods retained."] call _message};
        clearWeaponCargoGlobal _box;clearMagazineCargoGlobal _box;clearItemCargoGlobal _box;clearBackpackCargoGlobal _box;
        _box setVariable ["DSDS_tradeRevision",1+(_box getVariable ["DSDS_tradeRevision",0]),true];
        _player setVariable ["DSDS_fenceQuote",nil];
        [_player,_manifest] call DSDS_fnc_mysticLead;
        [format ["Goods sold for %1 personal credits.",_value]] call _message;
        true
    };
    case "BUY": {
        _args params [["_generation",-1,[0]],["_index",-1,[0]]];
        if (_generation != DSDS_fenceGeneration || {_index < 0} || {_index != floor _index} || {_index >= count DSDS_fenceStock}) exitWith {["Stock changed. Close and reopen the menu."] call _message};
        private _offer=+(DSDS_fenceStock select _index);
        _offer params ["_kind","_class","_section","_price"];
        if (!isClass (configFile >> _section >> _class)) exitWith {["That asset is unavailable."] call _message};
        private _plane=_kind == "VEHICLE" && {_class isKindOf "Plane"} && {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 0};
        if (_plane && {vehicle _player != _player}) exitWith {["Leave your current vehicle before buying an airborne aircraft."] call _message};
        if (_kind == "GEAR" && {isNull _box || {_box distance2D _npc > 40} || {!alive _box} || {!isNull attachedTo _box} || {!isNull isVehicleCargo _box}}) exitWith {["Request and place the community crate nearby first. Gear is delivered into it."] call _message};
        private _holder=_player getVariable ["owner",_player];
        if !([_player,-_price] call DSDS_fnc_changeWallet) exitWith {[format ["You need %1 personal credits.",_price]] call _message};
        _player setVariable ["DSDS_fencePending",true];
        [_player,_holder,_offer,_box,getPosATL _npc,_uid,_holder getVariable ["moneyX",0]] spawn DSDS_fnc_fenceDelivery;
        true
    };
    default {false};
}
