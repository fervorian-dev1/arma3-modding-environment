params [["_first",false]];
if (!hasInterface || {missionNamespace getVariable ["DSDS_mysticOpening",false]}) exitWith {};
private _npc=missionNamespace getVariable ["DSDS_mystic",objNull];
if (isNull _npc || {!alive _npc} || {!alive player} || {player distance _npc>6}) exitWith {};
DSDS_mysticOpening=true;
if (_first) then {
 private _camera="camera" camCreate (_npc modelToWorld [2,2,1.7]);
 _camera cameraEffect ["INTERNAL","BACK"];
 _camera camSetTarget (_npc modelToWorld [0,0,1.5]);_camera camSetFov 0.65;_camera camCommit 0;
 _camera camSetPos (_npc modelToWorld [0.6,1.9,1.6]);_camera camSetFov 0.4;_camera camCommit 4;
 "DSDS_MysticIntro" cutText ["Mystic: Forty consignments of industrial isotopes. Bring them a little at a time. Something exceptional will be yours.","PLAIN DOWN",0.5];
 private _until=diag_tickTime+4.5;
 waitUntil {sleep 0.05;diag_tickTime>_until || {!alive player} || {isNull _npc} || {!alive _npc} || {player distance _npc>8} || {visibleMap}};
 _camera cameraEffect ["TERMINATE","BACK"];camDestroy _camera;
 "DSDS_MysticIntro" cutText ["","PLAIN",0.2];
};
if (alive player && {!isNull _npc} && {alive _npc} && {player distance _npc<=6}) then {
 disableSerialization;
 if (createDialog "DSDS_MysticDialog") then {
  private _display=findDisplay 88430;private _offers=_display displayCtrl 1832;
  private _stock="true" configClasses (configFile >> "DSDS_Mystic" >> "Trinkets");
  if ((missionNamespace getVariable ["DSDS_mysticInfo",[]]) param [6,false]) then {_stock append ("true" configClasses (configFile >> "DSDS_Mystic" >> "Nuclear"));};
  {private _class=getText (_x >> "item");private _row=_offers lbAdd getText (configFile >> (if (_class=="DSDS_NuclearIED_Mag") then {"CfgMagazines"} else {"CfgWeapons"}) >> _class >> "displayName");_offers lbSetValue [_row,_forEachIndex];} forEach _stock;
  _offers lbSetCurSel 0;[] call DSDS_fnc_mysticRefresh;
 };
};
DSDS_mysticOpening=false;
