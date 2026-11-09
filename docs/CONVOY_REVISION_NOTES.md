# Convoy repairs — companion v2.3

Published 2026-11-07. Target: installed Antistasi Ultimate 12.0.3. Restart host/server and every client with `build/@AntistasiSupportServices`. Friends need that whole updated mod folder. No new campaign is required. Original Dynamic Supply Drops, Workshop files, faction selections, relationships, territory, saves, artwork and consumable effects were not changed.

## Gameplay

- Zeus retains **Modules > DEBUG**, but mission tasks, map markers, group names and player messages use ordinary mission wording. Internal IDs/RPT diagnostics still identify debug starts.
- Isotope cargo now uses actual cargo/medical trucks. Config checks reject ammo/fuel/repair resupply trucks and require usable carrying capacity. Inventory is unlocked on server, clients and JIP clients. Each shipment contains six sealed isotope items plus **6–10 injector items**, maximum two of each injector type (at least three distinct types with the installed six-item pool). Dedicated tests verify inventory cargo and unlocking; human inventory-taking acceptance remains.
- Destroying the isotope truck triggers three actual installed `PHEN_FSPLUS_AsphyxiantBomb_Unguided` projectiles and native CWP contamination. A 0.5-second server watchdog backs up the death-event queue; release is deduplicated. Tests deliberately removed the truck's MPKilled handlers and still observed release.
- CWP initialization is awaited on clients. The native particle code offsets origins by -6m; the wrapper now supplies a 6m ATL source. Main contamination remains 300m/15 minutes with an additional dense 45m rupture cloud for up to 90 seconds. Native CWP kill switch is respected. Existing JIP cloud replay remains.
- Isotope escorts use one or two crewed transports with **unstabilized door-gun turrets only**. Pilot weapons, pylons, explosive magazines and stabilized/copilot turret weapons are removed. Allowed ammunition must be kinetic `shotBullet`, have no explosive/splash damage and have hit <=35. The installed vanilla Ghost Hawk minigun is intentionally excluded: its submunition has splash damage. Validated RHS Chinook/UH-60/CH-53 transports provide alternatives. Filters run again during the escort; player-occupied aircraft are protected.
- Automatic isotope conversion is limited to eligible native **Supplies** cargo objectives (3% roll), so native ammo/fuel/repair objectives keep their intended trucks. Special conversion retains its 5% eligibility on native Ammo/Fuel/Repair objectives; shared rare cooldown remains 90 minutes. Native task, movement, objective vehicle references and ordinary cargo are preserved.
- Special shipments choose exactly one random theme. **METALS:** Gold Bullion, Palladium Sponges, Industrial Platinum. **TECH:** Silicon Wafers, Microchips, Palladium Sponges. **JEWELRY:** Cut Gems, Rough Gems, Gold Bullion. Delayed medical seeding cannot contaminate these manifests. Existing stolen-goods helicopter pursuit still lasts until the spotters are destroyed.

## Aggression scaling

Read the convoy owner's native `aggressionOccupants` or `aggressionInvaders`, clamped to 0–100. Never write either value or change factions.

| Aggression | Debug ground escorts | Native supplemental escorts | Passengers per escort | Isotope air escorts |
|---|---:|---:|---:|---:|
| 0–24 | 2 | 0 | 2 | 1 |
| 25–49 | 3 | 1 | 4 | 1 |
| 50–74 | 4 | 2 | 6 | 2 |
| 75–100 | 5 | 3 | 8 | 2 |

The objective truck is additional to these counts. Native convoys retain their original escorts, with supplements added after native initialization. Skill increases with aggression and war level while the existing AI Accuracy Fix integration is preserved. APC/IFV candidates enter at aggression 50; tanks enter at 75 with war level >=7, subject to the selected faction's assets. Special alert reinforcements and spotters also scale. Native Ammo/Fuel/Repair/Supplies/Money/Armor/Prisoners/Reinforcements objectives use the defense hook. Cleanup protects captured/player-occupied vehicles and delays removal near players.

## Files

All addon paths below are relative to `projects/antistasi_support_services/addons/dsds_support`.

Created `convoys.hpp` and ten registered functions under `functions/Smuggling/`: `fn_specialConvoyPool.sqf`, `fn_convoyDefenseProfile.sqf`, `fn_isConvoyCargoTruck.sqf`, `fn_convoyCargoTrucks.sqf`, `fn_safeDoorAmmo.sqf`, `fn_convoyDoorHelis.sqf`, `fn_sanitizeConvoyHeli.sqf`, `fn_convoyEscortPool.sqf`, `fn_convoyProtection.sqf`, `fn_isotopeInventory.sqf`.

Modified `config.cpp`, `functions/fn_initServices.sqf`; Smuggling functions `fn_upgradeConvoy.sqf`, `fn_isotopeRelease.sqf`, `fn_chemicalCloud.sqf`, `fn_initSmuggling.sqf`, `fn_convoyObserved.sqf`, `fn_smugglingVehicle.sqf`, `fn_convoyResponse.sqf`; Loot functions `fn_fillLootContainer.sqf`, `fn_seedMedicalLoot.sqf`; Debug functions `fn_startDebugConvoy.sqf`, `fn_tickDebugMission.sqf`, `fn_queueCustomMission.sqf`, `fn_debugMissionRequest.sqf`. Project `mod.cpp` and README updated for v2.3.

Tests: updated expansion and focused Fence-mission `initServer.sqf` fixtures; added `tests/support_services/dsds_convoy_defenses.Altis/` (mission.sqm, description.ext, initServer.sqf, optional initPlayerLocal.sqf client probe). Added `scripts/Test-ConvoyDefenses.ps1` and `scripts/Test-ConvoyClient.ps1`. Notes/handoff/root README updated. Reference extractions are read-only, ignored local research files.

## Verification and limits

**239 passing assertions across component runs, zero failures in the final component results:**

- `logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_22-13-26.rpt`: 161 PASS, 0 FAIL. Broad expansion regression on an earlier v2.3 candidate before the final turret restriction/client diagnostics/native-record cleanup.
- `logs/fence-missions-validation-ultimate/arma3server_x64_2026-11-07_22-24-44.rpt`: 56 PASS, 0 FAIL. Actual moving convoy, high-aggression five escorts plus cargo truck, two sanitized helicopters, injector quantities, unlocked inventory and watchdog chemical release without kill handlers.
- `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-07_22-24-44.rpt`: 22 PASS, 0 FAIL. All three exact theme manifests; invalid resupply trucks rejected without clearing their cargo; aggression bands; actual sanitized transport with injected unsafe weaponry; native Money convoy receives three real supplements without changing its task or original cargo.

Final production change after these runs only removed DEBUG from a private invalid-position error. CfgConvert and full source-to-extracted-PBO hash comparison passed after rebuilding. **116 registered functions /145 packed files.** Earlier fixture failures were corrected: count unique classes rather than total themed quantities, use real `markerText` instead of nonexistent `getMarkerText`, and do not assume the Ghost Hawk's minigun is non-explosive. These were test assumptions, not accepted gameplay failures. Previous v2.2 Fence transaction suite remains historical; it was not rerun for these convoy-only changes.

An isolated hidden actual-client attempt stalled during startup, before joining the test mission. It produced no client chemistry acceptance result and was stopped using its verified owned PID/profile. Dedicated tests cannot prove rendered gas, exposure/medical behavior or human UI access. **Still test in game:** take injectors from the truck, destroy a separate isotope truck and observe CWP gas/exposure with your normal protective equipment settings, verify door gunners visually, and try HC/JIP/two-client behavior. Use Zeus Modules > DEBUG > Start Isotope Convoy near a road. Repeat Start Special Convoy to sample the themes; random selection may repeat. No public debug prefix should appear.

CWP must be installed/enabled on everyone for its effects. If no same-side transport passes the strict door-gun filter, isotope designation fails gracefully rather than substituting an armed attack helicopter. Flight AI, terrain, faction asset availability and simultaneous high-aggression convoys can affect delivery/performance. No global AI/CWP settings were overridden. No normal user game process was stopped; only owned test processes/fixtures were cleaned. Source/logs remain, with no Git commit created.

Published SHA256: `629D705C18B06695D70F79DC05E9018C92F6418E2D5E96BFDA6DBAC710281B0B`.

Native API references: [lockInventory has local effects](https://community.bistudio.com/wiki/lockInventory), [triggerAmmo](https://community.bistudio.com/wiki/triggerAmmo), [SQF identifiers are case-insensitive](https://community.bistudio.com/wiki/identifier). Installed CWP spawnMist/bootstrap/bomb config and Ultimate convoy/aggression sources were inspected under `reference/`; the client offset correction follows that installed CWP implementation.
