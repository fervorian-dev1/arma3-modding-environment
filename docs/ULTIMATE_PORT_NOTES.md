# Antistasi Ultimate compatibility port

2026-11-07. User authorized switching from Antistasi Plus to Ultimate and porting the local gameplay addons as needed. User then confirmed **a fresh Ultimate campaign**, with no campaign progress/save files to migrate and no campaign start until the port is ready. No save conversion is needed. Faction/map choices, relationships and ownership remain outside this addon's scope.

## Inspected target

- Installed Workshop **3020755032**, Antistasi Ultimate **12.0.3.0**, read from its packaged `core/Includes/script_version.hpp`.
- Read-only extracted references: `reference/ultimate/{core,scrt,ultimate,gui,logistics,jeroen_arsenal,events}`. No Workshop files edited.
- Existing source target was Plus **2.3.2** (Workshop 2912941775). Keep one Antistasi edition enabled at a time; both ship overlapping A3A addon/function names.
- Original Dynamic Supply Drops remains v1.1.0, unchanged. Its optional loading/arsenal adapter uses APIs still present with matching arguments in Ultimate.
- Support Services port is **v1.6**, retaining Plus support through runtime capability detection rather than a hard Ultimate dependency.

## Audit and production changes

The following native interfaces remain available with the arguments we use: personal `moneyX`/`owner` ledger; `A3A_fnc_statistics`; `setStatVariable`/`returnSavedStat`; `A3A_saveTarget` and native player-save hashmap; `A3A_fnc_createUnit`, faction/role compilation and `A3A_customUnitTypes`; native damage/killed handlers; `A3A_fnc_airbomb`, napalm particles/damage, recon and loot gathering; native logistics and JNA cargo conversion/unlock management. Petros and `serverInitDone`/`bigAttackInProgress` still exist. No global native function overrides were introduced.

Two actual differences required adaptation:

1. **Vehicle prices:** Ultimate has category-nested `A3U_blackMarketStock`, a vehicle discount and diminishing seaport/resource reductions. Its `vehiclePrice` queries black-market stock even for HQ entries and falls back to 1,000 for unknown prices. Blindly querying all runtime classes would emit native errors and invent caps. New `DSDS_fnc_vehicleShopPrice` reads only known prices, applies the inspected native discount rules, returns the cheapest known source, and returns zero for unknown prices. The mechanic's existing 50% resale cap now covers Ultimate market-only vehicles; The Fence still quotes 2.8× mechanic value. Plus retains its native HQ-price path. Isolated assertions compare the adapter directly with Ultimate's actual native price functions.
2. **UAV crew:** Ultimate `A3A_fnc_AIVEHinit` creates buyer-side UAV crew itself. Fence delivery now preserves that crew, creating crew only if no driver exists. This prevents redundant native initialization/groups while keeping Plus behavior. Native civilian/vehicle initialization remains native; no side relationships or campaign ownership changes.

Production files:

- Modified `projects/antistasi_support_services/addons/dsds_support/config.cpp`: v1.6, one new function registration (56 total).
- Created `functions/fn_vehicleShopPrice.sqf`.
- Modified `functions/fn_vehicleValue.sqf`: shared known-price adapter.
- Modified `functions/Fence/fn_fenceDelivery.sqf`: retain native UAV driver/crew.
- Modified `functions/fn_initServices.sqf`: accurate version/edition diagnostic.
- Modified companion project `mod.cpp` and README; updated handoff/root README and these notes. Updated Dynamic Supply Drops README/launcher description to advertise the verified Ultimate adapter, without touching its SQF/config/PBO.
- Companion PBO rebuilt using staged extraction/hash verification. Pre-port v1.5 PBO retained in ignored `temp/pre-ultimate-v15/dsds_support.pbo`.
- No Dynamic Supply Drops gameplay/source changes; no mission reward/faction/save conversion scripts installed.

## Validation helpers and fixture changes

Six existing helpers now accept `-Edition Ultimate|Plus` (default **Ultimate**) and use edition-specific profiles: `Test-SupportServicesServer.ps1`, `Test-SupportServicesUI.ps1`, `Test-SupportServicesTerrain.ps1`, `Test-HQNoiseRaid.ps1`, `Test-Fence.ps1`, `Test-SupplyDropsServer.ps1`. They load only the selected Antistasi Workshop ID. Sources/ports stay separate by feature. Server helpers reject an already-used test port before copying a fixture. Do not run two editions of the same fixture/port together. All PowerShell helpers passed parser validation.

Fixture additions are isolated initialization, not production workarounds:

- `dsds_validation.VR/testUltimate.sqf`: native price comparisons, market-only and unknown classes, exact capped resale; called conditionally by `initServer.sqf`.
- Main support fixture initializes Ultimate's `lootCrateUnlockedItems=false`, matching the parameter normally initialized by a real campaign. The first preliminary Ultimate run omitted this and produced native loot-function undefined-variable errors; it was superseded after initializing the missing fixture parameter. Do not disable that parameter in the user's campaign.
- Raid fixture supplies Ultimate's `loadoutsToGenerate` when loading the actual installed 3CB AAF template, rather than editing production faction data.
- Fence fixture exercises the full real Ultimate vehicle-init path with Independent rebels and complete isolated faction animation/variant/loot-crate data. An initial test used a West rebel, which conflicts with native Ultimate's fixed side-to-faction macro and caused missing faction-data errors; the fixture was corrected to the real Independent mapping. This is not a campaign-side change.
- Fence fixture also supplies a dummy rebel marker and the native `varsHardcoded.hpp` 50 m marker-radius default, required by Ultimate's ground-vehicle initialization. Missing fixture values caused native lookup errors in intermediate runs; final tests below ran the actual functions with complete initialized state. No native functions were replaced/stubbed to make them pass.
- Plus regression fixture adds three direct old-price-path/cap assertions; existing side/visibility checks are retained.

Verified v1.6 PBO SHA256: `81D4009019EF307E2459D57EF43615A27A0AAACCDEB6DFCE0072973913DDDD4B`.

Final runtime results:

- Ultimate support services: **146 passes, zero failures/SQF expression errors**, `logs/support-services-validation-ultimate/arma3server_x64_2026-11-07_06-56-22.rpt`. Includes five new actual-native price comparisons, wallets, all eleven physical services, direct arsenal imports, mechanic and unchanged faction/airfield state after delayed native effects.
- Ultimate HQ raids: **96 passes, zero failures/SQF expression errors**, `logs/hq-noise-raid-ultimate/arma3server_x64_2026-11-07_06-56-22.rpt`. Actual 3CB AAF faction/Ultimate custom unit generation, 20 airborne infantry and three real helicopter landings/unloads at 1040/1024/1013 m, march, retreat/rearm and protection checks.
- Original unchanged DSD: **98 passes, zero failures/SQF expression errors**, `logs/supply-validation-ultimate/arma3server_x64_2026-11-07_06-58-24.rpt`. Includes actual C-130 drop/descent, five matched magazines, paid-DLC exclusion, real two-slot truck load/unload, direct/automatic Ultimate JNA imports and preserved cargo/node accounting.
- Ultimate Fence: **63 passes, zero failures/SQF expression errors**, `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_07-03-40.rpt`. Includes all v1.5 goods/quote/money/rotation/delivery checks plus real Ultimate `AIVEHinit` calls and exactly one native two-member UAV crew on the Independent buyer's side. Crew/pilot boarding, in-flight speed and vehicle ownership passed.
- Ultimate separate-process mechanic persistence: **3 alive-restore checks + 2 dead-restore checks**, zero failures/SQF errors; logs `support-services-validation-ultimate/arma3server_x64_2026-11-07_07-02-21.rpt` and `...07-03-39.rpt`. The fresh processes use Ultimate's actual statistics storage, not an in-memory mock.
- Plus fallback: **21 passes, zero failures/SQF expression errors**, `logs/support-services-validation-plus/arma3server_x64_2026-11-07_07-04-58.rpt`; original visibility/friendly-side checks and old native pricing/caps. This is a targeted fallback regression, not a second full eleven-contract Plus run.

**Total final checks: 408 on Ultimate + 21 on Plus = 429 passes, zero failures/SQF expression errors in these final runs.** All 56 function references resolve; all **59 packed addon files** extracted/hash-match current source. Original DSD PBO SHA256 remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`. The service PBO is the verified v1.6 hash above; subsequent README/launcher description updates do not change gameplay.

Earlier failing fixture-initialization runs remain in logs and are superseded, not erased. Some third-party addons emit config/model warnings (notably FHQ/RKSL/CBA compatibility warnings); a zero SQF-error count is not a claim that every Workshop asset is warning-free.

Completion cleanup: owned test servers stopped; owned copied `dsds_validation.VR`, `dsds_fence.Altis`, `dsds_raid.VR` and `dsd_validation.VR` fixtures removed from game MPMissions after verifying their identities/allowed files. Test sources and profiles/logs retained. No user game process or campaign save was touched.

## Installation and campaign boundary

1. Fully close Arma and restart any dedicated server after the update.
2. In Launcher, **disable Antistasi Plus** and enable **Antistasi Ultimate**, existing dependencies and both local addons. Use the existing local mod folders. Every client/server needs matching local companion and Workshop content.
3. Host an Ultimate mission using its normal menu. Keep your chosen factions/map; the port sets neither. Test Petros's terminal/mechanic, money, direct arsenal sales, The Fence and a controlled HQ raid in the new edition.
4. Normal Ultimate campaign saves persist the mechanic inside that Ultimate campaign. Fence remains session-only as before. Save/garage vehicles normally.

**User confirmed a fresh campaign, so campaign-save migration is out of scope and unnecessary.** No original Plus save has been read, renamed, overwritten, imported, deleted or reset. For future reference, addon portability is separate from save conversion; renaming a Plus save does not establish compatibility. Ultimate's official FAQ identifies `AntistasiUltimate.vars` / profile saves. No migration is claimed or required for this user's new campaign.

Sources consulted in addition to the installed code: [Ultimate official FAQ](https://antistasiultimate.com/FAQ/), [official repository/changelog](https://github.com/Antistasi-Ultimate-Community/A3-Antistasi-Ultimate/blob/unstable/ChangelogUltimate.md). Installed 12.0.3 source is the compatibility authority for this build, rather than assuming the current online branch matches it.

## Remaining acceptance

Dedicated-server fixtures validate actual native functions and physical entities with controlled campaign data. Human UI rendering, authenticated positive player RPC, JIP/respawn, remote pilot locality transfer, real-campaign combat/ACE behavior, every newly installed asset and actual 45–95-minute Fence timing still need in-game acceptance. Full live campaign-save conversion is not claimed. The terminal retains its existing eleven services and prices; this port does not automatically add every future Ultimate support option.
