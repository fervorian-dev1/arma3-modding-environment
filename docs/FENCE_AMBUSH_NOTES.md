# Fence sniper overwatch — companion v3.3, 2026-11-08

## User request and interpretation

After the third unique visit, players should intermittently encounter two teams of four snipers watching Fence's entrance and ambushing them. Implemented as shared faction visit episodes, not purchases, menu clicks, UIDs or each squadmate separately. No new task, map marker or player-facing warning.

## Behavior

- First living rebel/civilian player arrival within80m of current Fence starts one visit. Several squadmates and repeated menus/loitering count once. Uses actual3D distance so high flyovers do not count. Everyone must clear180m horizontally for60seconds before another arrival counts.
- After three completed visits, each departure permits one40% setup roll for the next return. It is not a guaranteed ambush on the third visit. Rolls wait until every player is900m away; no repeated rerolls while standing away. Failed terrain/role searches skip that opportunity rather than spawning exposed troops. One active ambush maximum.
- Exactly two groups of four actual occupying-faction snipers. Native Ultimate `groupTierSniper` tier pair's first role is used (war<5 /5–7 /8+), with verified registered-role fallbacks. No arbitrary AAF/NATO substitution or faction-relation changes. Skill0.85 uses existing optional Accuracy Fix integration; global aiming settings remain in force.
- Two separated overwatch anchors220–550m from camp, generally high ground, with terrain/geometry line to the tent's approach. Search across opposing half circles,90 candidates/team, with8m object clearance for four prone snipers. No player within600m of candidate or with a VIEW sight line; final camp900m clearance checked again. No forced fallback coordinate.
- Snipers stay prone in overwatch, hold fire, and use native AI targeting/fire when a living non-captive visitor returns within80m. No all-map reveal, chemical/QRF trigger or player teleport. LAMBS roaming is disabled only on these fixed overwatch units; other AI/global settings unchanged. Player kills/captures are normal.
- Retire on Fence death/disappearance/relocation,30-minute expiry or no remaining hostile noncaptive survivors. Retired teams stop assigned targeting. Existing generic cleanup tick retains nearby bodies/troops until players are1200m away and preserves captured/player-controlled/side-converted units. No deleting loot in front of players. It does not remove unrelated units/vehicles.
- Visit count continues across Fence relocations within the mission session. Counter and encounters reset on mission restart; no campaign-save format change. No changes to Fence stock, prices, relocation interval, community crate or financial transactions. No fees or new dependencies.

## Exact files

New addon functions:
- `functions/Fence/fn_tickFenceVisits.sqf`: shared episode tracking, engagement, cleanup and one setup roll.
- `functions/Fence/fn_spawnFenceAmbush.sqf`: native sniper role validation, hidden firing-position search and eight-unit encounter.

Modified addon files:
- `functions/Fence/fn_initFence.sqf`: one existing-initialization-guarded server loop, waits for serverInitDone, ticks every5seconds.
- `config.cpp`: register both functions, version3.3.

Project README/mod metadata, focused fixture and HANDOFF updated.168 DSDS functions/205 packed source files. No new remote-execution entries; both functions reject remote execution. Optional observer/time/roll arguments are private trusted engine-fixture seams, not player-facing options. Placement worker runs scheduled on server; no client loops or added player event handlers.

## Validation / provenance

Focused engine run **66 PASS/0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-53-58.rpt`: actual eight armed native sniper units in two groups of four, role/side/prone stance/AI, episode gates and no repeated rolls, return engagement, no stacking, relocation retirement and distance/captive cleanup. Existing49 convoy/parachute/Money checks retained. Expansion regression **210 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_07-53-58.rpt`. Both have no SQF expression errors. A final focused run after tightening proximity from2D to3D is recorded below before publication.

Earlier failed runs are retained: arbitrary test camp inside obstructed terrain exposed a one-sided LOS search and was replaced with a proper flat clear camp matching Fence's existing placement contract; production search was widened and diagnostics added. A cleanup assertion needed a frame delay after Arma deleteVehicle; final cleanup passes. These failures are not counted as passes.

Tests use server-owned observer AI and real server-created units, with fixture-only diplomacy and native role structure. They verify actual spawning, native engagement commands and cleanup, not a human squad's rendered view/damage outcome or every map/faction. Installed native source confirms custom role layout; a fresh full player visit cycle still needs acceptance. Future terrain/configurations may legitimately skip a setup if no two hidden firing positions exist. No claim of invisible spawn guaranteed against every mod's sensors.

## Player test and update

Restart host/server and every client with whole standard `build/@AntistasiSupportServices`. No campaign reset or Launcher re-add. Make three separate arrivals, leaving the180m area for a minute between them. After the third, leave900m to permit secret setup; on later return, an ambush is possible (40%, not guaranteed). Repeated menu use will not force it. No debug button was added: this is a silent world encounter, not a new task mission.

Final focused rerun after3D-distance tightening: **66 PASS/0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-56-27.rpt`, no SQF expression errors. Earlier210-check expansion run preceded only that two-expression proximity adjustment; no other gameplay changes followed it. CfgConvert and pack/extract/source-hash checks pass. Published v3.3 standard folder SHA256 `CE44E79F1B7AD234405B5506A622CF895F939BD25CCB9D365E4841DB5403E635`. Original supply-drop PBO unchanged. All owned test servers stopped, reusable fixture/logs retained; no user game stopped.
