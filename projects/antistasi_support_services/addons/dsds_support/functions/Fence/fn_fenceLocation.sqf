/* Road-adjacent dry, flat clearing. Never force a camp onto a fallback coordinate. */
private _found=[];
private _center=[worldSize/2,worldSize/2,0];
for "_attempt" from 1 to 180 do {
    private _seed=[random worldSize,random worldSize,0];
    private _roads=_seed nearRoads 650;
    if (_roads isNotEqualTo []) then {
        private _road=selectRandom _roads;
        private _pos=[getPosATL _road,18,85,12,0,0.12,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
        private _old=missionNamespace getVariable ["DSDS_fence",objNull];
        if (_pos distance2D [0,0,0] > 100 && {_pos select 0 < worldSize} && {_pos select 1 < worldSize} && {_pos distance2D _road < 100} && {_pos isFlatEmpty [10,-1,0.12,12,0,false,objNull] isNotEqualTo []} && {!isOnRoad _pos} && {allPlayers findIf {_x distance2D _pos < 400} < 0} && {isNull _old || {_old distance2D _pos > 1000}}) exitWith {_found=_pos;};
    };
};
_found
