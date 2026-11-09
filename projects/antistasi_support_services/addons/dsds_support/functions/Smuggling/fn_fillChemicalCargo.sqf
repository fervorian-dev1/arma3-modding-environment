/* Installed, DLC-free CWP rewards. No injectors from our stimulant pool. */
params ["_truck"];
if (!isServer || {isRemoteExecuted} || {isNull _truck}) exitWith {[]};
private _manifest=[];
private _valid={params ["_section","_class"];private _cfg=configFile >> _section >> _class;isClass _cfg && {getNumber (_cfg >> "scope")==2} && {getText (_cfg >> "DLC")==""}};
private _masks=["G_CBRN_M50_Hood","G_CBRN_M04_Hood","G_CBRN_S10"] select {["CfgGlasses",_x] call _valid};
if (_masks isNotEqualTo []) then {for "_i" from 1 to 4 do {private _class=selectRandom _masks;_truck addItemCargoGlobal [_class,1];_manifest pushBack [_class,1];};};
{
 _x params ["_class","_minimum","_extra"];
 if (["CfgWeapons",_class] call _valid) then {private _n=_minimum+floor random (_extra+1);_truck addItemCargoGlobal [_class,_n];_manifest pushBack [_class,_n];};
} forEach [["CBRN_gasmaskFilter",6,4],["CBRN_DuctTape",2,2],["PHEN_ATNAA_Injector",3,3],["CBRN_sealant",1,1]];
_manifest
