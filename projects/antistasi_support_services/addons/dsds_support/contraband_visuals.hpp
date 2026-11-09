// Client-only presentation; gameplay durations remain in the authoritative ledgers.
class DSDS_ContrabandVisuals {
 class Meth {effect="WetDistortion";fade=0.2;priority=325;settings[]={0.35,0.65,0.65,4.1,3.7,2.5,1.85,0.007,0.005,0.012,0.009,0.5,0.3,10,6};};
 class Cocaine {control=88523;fade=0.4;color[]={1,1,1,0.035};};
 class Marijuana {control=88521;fade=90;color[]={0.2,0.65,0.18,0.035};};
 class Vape {control=88522;fade=2;color[]={1,0.9,0.35,0.025};};
 class Zyn {effect="OVERLAY";fade=180;priority=0;opacity=0.05;texture="\dsds_support\ui\loot\zyn_overlay.jpg";};
};
class RscTitles {
 class DSDS_ContrabandTintOverlay {
  idd=-1;duration=1e10;fadeIn=0;fadeOut=0;movingEnable=0;
  onLoad="uiNamespace setVariable ['DSDS_contrabandTintDisplay',_this select 0]";
  onUnload="uiNamespace setVariable ['DSDS_contrabandTintDisplay',displayNull]";
  class Controls {
   class Marijuana {idc=88521;type=0;style=0;x="safezoneXAbs";y="safezoneY";w="safezoneWAbs";h="safezoneH";text="";font="RobotoCondensed";sizeEx=0;colorText[]={0,0,0,0};colorBackground[]={0,0,0,0};shadow=0;access=0;};
   class Vape {idc=88522;type=0;style=0;x="safezoneXAbs";y="safezoneY";w="safezoneWAbs";h="safezoneH";text="";font="RobotoCondensed";sizeEx=0;colorText[]={0,0,0,0};colorBackground[]={0,0,0,0};shadow=0;access=0;};
   class Cocaine {idc=88523;type=0;style=0;x="safezoneXAbs";y="safezoneY";w="safezoneWAbs";h="safezoneH";text="";font="RobotoCondensed";sizeEx=0;colorText[]={0,0,0,0};colorBackground[]={0,0,0,0};shadow=0;access=0;};
  };
 };
 class DSDS_ZynOverlay {
  idd=-1;duration=1e10;fadeIn=0;fadeOut=0;movingEnable=0;
  onLoad="uiNamespace setVariable ['DSDS_zynDisplay',_this select 0]";
  onUnload="uiNamespace setVariable ['DSDS_zynDisplay',displayNull]";
  class Controls {
   class Image {
    idc=88520;type=0;style=48; // ST_PICTURE stretches; deliberately no KEEP_ASPECT_RATIO.
    x="safezoneXAbs";y="safezoneY";w="safezoneWAbs";h="safezoneH";
    text="";font="RobotoCondensed";sizeEx=0;colorText[]={1,1,1,1};colorBackground[]={0,0,0,0};
    shadow=0;access=0;lineSpacing=0;fixedWidth=0;
   };
  };
 };
};
