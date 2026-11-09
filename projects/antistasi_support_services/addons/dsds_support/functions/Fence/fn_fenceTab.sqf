disableSerialization;
params [["_tab","VEHICLES"]];
private _display=findDisplay 88410;
if (isNull _display) exitWith {};
_display setVariable ["DSDS_tab",_tab];
private _control=_display displayCtrl 1750;
lbClear _control;
private _rows=[_display getVariable ["DSDS_stock",[]],_tab] call DSDS_fnc_fenceOffersForTab;
{
    _x params ["_original","_offer"];
    _offer params ["_kind","_class","_section","_price",["_role",""]];
    private _index=_control lbAdd format ["%1%2 - %3 credits",if (_role=="") then {""} else {"["+_role+"] "},getText (configFile >> _section >> _class >> "displayName"),_price];
    _control lbSetValue [_index,_original];
} forEach _rows;
_control lbSetCurSel 0;
(_display displayCtrl 1701) ctrlSetText ((if (_tab=="VEHICLES") then {"Six varied vehicles. Boats go directly to personal garage storage. Fixed-wing purchases start airborne with you piloting. AA is available in Items only."} else {"Ten mostly modded items: drones, terminals and AA launchers. Purchases go into the community crate. AA packages include five missiles."})+" Shared crate sales pay the first player to confirm. Custom valuables only.");
(_display displayCtrl 1714) ctrlSetText (if (_tab=="VEHICLES") then {"Vehicles (selected)"} else {"Vehicles"});
(_display displayCtrl 1715) ctrlSetText (if (_tab=="ITEMS") then {"Items (selected)"} else {"Items"});
