params ["_uid"];
private _p=DSDS_luckyPlayers getOrDefault [_uid,createHashMap];
if (count _p==0) then {_p=createHashMapFromArray [["tokens",0],["cars",0],["items",[]],["gummies",0],["met",false],["spin",[]],["result",-1],["message","One token, one spin. Try your luck, darling."]];DSDS_luckyPlayers set [_uid,_p];};
_p
