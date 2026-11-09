// Additive medical loot only. Native mission objectives and ordinary supplies stay intact.
class DSDS_MedicalLoot {
    enabled=1;
    initializationDelay=15;
    convoyMin=3; convoyMax=6;
    vehicleMin=1; vehicleMax=3;
    medicChance=0.35;
    class Weights {
        DSDS_Morphine=5;
        DSDS_AHJC=3;
        DSDS_M11=3;
        DSDS_Adrenaline=4;
        DSDS_OLB1=1;
        DSDS_OLB2=1;
    };
};
