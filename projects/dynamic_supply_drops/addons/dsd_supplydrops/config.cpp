class CfgPatches {
    class dsd_supplydrops {
        name = "Dynamic Supply Drops - ZEN";
        author = "Local Workspace";
        version = 1.2;
        versionStr = "1.2.0";
        requiredVersion = 2.22;
        requiredAddons[] = {"cba_main", "zen_context_menu", "zen_dialog", "zen_custom_modules"};
        units[] = {};
        weapons[] = {};
    };
};
class CfgFunctions {
    class DSD {
        class SupplyDrops {
            file = "\dsd_supplydrops\functions\SupplyDrops";
            class initSupplyDrops { postInit = 1; };
            class registerSupplyMenu {};
            class openSupplyDialog {};
            class validateDropPosition {};
            class validateDropOptions {};
            class requestSupplyDrop {};
            class notifySupplyDrop {};
            class buildSupplyPools {};
            class isSupplyAssetAllowed {};
            class getSupplyMagazines {};
            class fillSupplyCrate {};
            class runSupplyDelivery {};
            class landSupplyCrate {};
            class cleanupSupplyAircraft {};
            class registerAntistasiCrate {};
            class importAntistasiCrate {};
        };
    };
};
