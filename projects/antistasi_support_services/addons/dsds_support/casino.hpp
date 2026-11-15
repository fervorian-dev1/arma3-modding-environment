class DSDS_Casino {
 purchasePrice=100000;minimumBet=100;maximumBet=10000;
 buildings[]={"Land_Hotel_01_F","Land_i_House_Big_02_V1_F"};
 class Games {
  class BLACKJACK {label="Blackjack";dealer="Vivienne";handler="DSDS_fnc_casinoBlackjack";choices[]={"MAIN"};choiceLabels[]={"Blackjack"};actions[]={"HIT","STAND","DOUBLE"};actionLabels[]={"Hit","Stand","Double"};rules="Dealer stands on soft 17. Blackjack pays 3:2; wins pay 1:1. Double on the first two cards. No split or insurance. Closing stands your hand.";};
  class ROULETTE {label="Roulette";dealer="Celeste";handler="DSDS_fnc_casinoRoulette";choices[]={"RED","BLACK","ODD","EVEN","LOW","HIGH","DOZEN1","DOZEN2","DOZEN3","COLUMN1","COLUMN2","COLUMN3"};choiceLabels[]={"Red","Black","Odd","Even","1-18","19-36","1-12","13-24","25-36","Column 1","Column 2","Column 3"};actions[]={};actionLabels[]={};rules="European single zero. Even-money bets pay 1:1; dozens and columns 2:1; straight numbers 35:1. Zero loses all outside bets.";};
  class CRASH {label="Crash";dealer="Sable";handler="DSDS_fnc_casinoCrash";choices[]={"MAIN"};choiceLabels[]={"Crash"};actions[]={"CASHOUT"};actionLabels[]={"Cash out"};rules="Cash out before the multiplier crashes. The server determines the crash. House edge about 3%, maximum 100x. Leaving the table attempts an immediate cash-out; death, distance or timeout forfeits the stake.";};
  class CRAPS {label="Craps";dealer="Marina";handler="DSDS_fnc_casinoCraps";choices[]={"PASS"};choiceLabels[]={"Pass line"};actions[]={"ROLL"};actionLabels[]={"Roll dice"};rules="Pass line: 7 or 11 wins the come-out; 2, 3 or 12 loses. Otherwise make the point before a seven. Wins pay 1:1. Closing completes the rolls.";};
  class BACCARAT {label="Baccarat";dealer="Iris";handler="DSDS_fnc_casinoBaccarat";choices[]={"PLAYER","BANKER","TIE"};choiceLabels[]={"Player","Banker","Tie"};actions[]={};actionLabels[]={};rules="Punto banco, standard third-card rules. Player pays 1:1; Banker 0.95:1 after commission; Tie 8:1. A tie pushes Player and Banker bets.";};
  class WHEEL {label="Lucky Wheel";dealer="Roxie";handler="";};
 };
};
class RscEdit;class RscStructuredText;
class DSDS_CasinoDialog {
 idd=88470;movingEnable=0;enableSimulation=1;
 onUnload="['CLOSED',_this] call DSDS_fnc_casinoUI";
 class ControlsBackground {
class Backdrop: RscText {idc=-1;fade=0;x="safezoneX+0.12*safezoneW";y="safezoneY+0.1*safezoneH";w="0.76*safezoneW";h="0.8*safezoneH";sizeEx=0.033;colorBackground[]={0.025,0.03,0.028,0.99};};
};
 class Controls {
class Title: RscText {idc=1900;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.12*safezoneH";w="0.72*safezoneW";h="0.05*safezoneH";sizeEx=0.033;colorText[]={0.88,0.72,0.35,1};text="AURUM CASINO";};
class Money: RscText {idc=1901;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.18*safezoneH";w="0.72*safezoneW";h="0.04*safezoneH";sizeEx=0.033;};
class Rules: RscText {idc=1902;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.23*safezoneH";w="0.72*safezoneW";h="0.11*safezoneH";sizeEx=0.033;style=16;lineSpacing=1;};
class Table: RscStructuredText {idc=1910;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.36*safezoneH";w="0.72*safezoneW";h="0.3*safezoneH";sizeEx=0.033;colorBackground[]={0.025,0.16,0.10,1};};
class StakeLabel: RscText {idc=-1;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.68*safezoneH";w="0.22*safezoneW";h="0.04*safezoneH";sizeEx=0.033;text="Stake (100 - 10,000)";};
class Stake: RscEdit {idc=1903;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.73*safezoneH";w="0.17*safezoneW";h="0.045*safezoneH";sizeEx=0.033;text="1000";};
class Choice: RscCombo {idc=1904;fade=0;x="safezoneX+0.33*safezoneW";y="safezoneY+0.73*safezoneH";w="0.28*safezoneW";h="0.045*safezoneH";sizeEx=0.033;wholeHeight=0.4;};
class Bet: RscButton {idc=1905;fade=0;x="safezoneX+0.63*safezoneW";y="safezoneY+0.73*safezoneH";w="0.23*safezoneW";h="0.045*safezoneH";sizeEx=0.033;text="Place bet";onButtonClick="['BET',[]] call DSDS_fnc_casinoUI";};
class Action0: RscButton {idc=1906;fade=0;x="safezoneX+0.14*safezoneW";y="safezoneY+0.8*safezoneH";w="0.16*safezoneW";h="0.045*safezoneH";sizeEx=0.033;onButtonClick="['ACTION',[0]] call DSDS_fnc_casinoUI";};
class Action1: RscButton {idc=1907;fade=0;x="safezoneX+0.32*safezoneW";y="safezoneY+0.8*safezoneH";w="0.16*safezoneW";h="0.045*safezoneH";sizeEx=0.033;onButtonClick="['ACTION',[1]] call DSDS_fnc_casinoUI";};
class Action2: RscButton {idc=1908;fade=0;x="safezoneX+0.5*safezoneW";y="safezoneY+0.8*safezoneH";w="0.16*safezoneW";h="0.045*safezoneH";sizeEx=0.033;onButtonClick="['ACTION',[2]] call DSDS_fnc_casinoUI";};
class Close: RscButton {idc=1912;fade=0;x="safezoneX+0.72*safezoneW";y="safezoneY+0.8*safezoneH";w="0.14*safezoneW";h="0.045*safezoneH";sizeEx=0.033;text="Leave table";onButtonClick="closeDialog 0";};
 };
};
class DSDS_CasinoPlacementDialog {
 idd=88471;movingEnable=0;enableSimulation=1;onUnload="['PLACE_CLOSED',_this] call DSDS_fnc_casinoUI";
 class ControlsBackground {
class Background: RscText {idc=-1;fade=0;x="safezoneX+0.04*safezoneW";y="safezoneY+0.07*safezoneH";w="0.92*safezoneW";h="0.86*safezoneH";sizeEx=0.033;colorBackground[]={0.025,0.03,0.028,0.99};};
};
 class Controls {
class Title: RscText {idc=2011;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.09*safezoneH";w="0.86*safezoneW";h="0.05*safezoneH";sizeEx=0.033;colorText[]={0.88,0.72,0.35,1};};
class Help: RscText {idc=2012;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.16*safezoneH";w="0.25*safezoneW";h="0.32*safezoneH";sizeEx=0.033;style=16;lineSpacing=1;};
class DirectionLabel: RscText {idc=-1;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.52*safezoneH";w="0.25*safezoneW";h="0.04*safezoneH";sizeEx=0.033;text="Direction (degrees)";};
class Direction: RscEdit {idc=2013;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.58*safezoneH";w="0.25*safezoneW";h="0.05*safezoneH";sizeEx=0.033;text="0";onKillFocus="if (getMarkerColor 'DSDS_CasinoPreview'!='') then {'DSDS_CasinoPreview' setMarkerDirLocal (parseNumber ctrlText (_this select 0));}";};
class Map: RscMapControl {idc=2010;fade=0;x="safezoneX+0.34*safezoneW";y="safezoneY+0.16*safezoneH";w="0.6*safezoneW";h="0.67*safezoneH";sizeEx=0.033;onMouseButtonClick="['PLACE_CLICK',_this] call DSDS_fnc_casinoUI";};
class Place: RscButton {idc=2014;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.72*safezoneH";w="0.25*safezoneW";h="0.05*safezoneH";sizeEx=0.033;text="Place casino";onButtonClick="['BUILD',[]] call DSDS_fnc_casinoUI";};
class Cancel: RscButton {idc=2015;fade=0;x="safezoneX+0.06*safezoneW";y="safezoneY+0.8*safezoneH";w="0.25*safezoneW";h="0.05*safezoneH";sizeEx=0.033;text="Cancel";onButtonClick="closeDialog 0";};
 };
};

