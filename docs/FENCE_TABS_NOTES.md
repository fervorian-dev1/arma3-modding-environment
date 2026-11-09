# Fence vehicle/item tabs and drone/AA inventory

2026-11-07, Support Services v1.7. User confirmed the Ultimate port works perfectly, then requested separate Vehicles / Items tabs, ten item offers, mostly modded FPV/UAV/control equipment, and anti-air capabilities.

## Behavior

- Existing Fence dialog now has two visible vanilla button tabs. Vehicles shows six offers; Items shows **ten distinct inventory offers**. Each page uses the same purchase flow, with authoritative global stock indices preserved through filtering. A tab's first item must not accidentally buy vehicle zero.
- Reserve two FPV inventory drones, one portable UAV kit, one real side-compatible UAV terminal and two AA launchers per rotation when those categories exist. Fill remaining slots with premium equipment, preferring mod-origin classes until **eight of ten** items are modded when possible. Missing optional categories yield slots to other valid equipment, never nonexistent classes. Counts are offers, not a global stock quantity cap.
- Vehicles retain the all-loaded-config pool and 2.8× mechanic-value pricing, with one ground AA-capable vehicle reserved when an eligible class exists. Other slots remain randomized; prefer fresh vehicle classes as before.
- Preserve DLC-free filtering, personal funds, silent supply deliveries, custom-valuables-only sales, quote/refund protection, existing 45–95-minute relocation and session-only stock/crates. No campaign faction/map/ownership or native API changes.

## Installed assets inspected

- Read-only extracted `ArmaFPV.pbo`, Workshop **3045129955**, under `reference/fpv/ArmaFPV/`.
- ArmaFPV's inventory drones are **CfgMagazines**, not weapons/backpacks: `Item_Crocus_AT`, `Item_Crocus_AP`, `Item_Crocus_AT_TI`, `Item_Crocus_AP_TI`. Verified against its config and native `DB_fnc_fpv_createUavOnItemCheck` switch. Buying places the actual item in the personal crate; taking/dropping/deploying follows ArmaFPV's own controls. No replacement FPV script/interface.
- ArmaFPV also supplies side-specific portable backpacks, including Independent kits with `maximumLoad=0`; these must be discovered directly because generic storage-backpack pools omit them.
- UAV kit `assembleInfo.assembleTo` must be a valid DLC-free UAV on `teamPlayer`'s side. Real control terminals use `ItemInfo.type=621` and compatible `ItemInfo.side`; those fields were verified in the installed vanilla `drones_f.pbo` `Weapons_F_Gamma/Items/config.bin` (read-only conversion in `reference/vanilla-drones/items.cpp`). The Support Terminal is not a UAV controller and is excluded.
- AA inventory is restricted to real portable type-4 launchers with valid free ammunition. Discovery checks intended/default magazines before broad magazine wells, missile `airLock>0` / `groundLock=0`, and excludes an explicit anti-tank purpose in the weapon description. This matters because installed RHS Javelin inherits Titan AA behavior despite declaring itself anti-tank. Ground vehicles use AA editor categorization or turret AA missile ammunition. Mounted ammunition is retained. AA purchases receive **five compatible, DLC-free AA missiles**, preferring the weapon's own declared ammunition over broad cross-mod compatibility.
- Mod origin uses the first `configSourceAddonList` entry, rather than counting later compatibility patches on vanilla equipment as new modded equipment. CBA/ZEN/local utility definitions are not premium mod content merely because they patch configs.

## Prices

Special stock uses these basis values × existing gear multiplier 4:

| Item role | Purchase credits |
|---|---:|
| FPV inventory drone | 6,000 |
| Portable UAV kit | 10,000 |
| Real control terminal | 5,000 |
| AA launcher plus five compatible missiles | 12,000 |

Premium filler retains existing tiers; custom goods keep explicitly configured overrides. Ordinary gear cannot be resold to The Fence. Vehicles still use the shared native-price-aware mechanic valuation ×2.8.

## Files

Modified addon files: `config.cpp` (v1.7, ten/eight stock targets, five new registrations); `fence.hpp` (tabs/layout); `functions/Fence/fn_fenceCatalogue.sqf`, `fn_fenceRotate.sqf`, `fn_fenceOpen.sqf`, `fn_fenceSubmit.sqf`, `fn_fencePrice.sqf`, `fn_fenceDelivery.sqf`; `functions/fn_initServices.sqf` (diagnostic version).

New Fence functions: `fn_fenceIsModded.sqf`, `fn_fenceIsAntiAir.sqf`, `fn_fenceBuildStock.sqf`, `fn_fenceOffersForTab.sqf`, `fn_fenceTab.sqf`. Five helpers take total registrations to **61**. The stock selector and tab/index mapping are shared pure-data paths tested independently of GUI rendering.

Other files: project launcher `mod.cpp` / README, root README, handoff, these notes; `scripts/Test-Fence.ps1` adds installed ArmaFPV to its test modset; existing `tests/support_services/dsds_fence.Altis/initServer.sqf` adds stock/category/quota/tab-index/native FPV deployment and real item purchase assertions. Original Dynamic Supply Drops and Workshop files remain unchanged.

## Verification

Final v1.7 SHA256: `A6A6092BC84DA8151F004A3A98B2DCAA6131CC16DCB67169B1E021015B75FEFC`.

**102 passes, zero failures, zero SQF expression/position errors** in `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_08-47-35.rpt`. Tests include twenty generated catalogues (8–9 modded offers each), missing-category fallback, retaining a sole AA vehicle across rotations, portable/role-specific AA classification, original seller protections, the correct tab/server index, actual FPV/UAV/terminal/AA cargo delivery with exact payments, native ArmaFPV deployment and matching-side UAV crew. The purchased Stinger package contained five actual `rhs_fim92_mag` entries, not just a display count. Confirmed Stinger inclusion and exclusion of the AT Javelin from the AA role.

CfgConvert validation passed; all **61 function references** resolve and all **64 packed source files** hash-match the extracted candidate/current source. Original DSD PBO is unchanged (`F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`). This run covers the changed Fence feature and its old protections; the earlier 429 Ultimate/Plus checks remain historical port evidence, not falsely reported as rerun for v1.7. User confirmed v1.6 works perfectly before these edits. Human tab rendering/control connection still needs in-game acceptance; a headless test does not prove a human can use every mod's controller.

Intermediate validation corrections: `magazineCargo` lists types rather than proving missile quantities, so the test now inspects five real `magazinesAmmoCargo` entries. An empty native ground holder can disappear after FPV deployment; the test caches its position before checking the deployed drone. The test also ends its AI pilot flight safely before deleting the aircraft, preventing a deferred exit/teleport from moving or killing the test buyer before the next order. These are isolated fixture corrections, not changes to player flight/ejection behavior. The AA purpose guard is a production classification correction, verified against installed `rhsusf_c_weapons/rhsusf_weap_launchers.hpp`. Superseded failed RPTs remain available.

Completion: owned Fence server stopped and its verified copied `dsds_fence.Altis` fixture removed from game MPMissions; test sources/logs retained. No user game process, faction/map, Workshop file or live campaign save was modified. Updated companion README/launcher metadata copied after validation; the tested PBO was not changed afterward.

## Player check

Restart Arma/server with the updated companion everywhere. Enable ArmaFPV alongside the existing modset to obtain its Crocus items. Approach The Fence, switch between **Vehicles** and **Items**, request your trade crate and buy an item. Confirm its displayed name/price matches the received item and exact personal debit. Retrieve gear from the crate. Use the real UAV terminal matching your rebel side; it occupies the same GPS slot as the separate Support Terminal, so swap equipment manually. Deploy FPV items using ArmaFPV's normal inventory/drop controls; portable kits use their normal assembly action. Test an AA launcher with the included missiles and check ground AA vehicle offers. Save/garage normal possessions as before; no new campaign is required for this addon update.
