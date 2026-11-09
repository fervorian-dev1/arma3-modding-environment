[] spawn {
 sleep 3;private _passes=0;private _failures=0;
 private _assert={params ["_ok","_label"];if (_ok) then {_passes=_passes+1;} else {_failures=_failures+1;};diag_log format ["[CONTACT TEST] %1: %2",["FAIL","PASS"] select _ok,_label];};
 // Standalone fixture only. Match the hostile relationship established by a real campaign.
 east setFriend [resistance,0];resistance setFriend [east,0];
 private _targets=createGroup resistance;private _target=_targets createUnit ["I_G_Soldier_F",[14000,16000,0],[],0,"NONE"];_target disableAI "ALL";_target allowDamage false;
 private _group=createGroup east;private _unit=_group createUnit ["O_Soldier_F",[13400,16000,0],[],0,"NONE"];
 [_group,"CONTACT",[_target]] remoteExecCall ["DSDS_fnc_convoyLocal",2];
 private _deadline=diag_tickTime+10;
 waitUntil {sleep 0.2;((_group knowsAbout _target)>0 && {(waypoints _group findIf {waypointType _x=="SAD"})>=0}) || {diag_tickTime>_deadline}};
 diag_log format ["[CONTACT TEST] Native state: knowledge %1, current %2, waypoints %3",_group knowsAbout _target,currentWaypoint _group,(waypoints _group) apply {waypointType _x}];
 [(_group knowsAbout _target)>0,"server RPC supplies real target knowledge to a hostile AI group"] call _assert;
 [(waypoints _group findIf {waypointType _x=="SAD"})>=0,"server RPC issues a real hunt waypoint without assuming other AI mods keep it current forever"] call _assert;
 private _pilots=createGroup east;private _pilot=_pilots createUnit ["O_Helipilot_F",[13200,16000,0],[],0,"NONE"];
 _pilots setVariable ["DSDS_noContactRetask",true];_pilots setVariable ["lambs_danger_disableGroupAI",true];
 private _route=_pilots addWaypoint [[13200,18000,0],0];_route setWaypointType "MOVE";_pilots setCurrentWaypoint _route;
 [_pilots,"CONTACT",[_target]] remoteExecCall ["DSDS_fnc_convoyLocal",2];sleep 1;
 [(_pilots knowsAbout _target)>0,"protected flight crew still receive contact information"] call _assert;
 [(waypoints _pilots findIf {waypointType _x=="SAD"})<0 && {waypointType _route=="MOVE"},"shared contacts cannot hijack response pilots' landing or orbit routes"] call _assert;
 {deleteVehicle _x;} forEach [_target,_unit,_pilot];{deleteGroup _x;} forEach [_targets,_group,_pilots];
 diag_log format ["[CONTACT TEST] COMPLETE: %1 PASS, %2 FAIL",_passes,_failures];
};
