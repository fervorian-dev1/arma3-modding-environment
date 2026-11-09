# Host enemy-spawn optimization — companion v3.6, 2026-11-08

## Request and diagnosis boundary

User reports frame drops primarily on the host when enemies render in. The current setup is a player-hosted multiplayer mission (host runs local rendering and server AI/creation). The latest available real-game RPT remains `Arma3_x64_2026-11-08_10-58-05.rpt`; samples grow from117 to162 AI with serverFPS about106 to71–77. These averages do not measure individual spawn-time frame spikes or identify GPU texture/LOD stalls. No claim that one specific mod is proven responsible.

Installed Ultimate12.0.3 A3A_fnc_createUnit and the installed Accuracy Fix source were inspected. The native factory applies custom base classes, loadouts, identities, traits and unitType. Our previous optional AI integration additionally created one waiting polling script per addon unit. This release keeps native factory behavior and reduces burst scheduling/compatibility overhead rather than lowering population/skills or changing graphics/global AI settings.

## Changes

- One CfgFunctions CREATE/createUnit entry adapter lazily compiles/delegates to the installed original file. On **isServer && hasInterface && canSuspend**, hostile east/west/resistance groups share an atomic50ms interval between native-factory reservations. Concurrent scheduled reinforcement scripts share the same gate. It never truncates a wave or substitutes loadouts. Slower individual unit creation naturally exceeds the interval without extra waiting.
- Friendly/rebel/civilian units, unscheduled callers, non-host clients, dedicated servers and HCs bypass pacing and use original synchronous creation. No yielding from an unscheduled caller and no delayed object-return API. The group side and actual relation to teamPlayer determine hostility; no faction relation changes.
- This covers enemies created through Antistasi's factory. Engine createUnit/createGroup commands used directly by other mods and pure rendering/texture/LOD/model streaming of already existing units are not intercepted. A single expensive model/loadout can still stall; this is not a global GPU fix or a guaranteed FPS increase.
- Optional Accuracy Fix integration now has one lazily started, atomically guarded server worker and a shared pending queue. It checks at most8 entries every0.5seconds, dropping deleted/dead units and requeueing units until the installed Accuracy Fix has marked them. It restores exactly the prior tactical skills (general/commanding/courage/spotting/reload) and leaves aiming values alone. No per-unit sleeping DSDS script. Existing fixed/flight LAMBS exclusions and all other units/settings remain unchanged. At very large queues the tactical restoration can occur later than the old per-unit polling.

## Inventory

New addon files:
- `functions/Compatibility/nativeCreateUnit.sqf` — configured native entry adapter.
- `functions/Compatibility/fn_tickAICompatibility.sqf` — bounded shared work pass.

Modified addon files: `config.cpp` (version3.6, native file entry, one DSDS registration) and `functions/fn_configureAddonAI.sqf` (enqueue/lazy worker).

Project README/mod metadata/HANDOFF updated. New independent fixture `tests/support_services/dsds_hostspawn.Altis/{mission.sqm,description.ext,init.sqf}` and launcher `scripts/Test-HostSpawnClient.ps1` use their own profile/mission/autotest config. Native factory/source Workshop files are read, not edited.177 registered DSDS functions/216 packed files including3 configured native entry adapters.212 prior addon files unchanged fromv3.5; previous convoy/arsenal/revive/Mystic/Fence fixes retained.

## Tests / limits

- Dedicated expansion **214 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_12-18-53.rpt`.
- Dedicated convoy/native-driving regression **86 PASS/0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_12-23-13.rpt`.
- Fence/AI/mission regression **37 PASS/0 FAIL**, `logs/fence-missions-validation-ultimate/arma3server_x64_2026-11-08_12-23-14.rpt`.
- Actual local player-host engine test preliminary **15 PASS/0 FAIL**, `logs/hostspawn-client-validation/arma3_x64_2026-11-08_12-24-10.rpt`: all requested units preserved, registered custom loadout/type, native factory delegation, host pacing, two concurrent reinforcement workers, friendly and unscheduled bypass, bounded queue/restored tactical skills/unchanged aiming.12 custom hostile units took1.197seconds with minimum reservation spacing. This is scheduling/functionality evidence, **not a baseline-versus-updated FPS benchmark**. The fixture is single-player authority with isServer/hasInterface true, matching the pacing branch on a listen host; a real two-human multiplayer campaign still needs acceptance.
- First13-check prototype run had missing fixture faction identity maps and is NOT a clean passing engine run; maps were added to the fixture, not a gameplay identity workaround. Interrupted boots/runs are retained. Native original identity/loadout behavior is unchanged.
- Final repeat below also tests normal automatic worker startup/duplicate configuration after tightening worker startup to be atomic. Earlier dedicated regressions precede that small startup-guard refinement; factory and queue tick code remain the same.

## Deployment and practical check

Full restart host and all clients with whole standard build/@AntistasiSupportServices. No campaign reset or Launcher re-add. Compare the same enemy-activation encounter on the host after restart; note whether spawn-time hitches improve. Counts, equipment, AI mods/aim settings, draw/spawn distances, convoy delays, graphics and map/faction/save state remain. Actual multiplayer frame-time/FPS improvement is not measured here. All test processes are owned/isolated; their final stop/publication hash are recorded below.

Final actual player-host engine run **17 PASS/0 FAIL**, `logs/hostspawn-client-validation/arma3_x64_2026-11-08_12-26-17.rpt`, zero SQF expression errors. Includes normal background-worker activation, duplicate configuration suppression, bounded tick behavior, two concurrent actual reinforcement workers and the original count/loadout/bypass/aim-preservation checks. Earlier final dedicated suites also have zero expression errors. Combined tested assertions17+214+86+37=354; no FPS uplift benchmark is claimed.

Published standard companionv3.6 PBO SHA256 `F7EFDFBE03F47CEB0D6E6084E7B6DAFDBBE1A2805FE10C4244EC958BF4677C74`. CfgConvert and fresh candidate extraction/per-file hashes pass.177 DSDS functions/216 packed source files. All owned test processes finished/stopped; fixture/profile/autotest copies/logs retained. Original supply-drop addon unchanged. No user's normal game was stopped.
