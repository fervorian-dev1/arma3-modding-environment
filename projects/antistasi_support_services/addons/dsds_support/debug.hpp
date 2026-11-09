// Extension registry: future custom missions add a label and trusted server handler here.
class DSDS_DebugMissions {
    class SPECIAL {displayName="Start Special Convoy";handler="DSDS_fnc_startDebugConvoy";variant="SPECIAL";};
    class ISOTOPE {displayName="Start Isotope Convoy";handler="DSDS_fnc_startDebugConvoy";variant="ISOTOPE";};
    class MEDICAL {displayName="Start Medical Convoy";handler="DSDS_fnc_startDebugConvoy";variant="MEDICAL";};
    class CONTAMINATION {displayName="Start Contamination Response";handler="DSDS_fnc_startDebugResponse";variant="CONTAMINATION";};
    class ISOTOPE_STASH {displayName="Start Industrial Isotopes Stash";handler="DSDS_fnc_requestContrabandStash";variant="INDUSTRIAL";};
    class STASH {displayName="Start Contraband Stash";handler="DSDS_fnc_requestContrabandStash";variant="STASH";};
};
