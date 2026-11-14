class CfgPatches {
    class dsds_support {
        name = "Antistasi Support Services";
        author = "Local Workspace";
        version = 4.9;
        requiredVersion = 2.22;
        requiredAddons[] = {"dsd_supplydrops", "A3A_core", "A3A_scrt", "A3A_events", "A3A_garage", "A3_Weapons_F", "cba_common", "zen_modules", "A3_Weapons_F_Explosives", "A3_Structures_F_Civ_Garbage", "A3_Structures_F_Civ_Market"};
        units[] = {"DSDS_MysticNPC","DSDS_MechanicNPC","DSDS_StashSacks","DSDS_StashGarbage","DSDS_StashPallet"};
        weapons[] = {"DSDS_Oswald","DSDS_SupportTerminal", "DSDS_MechanicUniform", "DSDS_ValuableReceiver", "DSDS_Marijuana", "DSDS_NicotineVape", "DSDS_Cocaine", "DSDS_Zyn", "DSDS_GoldBullion", "DSDS_RoughGems", "DSDS_CutGems", "DSDS_IndustrialPlatinum", "DSDS_PalladiumSponges", "DSDS_SiliconWafers", "DSDS_Microchips", "DSDS_Methamphetamine", "DSDS_Morphine", "DSDS_AHJC", "DSDS_M11", "DSDS_Adrenaline", "DSDS_OLB1", "DSDS_OLB2", "DSDS_MedicalIsotopes", "DSDS_IndustrialIsotopes"};
    };
};
class A3U {class forbiddenItems {class DSDS_AHJC {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Cocaine {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_CutGems {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_GoldBullion {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_IndustrialIsotopes {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_IndustrialPlatinum {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_M11 {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Marijuana {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_MedicalIsotopes {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Methamphetamine {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Microchips {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_NicotineVape {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_OLB1 {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_OLB2 {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_PalladiumSponges {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_RoughGems {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_SiliconWafers {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_ValuableReceiver {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Zyn {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};class DSDS_Oswald {addons[]={"dsds_support"};unlimited=0;appearInCrates=0;};};};
class CfgAmmo {
    class IEDUrbanSmall_Remote_Ammo;
    class DSDS_NuclearIED_Ammo: IEDUrbanSmall_Remote_Ammo {
        defaultMagazine="DSDS_NuclearIED_Mag";
        class EventHandlers {class DSDS_Nuclear {init="_this call DSDS_fnc_nuclearIEDInit";};};
    };
};
class CfgMagazines {
    class IEDUrbanSmall_Remote_Mag;
    class DSDS_NuclearIED_Mag: IEDUrbanSmall_Remote_Mag {
        scope=2;scopeArsenal=0;displayName="Nuclear IED";descriptionShort="";
        picture="\dsds_support\ui\loot\nuclear_ied.jpg";ammo="DSDS_NuclearIED_Ammo";DLC="";
    };
};
class CfgWeapons {
    class Default;
    class Put: Default {
        muzzles[]+={"DSDS_NuclearMuzzle"};
        class PutMuzzle: Default {};
        class DSDS_NuclearMuzzle: PutMuzzle {magazines[]={"DSDS_NuclearIED_Mag"};};
    };
    class ItemWatch;
    class DSDS_Oswald: ItemWatch {
        scope=1;scopeArsenal=0;displayName="Oswald";descriptionShort="";descriptionUse="";DLC="";
        picture="\dsds_support\ui\loot\oswald.jpg";
    };
    class B_UavTerminal;
    class CBA_MiscItem;
    class InventoryItem_Base_F;
    class UniformItem;
    class U_B_CombatUniform_mcam;
    // Initial custom mission valuable: free GPS model, no GPS functionality.
    class DSDS_ValuableReceiver: CBA_MiscItem {
        scope = 1;
        scopeArsenal = 0;
        type = 131072;
        model = "\a3\Weapons_F\Ammo\mag_gps.p3d";
        picture = "\A3\Weapons_F\Data\UI\gear_item_gps_CA.paa";
        displayName = "Encrypted Data Receiver";
        descriptionShort = "Valuable encrypted electronics. Sell to The Fence.";
        simulation = "Weapon";
        dlc = "";
        // CBA's miscellaneous-item convention; portable cargo, not assigned GPS.
        class ItemInfo: InventoryItem_Base_F {type = 302; mass = 10;};
    };
    #include "loot.hpp"
    #include "loot_extra.hpp"
    class DSDS_SupportTerminal: B_UavTerminal {
        author = "Local Workspace";
        displayName = "Support Terminal";
        descriptionShort = "Private contractor fire support. Equip in the GPS slot and use Open Support Terminal.";
        simulation = "ItemGPS";
        dlc = "";
        class ItemInfo: InventoryItem_Base_F { mass = 20; };
    };
    class DSDS_MechanicUniform: U_B_CombatUniform_mcam {
        scope = 1;
        displayName = "PMC Mechanic (Black)";
        dlc = "";
        class ItemInfo: UniformItem {
            uniformModel = "-";
            uniformClass = "DSDS_MechanicNPC";
            containerClass = "Supply40";
            mass = 40;
        };
    };
};
class CfgVehicles {
    class C_man_polo_1_F;
    class DSDS_MysticNPC: C_man_polo_1_F {scope=1;scopeCurator=0;displayName="Mystic";};
    class Box_NATO_Equip_F;
    #include "stash.hpp"
    class B_Soldier_F;
    class DSDS_MechanicNPC: B_Soldier_F {
        scope = 1;
        side = 2;
        faction = "IND_G_F";
        displayName = "PMC Mechanic";
        uniformClass = "DSDS_MechanicUniform";
        hiddenSelectionsTextures[] = {"#(argb,8,8,3)color(0.025,0.025,0.025,1)", "#(argb,8,8,3)color(0.025,0.025,0.025,1)"};
    };
};
class CfgFunctions {
    class DB {class FPV {
        class fpv_getSignal {file="\dsds_support\functions\Compatibility\fpvFullSignal.sqf";};
        class fpv_ppfx_start {file="\dsds_support\functions\Compatibility\fpvClearVideo.sqf";};
    };};
    class SCRT {class Common {class common_unconsciousEventHandler {file="\dsds_support\functions\Compatibility\nativeReviveKeys.sqf";};};};
    class A3U {class REINF {class blackMarketVehiclePrice {file="\dsds_support\functions\Compatibility\nativeCivilBMPrice.sqf";};};};
    class A3A {
        class REINF {class vehiclePrice {file="\dsds_support\functions\Compatibility\nativeCivilHQPrice.sqf";};};
        class CREATE {class createUnit {file="\dsds_support\functions\Compatibility\nativeCreateUnit.sqf";};};
        class Missions {
            class convoy {file="\dsds_support\functions\Smuggling\nativeConvoy.sqf";};
        };
    };
    class DSDS {
        class Compatibility {
            file="\dsds_support\functions\Compatibility";
            class initGameplayHotfixes {postInit=1;};
            class initSilentFriendlyFire {postInit=1;};
            class initCivilianTransport {postInit=1;};
            class initGarageSlots {postInit=1;};
            class physicalDownState {};
            class repairReviveUI {};
            class protectOswaldArsenal {};
            class tickAICompatibility {};
        };
        class Nuclear {
            file="\dsds_support\functions\Nuclear";
            class nuclearBlast {};
            class nuclearClaim {};
            class nuclearDetonateVest {};
            class nuclearRequest {};
            class nuclearTick {};
            class nuclearClientTick {};
            class nuclearIEDInit {};
            class nuclearIEDReport {};
            class initNuclear {postInit=1;};
        };
        class Mystic {
            file="\dsds_support\functions\Mystic";
            class initMystic {postInit=1;};
            class mysticClient {};
            class mysticFinishTrade {};
            class mysticInventory {};
            class mysticLead {};
            class mysticLoad {};
            class mysticLocation {};
            class mysticOpen {};
            class mysticPublish {};
            class mysticRefresh {};
            class mysticRequest {};
            class mysticSave {};
            class mysticSpawn {};
            class mysticSubmit {};
            class mysticTick {};
            class mysticTransaction {};
            class oswaldAircraft {};
            class oswaldTick {};
        };
        class Debug {
            file="\dsds_support\functions\Debug";
            class initCustomMissions {postInit=1;};
            class queueCustomMission {};
            class debugMissionRequest {};
            class startDebugConvoy {};
            class startDebugResponse {};
            class runDebugTool {};
            class tickDebugMission {};
        };
        class Smuggling {
            file="\dsds_support\functions\Smuggling";
            class initSmuggling {postInit=1;};
            class initNativeConvoys {};
            class selectPetrosConvoy {};
            class smugglingFaction {};
            class specialConvoyPool {};
            class convoyDefenseProfile {};
            class convoyCargoTrucks {};
            class isConvoyCargoTruck {};
            class safeDoorAmmo {};
            class convoyDoorHelis {};
            class findConvoySpawn {};
            class adaptConvoySafety {};
            class isConvoyRoadSpawnClear {};
            class trackConvoyObjective {};
            class sanitizeConvoyHeli {};
            class convoyEscortPool {};
            class convoyProtection {};
            class smugglingUnit {};
            class smugglingVehicle {};
            class smugglingAirStart {};
            class convoyObserved {};
            class upgradeConvoy {};
            class alertConvoy {};
            class convoyResponse {};
            class pursuitTick {};
            class smugglingRequest {};
            class fillChemicalCargo {};
            class convoyHit {};
            class medicalIncident {};
            class convoyLocal {};
            class convoyCohesion {};
            class responseAssets {};
            class spawnResponseDrone {};
            class contaminationResponse {};
            class cleanupContaminationResponse {};
            class cleanupContaminationTick {};
            class landContaminationTeam {};
            class isotopeRelease {};
            class isotopeInventory {};
            class chemicalCloud {};
            class requestContrabandStash {};
            class createStashContainer {};
            class cleanupContrabandStash {};
            class generateGuardName {};
            class salvageConvoy {};
        };
        class Loot {
            file = "\dsds_support\functions\Loot";
            class initLoot {postInit = 1;};
            class initMedicalLoot {postInit = 1;};
            class medicalPool {};
            class medicalLootObserved {};
            class seedMedicalLoot {};
            class lootRequest {};
            class lootClient {};
            class lootConsume {};
            class lootCommit {};
            class lootMorphineHealTick {};
            class lootCanRevive {};
            class initPiRRescue {preInit=1;postInit=1;};
            class lootDownState {};
            class lootRescueClass {};
            class lootRecover {};
            class lootRescueTake {};
            class lootModifiers {};
            class consumableClasses {};
            class stimModifiers {};
            class lootTick {};
            class lootVisualPlan {};
            class lootVisuals {};
            class lootCleanup {};
            class lootCapacity {};
            class lootDose {};
            class lootOverdoseTick {};
            class fillLootContainer {};
        };
        class Services {
            file = "\dsds_support\functions";
            class initServices {postInit = 1;};
            class configureAddonAI {};
            class initDeathMoney {postInit = 1;};
            class applyDeathMoney {};
            class serviceActions {};
            class openTerminal {};
            class terminalSelect {};
            class terminalMapClick {};
            class terminalSubmit {};
            class closeTerminal {};
            class clientService {};
            class serverRequest {};
            class serviceTransaction {};
            class serviceCatalogue {};
            class validateServicePosition {};
            class changeWallet {};
            class vehicleValue {};
            class vehicleShopPrice {};
            class travelSafe {};
            class travelDestinations {};
            class refreshTravelDestinations {};
            class confirmPassengerJump {};
            class travelClient {};
            class runFriendlyTravel {};
            class validateVehicleSale {};
            class sellMechanicVehicle {};
            class createMechanic {};
            class moveMechanic {};
            class persistMechanic {};
            class restoreMechanic {};
            class runSupportContract {};
            class spawnSupportAircraft {};
            class finishSupportContract {};
            class landSupportPayload {};
            class boardSupportPassenger {};
            class jumpSupportPassenger {};
            class napalmRun {};
            class napalmEffect {};
            class flyStrikeAircraft {};
            class strikeFlightAltitude {};
        };
        class Fence {
            file = "\dsds_support\functions\Fence";
            class initFence {postInit = 1;};
            class tickFenceVisits {};
            class spawnFenceAmbush {};
            class fenceCommunityCrate {};
            class fenceLocation {};
            class fenceCatalogue {};
            class fencePrice {};
            class fenceRotate {};
            class fenceOpen {};
            class fenceSubmit {};
            class fenceRequest {};
            class fenceTransaction {};
            class fenceDelivery {};
            class fenceBoard {};
            class fenceCargoValue {};
            class fenceIsModded {};
            class fenceIsAntiAir {};
            class fenceBuildStock {};
            class fenceOffersForTab {};
            class fenceTab {};
            class storeFenceBoat {};
        };
        class HQRaid {
            file = "\dsds_support\functions\HQRaid";
            class initHQRaid {postInit = 1;};
            class registerNoisePlayer {};
            class noiseFired {};
            class reportHQNoise {};
            class noiseWeight {};
            class applyHQNoise {};
            class tickHQNoise {};
            class planHQRaid {};
            class runHQRaid {};
            class spawnRaidUnit {};
            class landRaidHelicopter {};
            class endHQRaid {};
            class cleanupHQRaid {};
        };
    };
};
class CfgRemoteExec {
    class Functions {
        class DSDS_fnc_isotopeInventory {allowedTargets=0;jip=1;};
        class DSDS_fnc_debugMissionRequest {allowedTargets=2;jip=0;};
        class DSDS_fnc_nuclearRequest {allowedTargets=2;jip=0;};
        class DSDS_fnc_nuclearIEDReport {allowedTargets=2;jip=0;};
        class DSDS_fnc_mysticRequest {allowedTargets=2;jip=0;};
        class DSDS_fnc_mysticClient {allowedTargets=1;jip=0;};
        class DSDS_fnc_mysticInventory {allowedTargets=0;jip=0;};
        class DSDS_fnc_convoyLocal {allowedTargets = 0; jip = 0;};
        class DSDS_fnc_convoyObserved {allowedTargets=2;jip=0;};
        class DSDS_fnc_medicalLootObserved {allowedTargets=2;jip=0;};
        class DSDS_fnc_smugglingRequest {allowedTargets=2;jip=0;};
        class DSDS_fnc_chemicalCloud {allowedTargets=0;jip=0;};
        class DSDS_fnc_lootRequest {allowedTargets = 2; jip = 0;};
        class DSDS_fnc_lootClient {allowedTargets = 0; jip = 0;};
        class DSDS_fnc_serverRequest {allowedTargets = 2; jip = 0;};
        class DSDS_fnc_clientService {allowedTargets = 0; jip = 0;};
        class DSDS_fnc_boardSupportPassenger {allowedTargets = 0; jip = 0;};
        class DSDS_fnc_travelClient {allowedTargets=1;jip=0;};
        class DSDS_fnc_jumpSupportPassenger {allowedTargets = 0; jip = 0;};
        class DSDS_fnc_reportHQNoise {allowedTargets = 2; jip = 0;};
        class DSDS_fnc_fenceRequest {allowedTargets = 2; jip = 0;};
        class DSDS_fnc_fenceBoard {allowedTargets = 0; jip = 0;};
    };
};
class DSDS_StrikeFlight {
    terrainClearance = 150;
    speed = 400;
    lookAhead = 4000;
};
class DSDS_HQRaid {
    enabled = 1;
    radius = 300;
    threshold = 300;
    decayPerSecond = 1;
    responseDelay = 90;
    responseRandom = 90;
    recovery = 3600;
    landingMin = 800;
    landingMax = 1200;
    approachDistance = 4500;
    transportLoad = 12;
    landingTimeout = 300;
    assaultTimeout = 1800;
    cleanupDistance = 1200;
    cleanupDelay = 120;
};
// Data-driven catalogue: new terminal services can be added here without changing the item.
class DSDS_SupportActions {
    class SMOKE { label = "$STR_commander_menu_smoke_barrage_title"; cost = 5000; points = 1; };
    class FLARE { label = "$STR_commander_menu_flare_barrage_title"; cost = 5000; points = 1; };
    class VEH_AIRDROP { label = "$STR_commander_menu_lva_title"; cost = 7500; points = 2; };
    class RECON { label = "$STR_commander_menu_rpr_title"; cost = 8000; points = 2; };
    class SUPPLY { label = "$STR_commander_menu_sca_title"; cost = 5000; points = 1; };
    class HE { label = "$STR_commander_menu_hba_title"; cost = 30000; points = 2; };
    class CLUSTER { label = "$STR_commander_menu_cba_title"; cost = 40000; points = 2; };
    class CHEMICAL { label = "$STR_commander_menu_chemba_title"; cost = 50000; points = 2; };
    class NAPALM { label = "$STR_commander_menu_na_title"; cost = 40000; points = 2; };
    class PARADROP { label = "$STR_commander_menu_paradrop_title"; cost = 10000; points = 1; };
    class LOOTHELI { label = "$STR_commander_menu_loot_heli_title"; cost = 10000; points = 2; };
};
#include "terminal.hpp"
#include "fence.hpp"
#include "effects.hpp"
#include "smuggling.hpp"
#include "medical.hpp"
#include "debug.hpp"
#include "convoys.hpp"
#include "contraband_visuals.hpp"
#include "mystic.hpp"
class DSDS_Fence {
    intervalMin = 2700;
    intervalMax = 5700;
    vehicleMultiplier = 2.9;
    gearMultiplier = 4;
    gearOffers = 10;
    moddedOffers = 8;
    tentClass = "Land_MedicalTent_01_white_generic_open_F";
    npcClass = "C_man_1";
    crateClass = "B_supplyCrate_F";
};
// Extension point: class entries use classname, section (CfgWeapons/CfgMagazines/
// CfgVehicles for backpacks), sellValue and optional stock=1. No invented loot classes.
class DSDS_FenceGoods {
    class IndustrialIsotopes {classname="DSDS_IndustrialIsotopes";section="CfgWeapons";sellValue=6000;stock=0;};
    class MedicalIsotopes {classname="DSDS_MedicalIsotopes";section="CfgWeapons";sellValue=4000;stock=0;};
    class RoughGems {classname="DSDS_RoughGems";section="CfgWeapons";sellValue=1000;stock=0;lootPool="COMMON";};
    class CutGems {classname="DSDS_CutGems";section="CfgWeapons";sellValue=1650;stock=0;lootPool="COMMON";};
    class IndustrialPlatinum {classname="DSDS_IndustrialPlatinum";section="CfgWeapons";sellValue=5200;stock=0;lootPool="SPECIAL";};
    class PalladiumSponges {classname="DSDS_PalladiumSponges";section="CfgWeapons";sellValue=4800;stock=0;lootPool="SPECIAL";};
    class SiliconWafers {classname="DSDS_SiliconWafers";section="CfgWeapons";sellValue=2800;stock=0;lootPool="SPECIAL";};
    class Microchips {classname="DSDS_Microchips";section="CfgWeapons";sellValue=2200;stock=0;lootPool="SPECIAL";};
    class Methamphetamine {classname="DSDS_Methamphetamine";section="CfgWeapons";sellValue=650;stock=0;lootPool="DRUG";};
    class Morphine {classname="DSDS_Morphine";section="CfgWeapons";sellValue=400;stock=0;lootPool="MEDICAL";};
    class AHJC {classname="DSDS_AHJC";section="CfgWeapons";sellValue=600;stock=0;lootPool="MEDICAL";};
    class M11 {classname="DSDS_M11";section="CfgWeapons";sellValue=550;stock=0;lootPool="MEDICAL";};
    class Adrenaline {classname="DSDS_Adrenaline";section="CfgWeapons";sellValue=500;stock=0;lootPool="MEDICAL";};
    class OLB1 {classname="DSDS_OLB1";section="CfgWeapons";sellValue=650;stock=0;lootPool="MEDICAL";};
    class OLB2 {classname="DSDS_OLB2";section="CfgWeapons";sellValue=750;stock=0;lootPool="MEDICAL";};
    class Marijuana {classname="DSDS_Marijuana"; section="CfgWeapons"; sellValue=300; stock=0;};
    class NicotineVape {classname="DSDS_NicotineVape"; section="CfgWeapons"; sellValue=150; stock=0;};
    class Cocaine {classname="DSDS_Cocaine"; section="CfgWeapons"; sellValue=800; stock=0;};
    class Zyn {classname="DSDS_Zyn"; section="CfgWeapons"; sellValue=200; stock=0;};
    class GoldBullion {classname="DSDS_GoldBullion"; section="CfgWeapons"; sellValue=3200; stock=0;};
    class EncryptedReceiver {
        classname = "DSDS_ValuableReceiver";
        section = "CfgWeapons";
        sellValue = 2500;
        stock = 0;
    };
};
// Timings in seconds; multipliers are gameplay balancing, not real-world effects.
class DSDS_Consumables {
    marijuanaDuration=600; marijuanaSway=0.75; marijuanaBlur=0.035; marijuanaMovement=0.9; marijuanaStamina=0.9;
    vapeDuration=600; vapeRegen=1.15; vapeMovement=1; vapeStamina=0.9; vapeSway=0.95;
    cocaineDuration=300; cocaineSprint=1.15; cocaineRegen=1.25; cocaineSway=1.15;
    crashDuration=300; crashMovement=0.85; crashSway=1.35; crashStamina=0.7; crashRegen=0.8;
    zynDuration=2700; zynCapacity=1.3;
    marijuanaMessage="You feel calm, but sluggish.";
    vapeMessage="You feel a little more focused.";
    cocaineMessage="You feel wired and restless.";
    zynMessage="You feel stronger.";
    crashMessage="You feel drained and shaky.";
    doseWindow=180; marijuanaDose=1; cocaineDose=3;
    sicknessThreshold=3; warningThreshold=6; overdoseThreshold=9;
    sicknessDuration=120; overdoseDelay=10;
    sicknessMovement=0.65; sicknessSway=1.6; sicknessStamina=0.4; sicknessBlur=0.12;
};
