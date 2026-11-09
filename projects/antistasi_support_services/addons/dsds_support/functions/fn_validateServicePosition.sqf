params [["_position",[],[[]]]];
if (count _position < 2 || {count _position > 3}) exitWith {[]};
if ((_position findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0) exitWith {[]};
if ((_position select 0) < 20 || {(_position select 1) < 20} || {(_position select 0) > worldSize-20} || {(_position select 1) > worldSize-20}) exitWith {[]};
[_position select 0,_position select 1,0]
