class DSDS_Mystic {
 leadPrice=92235;offeringGoal=40;respawnDelay=1800;
 class Nuclear {class IED {item="DSDS_NuclearIED_Mag";price=174000;};};
 class Trinkets {class Oswald {item="DSDS_Oswald";price=62000;};};
};
class RscPicture;
class DSDS_MysticDialog {
 idd=88430;movingEnable=0;enableSimulation=1;
 class ControlsBackground {
  class Void: RscText {idc=-1;fade=0;x="safezoneX+0.13*safezoneW";y="safezoneY+0.1*safezoneH";w="0.74*safezoneW";h="0.8*safezoneH";colorBackground[]={0.018,0.012,0.035,0.98};};
  class Seam: RscText {idc=-1;fade=0;x="safezoneX+0.43*safezoneW";y="safezoneY+0.2*safezoneH";w="0.002*safezoneW";h="0.58*safezoneH";colorBackground[]={0.62,0.43,0.24,0.8};};
 };
 class Controls {
  class Title: RscText {idc=-1;fade=0;x="safezoneX+0.18*safezoneW";y="safezoneY+0.13*safezoneH";w="0.57*safezoneW";h="0.06*safezoneH";text="M Y S T I C     /     0 : 4 0";colorText[]={0.82,0.71,0.48,1};sizeEx=0.047;};
  class Category: RscText {idc=-1;fade=0;x="safezoneX+0.47*safezoneW";y="safezoneY+0.23*safezoneH";w="0.32*safezoneW";h="0.05*safezoneH";text="///  Trinkets  ///";colorText[]={0.68,0.53,0.87,1};};
  class Image: RscPicture {idc=1831;fade=0;style=48+2048;x="safezoneX+0.17*safezoneW";y="safezoneY+0.24*safezoneH";w="0.22*safezoneW";h="0.47*safezoneH";text="";};
  class Offers: RscCombo {idc=1832;fade=0;x="safezoneX+0.47*safezoneW";y="safezoneY+0.3*safezoneH";w="0.33*safezoneW";h="0.05*safezoneH";onLBSelChanged="[] call DSDS_fnc_mysticRefresh";};
  class Buy: RscButton {idc=1833;fade=0;x="safezoneX+0.49*safezoneW";y="safezoneY+0.39*safezoneH";w="0.29*safezoneW";h="0.055*safezoneH";text="62,000";action="['BUY'] call DSDS_fnc_mysticSubmit";colorBackground[]={0.16,0.07,0.22,1};};
  class Promise: RscText {idc=-1;fade=0;style=16;x="safezoneX+0.47*safezoneW";y="safezoneY+0.49*safezoneH";w="0.33*safezoneW";h="0.09*safezoneH";text="Forty industrial isotopes. Bring them a little at a time. Something exceptional will be yours.";sizeEx=0.028;colorText[]={0.78,0.73,0.66,1};};
  class Counter: RscText {idc=1834;fade=0;x="safezoneX+0.49*safezoneW";y="safezoneY+0.61*safezoneH";w="0.29*safezoneW";h="0.05*safezoneH";text="0 / 40";sizeEx=0.04;colorText[]={0.82,0.71,0.48,1};};
  class Offering: RscButton {idc=1835;fade=0;x="safezoneX+0.47*safezoneW";y="safezoneY+0.7*safezoneH";w="0.33*safezoneW";h="0.055*safezoneH";text="Offer carried industrial isotopes";action="['OFFER'] call DSDS_fnc_mysticSubmit";};
  class Reward: RscButton {idc=1836;fade=0;x="safezoneX+0.17*safezoneW";y="safezoneY+0.75*safezoneH";w="0.22*safezoneW";h="0.05*safezoneH";text="Accept Mystic's reward";action="['REWARD'] call DSDS_fnc_mysticSubmit";};
  class Stash: RscButton {idc=1837;fade=0;x="safezoneX+0.17*safezoneW";y="safezoneY+0.82*safezoneH";w="0.36*safezoneW";h="0.04*safezoneH";text="Source Industrial Isotopes stash";action="['STASH',player,[]] remoteExecCall ['DSDS_fnc_mysticRequest',2];closeDialog 0";};
  class Exit: RscButton {idc=2;fade=0;x="safezoneX+0.61*safezoneW";y="safezoneY+0.82*safezoneH";w="0.2*safezoneW";h="0.04*safezoneH";text="Leave";action="closeDialog 0";};
 };
};
