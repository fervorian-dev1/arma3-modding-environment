# Petros convoy integration — companion v3.0, 2026-11-08

## Request and diagnosis

The user repeatedly requested convoys from Petros without seeing our custom shipments, and wanted the Containment Cleanup debug-launch notification removed.

Installed Ultimate12.0.3 `core/functions/missions/fn_missionrequest.sqf` schedules `A3A_fnc_convoy` with exactly two arguments: destination and origin. Its destination pool excludes cities. Our previous isotope/medical conversion required native `Supplies` convoys, selected for city destinations, making those types effectively inaccessible through that request. Special cargo had only5% eligibility on ammunition/fuel/repair trucks, with a shared90-minute rare-convoy cooldown. Raising only the percentage would not fix the missing mission types.

## Final behavior

- Petros requests now use a shuffled session rotation containing SPECIAL, MEDICAL, ISOTOPE and ordinary. Each appears once per four eligible spawned objectives. First type/order is random. Unsupported isotope delivery (missing CWP or safe door-gun helicopter) is omitted; no suitable faction cargo truck retains the ordinary worker. A failed route does not consume a rotation entry. There is no extra Petros rare-convoy cooldown; normal native active-task/convoy restrictions and departure delay remain.
- Custom requests use the installed ammunition-convoy mission logic: capture/destroy completion, native rewards/accounting, route, lead/tail escorts, travel, despawning and mission limits. A scoped insertion selects an actual faction cargo/medical truck for the objective BEFORE creation, crew and initialization. This avoids transplanting isotope cargo into an ammo/fuel/repair truck, or relying on a city's Supplies mission with its attached-crate delivery logic. Existing upgrade code supplies themed valuables, medical supplies/injectors or shielded isotopes/CWP rewards, task text, aggression defenses and response hooks15 seconds after initialization.
- One server-owned queue drains native scheduler RPCs outside remote context. HC-scheduled two-argument requests are forwarded to the server. Explicit typed attack/intel calls delegate to the installed original. Ordinary rotation entries also use that original. No Workshop, native source files, map, territory, faction, relation, save or global AI settings are edited.
- Ambient/intel/attack conversion eligibility and the existing rare cooldown retain previous behavior. Duplicate objective callbacks cannot consume multiple rotation entries. No additional dependencies.
- `CONTAMINATION` successful queueing is silent. Errors remain useful; its assets, targets and cleanup are unchanged. Other mission confirmations are unchanged.

## Adapter boundary

Ultimate's `A3A_fnc_convoy` is compiled final. An initial runtime-assignment candidate was rejected by the engine and was NOT published. The final addon config redirects only that CfgFunctions file entry to `Smuggling/nativeConvoy.sqf`. Initialization compiles the CURRENT installed native worker from the unchanged category path, retaining it for delegation. The custom variant inserts one scoped classname assignment immediately before the verified unique objective-spawn statement. Missing/changed anchor retains original behavior; an unavailable original source cancels/logs requests rather than running guessed code. Future Ultimate versions or another mod overriding that function entry require review. Plus is not newly certified by this change.

## Exact source inventory

New addon files:
- `functions/Smuggling/fn_initNativeConvoys.sqf`
- `functions/Smuggling/fn_selectPetrosConvoy.sqf`
- `functions/Smuggling/nativeConvoy.sqf`

Modified addon files:
- `config.cpp`: version3.0, two DSDS registrations, native convoy entry file adapter.
- `functions/Smuggling/fn_initSmuggling.sqf`: adapter setup, scoped objective metadata, duplicate guard.
- `functions/Smuggling/fn_convoyObserved.sqf`: trusted Petros designation independent of ambient rarity.
- `functions/Debug/fn_queueCustomMission.sqf`: silent containment success.

Project `mod.cpp`/README updated. Test launcher `scripts/Test-ConvoyDefenses.ps1` accepts a staged companion path; its fixture adds rotation/RPC/cargo/silent-queue coverage. Existing HQ launcher changes are from the separate pending HQ audit, not convoy gameplay changes. Handoff and this note record the release.

## Validation and limitations

- Final focused dedicated engine run: **37 PASS /0 FAIL**, `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-18-01.rpt`.
- Final expansion regression: **210 PASS /0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_07-18-01.rpt`.
- Both include the three installed AI mods, Ultimate, CWP, CBA/ZEN and relevant content mods. Neither final run has SQF expression errors or an attempt to overwrite final `A3A_fnc_convoy`.
- The focused test uses the real configured final entry, self-RPC, production queue, rotation, native event registry, real cargo trucks, existing upgrade functions, actual task descriptions and inventory. A controlled worker seam supplies the verified native objective dynamic scope to avoid needing a complete campaign. It verifies the installed source anchor and compilation, but DOES NOT claim a complete real Petros request/road trip/native mission reward cycle, HC forwarding or human-client UI acceptance. These remain in-game checks. Earlier failed fixture/runtime-assignment logs are retained and superseded.
- CfgConvert passes. Build helper repacks, extracts and hashes every source file. **166 DSDS functions /203 packed source files**, plus the configured native entry adapter. Exactly7 addon files differ from v2.9 (3 new,4 modified); the other196 are byte-identical.

Published standard folder: `build/@AntistasiSupportServices`.
PBO SHA256: `5B038E0C812D7C874CEEF43FE2F7CD79ECA366CD28CD288DBD94BE8F531BC1DB`.
Original supply-drop addon remains unchanged.

## User test

Restart Arma/server and every friend with the whole updated companion folder. Existing local Launcher entry stays valid; no campaign reset. Finish any current convoy, then request Convoy from Petros as usual. Wait the normal announced departure time. Across four supported spawned requests the rotation includes all three custom types and one ordinary; custom task text updates after objective setup. Inspect the truck's actual cargo and test capture/destroy normally. The Containment Response Zeus debug button should launch silently. Do not expect the preexisting debug convoy buttons to advance Petros's separate rotation.

Cleanup note: all owned test server processes were stopped after completion. Automatic approval review rejected the PowerShell removal of the three copied disposable MPMissions fixtures with the reason "blocked by policy". No deletion from that command occurred; copies remain at `A:/SteamLibrary/steamapps/common/Arma 3/MPMissions/dsds_raid.VR`, `dsds_convoy_defenses.Altis` and `dsds_expansion.Altis`. They do not affect ordinary missions or the published PBO. Source fixtures/logs and staged/baseline audit copies are retained. No user game was stopped.
