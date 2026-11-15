/* Visual presentation only. Bets, pockets and credits remain server-authoritative. */
disableSerialization;
params ["_d","_s"];
private _phase=_s select 3;private _id=_s select 1;private _number=_s param [15,-1];
private _busy=!(_phase in ["idle","finished"]);
private _wx=safeZoneX+safeZoneW*.145;private _wy=safeZoneY+safeZoneH*.25;
private _h=safeZoneH*.35;private _w=_h*pixelW/pixelH;
if (isNull (_d displayCtrl 2400)) then {
 (_d displayCtrl 1902) ctrlShow false;
 private _info=_d displayCtrl 1910;_info ctrlSetPosition [safeZoneX+safeZoneW*.14,safeZoneY+safeZoneH*.61,safeZoneW*.72,safeZoneH*.055];_info ctrlCommit 0;
 private _wheel=_d ctrlCreate ["RscPicture",2400];_wheel ctrlSetText "\dsds_support\ui\roulette_wheel_ca.paa";_wheel ctrlSetPosition [_wx,_wy,_w,_h];_wheel ctrlCommit 0;
 private _buttons=[];private _left=safeZoneX+safeZoneW*.39;private _top=safeZoneY+safeZoneH*.26;private _cw=safeZoneW*.035;private _ch=safeZoneH*.06;
 private _add={
  params ["_label","_choice","_rect","_color"];
  private _c=_d ctrlCreate ["RscButton",2410+count _buttons];_c ctrlSetText _label;_c ctrlSetPosition _rect;_c ctrlCommit 0;_c ctrlSetBackgroundColor _color;_c ctrlSetFontHeight (safeZoneH*.022);
  _c setVariable ["DSDS_choice",_choice];_c ctrlAddEventHandler ["ButtonClick",{
   params ["_c"];private _combo=(ctrlParent _c) displayCtrl 1904;private _choice=_c getVariable "DSDS_choice";
   for "_i" from 0 to (lbSize _combo-1) do {if ((_combo lbData _i)==_choice) exitWith {_combo lbSetCurSel _i;};};
  }];_buttons pushBack _c;
 };
 ["0","N:0",[_left,_top,_cw,_ch*3],[.02,.3,.12,1]] call _add;
 for "_col" from 0 to 11 do {for "_row" from 0 to 2 do {
  private _n=_col*3+3-_row;private _red=_n in [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
  [str _n,format ["N:%1",_n],[_left+(_col+1)*_cw,_top+_row*_ch,_cw,_ch],if (_red) then {[.5,.04,.06,1]} else {[.025,.03,.03,1]}] call _add;
 };};
 {[_x select 0,_x select 1,[_left+_cw+_forEachIndex*4*_cw,_top+3*_ch,4*_cw,_ch],[.02,.22,.12,1]] call _add;} forEach [["1 - 12","DOZEN1"],["13 - 24","DOZEN2"],["25 - 36","DOZEN3"]];
 {[_x select 0,_x select 1,[_left+_cw+_forEachIndex*2*_cw,_top+4*_ch,2*_cw,_ch],[.02,.22,.12,1]] call _add;} forEach [["1 - 18","LOW"],["EVEN","EVEN"],["RED","RED"],["BLACK","BLACK"],["ODD","ODD"],["19 - 36","HIGH"]];
 {[_x select 0,_x select 1,[_left+_cw+_forEachIndex*4*_cw,_top+5*_ch,4*_cw,_ch*.65],[.02,.22,.12,1]] call _add;} forEach [["COLUMN 1","COLUMN1"],["COLUMN 2","COLUMN2"],["COLUMN 3","COLUMN3"]];
 _d setVariable ["DSDS_rouletteButtons",_buttons];
 private _ball=_d ctrlCreate ["RscPicture",2401];_ball ctrlSetText "\dsds_support\ui\roulette_ball_ca.paa";
 private _chip=_d ctrlCreate ["RscPicture",2402];_chip ctrlSetText "\dsds_support\ui\roulette_chip_ca.paa";
 (_d displayCtrl 1905) ctrlSetText "Spin";
};
private _t=(serverTime-(_s select 11)) max 0;
private _angle=if (_busy) then {420*_t-15*(_t min 8)^2} else {0};
private _ballAngle=if (_busy) then {-90-560*_t+22*(_t min 8)^2} else {-90};
private _radius=.435;private _settling=false;
private _order=[0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26];
if (_phase=="finished" && {_number>=0}) then {
 private _end=_d getVariable ["DSDS_rouletteEnd",[]];
 if (_end isEqualTo [] || {(_end select 0)!=_id}) then {
  private _old=_d getVariable ["DSDS_rouletteMotion",[0,-90]];
  private _wheelEnd=(_old select 0)+180;private _target=_wheelEnd-90+(_order find _number)*360/37;
  private _ballEnd=_target+360*floor (((_old select 1)-_target)/360)-360;
  private _animate=(_d getVariable ["DSDS_rouletteWasSpinning",false]);
  _end=[_id,diag_tickTime,if (_animate) then {_old select 0} else {_wheelEnd},if (_animate) then {_old select 1} else {_ballEnd},_wheelEnd,_ballEnd,if (_animate) then {2.4} else {0.001}];_d setVariable ["DSDS_rouletteEnd",_end];
 };
 private _u=((diag_tickTime-(_end select 1))/(_end select 6)) min 1;private _ease=1-(1-_u)^3;
 _angle=(_end select 2)+((_end select 4)-(_end select 2))*_ease;_ballAngle=(_end select 3)+((_end select 5)-(_end select 3))*_ease;
 _radius=.435-(.435-.35)*_ease+.012*sin(_u*1080)*(1-_u);_settling=_u<1;
};
_d setVariable ["DSDS_rouletteWasSpinning",_busy];_d setVariable ["DSDS_rouletteMotion",[_angle,_ballAngle]];
(_d displayCtrl 2400) ctrlSetAngle [_angle mod 360,.5,.5];
private _bh=_h*.035;private _bw=_w*.035;private _ball=_d displayCtrl 2401;
_ball ctrlSetPosition [_wx+_w*(.5+_radius*cos _ballAngle)-_bw/2,_wy+_h*(.5+_radius*sin _ballAngle)-_bh/2,_bw,_bh];_ball ctrlCommit 0;
private _combo=_d displayCtrl 1904;private _choice=if (_busy || {_settling}) then {_s param [16,""]} else {_combo lbData lbCurSel _combo};
private _key=[_choice,_busy || _settling];
if ((_d getVariable ["DSDS_rouletteSelection",[]]) isNotEqualTo _key) then {
 _d setVariable ["DSDS_rouletteSelection",_key];private _chip=_d displayCtrl 2402;_chip ctrlShow false;
 {
  _x ctrlEnable (!_busy && {!_settling});
  if ((_x getVariable "DSDS_choice")==_choice) then {private _p=ctrlPosition _x;_chip ctrlSetPosition [(_p select 0)+(_p select 2)*.63,(_p select 1)+(_p select 3)*.35,_bw*1.7,_bh*1.7];_chip ctrlCommit 0;_chip ctrlShow true;};
 } forEach (_d getVariable ["DSDS_rouletteButtons",[]]);
};
if (_settling) then {(_d displayCtrl 1905) ctrlEnable false;(_d displayCtrl 1903) ctrlEnable false;_combo ctrlEnable false;};
