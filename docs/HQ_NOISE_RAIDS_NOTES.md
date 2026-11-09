# Noise-triggered HQ raids — v1.4, 2026-11-07

User authorized the proposed noise-driven raid. Preserve working support/PMC features and all campaign faction selections, maps, relationships and location/airfield ownership. User confirmed the AAF airfields were correct; there is no faction state to repair.

## Implemented behavior

- Player-local FiredMan handlers register once per player body and cover personal/mounted weapons. Reports batch every 0.5 seconds. Server verifies actual living player, owning connection, friendly side, record shape/rate, ammo config and distance to deployed HQ. Internal application is scope-guarded. Enemy/native/contractor AI cannot report noise.
- Throw/Put explosives attach an Explode projectile handler: placement itself is silent. Weights: small arms 1, suppressed shots 0.1, loud cannon/rocket/HE shots 15, detonations 40; smoke/flares zero. Radius 300 m; decay 1/second; threshold 300. No voice/chat, footsteps or engine-volume monitoring.
- quiet → preparing → active → recovery → quiet. Threshold consumes score; preparation 90–180 seconds. Ignore noise while preparing/active/recovering or defending a native major attack. No queued battle noise. Recovery 60 seconds; time alone cannot trigger another raid. Pending deployment expires if native attacks block it too long. HQ movement/death clears suspicion and ends an active raid. Mission restart resets ephemeral raid state.
- Native war level bands 1–3 / 4–6 / 7–10 select 20–25 / 30–35 / 40–50 airborne troops and 1–2 / 2–3 / 3–5 trucks/light vehicles. Crews are additional. Up to 12 infantry per helicopter, limited by actual cargo seats. All types come from selected occupier templates and native loadout IDs. No hardcoded AAF fallback, tanks or extra truck squads.
- Flat, dry, spaced LZs 800–1,200 m away with a sampled land-only infantry approach. Helicopters start on distant separated approaches above sea/terrain. Ground vehicles prefer roads and hidden safe positions. Distance/LOS rejects close visible ground spawns. Native AI lands with GET OUT/owned temporary helipad; infantry dismount and MOVE/SAD toward HQ; transports depart. Watchdogs bound failed landings; no airborne forced dismount.
- Raid ends on <25% capable infantry after landings, 30-minute assault timeout, Petros loss, HQ movement or native major-attack overlap. Survivors retreat. Captive groups split for retreat without ordering captives. Cleanup only recorded raid entities outside proximity/sight, preserving captives, converted/player-controlled units, ownership tags and attached/towed/transported assets. Native major-attack globals are read, never set.

## APIs and integration

Inspected installed Antistasi Plus 2.3.2 `attackHQ`, `createAttackForceMixed`, `createAttackVehicle`, `combatLanding`, `createUnit`, `createVehicleCrew`, `loadFaction`, `compileGroups`, `registerUnitType`, tier helpers and enemy death/deletion handlers. Existing HQ attack adds UAV/artillery/resources/tasks, so it is not called or replaced. Existing `landHelicopter` uses shared globals/frame handlers; `combatLanding` includes unconditional RTB deletion. Independent landing/cleanup preserves captured assets.

`A3A_fnc_createUnit` applies actual custom-template loadouts. Explicit group joining prevents inherited config sides from overriding Occupants. Real campaigns keep native enemy HandleDamage/Killed handling for normal medical, combat rewards and postmortem behavior. No native Deleted resource-refund handler or garrison marker is installed, avoiding free resource returns or garrison mutations on cleanup. Normal combat and Petros death keep their existing Antistasi consequences.

Official references: [FiredMan / Explode event handlers](https://community.bistudio.com/wiki/Arma_3:_Event_Handlers), [BIS_fnc_findSafePos](https://community.bistudio.com/wiki/BIS_fnc_findSafePos). Tested game 2.22.154089; existing dependencies retained. 3CB is the current faction/test asset provider, not an unconditional new addon dependency.

## Files

Modified `projects/antistasi_support_services/addons/dsds_support/config.cpp` for version, postInit, registrations, report RPC and defaults; `scripts/Build-SupportServices.ps1` for recursive function verification; project/workspace README and support notes. Existing Services SQF files remain unchanged.

Updated project `mod.cpp` launcher tooltip/overview to mention HQ noise raids.

Created under `projects/antistasi_support_services/addons/dsds_support/functions/HQRaid/`:

```text
fn_initHQRaid.sqf
fn_registerNoisePlayer.sqf
fn_noiseFired.sqf
fn_reportHQNoise.sqf
fn_noiseWeight.sqf
fn_applyHQNoise.sqf
fn_tickHQNoise.sqf
fn_planHQRaid.sqf
fn_runHQRaid.sqf
fn_spawnRaidUnit.sqf
fn_landRaidHelicopter.sqf
fn_endHQRaid.sqf
fn_cleanupHQRaid.sqf
```

Created these notes, `scripts/Test-HQNoiseRaid.ps1` and `tests/support_services/dsds_raid.VR/{mission.sqm,description.ext,initServer.sqf}`. Test uses loopback-only port 24346, isolated profile and the actual 3CB AAF template through native builders/registration. It never loads a user campaign. Fixture-only diplomacy enables test combat; production never calls setFriend.

## Validation and limits

Initial physical test passed: 22 airborne troops, two real helicopters and two ground vehicles from 3CB AAF. Helicopters landed 862/981 m from HQ, dismounted infantry advanced, defeat ended the raid, captured/captive assets survived cleanup, fresh noise was needed for another preparation and HQ relocation cleared it. Templates/airfield markers stayed intact. Final candidate also excludes defensive fire during native major attacks, weights AP cannon fire, splits captive groups on retreat and cancels a failed force below 20 boarded troops. Final results/hash are recorded below.

Headless tests cannot prove human FiredMan reporting/positive remote sender acceptance, human respawn/JIP, client-view spawn hiding or the full placed-explosive client path. Scoring uses a scope-authorized server-local actor; public reporting rejects that non-player actor. Physical faction/loadout/landing/foot movement is tested with installed engine/assets. Native death/ACE interactions in a real campaign, difficult island LZs, individual mod helicopter reliability and large war-level-10 live battles need in-game acceptance. Captured asset saving follows native Antistasi; no new vehicle persistence is added. Normal native HQ attacks remain independent of this noise feature.

## Final verification — 2026-11-07

- Final dedicated raid run: `logs/hq-noise-raid/arma3server_x64_2026-11-07_04-10-04.rpt`: **83 passes, zero failures, zero SQF expression/position errors**. Uses actual installed 3CB AAF loadouts/assets with native template builders. Final live force: 22 airborne infantry, three helicopters, two ground vehicles; unloads of 8/4/10 infantry at 1,155/1,015/1,087 m from HQ. Infantry advanced on foot. Defeat, retreat, captive/captured cleanup protection, idle rearming, fresh-noise trigger, relocation reset and faction/marker preservation passed. Planning tested war levels 1, 5 and 10 with their force/vehicle bands. Native major-attack fire exclusion and launch deferral passed.
- Existing feature regression: `logs/support-services-validation/arma3server_x64_2026-11-07_04-10-27.rpt`: **140 passes, zero failures, zero SQF errors**. All eleven support services, exact money changes, direct arsenal sale imports, low supersonic runs, mechanic behavior/persistence and faction-state assertions passed with the new module loaded. Total final checks: **223 passed**.
- Official CfgConvert/FileBank validation passed. All 43 DSDS functions registered and compiled by the game. Source/test delimiters and references checked; new PowerShell launcher parses. All **45 packaged source files** extracted and SHA256-compared with editable source; exact matches.
- Final companion SHA256: `2CDD0897C1844A9D910644F24BEB43139676B3E2B1F123E7B1B534116EFD9A46`.
- Original DSD PBO unchanged: `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.
- Owned validation servers are stopped and copied `dsds_raid.VR` / `dsds_validation.VR` removed from game MPMissions. Logs/isolated profiles remain under ignored `logs/`. No user campaign/profile was loaded or edited. Updated launcher metadata and README are copied to the generated local mod.

In-game acceptance: restart host/server and all clients with updated companion, resume campaign, perform safe sustained firing within 300 m of HQ (outside native close friendly-fire restriction), allow preparation plus travel, observe faction-correct distant landing/foot assault, finish or evade it, then remain quiet and verify no custom repeat. Optional server-only threshold reduction speeds the test; restore 300 afterward. Check respawn/JIP and placed explosives separately. Petros remains vulnerable to the actual raid.
