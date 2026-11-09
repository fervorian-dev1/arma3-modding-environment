if (missionNamespace getVariable ["DSDS_nuclearInitialized",false]) exitWith {};
DSDS_nuclearInitialized=true;
if (isServer) then {
 DSDS_nuclearBlastCount=0;
 DSDS_nuclearMines=missionNamespace getVariable ["DSDS_nuclearMines",createHashMap];
 addMissionEventHandler ["HandleDisconnect",{params ["_unit"];if (_unit==missionNamespace getVariable ["DSDS_nuclearWearer",objNull]) then {_unit setVariable ["DSDS_nuclearVest",false,true];DSDS_nuclearWearer=objNull;private _prop=missionNamespace getVariable ["DSDS_nuclearChest",objNull];if (!isNull _prop) then {deleteVehicle _prop;};DSDS_nuclearChest=objNull;};false}];
 addMissionEventHandler ["EntityKilled",{params ["_unit"];if (_unit getVariable ["DSDS_nuclearVest",false]) then {[_unit] call DSDS_fnc_nuclearDetonateVest;};}];
 [] spawn {while {true} do {{if (typeOf _x=="DSDS_NuclearIED_Ammo") then {[_x] call DSDS_fnc_nuclearIEDInit;};} forEach allMines;[] call DSDS_fnc_nuclearTick;sleep 0.25;};};
};
if (hasInterface) then {[] spawn {while {true} do {{if (local _x && {typeOf _x=="DSDS_NuclearIED_Ammo"}) then {[_x] call DSDS_fnc_nuclearIEDInit;};} forEach allMines;[] call DSDS_fnc_nuclearClientTick;sleep 0.5;};};};
