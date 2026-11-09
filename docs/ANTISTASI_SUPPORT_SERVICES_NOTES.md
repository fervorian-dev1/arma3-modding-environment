# Antistasi Support Services development notes

## Decisions â€” 2026-11-07

- User chose personal funds for support and the 1,000-credit mechanic hire; sale proceeds go to the seller.
- User chose campaign persistence. Store a versioned custom `DSDS_mechanicState` through native `A3A_fnc_setStatVariable` / `A3A_fnc_returnSavedStat`. Normal campaign saving flushes the namespace. Record death; do not resurrect a saved dead mechanic. Fresh campaign initialization clears an orphaned record rather than restoring it.
- Keep working Dynamic Supply Drops and Workshop addons unchanged. Deliver a separate companion `build/@AntistasiSupportServices`; new item config requires restarting with the addon enabled on server and clients.
- Installed versions inspected: Arma 3 2.22.154089; Antistasi Plus 2.3.2 (fd05fce); CBA 3.19; ZEN 1.15.1.36; RHS C-130J present. This addon targets that Antistasi Plus implementation, not an assumed universal Antistasi API.

## Integration evidence

Extracted local read-only references under `reference/antistasi` were used to inspect the commander support UI, dispatch gates, support payloads, personal-money owner ledger, save targets/statistics, logistics and JNA collection. Eleven unique support IDs were found; carpet bombing uses the same CLUSTER identifier. Avoid the original launcher because it enforces progression gates and mutates shared commander marker globals. Use an isolated display inheriting native controls and independent server jobs. Keep native commander markers, counters, cooldowns and functions untouched.

Support Terminal inherits the UAV terminal model but uses `ItemGPS` and `InventoryItem_Base_F`, rather than the UAV terminal's item type. Engine tests confirm `BIS_fnc_itemType` returns Item/GPS and assignment occupies the expected slot. A discarded positive-control probe calling `connectTerminalToUAV` on a headless AI crashed the dedicated server; no production function uses this command. Human UAV-UI acceptance remains manual.

Server requests validate ownership via `remoteExecutedOwner`, living rebel player, distances, equipped item, positions and server prices. Internal transaction helpers are scope-guarded. No global remoteExec mode changes or compiled-code RPCs. Support settlement refunds only once; aircraft cleanup uses existing DSD watchdogs. Dealer quotes revalidate object, ownership, price, time, cargo and occupancy before deleting anything. Loose cargo is transferred through native ammunition transfer to a DSD/Antistasi-compatible crate.

Mechanic custom black uniform uses procedural textures and native black equipment. RHS/free mod rifle and compatible magazine availability are validated. PATH is disabled; targeting remains enabled, AWARE/GREEN return-fire behavior. It does not inherit Petros death or campaign-reset behavior. Its `spawner=false` avoids native AI save-refund accounting. Move/placement is server-owned, with disconnect/death handling.

Native `A3A_fnc_napalm` in the installed Plus version passes a position array as the object argument of `playSound3D`, causing actual engine errors. The companion's `napalmRun`/`napalmEffect` adapter uses `objNull` and explicit ASL position, with existing native particles/damage. It does not override native functions. HE/cluster/chemical and recon/loot reuse the available native lower-level APIs.

## Test process

Use `scripts/Build-SupportServices.ps1`; then `scripts/Test-SupportServicesServer.ps1`. The latter starts a hidden, loopback-only dedicated server on port 24326 with its own profile, test mission and isolated campaign ID. Full phase exercises real config/function compilation, wallet transactions, hiring/movement/loadouts/save restoration, all price tiers, sale salvage, duplicate payment protections, failure refunds and all eleven actual support services with native progression resources absent. Aircraft fly their routes and crates/vehicles descend. Separate RestoreAlive and RestoreDead phases verify native persisted statistics across fresh server processes.

Fixture corrections during development: VR is only 8,192 m wide, so out-of-map test targets were corrected; `deleteVehicle` is deferred, so deletion assertions yield a frame; real logic objects and faction fields are initialized for native helpers. These are fixture changes, not relaxed production validation. Logs are retained under `logs/support-services-validation`.

Final test results and package hashes are recorded below after verification. Manual acceptance is still required for the human dialog, action menu, positive human RPC, actual campaign lifecycle and visual/combat behavior. An isolated save/reload proves the native persistence mechanism, not every real campaign scenario. No live campaign save was modified.

## File inventory

Created `projects/antistasi_support_services/README.md`, `mod.cpp`, `addons/dsds_support/config.cpp`, `addons/dsds_support/terminal.hpp`, and these files under `addons/dsds_support/functions/`:

```text
fn_boardSupportPassenger.sqf
fn_changeWallet.sqf
fn_clientService.sqf
fn_closeTerminal.sqf
fn_createMechanic.sqf
fn_finishSupportContract.sqf
fn_initServices.sqf
fn_jumpSupportPassenger.sqf
fn_landSupportPayload.sqf
fn_moveMechanic.sqf
fn_napalmEffect.sqf
fn_napalmRun.sqf
fn_openTerminal.sqf
fn_persistMechanic.sqf
fn_restoreMechanic.sqf
fn_runSupportContract.sqf
fn_sellMechanicVehicle.sqf
fn_serverRequest.sqf
fn_serviceActions.sqf
fn_serviceCatalogue.sqf
fn_serviceTransaction.sqf
fn_spawnSupportAircraft.sqf
fn_terminalMapClick.sqf
fn_terminalSelect.sqf
fn_terminalSubmit.sqf
fn_validateServicePosition.sqf
fn_validateVehicleSale.sqf
fn_vehicleValue.sqf
```

Also created `scripts/Build-SupportServices.ps1`, `scripts/Test-SupportServicesServer.ps1`, this notes file, and the fixture files `tests/support_services/dsds_validation.VR/{mission.sqm,description.ext,initServer.sqf,initServerRestore.sqf}`. Modified workspace `README.md` to link the companion. Generated output: `build/@AntistasiSupportServices/{mod.cpp,README.md,addons/dsds_support.pbo}`. Temporary dedicated-server profiles/logs stay under ignored `logs/`; the temporary copied game test mission is removed after verification. No Dynamic Supply Drops source or PBO changes.

## Final verification â€” 2026-11-07

- Official CfgConvert config validation and FileBank/BankRev packaging passed. All 28 functions register, all named DSDS function references resolve, and source delimiters balance. PowerShell build/launch helpers parse. All 30 packaged source files were extracted and hash-compared against editable source; exact matches.
- Full dedicated-server test: **101 passes, 0 failures**, no SQF expression/position errors. Log `arma3server_x64_2026-11-07_00-40-53.rpt`. All eleven services fulfilled; supply/vehicle payloads landed, loot inventory was recovered, paradrop deployed a real steerable chute with backpack retained, original commander state stayed unchanged. Delayed native effects were given an additional 150 seconds to run.
- Fresh-process RestoreAlive: **3 passes, 0 failures**, no SQF errors. Log `arma3server_x64_2026-11-07_00-46-09.rpt`. The mechanic restored from native campaign-qualified on-disk statistics with black outfit and RHS weapon, without another charge.
- Fresh-process RestoreDead: **2 passes, 0 failures**, no SQF errors. Log `arma3server_x64_2026-11-07_00-46-41.rpt`. A saved death did not resurrect the mechanic. Isolated test statistic was removed and flushed afterward.
- Total **106 assertions passed**. Positive human RPC and client rendering remain unverified; the fixture calls guarded business logic with server-controlled AI test actors and cannot prove those client interactions. Normal Antistasi initialization/save orchestration is integrated by source inspection; test restoration directly exercises its native storage with an isolated campaign ID.
- Final companion PBO SHA256: `EA53D07FCB4A60AF115E75978AE42782B93B115A3BD1682A988D71C9681E118A`.
- Existing Dynamic Supply Drops PBO SHA256 remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.

## v1.1 correction â€” 2026-11-07

User reported Petros attacking the mechanic and both menus failing. The v1.0 server-only assertions did not exercise real client controls and missed that imported `TextBase`, `TextBaseMT`, `BaseComboBox` and `ButtonBase` define `fade=1`. Native commander code later unfades its own controls; our isolated display did not. Replaced those dependencies with vanilla `RscText`, `RscCombo`, `RscButton`, `RscMapControl`, explicit `fade=0`, plain sizes and a background layer. Added menu-open diagnostics, serialization protection and an empty vehicle-list state.

Mechanic inherited WEST from `B_Soldier_F`; `createUnit` alone does not guarantee the requested group's side. Set the mechanic's config `side=2`, `faction=IND_G_F`, choose the living HQ object's actual group side (Petros) ahead of `teamPlayer`, and explicitly `joinSilent` the new unit into that group. No global side-friendship changes. The same creation path handles saved mechanics, so a normal restart/reload repairs their side without another hire fee.

Modified: `config.cpp`, `terminal.hpp`, `functions/fn_createMechanic.sqf`, `functions/fn_initServices.sqf`, `functions/fn_openTerminal.sqf`, project README, this notes file, and `scripts/Test-SupportServicesServer.ps1`. Added `scripts/Test-SupportServicesUI.ps1` and fixture `initServerRegression.sqf`, `initPlayerServerUI.sqf`, `initPlayerLocalUI.sqf`. Regression phase checks actual Petros/Independent allegiance even with stale WEST `teamPlayer`, fallback WEST creation, restored-loadout side, control visibility and vanilla inheritance. The isolated real client exercises dialog creation, visible controls, map selection, support submission and dealer quote/confirmation across authenticated RPC. Test player funds/vehicles are disposable fixture data; no user campaign save/profile is used. Startup parameters follow the [official documentation](https://community.bistudio.com/wiki/Arma_3_Startup_Parameters).

v1.1 verification: CfgConvert/FileBank build passed; all 28 named functions/references resolve and changed source/test delimiters and PowerShell scripts parse. Dedicated regression log `logs/support-services-validation/arma3server_x64_2026-11-07_02-12-47.rpt` records **18 passes, zero failures and zero expression/position errors**. Actual unit sides match Independent Petros; WEST fallback also works despite the Independent vehicle config. The real graphical client was attempted with an isolated profile, but stopped progressing during startup after loading movement data, before connecting/loading the fixture. Its log is `logs/support-services-ui/arma3_x64_2026-11-07_02-12-47.rpt`; **no graphical/client-RPC assertions ran**, so do not count this as a UI runtime pass. The fixture is retained for optional visible testing via `Test-SupportServicesUI.ps1 -Visible`. Test processes are stopped and their copied game mission removed. Human campaign UI/combat acceptance remains required.

v1.1 companion SHA256: `320D54C27FB96E823F4084BF0DB3C1600015BD8A35D07F042EDF206B3C8061DD`. Original supply-drop PBO still matches its recorded hash. Configuration changes require restarting host/server and clients; distribute the updated companion folder to the friend too.

## v1.2 tuning â€” 2026-11-07

**Permanent scope constraint from user: preserve all campaign factions, selected maps, faction templates, ownership of airfields/locations and faction relationships. Do not reset a campaign or change those settings to implement services.** No existing campaign save was edited. The latest user client log `C:/Users/mamaj/AppData/Local/Arma 3/Arma3_x64_2026-11-07_02-18-38.rpt` records a native `startType=new` campaign request at 02:22:55 with factions `[3CBF_AAF,3CBF_AFRF,3CBF_CCM,3CBF_A,3CBF_CHDKZ]`, followed by loading `3CBF_AAF` for WEST at 02:23:12. This is evidence that AAF was selected in the campaign's creation data; it does not establish who chose it or why. Source audit found no writes to native faction templates, `airportsX`, `sidesX`, map selection or diplomacy in either gameplay addon. Do not try to restore guessed factions. Only owned contract aircraft/NPC groups and temporary local target markers are controlled.

User confirmed the v1.1 mechanic and menus work flawlessly. Requested changes:

- New Support Terminal: 10,000 personal credits. Existing owned terminals stay usable and equipping one is free. Server rejects insufficient funds, occupied GPS slot, and duplicate pending purchases before charging. Delivery is checked against replicated inventory and failed delivery refunded once.
- Offensive prices doubled: HE 30,000; cluster 40,000; napalm 40,000; chemical 50,000. Smoke, flares, recon, supply, vehicle delivery, paradrop and loot recovery retain their prior prices. Mechanic hire remains 1,000.
- Vehicle sales use `jn_fnc_arsenal_cargoToArray` and `jn_fnc_arsenal_cargoToArsenal` directly, then native `A3A_fnc_arsenalManage` for ordinary unlock thresholds. Includes nested gear, attachments and magazine round counts; no crate/arsenal object is spawned, including empty sales. Native arsenal updates go to active arsenal clients. Preflight rejects cargo-transfer locks and an unavailable native arsenal. Old crates are not deleted because they may contain player gear.
- Offensive jet: verified installed `RHS_T50_vvs_generic_ext` / `RHS_T50_vvs_generic`, with `afterburner_source` and `soundSetSonicBoom[]={"Plane_Fighter_SonicBoom_SoundSet"}` in extracted AFRF `rhs_c_air` config. Original RHS maxSpeed is 1,800 km/h. The native afterburner script is player-HUD-bound and installs shared handlers, so it is not invoked. Our aircraft-local server loop sets full throttle, animates the actual RHS source and guides only the contract jet at 400 m/s (1,440 km/h), with terrain-clearance sampling and straight egress. It exits on death, locality change, player occupancy or timeout; existing aircraft watchdog handles deletion. No global frame handler, player UI or aircraft configs are overridden. Native sonic-boom audio is enabled by that model's config; audibility has not been listened to here. The [official config reference](https://community.bistudio.com/wiki/CfgVehicles_Config_Reference) documents the native sonic-boom soundset.

Changed gameplay files: `config.cpp`; `functions/fn_serviceTransaction.sqf`, `fn_serviceActions.sqf`, `fn_initServices.sqf`, `fn_sellMechanicVehicle.sqf`, `fn_clientService.sqf`, `fn_spawnSupportAircraft.sqf`, `fn_runSupportContract.sqf`; added `functions/fn_flyStrikeAircraft.sqf` (29th registered function). Updated full runtime fixture `tests/support_services/dsds_validation.VR/initServer.sqf`, project README and these notes. Original DSD and all Workshop source/PBOs remain unchanged.

Workspace `README.md` also records the permanent campaign-preservation rule for future work.

Fixture note: the first direct-import assertion also included the test HQ crate's default contents when native arsenal management ran. Emptying that disposable fixture HQ crate before testing yielded exactly one MX and 150 magazine rounds from the sale, plus the nested backpack/toolkit. Production uses the normal native HQ inventory and should import pending HQ gear as usual.

v1.2 final verification: full dedicated-server log `arma3server_x64_2026-11-07_02-46-34.rpt` completed with **131 passes, zero failures and zero SQF expression/position errors**. All eleven contracts fulfilled. All four strike types used the RHS T-50 at measured 1,440 km/h with afterburner animation phase >0.9. Loaded and empty vehicle-sale tests created zero crates; loaded sale imported exactly one MX, 150 magazine rounds and a backpack/toolkit into JNA. Purchase tests passed insufficient-funds, occupied-slot, exact 10,000 debit, pending-duplicate and existing-terminal checks. Final faction templates/maps, simulated airfield ownership and marker color stayed unchanged after an additional 150 seconds for native delayed effects.

After the full run, final packaging included a null-recipient guard on failed terminal delivery (prevents disconnected-player feedback broadcasting) and a corrected Petros prompt. The final PBO also passed the **18 side/UI-visibility regression checks**, with zero failures/errors. All 29 registrations/references and source/test delimiters checked; official config build passed; all **31 packaged source files** extracted and hash-matched exactly to editable source. Graphical menus were accepted by the user in v1.1 and kept intact; no new human-client or sonic-boom listening test was performed for v1.2.

Final v1.2 PBO SHA256: `4DF9A062F9BF08DC5B7CFFE726977AB4DD604FE564F890DF0CC92F540E9EE126`. Original DSD PBO remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`. Test servers are stopped and the owned game test mission removed; isolated test logs/profile remain under ignored `logs/`. Host/server and friends must replace the companion and restart; existing terminal owners do not need to rebuy.

## v1.3 money display and low strike runs — 2026-11-07

**User confirmed the AAF airfields were correct. There is no AAF/faction/map bug to repair.** Retain the preservation rule for all future work.

User reports no deduction and possibly wrong displayed amounts when buying/using the terminal. Inspected installed native `A3A_fnc_addMoneyPlayer`, `A3A_fnc_resourcesPlayer`, `A3A_fnc_statistics`, salary and save code. The wallet uses the same native `moneyX` / real-player `owner` ledger; it does not use a separate currency. A concrete defect was found: successful SUPPORT transactions and terminal ISSUE did not request a HUD refresh. Antistasi's native statistics function updates the displayed balance only when called. Therefore a correct server deduction could leave the old number visible. Live v1.2 logs lack before/after wallet values, so they do not prove whether every reported incident was display-only; do not claim a proven global banking fix.

`changeWallet` now sends a silent sequenced WALLET receipt with real holder and expected balance, then logs delta/before/after/sequence for diagnosis. Client waits briefly for the replicated server balance before calling native statistics. It never overwrites `moneyX` with a client absolute value; older receipts are discarded. Existing client service loop also watches real-holder/balance changes every two seconds and refreshes native HUD for refunds/native salary or other changes. All prices remain unchanged. Headless tests check exact terminal/HE debits, ownership indirection, insufficient funds and no duplicate payment, but cannot verify actual human HUD rendering or concurrent third-party money scripts.

Previous jets held an ASL height 500 m above the highest terrain over the entire route. This could hide a pass high above a flat target because of distant hills. New `strikeFlightAltitude` samples local/ahead terrain, targets 150 m clearance, and computes a climb envelope with 4 km look-ahead and 60 m/s planned ascent. Aircraft controller updates that envelope every 0.25 seconds, allows up to 90 m/s climb / 60 m/s descent and aligns pitch to actual velocity. Speed remains 400 m/s (about 1,440 km/h). Jets can climb above 150 m when needed. This is terrain-aware flight, not a guarantee against every narrow peak/building/custom obstacle. Flight settings are in `DSDS_StrikeFlight`; transport delivery heights remain unchanged.

Modified gameplay: `config.cpp`, `fn_changeWallet.sqf`, `fn_clientService.sqf`, `fn_initServices.sqf`, `fn_spawnSupportAircraft.sqf`, `fn_flyStrikeAircraft.sqf`, `fn_runSupportContract.sqf`; added `fn_strikeFlightAltitude.sqf` (30th function). Updated project README, this notes file and full server fixture with owner-wallet and measured low-altitude assertions. No native functions, original DSD files, faction state, campaign save or Workshop files are changed.

Added an independent real-terrain flight test: `scripts/Test-SupportServicesTerrain.ps1` and `tests/support_services/dsds_terrain.Altis/{mission.sqm,description.ext,initServer.sqf}`. It uses a separate loopback port/profile, scans Altis terrain for a summit and flies an unarmed test pass across it without loading or editing a campaign. The first run caught a real water-approach bug: raw terrain height can be seabed height and placed the lower plane underwater. `strikeFlightAltitude` now clamps terrain height to at least sea level at every sample, maintaining 150 m clearance above water as well as land. The terrain fixture also expanded its summit search to include western Altis and measures clearance above the greater of terrain/sea surface.

Full VR run `arma3server_x64_2026-11-07_03-31-23.rpt`: **140 passes, zero failures and zero SQF expression/position errors**. Exact new-terminal debit 10,000; HE debit 30,000; real-owner wallet indirection and insufficient funds passed. Four offensive releases measured 150 m above terrain and 1,440 km/h with full afterburners. All eleven services completed and faction/airfield state remained unchanged. This run preceded the sea-floor clamp; flat VR terrain is zero, so its flight calculation is unchanged by that correction. Final build passes config validation, all 30 function registrations/references and delimiter checks, and all **32 packaged source files** hash-match editable source after extraction. Human HUD refresh still requires in-game confirmation; server deductions and receipt sequencing passed but headless tests cannot render the HUD.

Final v1.3 PBO SHA256: `868693A3F591F91FC777D318FEBFA86EACD76A48CFD8BDADD4A4EE1814254341`. Host/server and friends need the updated companion and a restart. Terminal purchase is 10,000 only for a new item; re-equipping an existing item stays free, and failed support dispatches still refund by design. Existing client log also contains a legitimate failed transport refund in v1.2; do not misdiagnose every returned payment as an accounting fault.

Final Altis test log `logs/support-services-terrain/arma3server_x64_2026-11-07_03-36-40.rpt` completed with **5 passes, zero failures and zero SQF errors**. Actual 25-second flight crossed summit `[4750,22000]` and 335.5 m of terrain elevation change, survived, and maintained minimum measured surface clearance **103.9 m**. This validates the final sea-floor correction on real land/water terrain, beyond the flat-map assertions. Total v1.3 checks: **145 passed**. Owned test servers are stopped and both copied test missions removed; logs and isolated profiles retained.



## Proposed feature: noise-triggered HQ raids — 2026-11-07 (design only)

**Subsequently authorized and implemented in v1.4.** See [implementation notes](HQ_NOISE_RAIDS_NOTES.md). The following paragraphs preserve the original design discussion.

User is asking for implementation advice, not yet authorizing this feature's code. Desired behavior: careless player noise/gunfire within 300 m of the current HQ eventually triggers an occupier raid. Helicopters land away from HQ, dismount 20–50 infantry and withdraw; infantry march on HQ with trucks/light patrol vehicles scaled by war level. Each raid consumes the triggering noise. After success/failure, no new noise raid may occur without fresh careless player noise. Preserve all faction/map state.

Recommended design: decaying server-owned noise score with player-attributed unsuppressed fire, explosives and vehicle weapons weighted by noise; suppressed shots contribute less. Track current placed HQ position and relocation, not a fixed original coordinate. Exclude enemy fire, raid attackers, unrelated AI and contractor support to prevent self-triggering loops. Threshold crossing locks in exactly one raid and consumes the accumulated score. Ignore/reset qualifying noise while the raid is active; rearm after the encounter ends, so battle gunfire cannot queue another raid. Optional short recovery/quiet period is only a gate, never an automatic repeat timer. Do not bank expired noise across raids or campaign reloads without an explicit persistence decision.

Suggested scale: war levels 1–3: 20–25 airborne dismounts plus 1–2 light vehicles; levels 4–6: 30–35 plus 2–3; levels 7–10: 40–50 plus 3–5. Aircraft count follows actual occupier transport cargo capacity. Vehicle crews are additional to the requested airborne infantry; avoid accidentally doubling the force with full truck squads. Helicopter landing zone 800–1,200 m from HQ, selected for dry/flat terrain, obstacles, spacing and viable foot approach; ground units spawn outside player sight and use road approaches where feasible. Faction classes come from currently selected occupying templates; never substitute AAF or edit ownership. Only one custom raid at a time and defer around an existing native HQ attack/major attack.

Inspected installed native `core/functions/create/fn_attackhq.sqf`: `A3A_fnc_attackHQ` has HQ task/reinforcement/retreat infrastructure but automatically creates UAV support, requests artillery, uses native resource/attack pools, changes shared attack state and awards native results. Calling it directly would add behavior beyond this proposed infantry/vehicle raid. Prefer an isolated noise controller and raid lifecycle, reusing verified lower-level faction spawning/AI/retreat functions after further inspection. Do not override the native HQ-attack function or disable ordinary Antistasi attacks. Petros's normal death/HQ-loss consequences remain unless user explicitly chooses otherwise. Native heli landing reference `fn_landhelicopter.sqf` uses shared globals and a global onEachFrame handler; it is not suitable to call blindly for independent transports.

Encounter should end when attackers are defeated/retreat, Petros/HQ is lost or moved, or a bounded assault timeout expires. Survivors retreat physically; clean only owned raid AI/vehicles after distance/visibility checks, preserving captured or player-occupied assets. Helicopter landing AI, road paths, player attribution, locality and overlapping native attacks require runtime tests. No gameplay files changed for this proposal.
