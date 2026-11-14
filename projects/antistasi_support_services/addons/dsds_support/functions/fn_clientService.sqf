if (isRemoteExecuted && {isMultiplayer} && {remoteExecutedOwner != 2}) exitWith {};
if (!hasInterface) exitWith {};
params ["_operation",["_data",[]]];
switch (_operation) do {
    case "FENCE_ALERT": {
        hint format ["The Fence is open for business at grid %1. Look for his medical tent (map marker: The Fence).",_data param [0,""]];
        systemChat format ["The Fence: new location, grid %1.",_data param [0,""]];
    };
    case "FENCE_QUOTE": {
        private _display=findDisplay 88410;
        if (!isNull _display) then {
            _display setVariable ["DSDS_sellQuote",_data];
            (_display displayCtrl 1713) ctrlSetText format ["Confirm selling ALL crate contents: %1 credits",_data param [0,0]];
        };
    };
    case "WALLET": {
        // Never write money on the client: wait for the server's public variable.
        _data params ["_holder","_balance","_sequence"];
        if (isNull _holder) exitWith {};
        if (_sequence <= (_holder getVariable ["DSDS_walletReceipt",0])) exitWith {};
        _holder setVariable ["DSDS_walletReceipt",_sequence];
        [_holder,_balance,_sequence] spawn {
            params ["_holder","_balance","_sequence"];
            private _deadline = diag_tickTime + 2;
            waitUntil {sleep 0.05; isNull _holder || {_holder getVariable ["moneyX",-1] == _balance} || {diag_tickTime > _deadline}};
            if (isNull _holder || {_holder getVariable ["DSDS_walletReceipt",0] != _sequence}) exitWith {};
            if (!isNil "A3A_fnc_statistics") then {[] spawn A3A_fnc_statistics;};
        };
    };
    case "MESSAGE": {
        hint (_data param [0,""]);
        private _display = findDisplay 88400;
        if (!isNull _display && {(_display getVariable ["DSDS_mode",""]) == "DEALER"}) then {
            _display setVariable ["DSDS_quote",[]];
            (_display displayCtrl 1712) ctrlSetText "Get offer";
        };
        if (!isNil "A3A_fnc_statistics") then {[] spawn A3A_fnc_statistics;};
    };
    case "SOLD": {
        closeDialog 0;
        hint format ["Vehicle sold for %1 personal credits. Any cargo was added to the Antistasi arsenal.",_data param [0,0]];
        if (!isNil "A3A_fnc_statistics") then {[] spawn A3A_fnc_statistics;};
    };
    case "ISSUE": {
        if ("DSDS_SupportTerminal" in assignedItems player) exitWith {};
        private _gps = (getUnitLoadout player select 9) param [1,""];
        if (_gps != "") exitWith {hint "Stow your current GPS/UAV terminal, then speak to Petros again. Your existing equipment has been kept.";};
        if (!("DSDS_SupportTerminal" in items player)) then {player linkItem "DSDS_SupportTerminal";} else {player assignItem "DSDS_SupportTerminal";};
        hint "Support Terminal equipped. Use Open Support Terminal in your action menu.";
    };
    case "QUOTE": {
        _data params ["_vehicle","_price"];
        private _display = findDisplay 88400;
        if (isNull _display) exitWith {};
        private _vehicles = _display getVariable ["DSDS_vehicles",[]];
        private _index = lbCurSel (_display displayCtrl 1750);
        if (_index < 0 || {_index >= count _vehicles} || {(_vehicles select _index) != _vehicle}) exitWith {};
        _display setVariable ["DSDS_quote",[_vehicle,_price]];
        (_display displayCtrl 1751) ctrlSetText format ["Offer: %1 credits",_price];
        (_display displayCtrl 1701) ctrlSetText "Confirm sale to accept. Occupants and attached cargo must be unloaded. Cargo goes directly to the Antistasi arsenal. Sale cannot be undone.";
        (_display displayCtrl 1712) ctrlSetText "Confirm vehicle sale";
    };
};
