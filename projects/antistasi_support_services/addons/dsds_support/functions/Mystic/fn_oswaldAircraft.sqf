/* Watch slot only; carrying the artifact or controlling a UAV remotely is insufficient. */
params [["_players",allPlayers]];
private _aircraft=[];
{if (!isNull _x && {alive _x} && {"DSDS_Oswald" in assignedItems _x}) then {private _vehicle=objectParent _x;if (!isNull _vehicle && {_vehicle isKindOf "Air"} && {!(_vehicle isKindOf "ParachuteBase")}) then {_aircraft pushBackUnique _vehicle;};};} forEach _players;
_aircraft
