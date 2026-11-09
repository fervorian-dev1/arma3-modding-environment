# Dynamic Supply Drops development notes

## Version 1.1.0 - Antistasi refinement

User confirmed the original feature works well in-game. This revision targets their installed Antistasi Plus setup and preserves the delivery flight/physics and native Zeus menu.

### Decisions and inspected integration points

- Installed Antistasi Plus source reports **2.3.2**, build fd05fce. Extracted only reference copies of core, logistics, scrt and jeroen_arsenal; originals are unchanged.
- The default `B_supplyCrate_F` supplydrop model is already defined in Antistasi logistics cargo/vanilla.hpp, size **2**. Reuse public `A3A_Logistics_fnc_isLoadable` and `A3A_Logistics_fnc_addLoadAction` after landing. No new truck/cargo definitions or custom interaction system.
- Inspected native logistics load/unload functions: Cargo, Nodes, occupied seats, attachments and mass are tracked together. Deleting an attached crate after importing inventory could leave these records inconsistent. Therefore **import gear while loaded, retain the empty crate, and let native unloading free the slots**.
- Inspected public server-only `jn_fnc_arsenal_cargoToArsenal`: it captures real container contents (including subcontainers), clears them, updates server JNA counts, and synchronizes players already in the arsenal. Reuse it instead of injecting a separate arsenal inventory. Call `A3A_fnc_arsenalManage` afterward to preserve normal unlock thresholds. No forced unlimited items or changes to campaign save files.
- HQ is resolved from live mission `boxX` each poll, so HQ relocation is respected. Import requires a landed crate within 20m, altitude difference <=6m, stationary transport (<=1 km/h), ready native JNA/server state, and no ongoing loading/native transfer. Poll every five seconds; mark each drop imported once. Busy/uninitialized transfers leave cargo untouched and retry later.
- Every cargo pool and matching magazine is filtered through class/model `getAssetDLCInfo` and the class's DLC tag/registered CfgMods app ID. The latter also catches official DLC reskins that reuse a base-game model without a separate asset entitlement. Reject official DLC app IDs regardless of ownership; unknown/zero IDs retain free mods such as RHS. [Official command reference](https://community.bohemia.net/wiki/getAssetDLCInfo).
- Five compatible primary-muzzle ballistic magazines are allocated per unique weapon. If multiple weapons use the same chosen magazine class, accumulate five for each weapon (e.g. ten for two weapons). The selection slider continues to count unique cargo classnames.
- Delivery notifier now writes only to the server RPT. No call-in, inbound, release, landing or failure broadcasts. Live initialization removes the old DSD notification handler and invalidates old gear caches without duplicating menus/server request handlers.
- Changes affect new drops. Existing crates/inventories are preserved. Optional smoke and aircraft sounds/visuals remain normal; the existing smoke checkbox is unchanged.

### Files changed in this revision

New source functions under `projects/dynamic_supply_drops/addons/dsd_supplydrops/functions/SupplyDrops/`:

- `fn_isSupplyAssetAllowed.sqf`: cached official-DLC entitlement/model filtering.
- `fn_registerAntistasiCrate.sqf`: native load action and one HQ collection watcher per crate.
- `fn_importAntistasiCrate.sqf`: server-side guarded native JNA import, preserving attached cargo state.

Modified source: `config.cpp` (version and 16 function registrations); `fn_buildSupplyPools.sqf`, `fn_getSupplyMagazines.sqf` (DLC filtering); `fn_fillSupplyCrate.sqf` (magazine allocation); `fn_notifySupplyDrop.sqf`, `fn_initSupplyDrops.sqf` (silence and upgrade cleanup); `fn_openSupplyDialog.sqf` (accurate tooltip); `fn_landSupplyCrate.sqf` (start optional adapter); `mod.cpp` metadata.

Modified documentation/build/test files: project `README.md`, this notes file, `scripts/Build-SupplyDrops.ps1`, `scripts/Test-SupplyDropsServer.ps1`, and `tests/supply_drops/dsd_validation.VR/initServer.sqf`. Added `tests/supply_drops/dsd_validation.VR/testAntistasi.sqf`. Regenerated `LIVE_BOOTSTRAP.sqf` and the local build under `build/@DynamicSupplyDrops`.

### Validation

Packaged-addon dedicated-server run with CBA, ZEN, RHS AFRF/USAF and installed Antistasi Plus: **91 assertions passed, zero failures, zero SQF expression errors**. Log: `logs/supply-validation/arma3server_x64_2026-11-06_22-54-35.rpt`.

Verified DLC exclusion (including owned Apex), free RHS inclusion, all 15 filtered pools, matching five-magazine allowances including shared ammunition, silent notifier, real C-130/parachute descent, native two-slot cargo recognition, actual native truck loading, no collection away from HQ, deferral during busy transfer, full transfer to real JNA gear/round counts, no duplicate import, preserved truck Cargo/Nodes data, normal native unloading afterward, and the automatic HQ watcher.

The Antistasi test uses its actual installed functions with an isolated HQ/inventory fixture, `minWeaps=-1` to retain finite item counts, and no live campaign/save access. A real Antistasi campaign's unlock UI, connected-client interactions and persistence after its normal save/reload remain manual acceptance checks. Other Antistasi forks are unverified.

Additional checks caught and corrected an interface-only legacy-handler cleanup condition, official DLC reskins sharing base-game models, and an invalid server-logic construction in the isolated test fixture. The native importer correctly deferred transfers while that fixture was uninitialized. The fixture now creates its logic through a sideLogic group and asserts readiness. Earlier development runs remain in logs; final release validation results will be appended after both current runs finish.

Metadata inspection clarified a test assumption: `arifle_MX_SW_khk_F` has no DLC tag and the engine identifies it as base Arma 3 app 107410, so it is freely usable and retained. `B_Carryall_ghex_F` shares a base-game model but carries the official Expansion tag/app 395180, so the tag check excludes it. Tests assert these actual distinctions instead of treating every khaki skin as paid DLC.

**Final release validation (November 6, 2026, America/Chicago):**

| Final 1.1.0 run | Passed | Failed | SQF expression errors |
| --- | --- | --- | --- |
| Packaged addon + Antistasi Plus | 98 | 0 | 0 |
| Standalone live bootstrap + Antistasi Plus | 82 | 0 | 0 |

Final logs: `logs/supply-validation/arma3server_x64_2026-11-06_23-03-16.rpt` and `logs/supply-live-validation/arma3server_x64_2026-11-06_23-03-08.rpt`. Both runs completed. They include legacy pool/notification-handler upgrade cleanup, DLC tagged reskins versus free platform variants, real server logic readiness, full aircraft/descent and native cargo/JNA/unload paths. All earlier development results above are superseded by these final runs.

Reviewed all 16 SQF functions, function references/registrations, config and helper syntax, and generated bootstrap consistency. BankRev extraction matched all 17 packaged source files exactly by SHA-256. Final PBO SHA-256: `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.

Both temporary validation servers were stopped and their MPMissions copies removed. Test sources and logs remain in the workspace. No live campaign, player save, Workshop PBO, or installed Antistasi function was changed. Rebuilt local PBO and regenerated live bootstrap are ready; normal loading requires game/server reload, or apply the new Global-and-JIP bootstrap after removing an older bootstrap module.

---

## Inspection before implementation

- Workspace initially contained only environment_smoke, setup documentation, and its helper. No existing user-authored gameplay addon or ZEN integration existed to extend. Created an independent companion addon instead of changing installed Workshop mods.
- Arma executable: 2.22.154089; ZEN installed script_version.hpp: 1.15.1.36; CBA engine log: 3.19.0.260808.
- Extracted installed ZEN context_menu, custom_modules, dialog, common, main and CBA events to ignored reference/. Read public API comments and actual callback invocation.
- Context menu uses `zen_context_menu_fnc_createAction`, `zen_context_menu_fnc_addAction`. Callback first argument is ASL mouse position, including Zeus map support. Registration runs after ZEN's preInit compileActions, with one-time guards.
- Native options use `zen_dialog_fnc_create`; checked EDIT, SLIDER, CHECKBOX formats and confirm callback argument order in installed source.
- Optional native module registration uses `zen_custom_modules_fnc_register`, whose first callback argument is also ASL position.
- RHS USAF `rhsusf_c_a2port_air.pbo` config was converted to text. `RHS_C130J` and `RHS_C130J_Cargo` are public scope=2 CfgVehicles classes; pilot inherited from base is rhsusf_airforce_pilot. No RHS assets were copied into the addon. C-130 is selected only when present in the actual runtime config.
- Runtime item classification uses the game's BIS_fnc_itemType and baseWeapon plus compatibleMagazines; Throw/Put muzzle magazine definitions identify grenades/explosives. No unvalidated fixed loot list. Optional ACE medical classnames are checked before inclusion.

Primary references: [ZEN createAction source](https://github.com/zen-mod/ZEN/blob/master/addons/context_menu/functions/fnc_createAction.sqf), [BIS_fnc_itemType](https://community.bohemia.net/wiki/BIS_fnc_itemType), [addCuratorEditableObjects](https://community.bohemia.net/wiki/addCuratorEditableObjects). Installed source governs the implemented 1.15.1 API; upstream master has an additional optional createAction parameter not needed here.

## Files created

Under `projects/dynamic_supply_drops/`:

- `README.md`: install, live bootstrap, Zeus test procedure, options, lifecycle, limits.
- `mod.cpp`: local mod metadata.
- `LIVE_BOOTSTRAP.sqf`: generated self-contained function definitions for Global ZEN Execute Code in active sessions.
- `addons/dsd_supplydrops/config.cpp`: CfgPatches dependencies, CfgFunctions registration, PostInit.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_initSupplyDrops.sqf`: idempotent server/client event setup.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_registerSupplyMenu.sqf`: native menu category/action and optional modules-tree entry.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_openSupplyDialog.sqf`: defaults, native ZEN dialog, request dispatch.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_validateDropPosition.sqf`: finite coordinates, terrain bounds, water rejection, terrain ASL normalization.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_validateDropOptions.sqf`: class/type/numeric option validation.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_requestSupplyDrop.sqf`: server validation, assigned-curator check, cooldown/concurrency limits.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_notifySupplyDrop.sqf`: server diagnostics and requester feedback.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_buildSupplyPools.sqf`: runtime config discovery/cache.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_getSupplyMagazines.sqf`: cached primary-muzzle ballistic magazine discovery.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_fillSupplyCrate.sqf`: randomized unique manifests, matched magazines, global cargo population.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_runSupplyDelivery.sqf`: server aircraft, crew, approach, release, failure handling.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_landSupplyCrate.sqf`: descent monitor, detach, chute removal, optional smoke.
- `addons/dsd_supplydrops/functions/SupplyDrops/fn_cleanupSupplyAircraft.sqf`: departure watchdog, AI/vehicle cleanup, player-occupancy exception.

Workspace helpers and development-only test files:

- `scripts/Build-SupplyDrops.ps1`
- `scripts/Test-SupplyDropsServer.ps1`
- `tests/supply_drops/dsd_validation.VR/mission.sqm`
- `tests/supply_drops/dsd_validation.VR/description.ext`
- `tests/supply_drops/dsd_validation.VR/initServer.sqf`

Modified workspace `README.md` to link this feature. Existing environment setup files and sample addon are otherwise unchanged.

Generated output: `build/@DynamicSupplyDrops/addons/dsd_supplydrops.pbo` and `build/@DynamicSupplyDrops/mod.cpp`. Ignored reference extracts and test-server logs remain outside source control. Temporary copies of the development test mission are installed under the game's MPMissions as `dsd_validation.VR` and `dsd_live_validation.VR` while running validation; remove them after stopping the test servers.

No original Workshop mod, game PBO, player profile, or existing gameplay source is modified.

## Validation record

Completed November 6, 2026 (America/Chicago), using the installed Arma 3 2.22 dedicated server, CBA, ZEN, RHS AFRF and RHS USAF on the VR terrain.

| Run | Passed assertions | Failed assertions | SQF expression errors |
| --- | --- | --- | --- |
| Packaged addon | 64 | 0 | 0 |
| Standalone bootstrap, addon absent | 51 | 0 | 0 |

Packaged run log: `logs/supply-validation/arma3server_x64_2026-11-06_21-22-29.rpt`. Bootstrap run log: `logs/supply-live-validation/arma3server_x64_2026-11-06_21-23-04.rpt`. Earlier failed development runs remain in logs for traceability; use the filenames above for the final results.

Verified: all registered functions, engine compilation, initialization idempotency, position/option rejection, unauthorized request rejection, all 15 nonempty loot categories, 50 unique selections, valid manifest classes, quantities <=4, matching ballistic ammunition for every weapon, different successive manifests, all four actual cargo types, real C-130 approach/release, roughly 65 seconds of physical parachute descent from about 280m AGL, landed crate at terrain level, parachute removal, delivery counter release, departure and aircraft cleanup. Landed grids were 040041 and 040038 for requested grid 040040; natural drift/approach tolerance is visible in these results.

CfgConvert -test passed for addon config, mod metadata, test mission and description. PowerShell parser checks passed for both helpers. FileBank packed the addon; BankRev verified all 13 function files. Extracted PBO contents matched all 14 source files exactly by SHA-256. Final PBO SHA-256: `8F4CEBE6C97AF8F8FB2829783E0D1BAC86E1308DBAF9CA3FBDFC12E1B26D2117`.

Both temporary validation servers were stopped and both temporary MPMissions test copies were removed. Development test sources and logs remain in the workspace. The final local PBO is unsigned.

Issues found and corrected during actual engine tests:

- All-muzzle magazine discovery could pair a rifle with only UGL smoke. Added a cached primary-muzzle ballistic magazine helper and an engine assertion for matching ammunition for every weapon.
- Some mod vehicle weapons classify as MachineGun. Restricted infantry weapon pools to inventory weapon types 1/2 with usable ballistic ammunition.
- Muzzle brakes can reduce audibleFire slightly while retaining normal firing sounds. Suppressor classification also requires soundTypeIndex=1; other muzzle accessories remain in the attachment pool.
- Direct egress navigation could pass hundreds of metres to one side of the requested point. Added an explicit inbound waypoint and switch to egress on release.
- Departure cleanup could remove a slow inbound aircraft. Distance-based cleanup now requires the departing flag.
- Attached crates can retain a stale ground-contact flag. Landing requires actual terrain proximity; the test checks descent duration and final terrain altitude.

Static review also verified balanced SQF delimiters, all DSD function references registered, and no trailing whitespace in the 13 source functions.

## Remaining manual validation

Native Zeus menu rendering, map-position selection, dialog interaction and feedback on an actual Zeus client; live bootstrap across a connected multiplayer session; JIP and respawn behavior on the user's normal mission; aircraft flight over non-flat terrains and under load. The dedicated-engine test does not establish these client-facing behaviors.
