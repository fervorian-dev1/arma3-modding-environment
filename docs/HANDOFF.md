## Latest adjustment: v4.7 ? travel exclusion radius150m

Fast-travel hostile infantry exclusion changed400m->150m in fn_travelSafe.sqf and menu text in fn_openTerminal.sqf. Applies to requester and destination, including pre-jump recheck. Existing60-second combat timer and other safeguards retained. Official build checks only; no game test needed for this constant/text edit.

## Latest update: v4.6 ? cheaper civilian land vehicles and DEBUG tools

See [pricing/debug notes](CIVILIAN_DEBUG_46_NOTES.md). Civilian land purchases60% cheaper via tested native function adapters; PMC capped by reduced purchase prices, Fence receipts additionally capped. Zeus DEBUG now30 entries, including Respawn Mystic HERE/saved site, reveal/status, vendors/crates/arsenal/loot/HQ raids and every support service. Mystic spawn explicitly visible/simulated/grounded. Final smoke251/0, official build/source-PBO checks passed. Installed standard PBO after user closed Arma; all clients/server update/restart. No campaign save edits this turn.

## Latest update: v4.5 ? Mystic campaign restoration and paid Oswald unlock

See [Mystic repair notes](MYSTIC_PERSISTENCE_45_NOTES.md). Loader reads selected native saved state without fragile startType gate; schema2 remembers purchase-only Oswald unlimited arsenal unlock. IED43500. Live latest Green Sea save backed up and migrated, coordinates/progress retained; load with4.5. Official build passed;214/0 isolated smoke; human acceptance pending. Save normally after purchases. Private campaign backups ignored by Git.

## Focused smoke validation completed ? 2026-11-13

See [validation evidence](HOTFIX_SMOKE_VALIDATION.md). Current companion4.4 / Supply Drops1.2 rebuilt with config/package checks. Isolated dedicated smoke: **207 passed, 0 failures**, no SQF expression errors. Initial deletion-timing test corrected; gameplay unchanged. Owned test servers stopped. Human UI/travel/revive and broader campaign acceptance remain unverified.

## Latest update: v4.4 ? friendly parachute travel

See [travel notes](FRIENDLY_TRAVEL_44_NOTES.md). Player scroll menu travel to friendly units for fixed 350 personal credits; safety checks, five-second external aircraft camera, rear cargo seat then automatic parachute, backpack preserved. Existing transport fallback/refunds retained. No tests per user; restart clients/server.

## Latest update: companion v4.3 / Supply Drops v1.2

See [loot/support notes](LOOT_SUPPORT_43_NOTES.md). Custom loot quantities +125% (2.25x rounded/capacity-limited). Each faction-held airbase beyond first halves support request costs. Both addons rebuilt without tests per user; update BOTH and restart all clients/server.

## Latest update: v4.2 ? isotope convoy IED cargo

See [isotope IED notes](ISOTOPE_IED_LOOT_42_NOTES.md). New isotope convoys keep six isotopes and carry 12?18 native CWP chemical IED magazines instead of protective chemical gear. Six dug-in/urban asphyxiant/nerve/blister variants, runtime availability guards. No tests per user. Restart all clients/server; existing cargo untouched.

## Latest update: v4.1 ? silent friendly-fire notifications

See [friendly-fire notes](SILENT_FRIENDLY_FIRE_41_NOTES.md). Client chat filter hides friendly-fire system reports; matching native Antistasi warning hints suppressed. Damage/punishment unchanged. No tests per user. All players update/restart.

## Latest update: v4.0 ? emptied stash cleanup

See [stash cleanup notes](STASH_CLEANUP_40_NOTES.md). Empty/destroyed stash container, task and marker removed; active lead released. Also tracks old cleared but stocked stashes for later cleanup. Existing lead cooldown retained. No tests per user. Restart required; v3.7?3.9 retained.

## Latest update: v3.9 ? vehicle pricing and civilian purchases

See [vehicle economy notes](VEHICLE_ECONOMY_39_NOTES.md). Dealer-based PMC resale (50%, condition/native cheaper-store cap), Fence 2.8x resale retained. Native civilian car purchase lists gain up to 30 DLC-free unarmed passenger models, fastest configurations first. No tests per user. Restart all clients/server.

## Latest update: v3.8 ? native Antistasi revive instead of PiR injuries

See [native revive notes](NATIVE_REVIVE_38_NOTES.md). PiR player/AI injuries disabled; PiR bandages/medkits accepted by native teammate Revive. FULL restart required. No tests per user. v3.7 hotfixes retained.

## Latest hotfix: v3.7 (2026-11-13)

See [hotfix notes](HOTFIX_37_NOTES.md). User requested NO testing. Arsenal cleanup occurs on campaign load, then needs normal save; no offline save editing performed. Two uses EACH per life for Morphine/Adrenaline; all Fence resale blocked. Community crate follows Fence. Noise raid cooldown 60 minutes. Packaged without validation; in-game behavior unverified. GitHub publication remains pending authorization.

﻿# Arma 3 modding handoff

Updated 2026-11-08. Start here when continuing this workspace. Detailed histories and exact file inventories are linked below. This note consolidates completed work, accepted decisions, current builds and remaining verification; it does not claim every feature has been verified by human players.

## Current checkpoint - companion v3.6 host enemy-spawn optimization (2026-11-08)

[Host spawn notes](HOST_SPAWN_36_NOTES.md) record authority scope, implementation, exact files and test limits.

- Player-host scheduled hostile AI creation through Antistasi's installed native factory shares an atomic50ms reservation budget. Original count/loadout/identity/traits/type/return behavior remains; friendly/civilian, unscheduled callers, dedicated/HC authority bypass pacing. Direct engine spawners and pure model/texture rendering of existing AI are not intercepted. No measured live FPS uplift claim.
- Addon Accuracy Fix compatibility uses one atomically started server worker, at most8 queue entries per0.5second pass, replacing one polling script per addon AI. Same tactical restoration, installed aiming values/global AI settings retained. No graphics, population, map/faction/save/Workshop changes.
- Final actual player-host **17 PASS/0 FAIL**, `logs/hostspawn-client-validation/arma3_x64_2026-11-08_12-26-17.rpt`, including concurrent workers, count/custom-loadout preservation, friendly/unscheduled bypass and real shared worker activation. Dedicated expansion214/0(`12-18-53`), native driving86/0(`12-23-13`), Fence37/0(`12-23-14`) precede only atomic worker-start refinement. All final logs zero SQF expression errors. SP host authority exercises same branch as listen host; live two-human campaign FPS acceptance remains. Preliminary missing-faction fixture errors are documented, not treated as clean passes.
- Source: new Compatibility/nativeCreateUnit.sqf and fn_tickAICompatibility.sqf; modified config.cpp and fn_configureAddonAI.sqf.177 DSDS functions/216 packed files;212 old addon files unchanged. New isolated HostSpawn fixture/launcher and project metadata/notes updated.
- Standard companionv3.6 published; full restart host/server/every client with whole folder, no campaign reset. All owned tests finished/stopped, reusable copies/logs retained. Earlier convoy/Oswald/revive/Fence/Mystic features remain. SHA256 below.

## Previous checkpoint - companion v3.5 native convoy behavior/performance (2026-11-08)

[Native convoy notes](CONVOY_NATIVE_35_NOTES.md) document the user's Petros/DEBUG clarification, live-log evidence, exact12-file source inventory and tests.

- Latest user game log confirms addon offscreen recovery moved parked native convoy vehicles before their departure timer expired. Native route drivers now have **one controller: Antistasi**. No native cohesion/teleport-recovery loop. Collision checks advance along real route points instead of independently scattering trucks offroad. Driver-only LAMBS flags preserve route ownership; global settings unchanged.
- Additional aggression escorts now spawn in the native worker's escort loop (normal faction/war-level pool, route, departure, spacing and accounting), not independent roadside follow groups. Armed air cover/custom loot/70000 Money minimum retained. Custom mission title and origin/time/destination briefing are set from task creation, then retained when loot initializes. Parked before the announced time is normal.
- **DEBUG convoy** now uses real eligible campaign routes and the same native mission worker/departure timer; cursor chooses nearby destination, no short cursor route. Busy/no eligible campaign route fails usefully. DEBUG doesn't consume Petros rotation. Stash/Containment unaffected.
- Optimizations remove redundant world scans/driver RPCs, bind object task destination only on subject changes, broadcast only changed marker metadata, scan only Watch stock every30seconds and run fallback isotope watchdog every5seconds. Normal death callback still processed at0.5second cadence. No graphics, global AI, population, faction/map/save changes; no measured FPS uplift claim.
- Final engine **86 focused /214 expansion /37 Fence PASS,0 FAIL**. Focused log `2026-11-08_12-03-10.rpt` shows actual native road trucks travelling105m/108m after parked departure gate. Expansion `12-03-11`, Fence `12-05-35`; all no SQF expression errors. Full live campaign Petros/DEBUG route eligibility, timing/rewards/HC acceptance remains. Synthetic heal fixture is atomic now; no production healing change. Earlier failed fixture assertions/provenance in notes.
- Standard companionv3.5, **176 DSDS functions/214 packed files**;202 older addon files byte-identical. CfgConvert/source-to-PBO hash checks pass. All test processes stopped, fixtures/logs retained. Restart everyone and request NEW missions; no campaign reset. Runtime init log's hardcoded2.9 is historical, not build version. Published SHA256 below.

## Previous checkpoint - companion v3.4 arsenal/revive/convoy hotfixes (2026-11-08)

[Hotfix notes](GAMEPLAY_HOTFIX_34_NOTES.md) record all five requested fixes, exact18-file addon inventory, tests and honest limits.

- **Oswald paid-only:** scope1 removes it from native public/basic Watch enumeration; Ultimate forbidden-item config prevents unlimited unlocks. Server migration removes old unlimited JNA entries and Watch unlock membership; finite stock/carried/equipped bracelets remain. Mystic purchase/storage tested.
- **Stale R-to-respawn after teammate/PiR revive:** configured native SCRT key adapter delegates only for physical down/death. Owner monitor clears stale native incapacitated flag after2seconds conscious and removes exactly its respawnMenu handler. Numeric sentinel-1 permits the original unconscious worker to clean up safely. Recovery animation unconsciousoutprone is not treated as down. No free healing/invulnerability, unchanged syringe consumption/PiR recovery.
- **Continuous objective markers:** every native/debug convoy gets global two-second position updates and forced-known task destination. Native Money/Supplies logistics crate remains tracked after unloading. No delayed60-second native objective-marker duplicate. Marker expires with terminal/destroyed objective; normal escort spotting unchanged.
- **Clear roadside spawning:** classname-scaled empty-position/terrain/object checks, no unsafe fallback. Shared helper covers addon vehicles; exact-anchor adapter covers native objective/lead/escort worker. Missing objective cancels cleanly; missing escorts skip. Routes/rewards/70000 minimum unchanged. Does not guarantee immunity to later driving/model physics.
- **Armed helicopter companions:** spotters no longer explicitly disarmed. All convoy cover/insertion/spotter selections use validated kinetic door-gun pool; actual live gunner, compatible weapon and nonzero ammo required. No valid armed asset means skip, not unarmed replacement. Lost armament/gunner causes departure from escort/pursuit. Player-occupied aircraft are released from retasking. Original non-HE restriction retained.
- Final **77 convoy /213 expansion /60 Mystic /23 actual-player checks PASS,0 FAIL**. See notes for exact logs and final-code timing. No SQF expression errors. Mystic AA sensor control remains inconclusive (existing limitation, no new AA effect change). Initial failed recovery/crew/one healing fixture assertion is documented and superseded, not counted as passed. Full live native campaign road/revive/JIP/HC acceptance remains.
- **175 DSDS functions/213 packed files**, standard companionv3.4;195 previous addon files byte-identical to v3.3. CfgConvert and source/PBO extraction hashes pass. All owned test processes finished/stopped; fixtures/logs retained. Restart host/server/every client with whole folder and request fresh missions. No campaign reset, Workshop edit, map/faction/ownership or original supply-drop change. Published SHA256 below.

## Previous checkpoint - companion v3.3 Fence sniper ambush (2026-11-08)

[Fence ambush notes](FENCE_AMBUSH_NOTES.md) contain exact behavior, source inventory and test provenance.

- After three distinct shared faction visits, one40% roll after departure can prepare **two groups of four occupying-faction snipers** for a later return. Within80m actual distance counts an arrival; everyone must clear180m for60seconds to rearm. Squadmates/menu spam/loitering do not inflate count. Setup waits until every player is900m away, checks hidden sight lines and valid faction sniper roles, and skips invalid sites. No warnings, markers, fees or faction/map changes.
- Prone overwatch watches tent approach and silently engages a returning visitor. One active encounter. Retires on Fence loss/move,30-minute expiry or defeated/captured troops; normal distance cleanup preserves nearby/captured/player-controlled units. Existing AI mods keep global settings. Counter carries across camp moves within session; restart resets it, with no campaign-save schema change.
- Final focused **66 PASS/0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-56-27.rpt`; actual eight armed units, two groups, gates, engagement and cleanup. Expansion **210 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_07-53-58.rpt` (before final2D->3D proximity tightening). No SQF expression errors. Tests use server-owned AI observers and native role structure; human/faction/map acceptance remains. Failed preliminary terrain/cleanup-fixture assertions are documented, not counted as passes.
- Standard companionv3.3, **168 DSDS functions/205 packed source files**. New tickFenceVisits/spawnFenceAmbush functions; initFence starts guarded server monitor, config registers them. Project metadata/tests/notes updated. All test servers stopped; fixture/logs retained. Restart everyone with whole companion; no save reset. Previous convoy, Money minimum and rear-cargo fixes retained. Published SHA256 below.

## Previous checkpoint - companion v3.2 Money convoy minimum (2026-11-08)

[Reward notes](MONEY_CONVOY_REWARD_NOTES.md) record native fund recipient, exact change and validation.

- Successful native **Money convoy HQ delivery pays at least70,000 shared faction credits**, or its existing difficulty-scaled reward if higher. Native personal participation payments, failure behavior, completion requirements and other convoy payouts remain unchanged. Existing native-entry adapter modifies one uniquely verified statement before compiling the worker; changed future signatures retain original behavior and log review.
- Final dedicated **49 PASS/0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-42-14.rpt`, no SQF expression errors. New checks evaluate actual adapted expression at bonuses0.5/1/20:70,000/70,000/100,000; earlier45 checks retained. Full campaign delivery/account acceptance remains.
- Standard companionv3.2, **166 DSDS functions/203 packed files**. Only native-adapter helper and addon version changed inside PBO. Restart host/server and all clients; no save reset. Notes/metadata updated, test server stopped. Previous convoy rotation, silent containment and rear-seat fix retained. SHA256 below.

## Previous checkpoint - companion v3.1 parachute transport seating (2026-11-08)

[Seating notes](PARADROP_SEATING_NOTES.md) record the request, exact files and verification.

- Parachute support now boards the highest available explicit cargo index, with no crew-seat fallback. PARADROP aircraft lock pilot and all turret/copilot stations after creating AI crew. Scripted jump/backpack preservation and other support/purchased aircraft retain their behavior.
- **45 PASS/0 FAIL** dedicated engine checks, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-34-46.rpt`: actual transport/cargo role and index, AI pilot preserved, locks and real parachute transfer; previous37 convoy checks retained. No SQF expression errors. Remote human rendered seat/menu acceptance remains.
- Only boarding/spawn helpers and addon version changed inside PBO. **166 DSDS functions /203 packed files**. Standard companionv3.1, restart everyone with whole folder, no save reset. Petros rotation/Containment fix fromv3.0 retained. Test server stopped; reusable test copy retained.

## Previous checkpoint - companion v3.0 Petros convoy integration (2026-11-08)

[Integration notes](PETROS_CONVOY_INTEGRATION_NOTES.md) explain the verified eligibility mismatch, exact files, final-function adapter, tests and limitations.

- **Petros -> Convoy** now has a shuffled session rotation of **Special / Medical / Isotope / ordinary**, one of each supported type per cycle. This bypasses the separate ambient rare cooldown. Native active-task restrictions, departure delay, routes, rewards and escorts remain; custom cargo uses a valid faction cargo/medical truck and native ammunition-convoy capture/destroy handling. No city-Supplies dependency or specialized isotope truck. Ambient rarity remains unchanged.
- Successful **Containment Response** debug queueing is silent. No changes to its actual response or error messages.
- Ultimate compiles native functions final: final integration uses one CfgFunctions file-entry adapter, preserving/delegating to the installed native source. Exact unique objective anchor is checked before inserting the scoped truck selection. Explicit typed attack/intel and ordinary missions delegate unchanged. Future Ultimate updates/other convoy entry overrides require review. HC forwarding is implemented but not human-tested.
- Final focused engine **37 PASS/0 FAIL**, expansion **210 PASS/0 FAIL**; both `2026-11-08_07-18-01.rpt` in their respective validation profiles. No SQF expression errors. Focused test uses actual scheduler RPC/queue, event registry, truck and cargo, with a controlled native-worker seam. Full live Petros mission, road trip and reward cycle still need player acceptance; do not represent them as engine-tested end to end.
- **166 DSDS functions /203 packed files**, standard `build/@AntistasiSupportServices`, version3.0. Four existing addon files changed, three added,196 byte-identical to v2.9. Restart host/server/every client with whole folder; no save reset. Maps/factions, PiR rescue and other functionality retained. SHA256 below.


- Separate [HQ AI audit](HQ_RAID_AI_AUDIT_NOTES.md): **206 PASS/0 FAIL**, actual23 infantry/3 helicopters land and march with all three AI mods and PiR. No HQ gameplay changes or missing server-side Ultimate port found. Human-fired reporting remains unverified; several magazines can fall below existing300-point threshold/1-per-second decay. Final HQ log 2026-11-08_07-16-57.rpt; earlier interrupted run is not claimed as passed.

## Previous checkpoint - companion v2.9 Mystic isotope stash (2026-11-08)

[Stash notes](MYSTIC_STASH_NOTES.md) record the user's minimal-change request and exact source inventory.

- Mystic now offers **Source Industrial Isotopes stash**, free like Fence's lead. It reuses the same worker, roadside search, disguised container, three named high-skill squads/current occupying faction and original completion/failure/cleanup. New variant contains **10 Industrial Isotopes**, fitting the existing1500-mass container. Fence's original30-item contraband cargo is unchanged.
- The vendors share the existing **one active stash /45-minute cooldown**. Do not silently introduce independent cooldowns/parallel stashes or alter guarding/placement. Normal session mission persistence is unchanged. No automatic reward progress, payouts, contamination hooks or extra dependency.
- Existing Zeus registry exposes **DEBUG -> Start Industrial Isotopes Stash**, no settings dialog. Player mission labels contain no DEBUG prefix.
- Focused engine test **20 PASS/0 FAIL**, `logs/mystic-stash-validation-ultimate/arma3server_x64_2026-11-08_05-39-30.rpt`. Real transaction/queue/worker, correct cargo, capacity, guards, tasks, duplicate/cooldown/zero charge and original Fence regression verified. Full expansion regression208 PASS/0 FAIL at `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_05-39-30.rpt`; both logs have no SQF expression errors. Nine intended addon files changed; other191 are byte-identical to v2.8. Publication hash below and in stash notes. Button rendering/remote-human acceptance remains.
- **164 functions /200 packed files**, standard `build/@AntistasiSupportServices`, version2.9. Restart host/server and all clients with the whole folder. No campaign reset. PiR injector fix, Mystic nuclear reward, maps/factions and original supply-drop addon are retained.

## Previous checkpoint - companion v2.8 automatic PiR recovery (2026-11-08)

User reported non-working automatic syringes. [Injector recovery notes](AUTO_INJECTOR_RECOVERY_NOTES.md) supersede older metadata-only rescue checks.

- **Adrenaline** automatically consumes one carried syringe for a living incapacitated player; **Morphine** automatically treats PiR forced crawling and also rescues incapacitation if no Adrenaline is carried. For a crawl, Morphine has priority and Adrenaline is fallback. One syringe per episode, not both. Ordinary prone, no item and actual death do not qualify. Actual death still triggers Mystic's nuclear device normally.
- Owner-local recovery heals body/hitpoints once, wakes the player and uses installed PiR successful-treatment flags. No `PiRrespawn` reinitialization, duplicate hit handlers or cached inventory restoration. One optional runtime `Uncondition0` wrapper delegates to the retained installed original for normal/fresh injuries; it prevents an old healed crawl from launching a second down episode. No PiR source/settings edit. Native PiR cleanup restores temporarily removed weapons/throwables. Delayed-animation settling stops on fresh damage and is generation-guarded; no repeated healing/invulnerability. Five-second duplicate holdoff. Auto-rescue avoids adding overdose toxicity; other consumable behavior retained.
- **Final forced-branch actual-player engine test19 PASS/0 FAIL**, `logs/rescue-client-validation/arma3_x64_2026-11-08_04-56-04.rpt`, running installed PiR full crawl/unconscious routines and real automatic owner/server flow. Before the final flag cleanup/stale-transition guard: **dedicated PiR23/0**, `logs/rescue-server-validation-ultimate/arma3server_x64_2026-11-08_04-45-35.rpt`; **expansion207/0**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_04-48-12.rpt`. No SQF expression errors in final runs. Two distinct remote human clients and nondefault PiR settings still need acceptance.
- **164 registered functions /200 packed files**. Standard release `build/@AntistasiSupportServices`; all clients and host/server need the whole updated folder and restart. No campaign reset, PiR/Workshop edit, AI settings change or faction/map modification. Publication hash below. Temporary test processes/copies are owned and separate from the user's profile/campaign.

## Previous checkpoint - companion v2.7 Mystic nuclear reward (2026-11-08)

The user has now specified the forty-isotope reward. [Nuclear reward notes](MYSTIC_NUCLEAR_NOTES.md) supersede older pending-reward instructions.

- At shared forty, the first player to **Accept Mystic's reward** receives one non-removable attached chest device. Mystic delivers the exact requested line through private written dialogue. Existing armor/inventory is retained. Scroll-menu **Touch off chest device** or actual wearer death triggers one ZEN Atomic Bomb at the character. Disconnect parks the UID-bound armed reward; normal campaign save/load preserves it. No duplicate shared claim.
- After that vest detonation, Mystic stocks **Nuclear IEDs for174,000 personal credits** beside Oswald. Native IED model, real magazine/ammo/Put muzzle, ordinary placement/Touch Off; actual explosive detonation invokes the same ZEN effect. Supplied bottle artwork is the menu thumbnail. Deleting/defusing an intact charge does not automatically detonate it.
- Existing installed ZEN event `zen_modules_moduleNuke` supplies blast/destruction/visuals, **500m** destruction radius and **300 objects/sec** processing. No separate radiation system. Internal ZEN adapter is version-sensitive. Two authenticated server callbacks; raw blast is private. Validated callbacks use private server authorization flags because Arma retains remote-execution context through delegated calls.
- Backward-compatible Mystic save adds three optional fields; old v2.6 ten-field saves preserve existing progress and can claim the reward. `rewardState`, `rewardUID`, `nuclearUnlocked` track shared progression. Do not reintroduce a placeholder reward or reset the campaign.
- **159 registered functions /195 packed files**. Final nuclear40 PASS/0 FAIL at `logs/nuclear-validation-ultimate/arma3server_x64_2026-11-08_04-21-19.rpt`; Mystic60 PASS/0 FAIL at `logs/mystic-validation-ultimate/arma3server_x64_2026-11-08_04-21-20.rpt` (existing AA sensor experiment inconclusive). Publication hash is recorded below and in the nuclear notes. Rendered chest alignment/first-person clipping, written dialogue/UI presentation, real remote-player/HC/JIP and client nuclear visuals still need human acceptance. Native server destruction, real inventory delivery, placement/Touch Off and saved-state behavior are tested.
- Use only the standard `build/@AntistasiSupportServices` folder on every client and host/server; full restart, no campaign reset. Original supply-drop PBO and maps/factions remain unchanged.

## Previous checkpoint - companion v2.6 Mystic (2026-11-08)

User confirmed **shared campaign discovery/progress**, with **personal payments**. [Mystic notes](MYSTIC_NOTES.md) are authoritative for the new feature; v2.5 baseline history remains below.

- Successful Industrial Isotopes sale to Fence unlocks a **92,235-credit** lead. Paying reveals Mystic's shared marker at one fixed elevated/private location. Unarmed stationary civilian; silently returns 30 mission minutes after death. Normal campaign saving preserves location/discovery/count/intro history/death delay. Offline time pauses the delay.
- Strange **Trinkets** UI and first-conversation camera intro. Exactly one offer: **Oswald**, **62,000**, supplied bracelet thumbnail, Watch slot, name only/blank descriptions. Equipped wearer inside an aircraft gives native IR/radar signature suppression and local-missile target cancellation. Passenger qualifies; remote UAV control/unequipped carrying do not. Scripted seekers are not universally guaranteed.
- Carried Industrial Isotopes can be offered in batches toward shared **40**; excess retained. At 40 `DSDS_mysticState` has `ready=true`. This was the v2.6 placeholder; the v2.7 nuclear reward above now supersedes it.
- **150 registered functions /185 packed files**. Final Mystic engine suite: **60 PASS/0 FAIL**, plus **inconclusive AA sensor experiment** because its unprotected control never acquired a contact: `logs/mystic-validation-ultimate/arma3server_x64_2026-11-08_02-30-20.rpt`. Two native missile target cancellations and restoration passed. Real lock-screen/mod-specific seekers, remote-player/HC/JIP and rendered UI/camera still need acceptance.
- Expansion regression: **203 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_02-23-45.rpt`, before final pending-flag/refund fallback adjustments. Test provenance, earlier corrected staged/fixture failures and exact source inventory are in Mystic notes. No test failure is silently treated as proof of lock prevention.
- Standard release: `build/@AntistasiSupportServices`, version2.6; restart host/server and every client with this **whole folder** and existing dependencies. Enable one companion copy. No save reset, map/faction edit or Workshop change. Original Dynamic Supply Drops PBO remains unchanged.

## Previous checkpoint - companion v2.5 (2026-11-08)

The v2.5 baseline was published in the standard `build/@AntistasiSupportServices` folder; v2.6 now supersedes it. [Publication and cleanup notes](PUBLICATION_CLEANUP_NOTES.md) describe this finalization; [logistics/response notes](LOGISTICS_RESPONSE_NOTES.md) cover the convoy features. Copilot's visual, medical and thumbnail work is retained. The pre-consolidation handoff is archived in [this snapshot](HANDOFF_PRE_CONSOLIDATION_2026-11-08.md); its release labels, counts and publication instructions are historical.

- Isotope shipments carry shielded cargo plus DLC-free CWP masks/filters/antidotes/repair supplies. Medical Convoys carry healing supplies and the six custom injectors. Fence pays6,000 per industrial isotope item and4,000 per medical isotope item. Both isotope thumbnails are packaged in the standard build. Medical attacks add40 native aggression for60minutes (faction-wide), with a regional alert.
- Convoy cohesion paces the front for stragglers and permits limited offscreen road recovery. Industrial truck destruction can dispatch one Watchkeeper for up to60minutes, without replacement after shoot-down, plus one full24-specialist woodland CBRN Osprey insertion. Existing hostile sides are used; no faction/map/territory changes. See logistics notes for attribution, spawned-AI and engine view-distance limits.
- Response cleanup now retries every30seconds after the response ends, retaining assets within1200m of players and releasing captured/player-controlled/unrelated-occupied vehicles and captives from cleanup. Own distant vehicles, crew, dismounted units and empty groups are removed. Dedicated tests cover the actual delayed retry and capture safeguards; real human UAV/HC acceptance remains open.
- Copilot's low-alpha cocaine/weed/vape control overlays, meth distortion and5% Zyn image remain. Morphine heals up to0.30 overall Arma damage over60seconds; Adrenaline auto-consumes a carried injector to rescue a living incapacitated player. These do not promise complete PiR/ACE wound treatment. Private injector messages and both isotope images are retained.
- **132 registered functions /165 packed files**, config and source-to-PBO hashes verified. The v2.5 SHA256 was EE9C8E91DE99B93000BFAD6E7CDEDECAFCB320A007337032944260050578C1BA. Latest focused cleanup test: **16 PASS/0 FAIL**, `logs/cleanup-validation-ultimate/arma3server_x64_2026-11-08_01-36-25.rpt`.
- Earlier evidence: Copilot expansion201 PASS/0 FAIL at `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_00-43-17.rpt`; logistics40 PASS/1 FAIL at `logs/logistics-validation-ultimate/arma3server_x64_2026-11-07_23-29-13.rpt`. The failing contact test used a target beyond engine view distance; corrected focused contact run at23-37-21 passed4/0. Do not call these a fresh combined full-feature run of this cleanup build.3CB Osprey model warnings are upstream and remain recorded.
- Remaining: live player Adrenaline/PiR rescue, rendered tints/thumbnails, multiplayer/HC/JIP attribution and a fresh combined logistics acceptance run. These were outside this publication/cleanup finalization. Restart host/server and every client with the standard companion folder; friends need that whole updated folder. No campaign reset.
- Only verified owned copied test missions/processes were cleaned; source fixtures/logs and old candidate builds retained. No Git commit, Workshop edit or save reset. Never stop a normal user game process. Enable only one companion folder, not the archived IsotopeThumbnails candidate alongside the current standard folder.

## User requirements to preserve

- Current target: **Antistasi Ultimate12.0.3**, Zeus Enhanced and installed mod assets. User originally confirmed no campaign progress/save migration was needed. Preserve any current save; no reset is required. Plus2.3.2 has historical verification for older features; v2.0 through v2.2 mission additions are validated on Ultimate only. Enable one edition at a time. Inspect actual APIs/configs; do not invent functions/classnames.
- Preserve existing gameplay, faction selections, map choices, relationships and airfield/location ownership. Never reset a campaign to implement a feature. **User confirmed the AAF airfields were correct**; do not attempt an AAF fix.
- Keep notes and modular SQF source. Do not edit original game/Workshop files; use local companion addons. User accepts full game restarts during development.
- Use **personal money** for terminal purchases, support calls and mechanic hire. Vehicle sale proceeds go to the seller. Do not charge shared faction funds.
- PMC mechanic persists with normal campaign saves, including saved death. No resurrection or second hire fee on restoring a living saved mechanic.
- Supply-drop loot must be DLC-free, varied and usable: at least five compatible magazines per unique weapon, limited duplicates, native Antistasi logistics/arsenal integration, no public incoming-drop announcement.
- Raid repeats must require fresh noise after the previous encounter. Keep ordinary Antistasi behavior intact; do not disable its independent attacks.
- Fence v2.1: six **varied** vehicles; purchased boats go straight into the buyer's native personal garage. Dedicated AA vehicles are excluded; AA launchers/missiles stay in **Items only**. Ten mostly modded Items offers retain FPV/UAV/control/AA roles. **Injectors never appear in Fence stock**; he buys them for400â€“750. Native Supplies convoy objectives, enemy medical vehicles and occasional enemy medics provide medical loot instead. Preserve custom-valuables-only sales and session rotation behavior. v2.2 uses one community trade crate, first confirmed seller paid, and expands contraband to nicotine/Zyn. User approved the artwork; preserve it.
- Current valuables: Marijuana300, Vape150, Cocaine800, Zyn200, **Gold3,200**, Rough Gems1,000, Cut Gems1,650, Meth650. Four industrial goods are **Special Convoy only**. Keep flavor-only descriptions and short private post-use text; Zyn remains30% carrying/45minutes and exactly **"You feel stronger."** User accepted fitting game buffs instead of exact ADS/reload. Rapid dangerous drug mixes can overdose. No cocaine-resistance injury handler remains. Keep valuables outside unlimited arsenals.
- v2.0 rare Special/Isotope Convoys enrich eligible native cargo convoy objectives without replacing native movement or modifying factions/territory. **User confirmed scouts should follow the goods until the helicopters are destroyed, with no pursuit timeout.** Finite large response uses the actual convoy faction. Isotope destruction uses the installed Chemical Warfare PLUS native cloud API, not simulated radiation. Free Fence stash leads always require high-skill guards. New meth and six injector profiles include OLB-1's50/50 immediate death vs ten-minute boost; never claim literal infinite per-player inventory beyond engine limits.
- v1.9 **no personal-money loss on death**: enforce native `deathPenalty=0` across server/clients/startup/JIP/respawn. Never implement wallet top-ups/snapshot refunds that undo purchases or mint money. Preserve other native death consequences and faction money.

## Workspace and installed environment

- Workspace: `A:\arma3 modding enviroment`.
- Editable projects: `projects/dynamic_supply_drops`, `projects/antistasi_support_services`; initial tooling sample: `projects/environment_smoke`.
- Game: `A:\SteamLibrary\steamapps\common\Arma 3`.
- Tools: `A:\SteamLibrary\steamapps\common\Arma 3 Tools` (CfgConvert, FileBank, BankRev used).
- Workshop: `A:\SteamLibrary\steamapps\workshop\content\107410`.
- Last inspected/tested: Arma 3 2.22.154089; **Ultimate 12.0.3** (Workshop 3020755032), with targeted Plus 2.3.2 fallback; CBA 3.19; ZEN 1.15.1.36. RHS USAF/AFRF, RHS GREF/SAF/3CB and FHQ/RKSL assets were used in relevant fixtures. Versions are snapshots, not a guarantee about future Workshop updates.
- v2.0 also inspects/tests installed **Chemical Warfare PLUS** (Workshop3295358796, PHAN_CW.pbo, CBRN_scripts). Its native particle/exposure spawn exits on dedicated; actual visuals and client medical behavior remain a human acceptance step. Source references are extracted read-only under reference/chemical and reference/ultimate/garage.
- `reference/`: ignored extracted read-only API/config references. `build/@DynamicSupplyDrops` and `build/@AntistasiSupportServices`: current generated mod folders, tracked in Git. Other build outputs, `logs/` isolated profiles/test RPTs, and `temp/` extraction/review output are ignored.
- Source, docs and the two current built mod folders are in Git. The ready-to-play ZIP is published separately under GitHub Releases; temporary and historical build variants are not tracked.

## Current release files

| Mod | Version | Generated addon |
|---|---|---|
| Dynamic Supply Drops | 1.1.0 | `build/@DynamicSupplyDrops/addons/dsd_supplydrops.pbo` |
| Antistasi Support Services | 2.9 | `build/@AntistasiSupportServices/addons/dsds_support.pbo` |

SHA256:

```text
Dynamic Supply Drops (unchanged):
F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6

Antistasi Support Services v3.6:
F7EFDFBE03F47CEB0D6E6084E7B6DAFDBBE1A2805FE10C4244EC958BF4677C74
```

The standard v3.6 companion includes177 registered DSDS functions and216 packed source files, including the native convoy entry adapter. The normal build helper extracts a fresh candidate and checks every file before publication. Old candidates under temp/build are historical; use the standard folder above. Details of previous packaging mismatches are retained in the resume audit and archived handoff.

## Completed features and revisions

### Medical/isotope convoys and response cleanup (v2.5, current)

Convoy loot separation, isotope sale values/thumbnails, aggression, cohesion, Watchkeeper/Osprey response and delayed captured-safe cleanup. See [logistics notes](LOGISTICS_RESPONSE_NOTES.md) and [finalization notes](PUBLICATION_CLEANUP_NOTES.md).

### Contraband visuals and medical changes (v2.4 origin, retained in v2.5)

Independent client-only distortion/tints and user-supplied five-percent Zyn image, with existing buff/crash duration and cleanup integration. See [visual notes](CONTRABAND_VISUALS_NOTES.md).

### Convoy repairs (v2.3 history)

Accessible isotope/injector cargo, strict door-gun transport escorts, native CWP bomb release/watchdog and particle-height correction, aggression-scaled native/debug defenses, three Special Convoy themes and immersive mission text. See [exact changes and acceptance limits](CONVOY_REVISION_NOTES.md).

### Fence/AI/DEBUG missions (v2.2 history)

Repaired remote stash request/convoy-worker boundaries; shared community crate with atomic personal sale payouts; scenery inventory containers, five contraband goods, generated high-skill squad names; optional installed AI compatibility; real one-step Zeus DEBUG mission starters and future registry. Full file inventory, architecture, test provenance and remaining acceptance: [current development notes](FENCE_MISSIONS_AI_NOTES.md).

### Injector medical loot (v2.1 history; medical rules retained)

User approved the artwork and requested injectors move out of Fence stock into medical loot. Fence pays **Morphine 400, AHJ-C 600, M11 550, Adrenaline 500, OLB-1 650, OLB-2 750**; one of each sells for3,450. The current Morphine heal and Adrenaline auto-rescue additions are recorded in the injector balance table; prior art and overdose rules remain.

New guarded native `AIVehInit`/`AIInit` listeners add3â€“6 injectors to Supplies objective trucks,1â€“3 to selected-faction enemy medical vehicles, and give enemy medics a35% chance of one. Delayed vehicle additions retain native cargo and locked objective objects. Server/registered-HC authorization, ownership/source validation, capacity checks and per-object flags prevent client farming, friendly seeding or duplicate refills. The explicit additive `MEDICAL` pool contains only six injectors, with rare OLB weights; COMMON/SPECIAL/STASH remain separate. No shop-box refill loop, faction/territory edit or campaign reset.

**266 passing checks, zero failures/SQF errors**: Fence119 (`logs/fence-validation-ultimate/arma3server_x64_2026-11-07_16-42-13.rpt`) plus expansion147 on the published PBO (`logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_16-44-24.rpt`). All97 registrations/123 packed files match source. Fence ran before the final medical-worker guard tightening, with identical Fence code/config. Owned test servers and copied mission fixtures were cleaned; original source/logs remain. Exact sources, configuration, files, verification and acceptance limits: [medical loot notes](MEDICAL_LOOT_NOTES.md). Real headless-client events and human multiplayer pickup remain acceptance checks.

### Dynamic Supply Drops

ZEN category **Dynamic Supply Drops**, action **Spawn Randomized Supply Drop**, map-selected target, aircraft approach/delivery/egress, natural parachute crate descent and cleanup. Installed RHS C-130J is available. Config-driven randomized pools cover weapons, compatible ammunition, attachments, medical items, explosives, clothing and backpacks. DLC exclusion and five magazines per weapon were added. Native Antistasi vehicle loading and HQ arsenal collection were integrated. User confirmed the addon works well/flawlessly.

Source/function details, configuration and tests: [project README](../projects/dynamic_supply_drops/README.md), [supply notes](SUPPLY_DROPS_NOTES.md).

### Support Terminal and PMC mechanic (v1.0 to v1.4)

- Separate companion leaves original supply-drop functionality intact.
- Petros supplies the **Support Terminal**: UAV-controller model in the GPS/UAV slot, implemented as GPS equipment with no UAV-control capability. New item costs **10,000 personal credits**; an existing owned item can be equipped without repurchase.
- Item opens a simple vanilla Arma menu with all eleven installed Fire Support services, plus their map selection flow. No commander/airfield/radio/support-point/bomb-point/cooldown progression requirement; ordinary valid-player, position, equipment and funds checks remain.
- Prices: smoke 5,000; flare 5,000; supply 5,000; light vehicle airdrop 7,500; recon 8,000; paradrop 10,000; loot helicopter 10,000; HE 30,000; cluster 40,000; napalm 40,000; chemical 50,000. Last four were doubled at user's request.
- Offensive runs use installed RHS T-50s at approximately **1,440 km/h** with full throttle/afterburner animation. v1.3 targets **150 m above local terrain/sea**, planning climbs ahead instead of flying 500 m above the highest point along the whole route. A real Altis test measured minimum clearance about 104 m across a 335.5 m terrain elevation change. Sonic-boom soundset is present; human audibility is unverified.
- Supply retains original randomized/DLC-free/native-logistics helpers. Loot recovery returns a crate. Paradrop preserves the passenger's backpack. Aircraft depart and are cleaned by watchdogs.
- Petros hires one **PMC mechanic for 1,000 personal credits**. Custom black uniform, black vest/baseball cap and validated free mod rifle (RHS preferred). Stationary, targeting/self-defense retained; carry/place actions. Uses native campaign-qualified statistics for persistence; normal Antistasi save flushes hire/location/loadout/death state.
- Mechanic dynamically values all vehicle classes using type, armament, armor, utility, configured cost, condition and native shop-price caps. Protects occupied/other-player-owned/HQ/contractor/cargo-loaded assets and revalidates timed quotes.
- v1.2 vehicle sales transfer cargo **directly into JNA/Antistasi arsenal**, including attachments, rounds and nested backpack contents. No new crate/arsenal object is spawned for loaded or empty sales. Existing player crates were deliberately not deleted.
- v1.1 corrected mechanic allegiance: config defaults Independent/FIA and explicit joining uses Petros's actual side. Replaced inherited Antistasi controls with basic vanilla controls because native base classes defaulted to `fade=1`. **User confirmed the menus/mechanic work flawlessly after this fix.**
- v1.3 addressed missing money HUD refresh after successful terminal/support purchases. Silent sequenced receipt waits for replicated balance, then calls native statistics; a local watcher also catches refunds/salary. Client never overwrites the money ledger. Logs now record transaction delta/before/after. User described no/wrong-looking deductions; a display defect was proven, but no claim that every reported incident was display-only. Server exact-charge tests passed; final human HUD acceptance remains open.
- Native Plus napalm sound code had an actual playSound3D type error. A scoped adapter reuses native particles/damage with a valid sound source; no global native function replacement.

Details/inventory: [companion README](../projects/antistasi_support_services/README.md), [support development notes](ANTISTASI_SUPPORT_SERVICES_NOTES.md).

### Noise-triggered HQ raids (v1.4)

- Automatic hidden suspicion from player gunfire/explosions within **300 m of deployed Petros/HQ**. Weights: ordinary rounds 1, suppressed 0.1, cannon/rocket/HE firing 15, detonations 40; smoke/flares zero. Decay 1 point/second; threshold 300. Voice, footsteps and passive engine noise are not monitored.
- Player-local FiredMan/Explode input batches to an authenticated server entry. Enemy/contractor/other AI cannot build suspicion.
- One threshold crossing consumes the score and prepares one raid after **90â€“180 seconds**. During preparation/raid/recovery, further noise is discarded. Defensive fire during native major attacks is excluded.
- War bands 1â€“3 / 4â€“6 / 7â€“10: **20â€“25 / 30â€“35 / 40â€“50 airborne infantry**, plus **1â€“2 / 2â€“3 / 3â€“5** available trucks/light vehicles. Crews are additional; no truck passenger squads/tanks/UAV/artillery are added. All equipment and unit loadouts come from the selected occupying faction, without faction substitution.
- Helicopters land **800â€“1,200 m away**, infantry dismount and march/attack, transports depart. Ground vehicles approach using roads/safe ground. Actual passenger capacity limits troop loads.
- Ends on defeat, timeout, Petros/HQ loss or movement, or overlap with a native major attack. Survivors retreat. Recovery is 60 seconds, then **fresh noise is required**; no automatic repeating raid timer. Native Antistasi attacks remain independent.
- Captives/captured/player-occupied assets protected; cleanup limited to owned raid entities away from players/sight. No faction/ownership/diplomacy edits. Mission reload resets ephemeral noise/raid state; Petros retains native death consequences.
- Safe deployment can fail on unsuitable islands/terrain, unavailable transport templates or no hidden spawns. It cancels/logs rather than inventing faction assets or forcing an unsafe landing.

Exact files, defaults and test evidence: [raid notes](HQ_NOISE_RAIDS_NOTES.md).

## Validation status

### Fence / valuables / risky convoys / injectors (v2.0 history; sources/prices superseded by v2.1)

Boats use the real garage public API and buyer UID; varied vehicle slots exclude AA platforms. Two injector offers join the ten-item rotation. New lightweight rough/cut gemstone triplets share positioning; gold becomes3,200. Platinum5,200, palladium4,800, wafers2,800 and microchips2,200 appear only in Special Convoys. Meth650 participates in overdose. Six injector profiles have private post-use text; OLB-1 is server-randomized50/50 death or ten-minute stamina/encumbrance/storage boost, within the engine's fixed ceiling.

Native AIVehInit event integration recognizes Ultimate ammunition/fuel/repair objective context, upgrades5% to Special and3% to Isotope (chemical mod required), with a shared90-minute cooldown. Other convoy types/vehicles and native routes/rewards/capture rules remain. Special cargo alerts trigger a large finite faction-based road/air response;2â€“3 spotters follow tracked goods until neutralized. Sealed isotope trucks release a300m/15minute native choking-agent cloud on destruction. The Fence offers a free45-minute-cooldown contraband lead:12â€“18 high-skill patrol guards and30 cocaine/marijuana/meth items. Mission/trail/cloud timers are session state, not custom campaign persistence.

ZEUS testing: under **Dynamic Supply Drops**, drop **Designate Special Convoy vehicle** or **Designate Isotope Convoy vehicle** onto an enemy truck. These manual modules do not create routes; give the enemy crew waypoints yourself. Automatic variants attach to native missions without manual placement. Friendly/bought/player-occupied vehicles are protected from conversion. Actual client module rendering, long-campaign convoy selection/movement, two-client inventory tracing, JIP/headless ownership and chemical visuals/exposure still need human acceptance. The test suite and new assets/files are detailed in [current expansion notes](SMUGGLING_EXPANSION_NOTES.md).

v2.0 validation totals **327 passing checks across component/regression runs**: final expansion119, Fence107, baseline loot/death-money101; zero failures/SQF errors in those final component runs. Published-PBO expansion log is `logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_16-29-17.rpt`. Earlier clean Fence/Loot runs cover their relevant paths; they were not all rerun on the final byte-identical PBO. Manual designators deliberately create no standalone task, avoiding orphan test tasks; automatic missions retain native task lifecycle. Source/packed comparison found zero differences across118 files. Full provenance, corrected intermediate runs and cleanup are in the current notes.

### Death money, consumable rewrite and overdose (v1.9)

Personal death-money percentage is forced to zero without modifying balances, normal purchases/earnings, native scripts or other penalties. Consumable tooltips are flavor only. Private messages follow confirmed use; Zyn is exactly **"You feel stronger."** Marijuana now has movement/stamina penalties with its steadier aim/blur; vape focuses aim/recovery without faster movement; cocaine trades sprint/recovery for jitters, then crashes. Its old injury-resistance function was removed, retaining PiR/ACE handling.

Three-minute rolling toxicity: cocaine3 points, cannabis1. Pure cannabis3+ doses gives two-minute sickness. With cocaine present,6 points warns and9 schedules fatal overdose ten seconds later; three rapid cocaine doses suffice. Further cocaine use does not extend the boost or postpone its crash. No antidote currently. Death clears body-specific doses. Other item values, art, classes, Zyn carrying behavior and mission placement remain. See [exact rules, changed files and tests](CONSUMABLES_REBALANCE_NOTES.md).

Final v1.9: **198 checks passed (99 Ultimate +99 Plus), zero failures/SQF errors**, including each installed native respawn money formula, actual overdose death, nonfatal recovery, window expiry, mixed narcotics, simple descriptions, exact Zyn text and prior loot/sale safeguards. Exact logs/fixture correction/cleanup are in the current notes. Human multiplayer respawn/JIP/private text/blur and full medical-mod acceptance remain to verify; tests execute native money math, not a human respawn lifecycle. The user closed the game when the PBO lock blocked publication; build then published successfully. Owned test servers/fixtures were cleaned. Never stop the user's normal game process.

### Inventory valuables/consumables (v1.8)

Five portable custom items, generated 256px JPEG thumbnails, exact Fence sale values, four on-foot scroll-menu consume actions, server-validated inventory-removal handshake, timed nonstacking effects and cleanup. Zeus module **Dynamic Supply Drops â†’ Spawn valuables cache** and a context-menu action add ten random valuables on validated dry land. `[_crate,10] call DSDS_fnc_fillLootContainer` is the additive server mission-script helper. No automatic edits to existing mission/drop loot tables. One of each sells for 3,950 personal credits through the existing trade crate/quote flow.

Balance and limits: marijuana sway/blur; vape movement/recovery/stamina cap; cocaine sprint/recovery/vanilla resistance then crash; Zyn worn-container capacity + reduced loadCoef. ADS zoom/reload timing is unchanged. Arma's fixed global soldier ceiling stays intact. Cocaine resistance is absent with PiR/ACE medical; no injury-system override. Stamina changes respect mission-disabled stamina. Buffs are body/session state, not campaign-persistent inventory or reconnect bonuses. See [complete loot notes, files and artwork prompts](LOOT_CONSUMABLES_NOTES.md).

Final dedicated Ultimate loot test passed **73 checks** and the existing Fence suite passed **102** again: **175 passes, zero failures/SQF errors**. Exact logs and cleanup are recorded in the loot notes. The isolated hidden game client stalled before joining; no positive human RPC/blur/menu acceptance is claimed. Historical port/raid/supply suites were not rerun wholesale. User has not yet tested v1.7 tabs or v1.8 items.

### Fence tabs/drone/AA stock (v1.7)

User confirmed the Ultimate port works perfectly. New request: separate Vehicles/Items tabs, ten mostly modded inventory offers emphasizing FPV/UAV/control equipment and anti-air. Implemented two vanilla button tabs with preserved authoritative catalogue indices, six vehicles with ground AA coverage, and ten distinct items reserving FPV/UAV/terminal/AA roles and targeting eight modded offers. All DLC/personal-money/custom-sale rules retained. FPV inventory comes from the real installed ArmaFPV magazines and native deployment script; kits/terminals match the rebel side. AA packages use portable launcher/default ammo/purpose metadata to avoid classifying the AT Javelin as AA and include five usable missiles. Missing optional categories safely fall back.

**Final changed-feature suite: 102 passes, zero failures/SQF errors**, Ultimate with installed ArmaFPV/RHS/FHQ/RKSL, `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_08-47-35.rpt`. Twenty generated stocks had 8â€“9 modded items; real FPV deployment and all four item cargo kinds/payments passed, as did old Fence protections/aircraft. All 61 function references and 64 packed files verified. New human tab rendering/controller connection remains for user acceptance. Full earlier port suite is historical evidence, not rerun wholesale. Exact files, prices, fixture corrections and cleanup: [Fence tabs notes](FENCE_TABS_NOTES.md).

### Ultimate port (v1.6, user-confirmed working)

User moved to Ultimate and confirmed a fresh campaign with no save/progress migration needed. Installed Ultimate 12.0.3 is Workshop **3020755032**; read-only references under `reference/ultimate/`. Dynamic Supply Drops requires no gameplay changes: native truck loading and arsenal interfaces remain compatible. Companion adds `vehicleShopPrice` for Ultimate's nested market stock/diminishing/market discounts, extends existing resale protection to market-only vehicles, and preserves Ultimate-created UAV crew. Existing terminal/services/mechanic/Fence/raid behavior is retained. No native overrides, map/faction edits or campaign conversion were made.

**Final results: 408 Ultimate checks + 21 targeted Plus checks = 429 passes, zero failures/SQF errors in final runs.** Includes full services (146), actual faction-based raid/landings (96), unchanged DSD flight/truck/JNA (98), Fence with real native vehicle/UAV initialization (63), cross-process living/dead mechanic storage (5), and Plus fallback price/side/UI checks (21). All 56 function references resolve and 59 packed files match source. Earlier missing test-fixture globals caused native errors and were corrected with real campaign defaults; source/notes/logs distinguish those superseded runs from final results.

See [Ultimate port notes](ULTIMATE_PORT_NOTES.md) for exact modified files, API audit, logs, hashes, cleanup and limits. Test helpers now default to Ultimate; `-Edition Plus` selects Plus and a separate profile. Owned servers/fixtures cleaned afterward. Start a fresh Ultimate mission with **Plus disabled**, Ultimate and both local addons enabled on every client/server. Human UI/RPC/JIP/remote pilot transfer and real campaign combat still need acceptance. No save migration is pending.

### The Fence (v1.5)

User requested a roaming unarmed civilian in a medical tent, announcing a flat roadside location every 45â€“95 minutes, rotating six vehicles from loaded configs at 2.8Ã— mechanic sale value and offering expensive gear. User explicitly chose **only custom valuables** for his purchases and **buyer in pilot seat** for airborne fixed-wing delivery. Personal money and DLC-free constraints retained. Twelve Fence functions, simple vanilla UI, server-authoritative crate quote/sale, spawn/refund flow and native black-market vehicle initialization added. Initial custom valuable `DSDS_ValuableReceiver` is worth 2,500 and reuses the verified free GPS model as generic cargo; no GPS functionality or automatic mission-loot injection. New model assets can register later.

Fence camp/timer/stock/trade crates are session-only. Old nonempty crates and purchased assets are retained on relocation; recover/garage/save possessions normally before quitting. Fence death lasts until the next scheduled rotation. No faction/map/airfield changes or native function replacements. New testing includes installed FHQ/RKSL assets. **Final Fence run: 62 passes; full existing-feature rerun: 140 passes; 202 total, zero failures/SQF errors.** All 58 packed source files hash-matched and all 55 function references valid. Human menu, positive RPC/JIP and ownership-transfer acceptance remain open. Exact file inventory, logs, usage and limitations: [Fence notes](FENCE_NOTES.md). Earlier tests of item-config fixes were invalidated by stale PBO output held by another owned server; the build script now stages, extracts and hashes all files and fails on a locked destination. A preceding concurrent regression had one supply crate clip through terrain and correctly refund (two physical-delivery assertion failures); the complete solo rerun passed. Owned test servers/fixtures cleaned up afterward.

### Earlier verified releases

- Final v1.4 raid scenario: **83 passes, zero failures/SQF expression errors**, actual 3CB AAF template and assets. Three real helicopters unloaded 8/4/10 troops; 22 infantry advanced. Defeat/retreat, fresh-noise rearming, capture protection, tier planning and unchanged faction/airfield state passed.
- Final existing-feature regression with raid module loaded: **140 passes, zero failures/SQF errors**, all eleven support services, wallets, mechanic, direct arsenal imports and low supersonic strikes. **223 total final checks.**
- Earlier separate-process tests proved living mechanic restoration and saved death through native on-disk statistics. Earlier Altis test proved land/sea clearance correction. Histories/log names are in detailed notes.
- Official config validation, game function compilation, reference/delimiter checks and source-vs-PBO hash comparisons passed. Assertions do not prove every human multiplayer interaction.
- **Remaining in-game acceptance:** human FiredMan/placed-explosive reporting and positive RPC, player respawn/JIP, client-view spawn hiding, native death/ACE behavior, difficult island/mod helicopter landings, a full 50-infantry battle, final money-HUD rendering and sonic-boom audibility. Current human acceptance supports the original supply drops and corrected mechanic/menus, not every new v1.4 path.
- Earlier v1.4 owned test servers were stopped and copied validation missions removed; profiles/logs remain under `logs/`. That earlier check also found a normal user Arma client/BattlEye running. Recheck actual processes before cleanup; **do not stop user game processes or mistake them for owned test servers**. Current v1.5 test/cleanup status is recorded in the Fence notes.

## Build, update, share and resume

Build with `scripts/Build-SupplyDrops.ps1` or `scripts/Build-SupportServices.ps1`. The latter recursively packages/inspects nested functions. Source edits require rebuilding; metadata/docs alone are not gameplay updates. Use only isolated test helpers/profiles for automated checks; do not overwrite a live campaign or arbitrary mission folder.

Local launcher already points at the generated folders. **Fully restart Arma** after an addon update; no need to re-add the existing local mod. Enable both addons plus the same installed dependencies. Dedicated host/server and every friend need the same companion version. Current builds are unsigned; signature-enforcing servers need appropriate signing.

To share, send complete `build/@DynamicSupplyDrops` and `build/@AntistasiSupportServices` folders, preferably ZIPs preserving `@ModName/addons/file.pbo`. Friend extracts first and selects the **outer mod folder** through Launcher â†’ Mods â†’ Local mod. The launcher does not import the `.pbo` or ZIP as the local-mod folder. Share a launcher preset HTML for matching Workshop mods too. An update to the companion alone does not require replacing unchanged DSD.

User reported Google Drive uploads stalling. No cause was established and no upload was performed. Advice given: copy the complete mod folder to Desktop, ZIP the copy, upload the ZIP; a copying/zipping "file in use" error suggests a local lock, while upload-only failure suggests investigating Drive/browser/network. Keeping Codex/workspace open normally does not lock those files; a running game/other process may still hold files. Do not claim Drive was repaired or that all possible locks were checked.

If usage/session interruption occurs, source/PBO/notes already saved on disk remain. Resume from this note and the detailed histories, inspect actual files/logs, and check any interrupted edits before continuing. Last discussed official usage guidance allows an active turn to continue after reaching a usage limit subject to fair use; future turns may need reset/credits. No account allowance/reset time was verified locally.

**Next useful step:** restart everyone with the current v2.5 standard companion folder and the installed AI mods; keep Chemical Warfare PLUS for isotope missions. Test Fence stash creation/map marker/camouflage inventory, community-crate quotes with two players, and Zeus Modules > DEBUG mission starters. Existing medical loot, boat/gem/rare-convoy and consumption/expiry/overdose/cloud human acceptance remains. One of each original five goods sells for4,650; one of each injector sells for3,450. Older human money/respawn/JIP/medical edge cases remain unverified. User approved the artwork; preserve it. Source/build/notes are saved locally; no Git commit, Workshop edit or campaign reset was made. Do not change faction/map settings.








