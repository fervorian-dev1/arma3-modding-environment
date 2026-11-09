class DSDS_FenceDialog {
    idd=88410; movingEnable=0; enableSimulation=1;
    class ControlsBackground {
        class Background: RscText {idc=-1;fade=0;x=0.12;y=0.12;w=0.76;h=0.82;colorBackground[]={0.03,0.03,0.03,0.98};};
    };
    class Controls {
        class Title: RscText {idc=-1;fade=0;x=0.15;y=0.14;w=0.7;h=0.06;text="The Fence - personal credits";};
        class VehiclesTab: RscButton {idc=1714;fade=0;x=0.15;y=0.21;w=0.34;h=0.05;text="Vehicles";action="['VEHICLES'] call DSDS_fnc_fenceTab";};
        class ItemsTab: RscButton {idc=1715;fade=0;x=0.51;y=0.21;w=0.34;h=0.05;text="Items";action="['ITEMS'] call DSDS_fnc_fenceTab";};
        class Offers: RscCombo {idc=1750;fade=0;x=0.15;y=0.29;w=0.7;h=0.06;wholeHeight=0.6;};
        class Description: RscText {idc=1701;fade=0;style=16;x=0.15;y=0.37;w=0.7;h=0.15;sizeEx=0.029;text="";};
        class Buy: RscButton {idc=1712;fade=0;x=0.15;y=0.54;w=0.7;h=0.06;text="Buy selected offer";action="['BUY'] call DSDS_fnc_fenceSubmit";};
        class Crate: RscButton {idc=-1;fade=0;x=0.15;y=0.63;w=0.7;h=0.06;text="Request / locate community crate";action="['BOX'] call DSDS_fnc_fenceSubmit";};
        class Sell: RscButton {idc=1713;fade=0;x=0.15;y=0.72;w=0.7;h=0.06;text="Quote valuables / confirm sale";action="['SELL'] call DSDS_fnc_fenceSubmit";};
        class Close: RscButton {idc=2;fade=0;x=0.62;y=0.81;w=0.23;h=0.05;text="Close";action="closeDialog 0";};
        class Mystic: RscButton {idc=1717;fade=0;x=0.15;y=0.88;w=0.7;h=0.045;text="Reveal Mystic - 92,235 credits";action="['LEAD',player,[]] remoteExecCall ['DSDS_fnc_mysticRequest',2]";};
        class Stash: RscButton {idc=1716;fade=0;x=0.15;y=0.81;w=0.44;h=0.05;text="Locate contraband stash";action="['STASH'] call DSDS_fnc_fenceSubmit";};
    };
};
