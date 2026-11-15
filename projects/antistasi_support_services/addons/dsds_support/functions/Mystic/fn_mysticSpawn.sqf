params ["_position","_direction"];
if (!isServer || {isRemoteExecuted} || {count _position<2} || {surfaceIsWater _position}) exitWith {objNull};
private _safe=+_position;_safe set [2,0];
if ((_safe isFlatEmpty [1,-1,0.3,3,0,false,objNull]) isEqualTo [] || {(nearestObjects [_safe,["House","LandVehicle"],2]) isNotEqualTo []}) then {
 _safe=[_safe,0,25,2,0,0.3,0,[],[[],[]]] call BIS_fnc_findSafePos;
};
if (count _safe<2 || {surfaceIsWater _safe}) exitWith {objNull};
_position=_safe;
private _group=createGroup [civilian,true];
private _npc=_group createUnit ["DSDS_MysticNPC",_position,[],0,"NONE"];
if (isNull _npc) exitWith {deleteGroup _group;objNull};
_npc setPosATL [_position select 0,_position select 1,0];
_npc hideObjectGlobal false;_npc enableSimulationGlobal true;_npc enableDynamicSimulation false;
_npc setDir _direction;_npc setName "Mystic";_npc allowFleeing 0;
removeAllWeapons _npc;removeAllAssignedItems _npc;
{_npc disableAI _x;} forEach ["MOVE","PATH","FSM"];
[_npc,"FIXED"] call DSDS_fnc_configureAddonAI;
_npc setVariable ["DSDS_mystic",true,true];
DSDS_mystic=_npc;publicVariable "DSDS_mystic";
_npc
