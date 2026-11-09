/* Accept ASL from ZEN, discard click height, return terrain ASL. Reject sea/outside map. */
params [["_position", [], [[]]]];
if (count _position < 2 || {count _position > 3}) exitWith {[]};
if ((_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1) exitWith {[]};
_position params ["_xPos", "_yPos"];
if (_xPos < 50 || {_yPos < 50} || {_xPos > worldSize - 50} || {_yPos > worldSize - 50}) exitWith {[]};
if (surfaceIsWater [_xPos, _yPos]) exitWith {[]};
[_xPos, _yPos, getTerrainHeightASL [_xPos, _yPos]]
