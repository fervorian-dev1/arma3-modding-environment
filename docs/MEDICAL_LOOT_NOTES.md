# Injector medical loot — v2.1

Historical v2.1 release notes. Injector effects/prices/sources remain valid; **v2.2 replaces personal Fence crates with a community crate** and expands STASH contraband to include nicotine/Zyn. Current build, AI integration and DEBUG missions: [v2.2 notes](FENCE_MISSIONS_AI_NOTES.md).

Updated 2026-11-07. Target: installed Antistasi Ultimate12.0.3. User approved the existing artwork; all thumbnails, effect profiles and overdose rules are preserved. This revision replaces v2.0's Fence injector stock with medical loot. No campaign reset or Workshop edit is needed.

Closeout recheck: v2.1 is published with the SHA256 below; implementation is complete, test servers/copied fixtures are cleaned, and the built README matches source. This final notes update did not change gameplay or rebuild the PBO. Human multiplayer acceptance remains pending. Resume from [the handoff checkpoint](HANDOFF.md).

## Sources and payouts

| Injector | Class | Fence pays |
|---|---|---:|
| Morphine | DSDS_Morphine | 400 |
| AHJ-C | DSDS_AHJC | 600 |
| M11 | DSDS_M11 | 550 |
| Adrenaline | DSDS_Adrenaline | 500 |
| OLB-1 | DSDS_OLB1 | 650 |
| OLB-2 | DSDS_OLB2 | 750 |

Fence buys these through the existing personal trade-crate quote/sell flow. One of each pays3,450 personal credits. They never appear in his Items purchase rotation, including filler discovery. Ten mostly modded offers still prioritize FPV/UAV/control equipment and AA.

Automatic medical loot uses the native Ultimate event registry:

- **Supplies convoy objective:**3–6 injectors added to the transport's accessible inventory, after15seconds for native initialization. Ultimate uses this convoy type for medical/civilian supply deliveries, including non-ambulance trucks. Its locked visual mission cargo, route, rewards and completion logic remain intact. Escorts do not receive the objective consignment.
- **Enemy medical vehicles:**1–3 injectors in vehicles drawn from the loaded faction `vehiclesMedical`/`vehiclesCivMedical` lists. This includes native garrison/Medevac assets when initialized through `AIVehInit`. Rebel, purchased, captured and player-occupied assets are excluded.
- **Enemy medics:**35% chance of one injector, inserted into a worn container with room after native `AIInit`. Medic identity comes from native `unitType` membership in `A3A_faction_all.Medics`, so shared soldier base classes are handled correctly. Ordinary riflemen and rebel medics are excluded.
- **Authored medical containers:**server code can call `[_box,_count,"MEDICAL"] call DSDS_fnc_fillLootContainer`. This additive pool contains only the six registered injectors, at most two of any one class per call. Existing cargo is retained. Common valuables, Special Convoy industrial goods and contraband-stash pools do not gain injectors.

Relative selection weights are Morphine5, AHJ-C3, M113, Adrenaline4, OLB-11 and OLB-21. Automatic additions happen once per object. They do not refill after looting, reroll unsuccessful medic chances, spawn extra crates, or clear native contents. Insufficient capacity can reduce actual drops. New events affect newly initialized assets, not every already spawned unit/container.

`DSDS_MedicalLoot` in `medical.hpp` contains enable/delay/count/chance/weight settings. `DSDS_FenceGoods` tags the six classes `lootPool="MEDICAL"`, `stock=0`; their sell prices remain independent of stock availability. Injectors stay outside unlimited arsenals. Shop-bought medical boxes are deliberately excluded from automatic seeding because native boxes can cost only5credits.

## Implementation and review

Created:

- `addons/dsds_support/medical.hpp`.
- `functions/Loot/fn_initMedicalLoot.sqf`:guarded `AIVehInit`/`AIInit` listeners on server and headless clients.
- `functions/Loot/fn_medicalPool.sqf`:valid loaded DLC-free medical-tagged classes.
- `functions/Loot/fn_medicalLootObserved.sqf`:server/registered-HC authentication, native context/type/side checks and delayed processing.
- `functions/Loot/fn_seedMedicalLoot.sqf`:additive inventory worker, capacity and duplicate guards, capture recheck.

Modified addon files: `config.cpp` (v2.1, four function registrations, one narrow server RPC, medical include and payouts/stock tags); `functions/Loot/fn_fillLootContainer.sqf` (MEDICAL pool); `functions/Fence/fn_fenceCatalogue.sqf` and `fn_fenceBuildStock.sqf` (remove injector offers/reservations); `functions/fn_initServices.sqf` and project `mod.cpp` (version text).

Modified source fixtures: `tests/support_services/dsds_fence.Altis/initServer.sqf` and `dsds_expansion.Altis/initServer.sqf`. Documentation: this note, handoff, root/project READMEs and historical v2.0 banner. Original DSD addon, all artwork, item descriptions and consumption effects are unchanged.

Inspected installed native sources read-only: `core/functions/missions/fn_convoy.sqf`, `create/fn_aivehinit.sqf`, `create/fn_natoinit.sqf`, `create/fn_createunit.sqf`, `templates/fn_compilemissionassets.sqf`, `templates/templates/factiondefaults/rebeldefaults.sqf`, `ammunition/fn_filllootcrate.sqf`, and `events/events.hpp`. No invented native function or vehicle classname is used by production detection.

## Validation and use

**266 checks passed, zero failures or SQF errors**, using isolated dedicated Ultimate fixtures:

- Fence119: `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_16-42-13.rpt`. Includes20 rotations without injector offers, exact six payouts, a real six-injector quote/sale with3,450 personal-wallet credit, and prior drone/AA/boat/payment protections.
- Expansion147 on the final published PBO: `logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_16-44-24.rpt`. Includes real native event-registry calls, delayed3–6/1–3 additions, preserved native supplies, actual worn-container medic loot, duplicate/friendly/ordinary-truck rejection, pool separation, effects, artwork, rare convoys, response/pursuit, cloud registration and stash completion.

Fence ran on the preceding verified candidate; only the new medical worker's source/type guards changed before the final build. Fence catalogue, prices, stock and transaction paths were unchanged. CfgConvert and independent source review passed; all97 function registrations match97 source functions. Build extraction compared all123 packed files against source with no differences. No wholesale rerun of unrelated legacy support/raid suites was needed.

Published `build/@AntistasiSupportServices/addons/dsds_support.pbo` SHA256:

```text
DA90F8EE2F6D0CA8276410AF197C1851079C7D94C4A41F3ED844939CF546FE34
```

Original DSD remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`. Owned test servers were stopped after exact PID/executable/profile/port checks; only the inspected copied Fence/Expansion fixture folders were removed from game MPMissions. Source fixtures and logs remain. No player game process was stopped.

A real multiplayer/headless-client campaign remains a human acceptance step; server fixtures exercise the installed event registry with native-shaped metadata, not an entire live convoy route or a networked HC medic. Client rendering, inventory replication under latency and prior CWP visual/medical acceptance remain unverified.

Restart host/server and every client with the updated `build/@AntistasiSupportServices` folder. Keep the original Dynamic Supply Drops addon enabled. No launcher re-add or save reset is required. Find a newly spawned native Supplies convoy or enemy medical vehicle and inspect its **vehicle inventory** after initialization; do not expect the locked decorative objective box to become openable. Loot enemy medics for occasional single injectors. Put injectors in your personal Fence crate, quote and sell to confirm the values above. Existing campaign economy and all other mission types are preserved.
