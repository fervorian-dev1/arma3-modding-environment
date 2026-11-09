params ["_position",["_direction",0],["_loadout",[]]];
if (isRemoteExecuted && {isNil "_dsdsAuthorizedPlayer"}) exitWith {objNull};
if (!isServer || {isNil "teamPlayer"}) exitWith {objNull};
private _existing = missionNamespace getVariable ["DSDS_mechanic",objNull];
if (!isNull _existing && {alive _existing}) exitWith {_existing};
private _rifle = "";
{
    if (isClass (configFile >> "CfgWeapons" >> _x) && {[_x] call DSD_fnc_isSupplyAssetAllowed} && {([_x] call DSD_fnc_getSupplyMagazines) isNotEqualTo []}) exitWith {_rifle = _x;};
} forEach ["rhs_weap_m4a1_blockII","rhs_weap_m4a1","rhs_weap_ak105"];
if (_rifle == "") then {
    private _pools = [] call DSD_fnc_buildSupplyPools;
    private _modded = (_pools get "AssaultRifle") select {
        private _tag = getText (configFile >> "CfgWeapons" >> _x >> "dlc");
        _tag != "" && {getNumber (configFile >> "CfgMods" >> _tag >> "appId") == 0}
    };
    if (_modded isNotEqualTo []) then {_rifle = selectRandom _modded;};
};
if (_rifle == "") exitWith {diag_log "[DSDS] No valid DLC-free mod rifle found for PMC mechanic."; objNull};
// createUnit may use the inherited vehicle side. Always join the actual HQ side.
private _petros = missionNamespace getVariable ["petros",objNull];
private _side = if (!isNull _petros) then {side group _petros} else {teamPlayer};
private _group = createGroup [_side,true];
private _npc = _group createUnit ["DSDS_MechanicNPC",_position,[],0,"NONE"];
if (isNull _npc) exitWith {deleteGroup _group; objNull};
[_npc] joinSilent _group;
_npc setDir _direction;
removeAllWeapons _npc; removeAllItems _npc; removeAllAssignedItems _npc;
removeUniform _npc; removeVest _npc; removeHeadgear _npc; removeBackpack _npc;
_npc forceAddUniform "DSDS_MechanicUniform";
_npc addVest "V_TacVest_blk";
_npc addHeadgear "H_Cap_blk";
_npc addGoggles "G_Shades_Black";
private _magazines = [_rifle] call DSD_fnc_getSupplyMagazines;
for "_i" from 1 to 5 do {_npc addMagazine (_magazines select 0);};
_npc addWeapon _rifle;
if (_loadout isNotEqualTo []) then {
    private _savedWeapon = (_loadout param [0,[]]) param [0,""];
    // A removed weapon mod must not leave a restored dealer defenseless.
    if (isClass (configFile >> "CfgWeapons" >> _savedWeapon) && {[_savedWeapon] call DSD_fnc_isSupplyAssetAllowed}) then {_npc setUnitLoadout _loadout;};
};
_npc setName ["PMC Mechanic","PMC","Mechanic"];
_npc setSkill 0.85;
_npc setUnitPos "UP";
_group setBehaviourStrong "AWARE";
_group setCombatMode "GREEN";
_npc disableAI "PATH";
_npc setVariable ["spawner",false];
_npc setVariable ["DSDS_isMechanic",true,true];
[_npc,"FIXED"] call DSDS_fnc_configureAddonAI;
_npc addEventHandler ["Killed",{[] call DSDS_fnc_persistMechanic;}];
DSDS_mechanic = _npc;
_npc setPosATL _position;
publicVariable "DSDS_mechanic";
{_x addCuratorEditableObjects [[_npc],true];} forEach allCurators;
_npc
