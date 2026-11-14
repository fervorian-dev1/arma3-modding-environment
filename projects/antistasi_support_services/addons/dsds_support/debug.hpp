// Extension registry: future custom missions add a label and trusted server handler here.
class DSDS_DebugMissions {
    class SPECIAL {displayName="Start Special Convoy";handler="DSDS_fnc_startDebugConvoy";variant="SPECIAL";};
    class ISOTOPE {displayName="Start Isotope Convoy";handler="DSDS_fnc_startDebugConvoy";variant="ISOTOPE";};
    class MEDICAL {displayName="Start Medical Convoy";handler="DSDS_fnc_startDebugConvoy";variant="MEDICAL";};
    class CONTAMINATION {displayName="Start Contamination Response";handler="DSDS_fnc_startDebugResponse";variant="CONTAMINATION";};
    class ISOTOPE_STASH {displayName="Start Industrial Isotopes Stash";handler="DSDS_fnc_requestContrabandStash";variant="INDUSTRIAL";};
    class STASH {displayName="Start Contraband Stash";handler="DSDS_fnc_requestContrabandStash";variant="STASH";};

 class TOOL_MYSTIC {displayName="Respawn Mystic at saved location";handler="DSDS_fnc_runDebugTool";variant="MYSTIC";};
 class TOOL_MYSTIC_HERE {displayName="Respawn Mystic HERE";handler="DSDS_fnc_runDebugTool";variant="MYSTIC_HERE";};
 class TOOL_MYSTIC_REVEAL {displayName="Reveal Mystic location";handler="DSDS_fnc_runDebugTool";variant="MYSTIC_REVEAL";};
 class TOOL_FENCE {displayName="Relocate Fence and refresh stock";handler="DSDS_fnc_runDebugTool";variant="FENCE";};
 class TOOL_FENCE_CRATE {displayName="Recover community trade crate";handler="DSDS_fnc_runDebugTool";variant="FENCE_CRATE";};
 class TOOL_MECHANIC {displayName="Respawn PMC mechanic HERE";handler="DSDS_fnc_runDebugTool";variant="MECHANIC";};
 class TOOL_ARSENAL {displayName="Repair arsenal restrictions and unlocks";handler="DSDS_fnc_runDebugTool";variant="ARSENAL";};
 class TOOL_TERMINAL {displayName="Equip Support Terminal";handler="DSDS_fnc_runDebugTool";variant="TERMINAL";};
 class TOOL_LOOT {displayName="Spawn valuables test crate";handler="DSDS_fnc_runDebugTool";variant="LOOT";};
 class TOOL_MEDICAL_LOOT {displayName="Spawn injector test crate";handler="DSDS_fnc_runDebugTool";variant="MEDICAL_LOOT";};
 class TOOL_RAID {displayName="Start HQ noise raid";handler="DSDS_fnc_runDebugTool";variant="RAID";};
 class TOOL_RAID_RESET {displayName="Reset HQ raid cooldown";handler="DSDS_fnc_runDebugTool";variant="RAID_RESET";};
 class TOOL_STATUS {displayName="Report addon status (Zeus only)";handler="DSDS_fnc_runDebugTool";variant="STATUS";};

 class TOOL_SUPPORT_SMOKE {displayName="Test support - Smoke";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_SMOKE";};
 class TOOL_SUPPORT_FLARE {displayName="Test support - Illumination";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_FLARE";};
 class TOOL_SUPPORT_SUPPLY {displayName="Test support - Supply drop";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_SUPPLY";};
 class TOOL_SUPPORT_VEH_AIRDROP {displayName="Test support - Vehicle drop";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_VEH_AIRDROP";};
 class TOOL_SUPPORT_RECON {displayName="Test support - Recon";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_RECON";};
 class TOOL_SUPPORT_PARADROP {displayName="Test support - Parachute transport";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_PARADROP";};
 class TOOL_SUPPORT_LOOTHELI {displayName="Test support - Loot helicopter";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_LOOTHELI";};
 class TOOL_SUPPORT_HE {displayName="Test support - HE strike";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_HE";};
 class TOOL_SUPPORT_CLUSTER {displayName="Test support - Cluster strike";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_CLUSTER";};
 class TOOL_SUPPORT_NAPALM {displayName="Test support - Napalm strike";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_NAPALM";};
 class TOOL_SUPPORT_CHEMICAL {displayName="Test support - Chemical strike";handler="DSDS_fnc_runDebugTool";variant="SUPPORT_CHEMICAL";};
};
