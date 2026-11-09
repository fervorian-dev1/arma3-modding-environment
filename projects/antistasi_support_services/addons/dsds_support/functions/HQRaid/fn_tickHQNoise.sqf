if (!isServer || {isRemoteExecuted} || {isNil "DSDS_noise"}) exitWith {};
private _now = diag_tickTime;
private _elapsed = 0 max (10 min (_now - (DSDS_noise get "lastTick")));
DSDS_noise set ["lastTick",_now];
private _phase = DSDS_noise get "phase";
if (_phase == "active") exitWith {};
private _petros = missionNamespace getVariable ["petros",objNull];
if (isNull _petros || {!alive _petros} || {!isNull attachedTo _petros} || {DSDS_raidConfig get "enabled" == 0}) exitWith {
    DSDS_noise set ["phase","quiet"]; DSDS_noise set ["score",0]; DSDS_noise set ["hq",[]];
};
private _hq = getPosATL _petros;
private _oldHQ = DSDS_noise get "hq";
if (_oldHQ isEqualTo [] || {_oldHQ distance2D _hq > 50}) then {
    DSDS_noise set ["phase","quiet"]; DSDS_noise set ["score",0]; DSDS_noise set ["hq",_hq];
    _phase = "quiet";
};
if (_phase == "recovery") exitWith {
    if (_now >= (DSDS_noise get "readyAt")) then {DSDS_noise set ["phase","quiet"]; DSDS_noise set ["score",0];};
};
if (_phase == "quiet") exitWith {
    if (missionNamespace getVariable ["bigAttackInProgress",false]) exitWith {DSDS_noise set ["score",0];};
    private _score = 0 max ((DSDS_noise get "score") - _elapsed * (DSDS_raidConfig get "decayPerSecond"));
    DSDS_noise set ["score",_score];
    if (_score >= (DSDS_raidConfig get "threshold")) then {
        DSDS_noise set ["phase","preparing"]; DSDS_noise set ["score",0];
        DSDS_noise set ["dueAt",_now + (DSDS_raidConfig get "responseDelay") + random (DSDS_raidConfig get "responseRandom")];
        DSDS_noise set ["expiresAt",_now + 900];
        diag_log "[DSDS HQ] Player noise threshold reached; one occupier raid preparing.";
    };
};
if (_phase != "preparing") exitWith {};
if (_now > (DSDS_noise get "expiresAt")) exitWith {DSDS_noise set ["phase","quiet"]; DSDS_noise set ["score",0];};
if (_now < (DSDS_noise get "dueAt") || {missionNamespace getVariable ["bigAttackInProgress",false]}) exitWith {};
// Reserve before spawning: another tick cannot create a duplicate raid.
DSDS_noise set ["phase","active"];
DSDS_noise set ["generation",(DSDS_noise get "generation") + 1];
private _raid = createHashMapFromArray [["id",DSDS_noise get "generation"],["hq",_hq],["petros",_petros],["ended",false],["vehicles",[]],["units",[]],["groups",[]],["pads",[]],["infantry",[]],["landingsDone",0],["landingsTotal",0]];
DSDS_noise set ["raid",_raid];
[_raid] spawn DSDS_fnc_runHQRaid;
