if (!hasInterface || {isNull player}) exitWith {};
if (!(player getVariable ["DSDS_nuclearAction",false])) then {
 player setVariable ["DSDS_nuclearAction",true];
 player addAction ["Touch off chest device",{[player] remoteExecCall ["DSDS_fnc_nuclearRequest",2];},nil,1.5,false,true,"","alive _this && {_this getVariable ['DSDS_nuclearVest',false]}"];
};
