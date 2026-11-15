disableSerialization;
params ["_d","_spin","_result","_tokens"];
private _height=safeZoneH*.43;private _width=_height*pixelW/pixelH;private _left=safeZoneX+safeZoneW*.27-_width/2;
(_d displayCtrl 2210) ctrlSetPosition [_left,safeZoneY+safeZoneH*.25,_width,_height];(_d displayCtrl 2210) ctrlCommit 0;
(_d displayCtrl 2211) ctrlSetPosition [safeZoneX+safeZoneW*.245,safeZoneY+safeZoneH*.21,safeZoneW*.05,safeZoneH*.04];(_d displayCtrl 2211) ctrlCommit 0;
private _angle=0;private _settling=false;
if (_spin isNotEqualTo []) then {
 private _t=(serverTime-(_spin select 0)) max 0;_angle=630*_t-25*(_t min 7)^2;
 _d setVariable ["DSDS_wheelLastAngle",_angle];_d setVariable ["DSDS_wheelWasSpinning",true];_d setVariable ["DSDS_wheelEnd",[]];
} else {
 if (_result>=0) then {
  private _end=_d getVariable ["DSDS_wheelEnd",[]];
  if (_end isEqualTo []) then {
   private _rows="true" configClasses (configFile >> "DSDS_LuckyWheel" >> "Rewards");private _sum=0;for "_i" from 0 to (_result-1) do {_sum=_sum+getNumber ((_rows select _i) >> "weight");};
   private _target=270-((_sum+getNumber ((_rows select _result) >> "weight")/2)*.036);
   private _start=_d getVariable ["DSDS_wheelLastAngle",0];private _finish=_target+360*ceil ((_start+180-_target)/360);
   private _duration=if (_d getVariable ["DSDS_wheelWasSpinning",false]) then {2.5} else {.001};_end=[diag_tickTime,_start,_finish,_duration];_d setVariable ["DSDS_wheelEnd",_end];
  };
  private _u=((diag_tickTime-(_end select 0))/(_end select 3)) min 1;
  _angle=(_end select 1)+((_end select 2)-(_end select 1))*(1-(1-_u)^3);_settling=_u<1;
 };
};
(_d displayCtrl 2210) ctrlSetAngle [_angle mod 360,.5,.5];
if (_settling) then {(_d displayCtrl 2203) ctrlEnable false;};
