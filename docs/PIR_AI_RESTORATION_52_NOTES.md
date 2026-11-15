# PiR AI injuries restored, player knockdown disabled — v5.2

The v3.8 native-revive bridge was too broad: it forced both `PiR_injuriplayer_on=false` and `PiR_injuriAI_on=false`. The second setting prevented PiR from registering its AI hit/injury callbacks, removing the enemy injury/knockdown behavior the user wanted to keep.

The installed PiR separates these paths. Its `PiRinitStart` initializes nonplayer injury handlers only when `PiR_injuriAI_on` is enabled; `PiRinitStart0` uses the independent player setting. PiR's native animation, crawl and unconscious routines are still installed. The addon AI compatibility worker does not disable them.

## Fix

`functions/Loot/fn_initPiRRescue.sqf` now enforces:

- `PiR_injuriplayer_on=false`: players keep native Antistasi incapacitation/revive instead of PiR's forced crawl/knockdown system.
- `PiR_injuriAI_on=true`: restore native PiR AI injuries, knockdowns and associated reactions.

Applies before/after initialization, on CBA settings synchronization, and through the existing five-second compatibility worker, including host/server/client/JIP. Other PiR tuning (animation preference, body-part probabilities, armor, bleeding, AI healing and side filters) is left as configured. Not every hit should knock an enemy down.

The native medical-item bridge remains: PiR bandages and medkits are accepted by Antistasi's existing teammate Revive. Existing player-only `physicalDownState`, `nativeReviveKeys` and `repairReviveUI` protections remain unchanged: an actually downed player retains the native key path, while a conscious recovered player cannot trigger stale R-to-respawn; the monitor removes the stale flag and exact respawn handler without healing or invulnerability. Existing injector consumption/use limits are unchanged.

**Full Arma restart on every client and host/server is required.** PiR decides whether to attach injury handlers when units initialize. The update does not delete or rebuild arbitrary live-unit handlers; already-created AI in the old session need a fresh mission startup. No campaign reset, user-save edit or Workshop-file edit is needed. This does not promise to cure unrelated network/medical-mod bugs.

## Files

Gameplay: `functions/Loot/fn_initPiRRescue.sqf` only. Version entries in addon config.cpp and project mod.cpp bumped to5.2; standard companion PBO rebuilt. Added isolated `dsds_pir_split.VR` client fixture and `scripts/Test-PiRSplitClient.ps1`; README and handoff updated. The historical v3.8 notes are marked superseded for AI behavior. Casino, loot, AI tactics/accuracy, factions/maps and supply-drop implementations are not changed for this fix.

## Validation

Official configuration compilation and candidate PBO extraction/source-hash verification passed (227 functions). A separate player-client fixture checks real installed PiR AI handler registration, player handler absence, settings reapplication without duplicated handlers or medical supplies, actual AI hit animation/unconscious branches, and actual owner-side stale respawn-key protection following recovery. Only fixture-local probabilities are adjusted temporarily to make the AI unconscious branch deterministic; production injury probabilities are not changed.

Final engine run: **14 passed, 0 failed**, actual local player and installed PiR AI routines. Startup and periodic split, real AI callbacks/animations, native medical items, duplicate protection and recovered-player R-key/flag cleanup all passed. Health stayed0.35 across the repair interval and damage remained enabled. The first fixture mixed AI injury and player-health checks; the repeat removes test AI before evaluating the player monitor and compares health across that monitor interval.

The installed third-party AI `PiR/Functions/Uncondition.sqf` logged an undefined `_dummy` diagnostic (line543). AI reached the unconscious state; this is recorded rather than claiming an entirely error-free PiR log. No DSDS expression error was observed, and no PiR/Workshop code was modified. This is another reason to keep actual players outside PiR's down-state path.

Final results are also recorded in HANDOFF.md. Two-human multiplayer teammate treatment, headless-client transfer and rendered subjective combat feel still need normal in-game acceptance. No user campaign files are touched by the tests.
