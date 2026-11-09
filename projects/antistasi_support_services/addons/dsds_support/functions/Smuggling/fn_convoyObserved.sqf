/* Native Antistasi AIVehInit callback passes the real objective context; no mission override. */
params ["_truck","_side","_task",["_nativeType","Ammunition"],["_petrosKind",""]];
if (!isServer) exitWith {};
private _sender=if (isRemoteExecuted) then {remoteExecutedOwner} else {2};
if (!(_sender in ([2]+(missionNamespace getVariable ["hcArray",[]]))) || {isNull _truck} || {!(_truck isKindOf "LandVehicle")} || {!(_nativeType in ["Ammunition","Fuel","Repair","Supplies","Money","Armor","Prisoners","Reinforcements"])} || {(_task find "CONVOY")!=0} || {_truck getVariable ["DSDS_convoyConsidered",false]}) exitWith {};
if (!isNil "teamPlayer" && {_side==teamPlayer}) exitWith {};
_truck setVariable ["DSDS_convoyConsidered",true,true];
_truck setVariable ["DSDS_objectiveNativeType",_nativeType];
DSDS_objectiveTrackQueue pushBack [_truck,_task];
DSDS_nativeDefenseQueue pushBack [_truck,_side,_task,serverTime+20];
private _cfg=configFile >> "DSDS_Smuggling";
// Petros's balanced rotation bypasses the separate rare ambient-convoy cooldown.
// Clients/HCs cannot force this designation through the public callback.
if (!isRemoteExecuted && {_truck getVariable ["DSDS_petrosConvoy",false]}) exitWith {
 if (_petrosKind in ["SPECIAL","MEDICAL","ISOTOPE"]) then {DSDS_convoyUpgrades pushBack [_truck,_side,_task,_petrosKind,serverTime+15];};
 diag_log format ["[DSDS Convoy] Petros objective %1 selected %2.",_task,if (_petrosKind=="") then {"STANDARD"} else {_petrosKind}];
};
if (serverTime<(missionNamespace getVariable ["DSDS_nextRareConvoy",0])) exitWith {};
private _roll=random 1;private _mode="";
if (_nativeType in ["Ammunition","Fuel","Repair"] && {_roll<getNumber (_cfg >> "specialChance")}) then {_mode="SPECIAL";};
if (_nativeType=="Supplies" && {_roll<getNumber (_cfg >> "isotopeChance")} && {!isNil "CBRN_fnc_spawnMist"} && {[typeOf _truck,_side] call DSDS_fnc_isConvoyCargoTruck}) then {_mode="ISOTOPE";};
if (_mode=="" && {_nativeType=="Supplies"} && {_roll<0.18} && {[typeOf _truck,_side] call DSDS_fnc_isConvoyCargoTruck}) then {_mode="MEDICAL";};
if (_mode=="") exitWith {};
DSDS_nextRareConvoy=serverTime+getNumber (_cfg >> "convoyCooldown");
DSDS_convoyUpgrades pushBack [_truck,_side,_task,_mode,serverTime+15];
