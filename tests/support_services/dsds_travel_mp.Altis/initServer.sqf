createMarker ["respawn_guerrila",[14000,16000,0]];
teamPlayer=resistance;publicVariable "teamPlayer";Occupants=west;Invaders=east;tierWar=1;publicVariable "tierWar";
DSDS_jobs=createHashMap;DSDS_jobSequence=0;
A3A_saveTarget=[false,"fixture48mp","Altis"];A3A_saveDataHM=createHashMap;A3A_saveData=createHashMap;
A3A_faction_reb=createHashMap;A3A_faction_occ=createHashMap;A3A_faction_inv=createHashMap;A3A_faction_civ=createHashMap;
HR_GRG_PoolBase=20;HR_GRG_PoolIncr=4;HR_GRG_VehCap={HR_GRG_PoolBase+tierWar*HR_GRG_PoolIncr};
private _lg=createGroup sideLogic;server=_lg createUnit ["Logic",[0,0,0],[],0,"NONE"];
flagX=createVehicle ["FlagPole_F",[14000,16000,0],[],0,"NONE"];vehicleBox=createVehicle ["Land_CargoBox_V1_F",[14003,16000,0],[],0,"NONE"];
{publicVariable _x;} forEach ["flagX","vehicleBox","server"];
serverInitDone=true;publicVariable "serverInitDone";
[] spawn {while {true} do {
 DSDS_testSequence=DSDS_jobSequence;DSDS_testJobState=(DSDS_jobs getOrDefault [str DSDS_jobSequence,createHashMap]) getOrDefault ["state",""];
 private _saved=["DSDS_extraGarageSlots"] call A3A_fnc_returnSavedStat;
 DSDS_testSavedSlots=if (isNil "_saved") then {-1} else {_saved};
 {publicVariable _x;} forEach ["DSDS_testSequence","DSDS_testJobState","DSDS_testSavedSlots"];
 sleep 0.2;
};};
