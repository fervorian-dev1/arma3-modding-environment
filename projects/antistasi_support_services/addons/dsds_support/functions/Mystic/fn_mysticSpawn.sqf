params ["_position","_direction"];
if (!isServer || {isRemoteExecuted} || {count _position<2} || {surfaceIsWater _position}) exitWith {objNull};
private _group=createGroup [civilian,true];
private _npc=_group createUnit ["DSDS_MysticNPC",_position,[],0,"NONE"];
if (isNull _npc) exitWith {deleteGroup _group;objNull};
_npc setDir _direction;_npc setName "Mystic";_npc allowFleeing 0;
removeAllWeapons _npc;removeAllAssignedItems _npc;
{_npc disableAI _x;} forEach ["MOVE","PATH","FSM"];
[_npc,"FIXED"] call DSDS_fnc_configureAddonAI;
_npc setVariable ["DSDS_mystic",true,true];
DSDS_mystic=_npc;publicVariable "DSDS_mystic";
_npc
