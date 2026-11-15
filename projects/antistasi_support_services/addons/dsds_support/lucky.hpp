class DSDS_LuckyWheel {
 tokenChance=0.01;gummyDuration=600;
 hellcats[]={"DCH18_UCG_Black","DCH18_UCG_White","DCH18_UCG_Blue","DCH18_UCG_Red","DCH18_UCG_Yellow","DCH18_UCG_Sport"};
 // Weights total 10,000; displayed wheel sectors use these exact proportions.
 class Rewards {
  class Cash1000 {label="1,000 credits";kind="CASH";amount=1000;weight=3300;};
  class Cash2500 {label="2,500 credits";kind="CASH";amount=2500;weight=2500;};
  class Cash10000 {label="10,000 credits";kind="CASH";amount=10000;weight=1000;};
  class Hellcat {label="Free Hellcat";kind="CAR";weight=500;};
  class Raid {label="HQ Raid";kind="RAID";weight=600;};
  class FreeSpin {label="Free spin";kind="SPIN";weight=1200;};
  class Mystery {label="Mystery item";kind="ITEM";weight=890;};
  class Jackpot {label="100,000-credit jackpot";kind="CASH";amount=100000;weight=10;};
 };
};
class DSDS_LuckyDialog {
 idd=88472;movingEnable=0;enableSimulation=1;
 class ControlsBackground {
  class Back: RscText {idc=-1;x="safezoneX+0.08*safezoneW";y="safezoneY+0.07*safezoneH";w="0.84*safezoneW";h="0.86*safezoneH";colorBackground[]={0.025,0.02,0.04,0.99};};
 };
 class Controls {
  class Title: RscText {idc=2200;x="safezoneX+0.1*safezoneW";y="safezoneY+0.09*safezoneH";w="0.8*safezoneW";h="0.05*safezoneH";text="AURUM  |  ROXIE'S LUCKY WHEEL";colorText[]={1,0.7,0.8,1};sizeEx=0.038;};
  class Money: RscText {idc=2201;x="safezoneX+0.1*safezoneW";y="safezoneY+0.15*safezoneH";w="0.8*safezoneW";h="0.04*safezoneH";sizeEx=0.033;};
  class Wheel: RscPicture {idc=2210;x="safezoneX+0.11*safezoneW";y="safezoneY+0.25*safezoneH";w="0.32*safezoneW";h="0.43*safezoneH";style=48+2048;text="\dsds_support\ui\lucky_wheel.jpg";};
  class Pointer: RscText {idc=-1;x="safezoneX+0.245*safezoneW";y="safezoneY+0.21*safezoneH";w="0.05*safezoneW";h="0.04*safezoneH";style=2;text="V";sizeEx=0.04;colorText[]={1,0.85,0.35,1};};
  class Message: RscStructuredText {idc=2202;x="safezoneX+0.47*safezoneW";y="safezoneY+0.23*safezoneH";w="0.41*safezoneW";h="0.24*safezoneH";size=0.032;};
  class Odds: RscText {idc=-1;x="safezoneX+0.47*safezoneW";y="safezoneY+0.49*safezoneH";w="0.41*safezoneW";h="0.21*safezoneH";style=16;lineSpacing=1;sizeEx=0.025;text="1 token per spin. Enemy kills: 1% token chance. Prizes: 1,000 (33%), 2,500 (25%), 10,000 (10%), Hellcat (5%), HQ raid (6%), free spin (12%), mystery item (8.9%), 100,000 jackpot (0.1%). Gummy bears: 10-minute vehicle boost; no stacking. Collect goods outside the hotel.";};
  class Spin: RscButton {idc=2203;x="safezoneX+0.1*safezoneW";y="safezoneY+0.74*safezoneH";w="0.24*safezoneW";h="0.055*safezoneH";text="Spin (1 token)";onButtonClick="['ACTION',['SPIN']] call DSDS_fnc_luckyUI";};
  class Gummies: RscButton {idc=2204;x="safezoneX+0.36*safezoneW";y="safezoneY+0.74*safezoneH";w="0.25*safezoneW";h="0.055*safezoneH";text="Gummy bears (150)";onButtonClick="['ACTION',['BUY_GUMMIES']] call DSDS_fnc_luckyUI";};
  class Close: RscButton {idc=2207;x="safezoneX+0.64*safezoneW";y="safezoneY+0.74*safezoneH";w="0.24*safezoneW";h="0.055*safezoneH";text="Leave table";onButtonClick="closeDialog 0";};
  class Car: RscButton {idc=2205;x="safezoneX+0.1*safezoneW";y="safezoneY+0.83*safezoneH";w="0.37*safezoneW";h="0.05*safezoneH";text="Collect Hellcat";onButtonClick="['ACTION',['CLAIM_CAR']] call DSDS_fnc_luckyUI";};
  class Item: RscButton {idc=2206;x="safezoneX+0.5*safezoneW";y="safezoneY+0.83*safezoneH";w="0.38*safezoneW";h="0.05*safezoneH";text="Collect items";onButtonClick="['ACTION',['CLAIM_ITEM']] call DSDS_fnc_luckyUI";};
 };
};
