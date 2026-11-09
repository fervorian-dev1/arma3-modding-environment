# The Fence development notes

Historical v1.5 notes. Current **v1.7** uses separate Vehicles/Items tabs and ten mostly modded item offers; see [current Fence tabs/stock notes](FENCE_TABS_NOTES.md). User confirmed the subsequent Ultimate port works perfectly.

2026-11-07. Companion v1.5, built on Support Services v1.4. Original Dynamic Supply Drops and Workshop sources are preserved.

## Accepted requirements and decisions

- Unarmed civilian called **The Fence**, inside a medical tent at a random dry, flat roadside clearing.
- Announces his first camp after discovery finishes. Subsequent successful rotations occur after a uniformly random **45–95 minutes of mission runtime**; he remains at that location between rotations. Each replacement is at least 1 km from the previous camp. No forced fallback placement; failed searches retain the old camp and retry after five minutes.
- Six distinct vehicle offers at all times when six usable classes exist; twelve premium gear offers. Prefer different vehicle classes at the next rotation. Purchases do not remove an offer; stock is a rotating catalogue, not a six-vehicle global quantity cap.
- Discover loaded server configuration: land vehicles (including statics), helicopters, planes, boats and UAVs, without faction/classname whitelists. Exclude non-public definitions, parachutes, missing models and paid DLC, preserving the user's earlier no-DLC rule. New mods must be enabled on server and clients, not merely downloaded. Non-vehicle props/characters are not vehicles for sale.
- Vehicle price is exactly **2.8 × the undamaged mechanic sale valuation at rotation time**, including its native shop-price cap. Prices are fixed for that rotation. Gear uses four times its own sale-value tier. No ordinary equipment resale through The Fence.
- User explicitly chose **buyer in pilot seat** for airborne purchases and **only custom valuables** for sales. Ordinary guns/ammo/clothing/backpacks in a trade crate cause the entire sale to be rejected without removal or payment. Unpack valuables before selling; unsupported container wrappers must also be removed.
- All payments/proceeds use personal money and the existing owner-aware ledger. No faction treasury, faction templates, relationships, location ownership or map selections are changed.

## Implementation

New `functions/Fence/` functions:

| File | Purpose |
|---|---|
| `fn_initFence.sqf` | Idempotent postInit; server rotation loop, local action repair/JIP |
| `fn_fenceLocation.sqf` | Road-adjacent safe-site search, dry/flat/clear/player-distance checks |
| `fn_fenceCatalogue.sqf` | Scheduled merged-config discovery, existing free-asset/pool helpers |
| `fn_fencePrice.sqf` | Generic gear tiers and explicit custom-valuable whitelist |
| `fn_fenceRotate.sqf` | Civilian/tent creation, six vehicles, gear rotation, public state/marker/alert |
| `fn_fenceOpen.sqf` | Simple vanilla combo/buttons display |
| `fn_fenceSubmit.sqf` | Local request/quote-confirm flow |
| `fn_fenceRequest.sqf` | Player/sender/side/mission/rate authentication |
| `fn_fenceTransaction.sqf` | Proximity, server prices, generation checks, personal crate, quote/sale/debit |
| `fn_fenceCargoValue.sqf` | Exact nested manifest, custom valuation, unsupported-content detection |
| `fn_fenceDelivery.sqf` | Gear/vehicle fulfilment, delivery checks/refunds, native vehicle initialization |
| `fn_fenceBoard.sqf` | Server-authorized local pilot boarding, engine/throttle/velocity |

Other addon edits: `config.cpp` (v1.5, twelve function registrations, two narrow remote entries, Fence settings/custom goods/custom item, explicit already-required CBA common dependency); new `fence.hpp`; `fn_clientService.sqf` adds Fence alerts and quote display only. Launcher `mod.cpp` updated. No original support/raid logic is replaced.

Workspace file inventory beyond the addon: modified `scripts/Build-SupportServices.ps1`, `projects/antistasi_support_services/mod.cpp`, `projects/antistasi_support_services/README.md`, root `README.md`, and `docs/HANDOFF.md`; created this note, `scripts/Test-Fence.ps1` and the three fixture files listed below. Generated companion PBO/metadata/README are under `build/@AntistasiSupportServices/`. No Dynamic Supply Drops source/build files, original Antistasi/Workshop files, live mission saves or installed maps were edited.

New tests: `tests/support_services/dsds_fence.Altis/{mission.sqm,description.ext,initServer.sqf}` and `scripts/Test-Fence.ps1`. Test server uses loopback port 24356 and isolated `logs/fence-validation`; includes newly installed FHQ and RKSL mods alongside existing RHS/CBA/ZEN/Antistasi. Tests use an AI actor only through the internal authorized transaction scope; the public endpoint must reject that AI actor. This does not prove positive human RPC/UI operation.

### Goods and crates

Each player requests a personal trade crate. Stock gear is delivered into it. Sales use a server-generated manifest/price, explicit confirmation, 60-second expiry, full content recheck and atomic wallet/cargo operations. No client-supplied item class or price is trusted. Duplicate sales and stale rotations fail. Ordinary gear stays intact when rejected.

Initial custom valuable: **Encrypted Data Receiver**, classname `DSDS_ValuableReceiver`, value **2,500 personal credits**. It reuses the existing free GPS visual, with CBA's miscellaneous-item configuration instead of GPS simulation. Model/icon paths were verified in the installed vanilla `weapons_f.pbo` config; the CBA base convention was checked against its source. Scope 1 / arsenal scope 0 makes it scripted mission loot, excluding it from ordinary scope-2 random supply pools. This is a starter scripted mission valuable, not an imported/downloaded model. `DSDS_FenceGoods` is the extension registry (`classname`, `section`, `sellValue`, optional `stock`). Future model-based valuables can register here. `stock=0` prevents selling the receiver to players. No existing mission reward/loot table is rewritten to inject it.

Keep custom valuables outside the arsenal: they are deliberately hidden from arsenal/loadout menus, avoiding unlimited valuable withdrawals/resale after native unlock thresholds. Installed JNA reads `scopeArsenal` before `scope` when constructing its weapon/item catalogue (`jna/fn_arsenal.sqf`). Future valuable definitions should keep this restriction. Carry/store them as physical loot and sell them to The Fence.

Personal crates are not private inventory vaults: nearby players can use Arma's normal inventory, but only the registered owner may quote/sell that crate. Do not leave valuables unattended. Empty abandoned crates can be replaced at a new camp; nonempty crates are retained and their grid is reported. There is no automatic transfer of their cargo into the arsenal and no remote selling from old camps.

### Vehicles

- Ground vehicles/helicopters: safe dry clearance 25–180 m from camp, uncrewed and unlocked. Boats: safe water within 3 km; failure refunds.
- Crewed fixed-wing: buyer must be on foot. Spawn roughly 2.5 km from camp, at least 800 m above the highest sampled terrain along the initial 8 km corridor, simulation held while boarding. Server verifies the buyer in pilot seat, then enables flight; owner-local code starts engine/full throttle and sets speed to at least 80 m/s or 1.5× configured landing speed. No AI pilot takes the buyer's seat.
- Buyer with no backpack receives `B_Parachute`. Existing backpacks are preserved, so a buyer carrying another pack must arrange their own parachute/ejection equipment. No destructive backpack swap.
- UAVs receive buyer-side native UAV crew and are not boarded as human aircraft; fixed-wing UAVs also start in flight. UAV control still requires a real UAV terminal, not the Support Terminal.
- Vehicle default inventory cargo is cleared; mounted weapons/ammunition remain. In a real initialized campaign the same `A3A_fnc_AIVEHinit` and `SCRT_fnc_misc_tryInitVehicle` hooks as the native black market are used. Ownership is assigned to the buyer. Use normal Antistasi garaging/saving; purchases are not automatically added to the garage.
- One pending delivery per player; failed creation/boarding refunds once to captured holder, with native offline player-save-map fallback if the holder was deleted. Delivered assets are not insured against later loss.

## Session behavior and limitations

- Fence camp, timer, stock and personal trade crates are **session state**, not custom campaign-save records. Restarting creates a new camp/rotation. Recover goods and save/garage possessions normally before quitting. PMC mechanic campaign persistence is unchanged.
- If killed, The Fence stays dead until the next scheduled rotation creates his replacement. There is no immediate resurrection or faction diplomacy change.
- Old tent waits for nearby visitors to leave before deletion. Nonempty trade crates and purchased vehicles are not deleted by rotation. Regular Antistasi cleanup/AI/airspace behavior still applies.
- All public configured vehicle variants can be selected, so cosmetic variants may occupy distinct offers. Broken third-party configs cannot be guaranteed; unsuitable spawn sites fail/refund. No claim that every mod aircraft/boat/UAV was physically tested.
- Runtime timing is not wall-clock persistence through server shutdown. First catalogue discovery can take around a minute with many assets because the existing DLC filter inspects models.
- Human menu rendering, dedicated-client locality transfer, respawn/JIP, parachute behavior with every mod and full 45–95-minute observation require player acceptance. Timer bounds/rotation behavior are tested separately rather than pretending to wait hours.

## Verification

Verified candidate SHA256: `CAB6D6037ACF754165FC22C3207E79FBF3D51908B350C91FE3694C603F1623A7`.

- `logs/fence-validation/arma3server_x64_2026-11-07_06-32-53.rpt`: **62 passes, zero failures, zero SQF expression/position errors**. Actual Altis roadside camps/relocation, six unique vehicles, exact 2.8× prices, cargo-only custom valuable and its real 5,000-credit sale, retained ordinary/mixed goods, duplicate/stale-sale protection, gear plus five magazines, actual ground vehicle, airborne crewed plane/pilot boarding and buyer-side airborne UAV all passed. Discovered 979 vehicle / 672 premium-gear definitions with the test modset.
- All 55 function references resolve to source; all **58 addon files** extracted/hash-matched to the verified build candidate. CfgConvert validation passed. User's original DSD hash remained `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.
- `logs/support-services-validation/arma3server_x64_2026-11-07_06-36-54.rpt`: **140 passes, zero failures/SQF expression errors**, all eleven native support types physically fulfilled, exact wallets, mechanic/sales/arsenal transfers, low strike passes, and preserved faction/airfield state including delayed native effects. Combined final result: **202 passing checks**.
- A preceding concurrent regression on the final candidate had two assertions fail for one physical SUPPLY crate: RPT explicitly reported it falling under terrain, and its unchanged landing watchdog refunded it as designed. The complete solo rerun above passed. This demonstrates an intermittent physics failure, not a promise that every Arma parachute delivery is infallible. No supply/raid gameplay functions were edited for this feature.

Build debugging history: a test arithmetic mistake was corrected. Switching sales to custom-only exposed an inventory-class configuration issue in the new starter valuable. Repeated tests were then found to have loaded a stale PBO: FileBank returned success while a second owned test server held the old output open. Both owned servers were stopped; `Build-SupportServices.ps1` now creates a fresh staging candidate, extracts/hash-compares every packed source file, publishes using a copy that fails on file locks and verifies the published hash. The final Fence run above used the verified candidate and succeeded. Do not trust the superseded failing runs as tests of later source edits. This proven write-lock issue does **not** establish the cause of the user's earlier Google Drive upload stall.

Completion cleanup: owned test servers stopped; owned copied `dsds_fence.Altis` / `dsds_validation.VR` fixtures removed from game MPMissions. Test sources, profiles and RPT evidence remain in the workspace. User game processes were not stopped. Final PBO/source hashes rechecked; launcher metadata/README updated without modifying the tested PBO.

## Player test

1. Fully restart Arma with the updated companion on host/server and every client; original DSD is still required.
2. Resume the campaign. After config discovery, look for **The Fence** marker/message. Approach the unarmed civilian in his medical tent and choose **Trade with The Fence**.
3. Request your trade crate before buying gear. Take purchased gear from the crate. Verify exact personal money deductions.
4. For a controlled valuable test, a server/admin can add `DSDS_ValuableReceiver` into that personal crate using `addItemCargoGlobal`. Request a quote, then confirm. Two receivers should pay 5,000. Adding an ordinary rifle/ammo/backpack must reject the sale and retain everything.
5. Purchase a ground vehicle. For a plane, stand on foot, preserve/arrange your parachute and be ready to pilot immediately. Verify altitude, speed, ownership and native garage flow.
6. Observe a natural rotation or explicitly invoke the server-only rotation function during an isolated test. Confirm new camp/stock and retention of old purchased goods/assets. Do not spam rotations while others are shopping.
