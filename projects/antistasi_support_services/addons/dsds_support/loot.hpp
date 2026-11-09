// Inventory-only contraband. Hidden from unrestricted arsenal unlock pools.
class DSDS_Marijuana: DSDS_ValuableReceiver {
    displayName = "Marijuana";
    picture = "\dsds_support\ui\loot\marijuana.jpg";
    descriptionShort = "A small bag of dried cannabis.";
    class ItemInfo: InventoryItem_Base_F {type = 302; mass = 2;};
};
class DSDS_NicotineVape: DSDS_ValuableReceiver {
    displayName = "Nicotine Vape";
    picture = "\dsds_support\ui\loot\nicotine_vape.jpg";
    descriptionShort = "A pocket-sized disposable nicotine vape.";
    class ItemInfo: InventoryItem_Base_F {type = 302; mass = 0.2;};
};
class DSDS_Cocaine: DSDS_ValuableReceiver {
    displayName = "Cocaine";
    picture = "\dsds_support\ui\loot\cocaine.jpg";
    descriptionShort = "A sealed bag of suspicious white powder.";
    class ItemInfo: InventoryItem_Base_F {type = 302; mass = 1;};
};
class DSDS_Zyn: DSDS_ValuableReceiver {
    displayName = "Zyn Nicotine Pouches";
    picture = "\dsds_support\ui\loot\zyn.jpg";
    descriptionShort = "A small tin of nicotine pouches.";
    class ItemInfo: InventoryItem_Base_F {type = 302; mass = 0.5;};
};
class DSDS_GoldBullion: DSDS_ValuableReceiver {
    displayName = "Gold Bullion";
    picture = "\dsds_support\ui\loot\gold.jpg";
    descriptionShort = "A dense bar of refined gold.";
    class ItemInfo: InventoryItem_Base_F {type = 302; mass = 275;};
};
