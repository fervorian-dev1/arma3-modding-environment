// Terrain-following climb envelope. Reads terrain only; never changes map state.
params ["_position","_bearing",["_speed",400]];
private _config = configFile >> "DSDS_StrikeFlight";
private _clearance = 60 max getNumber (_config >> "terrainClearance");
private _lookAhead = 1000 max getNumber (_config >> "lookAhead");
// Over water, maintain clearance above the sea surface, never the seabed.
private _height = (0 max getTerrainHeightASL _position) + _clearance;
for "_distance" from 250 to _lookAhead step 250 do {
    private _point = _position getPos [_distance,_bearing];
    // Plan at 60 m/s climb; the controller permits 90 m/s to retain margin.
    private _required = (0 max getTerrainHeightASL _point) + _clearance - (_distance / (1 max _speed)) * 60;
    _height = _height max _required;
};
_height
