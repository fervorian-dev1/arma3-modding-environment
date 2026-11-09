// Actual inventory containers, with verified base-game scenery models.
class DSDS_StashSacks: Box_NATO_Equip_F {
 scope=1;scopeCurator=0;displayName="Concealed Contraband";
 model="\A3\Structures_F\Civ\Market\Sacks_heap_F.p3d";
 hiddenSelections[]={};hiddenSelectionsTextures[]={};
 maximumLoad=1500;supplyRadius=3;memoryPointSupply="";
 class TransportWeapons {};class TransportMagazines {};class TransportItems {};class TransportBackpacks {};
};
class DSDS_StashGarbage: DSDS_StashSacks {model="\A3\Structures_F\Civ\Garbage\GarbageBags_F.p3d";};
class DSDS_StashPallet: DSDS_StashSacks {model="\A3\Structures_F\Civ\Garbage\GarbagePallet_F.p3d";};
