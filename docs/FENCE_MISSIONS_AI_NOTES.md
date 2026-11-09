# Fence fixes, mission debugging and AI compatibility — v2.2

Updated 2026-11-07. Target: Antistasi Ultimate12.0.3. Builds on v2.1 and keeps its injector prices, artwork, effects and medical-loot sources. No Workshop original, campaign save, faction relationship, map choice or territory ownership is changed.

## Installed AI mods

| Mod actually inspected | Workshop ID | Installed source |
|---|---|---|
| Ai accuracy fix | 619834340 | `addons/tws_aimfix.pbo` |
| AI behavior modification | 3641926249 | `addons/AI_BM.pbo`; core config declares1.6 |
| LAMBS_Danger.fsm (DEV) | 2434257231 | `lambs_danger`, `lambs_main`, `lambs_eventhandlers`; mod.cpp declares2.6.2 |

All three are included in the updated automated test helpers. Enable them alongside the existing preset on the host/server and clients. They remain optional companion integrations, not new hard dependencies. Removing them does not make Support Services fail to load.

Accuracy Fix's installed script makes one server-side pass over each unit. It changes general/command/spotting/reload skills as well as aim. Addon-owned combat units now retain their requested tactical training after that pass, while its aiming accuracy/shake/speed values remain intact. Its accuracy expression is **0.01 + random0.3**, so values up to0.31 are expected. Stash guards retain0.85 general/commanding/spotting/reload training. The helper also handles an already-processed unit without resetting its aim. It never replaces the mod's global loop or edits its processed-unit list.

LAMBS keeps its danger FSM and tactics on combat infantry. Only our stationary Fence/mechanic and scripted aircraft crews opt out of autonomous manoeuvres through the installed `lambs_danger_disableAI`/`lambs_danger_disableGroupAI` variables. Debug convoy driver groups retain their route. Targeting/self-defense on the mechanic stays enabled. Native Petros, global AI settings and faction templates are untouched. AI Behavior Modification's brain/weapon configuration is retained; no competing global AI override is added.

Read-only references are under `reference/ai_compat`. Startup logs report detection of each mod. Upstream configuration/model warnings can still occur (including AI_BM's `CfgWeapons/manual` warnings); zero SQF errors does not mean every third-party startup warning was removed. Long-campaign combat balance and HC locality still require playtesting.

## Contraband lead repair

The Fence transaction was reached through remote execution, but its spawned stash worker rejected `isRemoteExecuted`; direct server tests had missed this boundary. Authenticated requests now enter a server queue drained by a background script outside RPC context. The private workers keep their remote-execution rejection. A worker-completion guard releases a stuck pending request and reports failure rather than leaving the button silent. The button also closes the trader dialog so feedback/map use is accessible, and no longer reads an invalid shop row for a non-purchase operation.

The normal lead is still free, requires speaking to Fence within6m and preserves the45-minute lead cooldown. An active lead reports its marked grid instead of creating another. Safe placement searches roadside land1.8–6.5km from the requester, away from HQ and players. Failures produce a private message and diagnostics.

Each successful lead creates a real **Contraband Stash** task and orange public map marker. It contains30 items, guaranteeing at least three of each: Marijuana, Cocaine, Methamphetamine, Nicotine Vapes and Zyn. The extra15 selections come only from those five goods; medical injectors and industrial convoy valuables stay separate.

The inventory container uses a verified free base-game scenery model: sacks in rural surroundings, garbage bags/pallets near buildings. These are real inherited inventory containers, not decorative props with inaccessible hidden cargo. They retain1500 inventory mass capacity and normal pickup/gear interactions. No new artwork was needed.

Three squads, normally12–18 guards total, use the active occupying faction. They have distinct generated public group IDs such as “Copper Ravens”; the task description lists those names. They patrol the stash with high tactical skill and normal LAMBS combat behavior. Clearing the guards completes the task; destroying the stash fails it. Existing contents are not deleted at task completion.

## Community trade crate

One server-owned `DSDS_fenceCommunityBox` replaces the per-UID crate map. **Request / locate community crate** returns the same live object for every player, including gear purchases. The object has no personal `ownerX` UID. Existing personal money, boat storage and vehicle delivery rules remain.

Quotes remain personal, expire after60seconds and include the full server-valued manifest plus the crate's trade revision. A quote reserves nothing. The first valid **confirmed sale** consumes the goods and credits that seller's personal wallet. Other players' stale quotes cannot pay again, including when someone later deposits an identical replacement manifest. Unsupported ordinary gear or mixed cargo is retained and rejected as before.

The same free-standing crate moves with Fence's camp, preserving its cargo. Attached, roped or vehicle-loaded crates stay where they are; the locate action reports their grid and does not create a replacement. Bring one back within40m to trade. Historical user-owned crates are not arbitrarily deleted. This revision does not migrate or erase campaign cargo.

## Zeus developer missions

In Zeus **Modules → DEBUG**, place one of these modules on dry ground near a road:

1. **Start Special Convoy** — real faction cargo truck and two escorts, actual connected-road driving route, live task/position marker, all seven Special Convoy valuables. Uses the production cargo, salvage, alert, reinforcement and helicopter-pursuit functions.
2. **Start Isotope Convoy** — the same complete mission structure with sealed isotope cargo. Destroying it invokes the production Chemical Warfare PLUS cloud wrapper. CWP must be loaded on server/clients.
3. **Start Contraband Stash** — creates the actual guarded stash near the module, bypassing the ordinary lead cooldown for testing. It still avoids creating a second active stash.

No settings dialog or manually placed truck is required. Convoys approach the selected area from a connected-road spawn away from players. Unsafe/missing road routes, unavailable faction assets and missing chemical support produce messages without faction substitution. There are at most three active debug convoys, including queued requests; completed missions allow new starts.

Capture/recover the truck or take Special cargo to complete its task. Isotope truck destruction fails its task. Convoys otherwise end after escape grace at the destination or a30-minute timeout. Completed debug tasks/markers and unclaimed escort assets clean up after a delay when players are far away. Loot trucks, recovered goods, captured assets and player-occupied assets are protected. Production spotting helicopters continue tracking Special goods until destroyed, including after recovery completes the debug task.

The DEBUG RPC requires a living owned player with an assigned curator and a valid mission/map position. It accepts only the static config registry, not arbitrary SQF, classnames or prices. Existing object-designation modules remain available. Convoy upgrades arriving from HC/designation and loot-triggered alerts also drain through non-remote server queues, fixing the same protected-worker boundary without weakening worker authentication.

Future custom missions add a `DSDS_DebugMissions` entry in `debug.hpp` with displayName, registered trusted server handler and variant. Client registration automatically adds its one-step starter through the installed ZEN `zen_custom_modules_fnc_register` API. Keep future mission lifecycle/cleanup inside its handler. This registry is for companion custom missions, not an override of native Antistasi mission selection.

## Files

Created in `projects/antistasi_support_services/addons/dsds_support`:

- `debug.hpp`, `stash.hpp`.
- `functions/fn_configureAddonAI.sqf`.
- `functions/Fence/fn_fenceCommunityCrate.sqf`.
- `functions/Smuggling/fn_createStashContainer.sqf`, `fn_generateGuardName.sqf`.
- `functions/Debug/fn_initCustomMissions.sqf`, `fn_queueCustomMission.sqf`, `fn_debugMissionRequest.sqf`, `fn_startDebugConvoy.sqf`, `fn_tickDebugMission.sqf`.

Modified addon files:

- `config.cpp`:v2.2; nine new function registrations, one curator RPC, scenery-container classes/includes and base-game asset dependencies.
- Fence: `fn_initFence`, `fn_fenceTransaction`, `fn_fenceDelivery`, `fn_fenceSubmit`, `fn_fenceRotate`, `fn_fenceTab`, plus `fence.hpp`.
- Smuggling: `fn_requestContrabandStash`, `fn_initSmuggling`, `fn_smugglingUnit`, `fn_smugglingVehicle`, `fn_convoyObserved`, `fn_smugglingRequest`.
- `functions/Loot/fn_fillLootContainer`, `functions/HQRaid/fn_spawnRaidUnit`, `functions/fn_createMechanic`, `fn_spawnSupportAircraft`, `fn_initServices`.
- Project `mod.cpp`, root/project READMEs and handoff.

Tests: new `scripts/Test-FenceMissions.ps1` and `tests/support_services/dsds_fence_missions.Altis/{mission.sqm,description.ext,initServer.sqf}`. Updated Fence/Expansion scripts load the three AI mods; Fence's script also stops reusing PowerShell's automatic `$PROFILE` name. Fence, Expansion and Loot fixtures now use community-crate/expanded-stash semantics. Test-only remote relay functions live only in the fixture and are never packed into the addon.

## Verification and remaining acceptance

**321 passing checks, zero failures or SQF errors**, with all three new AI mods enabled:

- Fence126: `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_20-22-57.rpt`. Includes two users sharing one crate, first confirmed seller paid exactly once, stale quotes rejected even with identical replacement goods, and prior stock/FPV/AA/boat/payment checks.
- Expansion151: `logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_20-22-57.rpt`. Includes expanded stash contents, functioning camouflaged inventory, named guard groups, medical loot, injector effects, rare convoy response/salvage/pursuit, isotope release and actual stash completion.
- Focused missions44 on the final published PBO: `logs/fence-missions-validation-ultimate/arma3server_x64_2026-11-07_20-32-57.rpt`. Includes a real remote boundary into the Fence transaction, queued stash creation, native task/marker, correct Accuracy Fix range and retained tactical skills, LAMBS flags/FSM/AI_BM config, real moving three-vehicle Special Convoy with all seven goods, queued alert and large helicopter response, remote-origin queued cargo upgrade, separate isotope start/cloud/failure lifecycle and debug stash cooldown bypass.

Fence/Expansion used the preceding verified candidate, before final aim-race and convoy-queue tightening. The final focused run exercises those changes; do not claim every component used byte-identical builds. CfgConvert passed. All106 function registrations match106 source functions, all referenced DSDS functions are registered, and build extraction compared all134 packed files against source with zero differences.

Published `build/@AntistasiSupportServices/addons/dsds_support.pbo` SHA256:

```text
7CEB159385C4B6404612DAFB8A647679360C63584BE3A7E1B1E79D22B2AEF3B6
```

The original Dynamic Supply Drops PBO remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`. Logs/source fixtures are retained. Owned test servers are stopped after exact PID/executable/profile/port checks; copied validation missions are removed after checking their marker/file inventory. No normal user game process is stopped.

An intermediate focused run passed43 checks, including a real remote Fence transaction producing a stash, actual driving Special Convoy, its large helicopter response, isotope start/destruction and debug stash cooldown bypass. An earlier run exposed two **fixture** issues: its aim threshold incorrectly omitted Accuracy Fix's0.01 offset, and native group cleanup needed the fixture's `distanceSPWN` value. Both were corrected; they are not hidden as successful runs.

Human acceptance: restart Arma/server with the rebuilt companion and enable the three AI mods alongside the existing dependencies. Friends need the same updated companion. Use Fence's button and check the Tasks/map display; inspect the bag/rubbish pile inventory; verify generated guard names in Zeus. Test two-player quote/sale competition. Open Zeus Modules and search **DEBUG**, place Special Convoy near a road, attack/recover it, then test isotope/stash variants away from base. Actual client UI/interaction, two-human network timing, HC ownership and CWP rendering/exposure still need acceptance. No campaign reset is required.
