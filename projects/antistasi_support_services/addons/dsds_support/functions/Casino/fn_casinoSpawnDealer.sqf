params ["_game","_pos","_direction",["_index",0],["_group",grpNull]];
if (!isServer || {isRemoteExecuted}) exitWith {objNull};
private _faces=["B_female_bun_01","B_female_bun_02","B_female_bun_03","B_female_bun_04"] select {isClass (configFile >> "CfgFaces" >> "Man_A3" >> _x)};
if (_faces isEqualTo []) exitWith {objNull};
if (isNull _group) then {_group=createGroup [civilian,true];};
// Timberwolf supplies heads only. Civilian polo bodies provide shirts and trousers.
private _body=["C_man_polo_1_F","C_man_polo_2_F"] select (_index mod 2);
private _npc=_group createUnit [_body,_pos,[],0,"NONE"];
if (isNull _npc) exitWith {if (units _group isEqualTo []) then {deleteGroup _group;};objNull};
_npc setPosATL _pos;_npc setDir _direction;removeAllWeapons _npc;removeAllAssignedItems _npc;removeVest _npc;removeBackpack _npc;removeHeadgear _npc;removeGoggles _npc;
_npc setVariable ["BIS_enableRandomization",false,true];
_npc forceAddUniform (["U_C_Poloshirt_blue","U_C_Poloshirt_stripped"] select (_index mod 2));
_npc setSpeaker "NoVoice";_npc disableAI "RADIOPROTOCOL";_npc setVariable ["BIS_noCoreConversations",true,true];
_npc setName getText (configFile >> "DSDS_Casino" >> "Games" >> _game >> "dealer");
private _face=if (_game=="WHEEL") then {"B_female_bun_04"} else {_faces select (_index mod count _faces)};_npc setFace _face;_npc setVariable ["DSDS_casinoFace",_face,true];
{_npc disableAI _x;} forEach ["MOVE","PATH","FSM","TARGET","AUTOTARGET"];
_npc setBehaviour "CARELESS";_npc allowFleeing 0;_npc enableDynamicSimulation false;_npc setVariable ["DSDS_casinoGame",_game,true];
[_npc,"FIXED"] call DSDS_fnc_configureAddonAI;_npc
