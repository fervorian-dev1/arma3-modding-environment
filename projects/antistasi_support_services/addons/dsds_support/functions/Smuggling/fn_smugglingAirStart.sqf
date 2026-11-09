params ["_target","_bearing",["_distance",3200],["_height",220]];
private _result=[];
for "_try" from 0 to 15 do {
 private _position=_target getPos [_distance,_bearing+_try*47.5];
 if ((_position select 0)>50 && {(_position select 1)>50} && {(_position select 0)<worldSize-50} && {(_position select 1)<worldSize-50} && {(allPlayers findIf {alive _x && {_x distance2D _position<1000}})<0}) exitWith {_position set [2,_height];_result=_position;};
};
_result
