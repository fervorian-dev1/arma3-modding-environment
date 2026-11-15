[] spawn {sleep 3;
{
 private _cfg=configFile >> "CfgVehicles" >> _x;
 if (isClass _cfg) then {private _o=createVehicle [_x,[4000,4000,0],[],0,"NONE"];diag_log format ["[CASINO ASSET] %1 name=%2 positions=%3 box=%4 model=%5",_x,getText (_cfg >> "displayName"),count (_o buildingPos -1),boundingBoxReal _o,getText (_cfg >> "model")];deleteVehicle _o;} else {diag_log format ["[CASINO ASSET] MISSING %1",_x];};
} forEach ["Land_Hotel_02_F","Land_Hotel_01_F","Land_i_House_Big_02_V1_F","Land_Offices_01_V1_F","Land_Sofa_01_F","Land_ArmChair_01_F","Land_TableBig_01_F","Land_TableDesk_F","Land_RattanTable_01_F","Land_RattanChair_01_F","Land_FlowerPot_01_F","Land_FlowerPot_02_F"];
diag_log "[CASINO ASSET] DONE";};
