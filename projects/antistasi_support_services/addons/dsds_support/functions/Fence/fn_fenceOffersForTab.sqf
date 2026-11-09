/* Preserve authoritative catalogue indices when the client filters rows. */
params ["_stock",["_tab","VEHICLES"]];
private _rows=[];
{
    if (((_x select 0)=="VEHICLE") isEqualTo (_tab=="VEHICLES")) then {_rows pushBack [_forEachIndex,_x];};
} forEach _stock;
_rows
