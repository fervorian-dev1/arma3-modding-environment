/* Client-only animated table/chart. Server snapshots remain the sole game authority. */
disableSerialization;
params ["_d","_s"];
private _game=_s select 0;private _id=_s select 1;private _phase=_s select 3;
private _finished=_phase=="finished";
if (isNull (_d displayCtrl 2500)) then {
 private _bg=_d ctrlCreate ["RscText",2500];_bg ctrlSetPosition [safeZoneX+safeZoneW*.14,safeZoneY+safeZoneH*.34,safeZoneW*.72,safeZoneH*.29];_bg ctrlSetBackgroundColor [.015,.12,.075,1];_bg ctrlCommit 0;
 private _info=_d displayCtrl 1910;_info ctrlSetPosition [safeZoneX+safeZoneW*.14,safeZoneY+safeZoneH*.635,safeZoneW*.72,safeZoneH*.035];_info ctrlCommit 0;
 if (_game=="BLACKJACK") then {
  {private _c=_d ctrlCreate ["RscStructuredText",2501+_forEachIndex];_c ctrlSetPosition [safeZoneX+safeZoneW*.16,safeZoneY+safeZoneH*(.34+.15*_forEachIndex),safeZoneW*.66,safeZoneH*.035];_c ctrlCommit 0;} forEach [0,1];
 } else {
  private _label=_d ctrlCreate ["RscStructuredText",2501];_label ctrlSetPosition [safeZoneX+safeZoneW*.16,safeZoneY+safeZoneH*.35,safeZoneW*.64,safeZoneH*.07];_label ctrlCommit 0;
  for "_i" from 0 to 59 do {private _c=_d ctrlCreate ["RscText",2600+_i];_c ctrlSetBackgroundColor [.85,.66,.2,.9];};
  private _tip=_d ctrlCreate ["RscText",2502];_tip ctrlSetText ">>";_tip ctrlSetFontHeight (safeZoneH*.045);_tip ctrlSetTextColor [1,.85,.4,1];
 };
};
if ((_d getVariable ["DSDS_visualRound",""])!=_id) then {
 if (_game=="BLACKJACK") then {{ctrlDelete (_x select 0);} forEach (_d getVariable ["DSDS_visualCards",[]]);_d setVariable ["DSDS_visualCards",[]];};
 _d setVariable ["DSDS_visualRound",_id];_d setVariable ["DSDS_visualFinishedAt",-1];
};
if (_finished && {(_d getVariable ["DSDS_visualFinishedAt",-1])<0}) then {_d setVariable ["DSDS_visualFinishedAt",diag_tickTime];_d setVariable ["DSDS_crashFinalTime",(serverTime-(_s select 11)) max 0];};
if (_game=="BLACKJACK") exitWith {
 private _hands=[+(_s select 8),+(_s select 7)];if (!_finished && {_phase!="idle"}) then {(_hands select 0) pushBack -1;};
 private _all=_d getVariable ["DSDS_visualCards",[]];
 {
  private _row=_forEachIndex;private _cards=_x;private _score=if (_cards isEqualTo []) then {""} else {str ([(_cards select {_x>=0})] call DSDS_fnc_casinoScore)};
  (_d displayCtrl (2501+_row)) ctrlSetStructuredText parseText format ["<t color='#ddc382'>%1  %2%3</t>",["DEALER","YOUR HAND"] select _row,_score,if (_row==0 && {!_finished} && {_phase!="idle"}) then {" + ?"} else {""}];
  {
   private _card=_x;private _index=_forEachIndex;private _key=_row*32+_index;private _found=_all findIf {(_x select 1)==_key};
   if (_found<0) then {
    private _c=_d ctrlCreate ["RscStructuredText",2700+_key];_all pushBack [_c,_key,_card,diag_tickTime+.10*(_index min 5),false];_found=count _all-1;
   };
   private _entry=_all select _found;_entry params ["_c","_unused","_old","_start","_flip"];
   if (_old!=_card) then {_start=diag_tickTime;_flip=true;_entry set [2,_card];_entry set [3,_start];_entry set [4,true];};
   private _u=((diag_tickTime-_start)/.45) max 0 min 1;private _ease=1-(1-_u)^3;
   private _cw=safeZoneW*.052;private _ch=safeZoneH*.105;private _spacing=(safeZoneW*.65/((count _cards) max 1)) min (safeZoneW*.065);
   private _xFinal=safeZoneX+safeZoneW*.16+_index*_spacing;private _yFinal=safeZoneY+safeZoneH*(.375+.15*_row);
   private _width=if (_flip) then {_cw*(abs(2*_u-1) max .04)} else {_cw};
   private _back=_card<0 || {_flip && {_u<.5}};
   _c ctrlSetBackgroundColor (if (_back) then {[.15,.06,.25,1]} else {[.94,.92,.85,1]});
   private _text="<t align='center' color='#ddbf72'>AURUM<br/>* * *</t>";
   if (!_back) then {private _rank=(_card mod 13)+1;private _suit=floor(_card/13) mod 4;_text=format ["<t align='center' size='1.15' color='%1'>%2<br/>%3</t>",if (_suit in [1,2]) then {"#b51f33"} else {"#151a19"},if (_rank==1) then {"A"} else {if (_rank>10) then {["J","Q","K"] select (_rank-11)} else {str _rank}},["♠","♥","♦","♣"] select _suit];};
   _c ctrlSetStructuredText parseText _text;
   private _xPos=if (_flip) then {_xFinal+(_cw-_width)/2} else {_xFinal+(1-_ease)*(safeZoneX+safeZoneW*.79-_xFinal)};
   private _yPos=if (_flip) then {_yFinal} else {_yFinal-(1-_ease)*safeZoneH*.045};
   _c ctrlSetPosition [_xPos,_yPos,_width,_ch];_c ctrlCommit 0;
  } forEach _cards;
 } forEach _hands;
 _d setVariable ["DSDS_visualCards",_all];
 (_d displayCtrl 1910) ctrlSetStructuredText parseText format ["<t color='#ddbf72'>%1</t>",_s select 6];
};
// Crash: rising exponential trace with animated marker and a red crash flash.
private _active=_phase=="playing";
private _elapsed=if (_finished) then {9*ln ((_s param [17,1]) max 1)} else {if (_active) then {(serverTime-(_s select 11)) max 0} else {0}};
private _mult=(floor(exp(_elapsed/9)*100))/100;private _scale=3 max (_mult*1.2);private _range=5 max (_elapsed*1.2);
private _left=safeZoneX+safeZoneW*.17;private _base=safeZoneY+safeZoneH*.61;private _width=safeZoneW*.65;private _height=safeZoneH*.17;
private _lost=_finished && {(_s select 5)==0};private _flash=if (_lost) then {.65+.25*abs(sin((diag_tickTime-(_d getVariable ["DSDS_visualFinishedAt",diag_tickTime]))*260))*((1-(diag_tickTime-(_d getVariable ["DSDS_visualFinishedAt",diag_tickTime]))/1.2) max 0)} else {.9};
for "_i" from 0 to 59 do {
 private _t=(_i/59)*_range;private _bar=_d displayCtrl (2600+_i);_bar ctrlShow (_t<=_elapsed && {_phase!="idle"});
 private _v=((exp(_t/9)-1)/(_scale-1)) min 1;_bar ctrlSetBackgroundColor (if (_lost) then {[.9,.13,.12,_flash]} else {[.85,.66,.2,.9]});
 _bar ctrlSetPosition [_left+(_i/60)*_width,_base-_v*_height,_width/65,(_v*_height) max .001];_bar ctrlCommit 0;
};
private _tip=_d displayCtrl 2502;_tip ctrlShow (_phase!="idle");_tip ctrlSetPosition [_left+(_elapsed/_range)*_width,_base-((_mult-1)/(_scale-1))*_height-safeZoneH*.022,safeZoneW*.04,safeZoneH*.05];_tip ctrlCommit 0;
(_d displayCtrl 2501) ctrlSetStructuredText parseText format ["<t size='1.5' color='%1'>%2x  %3</t>",if (_lost) then {"#ef5147"} else {"#ddbf72"},_mult,if (_finished) then {if (_lost) then {"CRASHED"} else {"CASHED OUT"}} else {if (_active) then {""} else {"Place a stake"}}];
(_d displayCtrl 1910) ctrlSetStructuredText parseText format ["<t color='#ddbf72'>%1</t>",_s select 6];
