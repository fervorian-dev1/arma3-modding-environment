if (!hasInterface) exitWith {};
disableSerialization;
private _display=findDisplay 88430;
if (isNull _display || {_display getVariable ["DSDS_stockRefresh",false]}) exitWith {};
private _info=missionNamespace getVariable ["DSDS_mysticInfo",[false,false,0,40,false]];
(_display displayCtrl 1834) ctrlSetText format ["%1 / 40",_info select 2];
private _stock="true" configClasses (configFile >> "DSDS_Mystic" >> "Trinkets");if (_info param [6,false]) then {_stock append ("true" configClasses (configFile >> "DSDS_Mystic" >> "Nuclear"));};private _list=_display displayCtrl 1832;private _row=lbCurSel _list;
if (lbSize _list!=count _stock) then {
 _display setVariable ["DSDS_stockRefresh",true];
 lbClear _list;
 {private _class=getText (_x >> "item");private _root=if (_class=="DSDS_NuclearIED_Mag") then {"CfgMagazines"} else {"CfgWeapons"};private _i=_list lbAdd getText (configFile >> _root >> _class >> "displayName");_list lbSetValue [_i,_forEachIndex];} forEach _stock;
 _row=(_row max 0) min ((count _stock)-1);_list lbSetCurSel _row;_display setVariable ["DSDS_stockRefresh",false];
};
if (_row>=0) then {
 private _index=_list lbValue _row;
 if (_index<count _stock) then {private _cfg=_stock select _index;(_display displayCtrl 1833) ctrlSetText format ["%1",getNumber (_cfg >> "price")];(_display displayCtrl 1831) ctrlSetText getText (configFile >> (if (getText (_cfg >> "item")=="DSDS_NuclearIED_Mag") then {"CfgMagazines"} else {"CfgWeapons"}) >> getText (_cfg >> "item") >> "picture");};
};
(_display displayCtrl 1835) ctrlEnable ((_info select 2)<40 && {"DSDS_IndustrialIsotopes" in items player} && {player getVariable ["DSDS_mysticPending",""]==""});
(_display displayCtrl 1833) ctrlEnable (player getVariable ["DSDS_mysticPending",""]=="");

(_display displayCtrl 1836) ctrlShow ((_info select 4) && {(_info param [5,""])==""});
(_display displayCtrl 1836) ctrlEnable (player getVariable ["DSDS_mysticPending",""]=="");
