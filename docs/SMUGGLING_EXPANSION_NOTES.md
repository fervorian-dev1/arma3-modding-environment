# Fence, valuables, rare convoys and injectors — v2.0

**Current v2.5 supersedes isotope/medical convoy cargo, isotope prices/artwork, defenses and response cleanup.** See [the current handoff](HANDOFF.md) and [logistics notes](LOGISTICS_RESPONSE_NOTES.md); the older release history below is retained.

Historical v2.0 release notes. **v2.1 supersedes injector sources/prices:** no Fence stock; medical loot instead, with400–750 buyback payouts. Artwork and effects stay unchanged. See [current medical loot notes](MEDICAL_LOOT_NOTES.md).

**v2.2 supersedes trader-crate/stash/debug behavior:** shared trade crate, repaired remote stash leads, nicotine/Zyn loot, camouflage containers, named squads, optional AI integration and full Zeus DEBUG mission starters. See [current release notes](FENCE_MISSIONS_AI_NOTES.md).

Updated 2026-11-07. Current target: **Antistasi Ultimate12.0.3**, Arma3 2.22, ZEN1.15.1.36. This expansion preserves the existing support contracts, persistent PMC mechanic, death-money protection, HQ noise raids and DSD addon. No Workshop original, faction selection, ownership marker, relationship or campaign save was edited. Prior Plus compatibility is historical; this expansion's new convoy integration is validated on Ultimate only.

## Fence changes

- Six varied vehicle offers reserve ground transport, armor, helicopter, fixed-wing and boat families when valid classes exist, plus a sixth random offer. Discovery still reads loaded vehicle configs. Dedicated ground AA platforms are excluded from the vehicle offers; the existing AA launcher/missile packages remain in **Items only**. Multi-role aircraft remain aircraft offers.
- Boats go **directly into the buyer's personal Antistasi garage**, without a world spawn or shoreline requirement. This calls the installed public `HR_GRG_fnc_addVehiclesByClass` with the buyer UID, validates the native category and confirms a matching new entry. Native garage saving/retrieval owns the result. Unsupported/unavailable storage causes the existing exact refund to the original personal wallet. Other vehicles retain their previous delivery behavior; prices remain2.8× mechanic sale value.
- Ten Items offers still prioritize FPV/UAV/control equipment and two AA packages. Two slots now reserve the new injectors when available. Real companion-defined injector items count as modded stock; the nonfunctional Support Terminal is still excluded from drone-terminal offers. Item purchase prices remain4× registered sale value.
- **Locate contraband stash** is a new Fence button. This is a free lead, limited to one active stash and a45-minute mission-session cooldown. No new money charge was silently added.

## Valuables and inventory

| Item | Classname | Sale value | Inventory mass | Normal source |
|---|---|---:|---:|---|
| Rough Gems | DSDS_RoughGems | 1,000 | 1 | Common valuables caches; Special Convoy |
| Cut Gems | DSDS_CutGems | 1,650 | 0.5 | Common valuables caches; Special Convoy |
| Gold Bullion | DSDS_GoldBullion | **3,200** | 275 | Common valuables caches; Special Convoy |
| Industrial Platinum | DSDS_IndustrialPlatinum | 5,200 | 80 | **Special Convoy only** |
| Palladium Sponges | DSDS_PalladiumSponges | 4,800 | 15 | **Special Convoy only** |
| High-Purity Silicon Wafers | DSDS_SiliconWafers | 2,800 | 4 | **Special Convoy only** |
| Micro-Chips | DSDS_Microchips | 2,200 | 1 | **Special Convoy only** |
| Methamphetamine | DSDS_Methamphetamine | **650** | 1 | Contraband stash; common valuables cache |

These are fictional game-economy values. All use the existing portable CBA miscellaneous-item convention, generic free placeholder model and generated inventory picture. No physical custom models are required. `scope=1`, `scopeArsenal=0` keep them out of unlimited arsenal discovery. The four industrial goods have no Fence purchase stock entry and are absent from COMMON/STASH loot pools. Administrative SQF/Zeus designation can intentionally create them; "exclusive" refers to ordinary gameplay loot sources, not an anti-cheat restriction on admins.

The existing Fence quote/manifest transaction buys them at the listed values. One of each of the original five valuables now totals **4,650** because gold increased by700. Other previous sale prices are unchanged. Keep valuables outside Antistasi unlimited arsenals; unload them before using native vehicle garage/arsenal transfer or selling a loaded vehicle to the mechanic. Native cargo-transfer systems do not provide valuable-item provenance or dedicated virtual storage.

## Special Convoy

The addon listens to the installed **public A3A Events AIVehInit event**. It recognizes only the objective-spawn context of native **Ammunition/Fuel/Repair** convoy missions, including the verified `_taskId`, `_convoyType` and `_markName` worker variables. Native convoy movement, routes, escorts, mission accounting, capture/destroy completion rules and cleanup remain the original code. Prisoner/reinforcement/supply/money/armor convoys and unrelated vehicle spawns are not altered. Unsupported native layouts fail closed.

Defaults in `smuggling.hpp`:

- **5%** chance that an eligible objective becomes a Special Convoy.
- **3%** chance of an Isotope Convoy, if Chemical Warfare PLUS is loaded.
- Shared **90-minute** cooldown after a rare variant is selected. The other92% of eligible rolls remain ordinary convoys; ineligible convoys always remain ordinary. Without the chemical mod, isotope rolls remain ordinary too.
- Payload is applied15 seconds after the objective event, allowing the native ammunition-loot initialization to finish. Existing ordinary cargo is replaced on this designated enemy objective only. The model/class remains the native objective truck.

A Special Convoy carries all seven precious/industrial goods above: one gold bar and1–4 of each other type. The native task title becomes **Special Convoy**. The server records one manifest, and repeated initialization cannot duplicate the payload or event handlers.

Truck hits/destruction, crew combat alert, player takeover or observed looting trigger **one** large response. Response uses the actual convoy side's currently selected faction templates; no substitute faction or global faction change is introduced. Typical deployment is3–5 road vehicles, two troop-transport helicopters and2–3 unarmed spotting helicopters, scaling by war level and available vehicle seats. This can produce roughly40–80+ troops/crew with a capable faction. Safe deployment depends on real road/LZ/aircraft availability; a faction without suitable helicopters cannot receive invented aircraft. Aircraft approach bearings are retried at map edges, and ground spawns avoid nearby players and each other. Transport landings reuse the already-tested companion landing helper.

The spotting helicopters follow tracked cargo holders and update the ground troops' hunt position every5 seconds. Truck/box cargo, loaded containers, player inventory and subsequent **Take/Put** transfers are tracked; worn containers receive the same tags. Multiple scouts can follow different observed holders after a split. **There is no pursuit timer**: the user explicitly confirmed pursuit should continue until the spotting helicopters are destroyed. Pilots killed, aircraft captured by a player, or otherwise no longer capable of enemy spotting also count as neutralized. Reinforcements are a finite initial deployment, not endlessly respawned waves. Ordinary Antistasi support behavior can still happen independently.

When the truck is destroyed, remaining item cargo can be salvaged into **one** recovery crate a short distance from the wreck. Transfer clears the original item cargo only after a valid crate exists, and repeats/empty cargo never spawn another crate. Native logistics loading is attached to the recovery box. Loot already removed is not recreated.

**Tracking limits:** standard Arma inventory stacks have no per-item serial number. Tracking follows tagged containers/holders and observed transfers; merging indistinguishable copies can lose exact provenance. Mods that move inventory without ordinary Take/Put events, arbitrary scripts, native arsenal imports or campaign reloads are not claimed to preserve a trail. If goods disappear/sell, surviving scouts retain the last known location until neutralized. Human two-client transfers and headless-client delivery remain acceptance checks.

## Isotope Convoy / Chemical Warfare PLUS

This is a separate rare variant titled **Medical Isotopes Convoy** or **Industrial Isotopes Convoy**, chosen randomly. The native objective truck carries six shielded containers (`DSDS_MedicalIsotopes` or `DSDS_IndustrialIsotopes`) as a sealed, inventory-locked consignment; recover the vehicle intact. These two mission-only container classes are not Fence valuables or general loot.

Destruction fires a server-owned, duplicate-safe MPKilled release: **300m radius**, **15-minute** contamination cloud, using the installed Chemical Warfare PLUS **`CBRN_fnc_spawnMist`** function with its native choking-agent type1. Client rendering/exposure remains that mod's code/settings, gas masks and protections. This is the requested large toxic effect, **not a radiation/isotope simulation**. The mod's kill switch and exposure settings remain authoritative.

The installed source explicitly exits its particle-spawn function on dedicated servers; the wrapper therefore runs the native effect on clients and records expiry on the server. Joining clients request active clouds and receive only the remaining lifetime, with per-cloud deduplication. After expiry, no new JIP replay is sent. If Chemical Warfare PLUS is absent, isotope conversion is skipped and the ordinary convoy is preserved; other companion features remain available.

Chemical Warfare PLUS snapshot: Workshop **3295358796**, `addons/PHAN_CW.pbo`, `CfgPatches/CBRN_scripts`. API/signature and dedicated guard were read from the installed extracted `cbrn_scripts/functions/fn_spawnmist.sqf` and `bootstrap/xeh_preinit.sqf`. No speculative CWP function or radiation effect was invented. **Host and every client must load Chemical Warfare PLUS for these missions.** The six isotope containers reuse an actual existing gas-mask icon from that mod.

## Contraband stash

Speak to The Fence, open his menu and select **Locate contraband stash**. A dry, reasonably flat location near roads is chosen1.8–6.5km from the requester, avoiding nearby players and HQ. Three occupier-faction patrol squads, normally12–18 guards, have skill0.85 and defend the site. Failure to create enough guards cancels the lead and removes partial spawn results; unguarded free loot is not handed out.

The box contains30 items: at least four each of cocaine, marijuana and meth, with the remainder randomized among those same three. No industrial convoy-exclusive goods appear. Native logistics loading is available. Clear the guards to complete the task; the cargo remains available afterward. Repeated requests reuse the active lead rather than duplicating loot. The cooldown and active task are mission-session state.

## Meth and injectors

All use normal inventory pickup and the existing on-foot **Consume [name]** action. Adrenaline is also consumed automatically if the living player becomes incapacitated while carrying one. Private flavor text and gameplay effects follow server-confirmed item removal. Selling/buying and consumption cannot double-apply a delivery/nonce. Current classes/timings are data-driven in `effects.hpp`; all six injector profiles are distinct.

| Item / class | Sale / Fence purchase | Boost | Gameplay profile |
|---|---:|---|---|
| Methamphetamine / DSDS_Methamphetamine |650 / not stocked|4min +5min crash|+20% sprint,+40% recovery,+20% sway; crash: movement0.8,recovery0.65,max stamina0.6,sway1.5|
| Morphine / DSDS_Morphine |450 /1,800|4min|Steadier aim/recoil, suppressed suppression response and slower movement/reduced stamina capacity. During the first60seconds, gradually restores up to0.30 overall damage. Does not stop PiR/ACE bleeding or clear their wound states.|
| AHJ-C / DSDS_AHJC |950 /3,800|3min|Strong aim steadiness,reduced recoil; available max stamina0.85|
| M11 / DSDS_M11 |750 /3,000|2.5min +1.5min crash|+10% movement,+50% recovery; subsequent movement/recovery/stamina/aim penalties|
| Adrenaline / DSDS_Adrenaline |650 /2,600|1.5min +1.5min crash|+30% sprint,+5% movement,+80% recovery,but jittery aim; short exhausting crash. Automatically consumes one from inventory to revive a living incapacitated player, restoring at most to0.5 overall damage. Does not revive after death.|
| OLB-1 / DSDS_OLB1 |1,250 /5,000|10min if survived|**50% immediate death /50% boost**, server-randomized after consumption; survivors have native stamina disabled, fatigue cleared, zero effective load coefficient and massively expanded worn storage|
| OLB-2 / DSDS_OLB2 |1,800 /7,200|8min +2min crash|+60% worn/effective carrying allowance,+35% recovery,slight movement penalty; exhausting crash|

OLB-1's carrying implementation expands worn-container capacities1000× up to1,000,000 and removes encumbrance. **Arma's fixed global soldier inventory ceiling still exists; literal per-player infinite capacity cannot be promised.** Global config limits were not raised for everyone. On expiry/death, baseline stamina, aim, recoil, load traits and container capacities are restored; contents are not deleted when capacity shrinks. Existing mission-disabled stamina remains disabled afterward. Custom ACE fatigue systems may use different mechanics and need a live-stack check.

Zyn remains unchanged:45-minute30% carrying bonus and **"You feel stronger."** Legacy marijuana/vape/cocaine/death-money behavior remains, apart from the new drugs participating in overdose. Multiple injector recovery bonuses choose the strongest boost; all active crash recovery penalties are then multiplied independently of hashmap iteration order. Other aim/recoil/movement profiles combine with existing effects. Redosing an active injector does not postpone its existing crash; messaging says you still feel drained if redosed while crashing.

Meth contributes4 toxicity points and morphine2; M11/adrenaline/OLB-2 contribute1. These are dangerous drugs for the same180-second overdose ledger as cocaine3/marijuana1. A dangerous-drug mix warns at6 and causes fatal overdose at9, with the existing ten-second warning. Pure cannabis-only overuse remains nonfatal sickness. OLB-1 has its separate50/50 immediate outcome; AHJ-C adds no overdose points. All counts/values are fictional game balance, not medical dosing information.

## Testing in game

1. Restart host/server and clients with updated **@AntistasiSupportServices**, existing **@DynamicSupplyDrops**, CBA/ZEN and **Ultimate**. Load Chemical Warfare PLUS on everyone for isotope missions. No campaign reset or Workshop-file replacement is needed.
2. Check Fence's varied Vehicles tab and purchase a boat: verify an exact debit and a private garage entry, with no world boat. Check AA and injectors in Items. Request the stash lead and inspect guard difficulty/cargo.
3. In Zeus, under **Dynamic Supply Drops**, use **Spawn valuables cache** for common valuables. Common caches do not contain industrial-exclusive goods. Buy injectors from the Fence or add exact classes to a test crate in SQF.
4. To force convoy testing, place an enemy truck and its crew, then drop **Designate Special Convoy vehicle** or **Designate Isotope Convoy vehicle** directly on it. These use the verified ZEN callback `[positionASL, attachedObject]` and a curator-authenticated server request. Set Zeus waypoints yourself for this manually designated vehicle. These are vehicle test helpers: they create neither a standalone task nor a route. Automatic production variants use native missions/tasks/routes and require no manually placed objects. Friendly/bought/player-occupied vehicles cannot be converted, and cargo space is required.
5. Damage/alert the Special Convoy, loot it, move the goods between inventory and containers/vehicles, and observe the scouts/ground response. Destroy or neutralize all spotters to end tracking. Destroy a designated isotope truck away from base to inspect the large native cloud and protections.
6. Check injector trade-offs and expiry. OLB-1 can kill immediately; rapid meth/mixed narcotics can cause overdose. Test these in a disposable scenario. Verify money survives a real player respawn and check for private-only messages.

Missions, pursuit trails, rare/stash cooldowns, clouds and buff ledgers are **session state**, matching existing native mission/companion session behavior. They are not saved as custom campaign missions; restarting does not restore a special truck's hazard/trail. Normal item inventory and boat garage entries use native persistence. The PMC's separate saved state is unchanged.

## Artwork and exact file inventory

Thirteen new images were created through the **OpenAI built-in imagegen tool**, one call per asset; cut gems used an imagegen edit of the inspected rough-gem image. All13 were visually reviewed. Transparent PNG masters are in `projects/antistasi_support_services/art/loot/`; generated256px JPEGs are in `addons/dsds_support/ui/loot/` after reproducible System.Drawing conversion. Existing gold art was retained.

Stems: `rough_gems`, `cut_gems`, `industrial_platinum`, `palladium_sponges`, `silicon_wafers`, `microchips`, `methamphetamine`, `morphine`, `ahj_c`, `m11`, `adrenaline`, `olb_1`, `olb_2`. Ruby upper-left, sapphire upper-right, emerald bottom-center are preserved between rough and cut variants. Exact prompts/method/paths are in [EXPANSION_PROMPTS.json](../projects/antistasi_support_services/art/loot/EXPANSION_PROMPTS.json). No API-key CLI or external image service was used.

New runtime files:

- `loot_extra.hpp`, `effects.hpp`, `smuggling.hpp`; the13 JPEGs above.
- `functions/Fence/fn_storeFenceBoat.sqf`.
- `functions/Loot/fn_consumableClasses.sqf`, `fn_stimModifiers.sqf`.
- `functions/Smuggling/fn_initSmuggling.sqf`, `fn_smugglingFaction.sqf`, `fn_smugglingUnit.sqf`, `fn_smugglingVehicle.sqf`, `fn_smugglingAirStart.sqf`, `fn_convoyObserved.sqf`, `fn_upgradeConvoy.sqf`, `fn_alertConvoy.sqf`, `fn_convoyResponse.sqf`, `fn_pursuitTick.sqf`, `fn_smugglingRequest.sqf`, `fn_isotopeRelease.sqf`, `fn_chemicalCloud.sqf`, `fn_requestContrabandStash.sqf`, `fn_salvageConvoy.sqf`.

Modified runtime files:

- `config.cpp`: version2.0, exports/registrations, native Events/Garage dependencies, restricted public RPC entries, new Fence goods, gold value and config includes.
- `fence.hpp`: stash button.
- Fence `fn_fenceCatalogue`, `fn_fenceBuildStock`, `fn_fenceDelivery`, `fn_fenceTab`, `fn_fenceTransaction`, `fn_fenceIsModded`.
- Loot `fn_fillLootContainer`, `fn_lootConsume`, `fn_lootRequest`, `fn_lootCommit`, `fn_lootDose`, `fn_lootTick`, `fn_lootCleanup`, `fn_lootCapacity`, `fn_initLoot`.
- `functions/fn_initServices.sqf`: version text only.

Other source changes: project `mod.cpp`, root/project READMEs, `docs/HANDOFF.md`, a supersession banner in `docs/CONSUMABLES_REBALANCE_NOTES.md`, and this new note; artwork masters and prompt manifest; thumbnail build script; existing Loot/Fence fixtures updated for changed gold/AA/boat expectations; new `scripts/Test-Expansion.ps1` and `tests/support_services/dsds_expansion.Altis/{mission.sqm,description.ext,initServer.sqf}`. Published build folder gets the updated PBO/README/mod.cpp. No DSD gameplay/source/PBO changes.

## Verification and limitations

**327 passing checks across the final component/regression runs**, with zero failures/SQF exceptions in those runs. Runtime totals are **93 functions and118 packed files**, including the new art. CfgConvert validation passed; fresh candidate extraction and final comparison found zero source/packed differences. Validation uses the real Arma dedicated executable and installed assets.

- **Expansion119:** `logs/expansion-validation-ultimate/arma3server_x64_2026-11-07_16-29-17.rpt`, against the published PBO. Includes13 thumbnail/class/value checks, industrial exclusivity, all injector definitions, both deterministic OLB-1 outcomes/expiry/restoration, order-independent mixed recovery/crash effects, meth overdose, actual native garage insertion/save data, native objective Events dispatch including fuel/repair, friendly-cargo protection, map-edge aircraft approach, live mission title changes, actual large response/spotters, exact one-time salvage, moving-goods pursuit/neutralization, real native reinforcement vehicle initialization, actual isotope-truck destruction/release metadata, guarded stash generation and completion.
- **Fence107:** `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_15-58-07.rpt`. Includes20 randomized rotations, AA exclusion/Items-only coverage, modded quotas, existing FPV/UAV/AA/aircraft/sale/refund checks, and new full boat-purchase debit/private storage/no-world-spawn/exact-failure-refund checks.
- **Baseline Loot101:** `logs/loot-validation-ultimate/arma3server_x64_2026-11-07_15-53-14.rpt`. Includes revised4,650 original-five sale quote/payment, unchanged native death-money calculation/debit preservation, original drug/crash/overdose/stamina/capacity safeguards and new helper registrations.
- Fence/baseline runs were on preceding v2.0 candidates. Later changes were in Smuggling/new mixed-stim handling and curator helpers, covered by the final expansion run; do not claim all327 checks ran against the final byte-identical PBO or that unrelated full contract/raid/flight suites were rerun.
- Intermediate failures were corrected before final validation: a2D-safe-position conversion mistakenly passed to ATLToASL; missing fixture rebel-faction data for native logistics; counting newly reserved companion injector stock in the modded quota; native localized task-title arrays needing unwrapping in the fixture; nullable ownership-map access; native vehicle initialization being skipped if ownerSide was prewritten. Mixed recovery/crash aggregation was made independent of profile iteration order. Read-only independent review confirmed the manual test-task lifecycle gap; designators now create no standalone task, while automatic missions retain their native lifecycle. These superseded/intermediate runs are not counted as clean final evidence.

Published companion SHA256: **`B6E4C38D6CAA26A925012AE31BC1528FF780FF40ADF82FFE953FB3FCCFBFCE4F`**.
Unchanged DSD SHA256: **`F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`**.

Owned test servers were stopped after matching exact PID/name/profile/port. Copied `dsds_expansion.Altis`, `dsds_fence.Altis` and `dsds_loot.VR` fixtures were removed after explicit file/path/marker inspection; source fixtures/logs remain. No user game process, native Workshop file or campaign save was terminated/edited. Generated image originals remain under Codex's default generated_images folder as well as the saved workspace masters.

New behavior tests use real garage storage/save data, native Events dispatch with verified objective context, live task descriptions, actual response units/aircraft, moving physical cargo, actual isotope-truck destruction, and real guarded-stash task creation/completion. Timestamps/rolls can be injected only through private server helpers for deterministic expiry/OLB/overdose tests; public consumption never accepts a client-specified outcome.

**Still requires human acceptance:** full campaign convoy selection/movement/completion over long sessions, ZEN module/menu rendering, real two-client Take/Put transfers and split cargo, headless-client ownership transitions, JIP chemical rendering/exposure, visual cloud size/frame rate, pilot/AI pathfinding on each selected map/faction, actual recoil feel and full PiR/ACE fatigue behavior. Dedicated tests cannot render the native CWP cloud because the mod intentionally exits on dedicated. No claim is made that all original service/raid/flight suites were rerun wholesale for this expansion.

API evidence: installed `reference/ultimate/garage/public/fn_addvehiclesbyclass.sqf` and garage save/category functions; `core/functions/missions/fn_convoy.sqf` plus `create/fn_aivehinit.sqf`; `events/functions/fn_addeventlistener.sqf` and `fn_triggerevent.sqf`; installed `reference/zen/zen_custom_modules/functions/fnc_init.sqf` / `fnc_register.sqf`; installed Chemical Warfare PLUS files above. [Official task-description API](https://community.bistudio.com/wiki/BIS_fnc_taskSetDescription), [recoil command](https://community.bistudio.com/wiki/setUnitRecoilCoefficient), [stamina command](https://community.bohemia.net/wiki/enableStamina). Native source was inspected rather than guessing API/function/class names.
