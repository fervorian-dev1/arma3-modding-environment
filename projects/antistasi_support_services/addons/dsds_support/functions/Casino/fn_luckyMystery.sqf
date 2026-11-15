/* Supply pools already validated DLC/classes at discovery. Reuse them; never rebuild
   the catalogue or repeat expensive mod-source queries inside the casino worker. */
if (!isServer || {isRemoteExecuted}) exitWith {[]};
if (isNil "jna_dataList") exitWith {[]};
private _pools=missionNamespace getVariable ["DSD_supplyPools",createHashMap];if (count _pools==0) exitWith {[]};
private _candidates=[];private _unlimited=createHashMap;
{{if ((_x param [1,0])==-1) then {_unlimited set [_x select 0,true];};} forEach _x;} forEach jna_dataList;
{{_unlimited set [_x,true];} forEach (missionNamespace getVariable [_x,[]]);} forEach ["unlockedItems","unlockedWeapons","unlockedMagazines","unlockedOptics","unlockedBackpacks","unlockedVests","unlockedUniforms","unlockedHeadgear","unlockedNVGs","unlockedGPS","unlockedMisc"];
{
 private _section=if (_x=="Backpack") then {"CfgVehicles"} else {"CfgWeapons"};
 {if (!(_unlimited getOrDefault [_x,false]) && {(toUpper _x find "DSDS_")!=0} && {isClass (configFile >> _section >> _x)}) then {_candidates pushBackUnique [_section,_x];};} forEach (_pools getOrDefault [_x,[]]);
} forEach ["AssaultRifle","SubmachineGun","SniperRifle","MachineGun","Handgun","Attachment","Optic","Suppressor","Medical","Backpack","Uniform","Vest"];
if (_candidates isEqualTo []) exitWith {[]};selectRandom _candidates
