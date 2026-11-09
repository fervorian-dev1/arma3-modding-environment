// Vanilla controls only. Antistasi's TextBase/ButtonBase default to fade=1.
class RscText;
class RscCombo;
class RscButton;
class RscMapControl;
class DSDS_SupportTerminalDialog {
    idd = 88400;
    movingEnable = 0;
    enableSimulation = 1;
    onUnload = "[] call DSDS_fnc_closeTerminal";
    class ControlsBackground {
        class Background: RscText {
            idc=-1; fade=0;
            x="safezoneX + 0.03 * safezoneW"; y="safezoneY + 0.08 * safezoneH";
            w="0.94 * safezoneW"; h="0.84 * safezoneH";
            colorBackground[]={0.04,0.04,0.04,0.98};
        };
    };
    class Controls {
        class Title: RscText {
            idc=100; fade=0; sizeEx=0.04; text="Support Terminal";
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.10 * safezoneH";
            w="0.85 * safezoneW"; h="0.04 * safezoneH";
        };
        class Options: RscCombo {
            idc=1750; fade=0; sizeEx=0.035; wholeHeight=0.45;
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.18 * safezoneH";
            w="0.28 * safezoneW"; h="0.045 * safezoneH";
            onLBSelChanged="_this call DSDS_fnc_terminalSelect";
        };
        class Description: RscText {
            idc=1701; fade=0; style=16; sizeEx=0.035; lineSpacing=1;
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.25 * safezoneH";
            w="0.28 * safezoneW"; h="0.30 * safezoneH"; text="";
        };
        class Cost: RscText {
            idc=1751; fade=0; sizeEx=0.035;
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.57 * safezoneH";
            w="0.28 * safezoneW"; h="0.045 * safezoneH";
        };
        class Map: RscMapControl {
            idc=1000; fade=0;
            x="safezoneX + 0.35 * safezoneW"; y="safezoneY + 0.18 * safezoneH";
            w="0.60 * safezoneW"; h="0.63 * safezoneH";
            onMouseButtonClick="_this call DSDS_fnc_terminalMapClick";
        };
        class Launch: RscButton {
            idc=1712; fade=0; sizeEx=0.035; text="Request support";
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.69 * safezoneH";
            w="0.28 * safezoneW"; h="0.05 * safezoneH";
            action="[] call DSDS_fnc_terminalSubmit";
        };
        class Reset: RscButton {
            idc=1711; fade=0; sizeEx=0.035; text="Reset target";
            x="safezoneX + 0.05 * safezoneW"; y="safezoneY + 0.76 * safezoneH";
            w="0.28 * safezoneW"; h="0.05 * safezoneH";
            action="[(findDisplay 88400) displayCtrl 1750, lbCurSel ((findDisplay 88400) displayCtrl 1750)] call DSDS_fnc_terminalSelect";
        };
        class Close: RscButton {
            idc=2; fade=0; sizeEx=0.035; text="Close";
            x="safezoneX + 0.80 * safezoneW"; y="safezoneY + 0.84 * safezoneH";
            w="0.15 * safezoneW"; h="0.05 * safezoneH";
            action="closeDialog 0";
        };
    };
};
