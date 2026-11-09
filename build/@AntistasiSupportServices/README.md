# Antistasi Support Services

Version3.6 targets player-host enemy-spawn spikes: scheduled hostile units created through Antistasi's native factory share a50ms creation budget on the host. Counts, loadouts and original initialization remain; friendly/civilian/unscheduled calls and dedicated/HC authority bypass pacing. Addon AI Accuracy Fix integration uses one bounded shared worker instead of one polling script per unit. No graphics/global AI changes or measured live FPS claim. Restart everyone with the updated companion. [Host spawn notes and test limits](../../docs/HOST_SPAWN_36_NOTES.md).

Version3.5 puts custom cargo and aggression escorts into **Antistasi's normal convoy route, departure timer and driver controller**. Task briefings show origin, destination/grid and scheduled departure from creation and retain that information after loot setup. Native route points are checked for collisions; core vehicles are no longer scattered offroad or controlled/teleported by the addon cohesion loop. Zeus DEBUG convoy buttons now choose a real eligible campaign route rather than driving toward the cursor. Lower-frequency Watch-only arsenal maintenance, isotope fallback scans and change-only task/marker updates reduce addon/network overhead. Existing loot, armed air cover, Money minimum and other services remain. Restart everyone and request a fresh convoy; no campaign reset. [Exact changes, driving evidence and limits](../../docs/CONVOY_NATIVE_35_NOTES.md).

Version3.4 fixes free Oswald arsenal unlocks, stale Antistasi respawn controls after PiR/teammate recovery, continuously marked convoy objectives (including unloaded native Money/Supplies cargo), clearance-checked open roadside spawns, and armed convoy helicopter cover/spotters. Old unlimited Oswald entries are removed while finite stock and carried bracelets remain. Unsafe spawns are skipped/cancelled rather than forced. Restart host/server and every client with the updated folder; no campaign reset. [Hotfix notes](../../docs/GAMEPLAY_HOTFIX_34_NOTES.md).

Version3.3 adds silent **Fence sniper ambushes** after three distinct faction visits. Arrivals within80m count once for the group; everyone must leave180m for60seconds before another arrival counts. Each later visit can encounter two teams of four occupying-faction snipers (40% setup roll after departure). They prepare only while players are away, watch the camp approach, and engage returning visitors. No warnings/markers. Session visit count survives Fence relocations; ambushes expire or retire on relocation, with distant cleanup/captive protection. [Exact behavior and tests](../../docs/FENCE_AMBUSH_NOTES.md).

Version3.2 sets native **Money convoy HQ-delivery rewards to at least70,000 faction credits**, keeping any higher difficulty-scaled amount. Normal completion requirements and personal participation payments remain. Restart host/server and clients; no campaign reset.

Version3.1 seats parachute-support passengers in an explicitly selected rear cargo seat and locks pilot/copilot stations after the AI crew boards. Normal parachute deployment and backpack preservation remain. Restart host/server and clients with the updated folder. [Seating fix notes](../../docs/PARADROP_SEATING_NOTES.md).

Version3.0 connects **Petros -> Convoy mission** to a shuffled rotation: **Special, Medical, Isotope, ordinary** (one of each per cycle, when dependencies/faction assets support them). Petros requests bypass the ambient rare-convoy cooldown; ambient rolls remain rare. Custom shipments use a valid faction cargo/medical truck and Antistasi's original ammunition-convoy capture/destroy handling, routes, departure delay, rewards, escorts and cleanup. They contain the existing themed valuables, medical supplies/injectors or shielded isotopes/CWP rewards. Containment Response debug launches no longer show a preparation notification. Restart everyone with the updated companion; no campaign reset. [Integration and verification notes](../../docs/PETROS_CONVOY_INTEGRATION_NOTES.md).

Companion addon **v3.6** for **Antistasi Ultimate 12.0.3**, using the existing Dynamic Supply Drops addon. Original supply-drop gameplay and Workshop files are preserved. Earlier features have historical Plus2.3.2 verification; new mission integration is validated on Ultimate.

Version2.9 adds Mystic's **Source Industrial Isotopes stash** option by reusing Fence's existing guarded roadside stash mission. Same containers, guards, names and completion behavior; the new variant contains **10 Industrial Isotopes**. The vendors share the existing active-stash limit and45-minute cooldown. Also available through the existing Zeus DEBUG mission registry. [Exact changes and validation](../../docs/MYSTIC_STASH_NOTES.md).

Version2.8 fixes **automatic Adrenaline/Morphine recovery with PiR**. Living incapacitated players use one carried Adrenaline; PiR forced-crawl prioritizes Morphine, with either syringe as fallback. Recovery restores combat health/consciousness, releases PiR's down-state loops and retains its native equipment cleanup. Ordinary prone, empty inventory and actual death do not trigger rescue. **Final forced-branch actual-player test:19/0**; earlier focused PiR23/0 and expansion207/0 evidence is recorded in the notes. [Behavior, exact files and test evidence](../../docs/AUTO_INJECTOR_RECOVERY_NOTES.md). Restart host/server and clients; no campaign reset.

Version2.7 implements Mystic's **40-isotope reward**: accept a non-removable chest device, touch it off through the scroll menu or trigger it by dying. The existing ZEN Atomic Bomb system supplies the blast. After that detonation Mystic sells native-placeable **Nuclear IEDs for 174,000 personal credits**, with the supplied thumbnail and ordinary Touch Off controls. Shared reward/stock state survives campaign saving. [Exact behavior, files, validation and limitations](../../docs/MYSTIC_NUCLEAR_NOTES.md).

Version2.6 adds **Mystic**: selling industrial isotopes to Fence unlocks a **92,235-personal-credit** lead to his fixed hidden location. His **Trinkets** menu initially sells **Oswald** for **62,000**, equipped in the Watch slot. Industrial offerings accumulate toward a shared campaign-saved **40**; the eventual reward awaits specification. Includes a first-conversation camera intro, unusual UI and native aircraft anti-lock behavior for wearers. [Exact behavior, files, tests and compatibility limits](../../docs/MYSTIC_NOTES.md). Restart host/server and all clients; no campaign reset.

Version2.5 consolidates medical convoys, CWP isotope rewards, both isotope thumbnails, Fence payouts, convoy cohesion and the Watchkeeper/Osprey contamination response with Copilot's visual and medical changes below. Response cleanup now retries every30seconds once players leave, preserving captured/player-controlled vehicles, captives and unrelated occupants. Use the standard `build/@AntistasiSupportServices` folder on host and clients; no campaign reset. Do not enable a second archived candidate alongside it. [Release, cleanup tests and remaining checks](../../docs/PUBLICATION_CLEANUP_NOTES.md); [convoy behavior and earlier validation](../../docs/LOGISTICS_RESPONSE_NOTES.md).

Version2.4 adds subtle independent color overlays and meth distortion, plus the supplied Zyn image stretched full-screen at5% opacity. It also adds Morphine's gradual heal (up to0.30 damage over60seconds) and automatic Adrenaline rescue for living incapacitated players carrying the item; rescue consumes one stim and does not clear all PiR/ACE wounds. Injector use messages are private. **201 automated expansion checks passed**; rendered visuals and live multiplayer rescue still need in-game acceptance. Restart host/server and clients; no campaign reset. [Exact files, timings and verification](../../docs/CONTRABAND_VISUALS_NOTES.md).

Version2.3 repairs isotope cargo access/truck selection and adds 6?10 randomized injectors. Destruction releases actual CWP bomb projectiles plus native gas, backed by a server watchdog. Escorts have kinetic door guns only; convoy defenses scale with the owning faction's aggression. Special shipments choose METALS (gold/palladium/platinum), TECH (silicon/microchips/palladium), or JEWELRY (cut gems/rough gems/gold). Mission text no longer reveals DEBUG. **239 checks passed across component runs**; rendered gas/exposure and live HC/JIP acceptance remain unverified. Restart host/server and clients; no campaign reset. [v2.3 files, test provenance and limitations](../../docs/CONVOY_REVISION_NOTES.md).

Version2.2 fixes remote Fence stash requests, creates map-marked stash missions in lootable rubbish/sack containers, adds nicotine/Zyn to the contraband pool and gives the high-skill guard squads generated names. **One community trade crate** serves everyone; the first player to confirm a valid quote receives the personal payout. It integrates the installed Ai accuracy fix, AI behavior modification and LAMBS Danger DEV without replacing their global settings. **321 automated checks passed** across component runs; human UI/multiplayer acceptance remains.

In Zeus use **Modules â†’ DEBUG â†’ Start Special Convoy / Start Isotope Convoy / Start Contraband Stash**. Place the module on dry land near a road; there is no settings dialog or pre-placed truck requirement. Special Convoy spawns real moving escorts/cargo and uses the normal loot, alert and helicopter response. Isotope needs Chemical Warfare PLUS. Future custom mission starters use the same registry. Restart host/server and clients with the updated companion; enable the three AI mods alongside the existing dependencies. No campaign reset is required. [Exact files, integration details, test logs and limitations](../../docs/FENCE_MISSIONS_AI_NOTES.md).

Version2.1 moves all six injectors from Fence's Items rotation into **native Supplies convoys, enemy medical vehicles and occasional enemy medic loot**. Fence still buys them: Morphine 400, AHJ-C 600, M11 550, Adrenaline 500, OLB-1 650 and OLB-2 750 credits. Existing artwork and effects are unchanged. **266 automated checks passed** across the Fence and expansion fixtures; live multiplayer/headless-client acceptance remains. See [medical loot, exact files and validation](../../docs/MEDICAL_LOOT_NOTES.md).

Version2.0 sends purchased **boats directly into personal garage storage**, gives the Fence six varied vehicles with AA reserved for Items only, and adds rough gems (1,000), cut gems (1,650), gold at **3,200**, meth (650), four convoy-exclusive industrial valuables and six unique injectors. Thirteen new thumbnails include matching rough/cut gemstone compositions.

Rare **Special Convoys** bring valuable cargo and a large faction-based response; spotting helicopters follow observed stolen goods until neutralized. Separate **Isotope Convoys** release a native Chemical Warfare PLUS cloud when destroyed (300m radius,15minutes). The Fence's **Locate contraband stash** button provides a free lead to high-skill guards and cocaine/marijuana/meth loot. Native cargo convoy events are enriched without replacing convoy movement or changing territory/factions. OLB-1 has a server-owned50% immediate death /50% ten-minute stamina and carrying boost outcome. Its carrying bonus remains subject to Arma's hard inventory ceiling.

Restart host/server and all clients with the updated companion. Load **Chemical Warfare PLUS** (Workshop3295358796) on everyone for isotope missions. No new campaign is needed. To test without waiting for a rare roll, place an enemy truck in Zeus and use **Dynamic Supply Drops â†’ Designate Special Convoy vehicle / Designate Isotope Convoy vehicle** on it. Bought/friendly vehicles and player-occupied trucks are protected. Full balance, image prompts, new files, testing and honest limits: [v2.0 expansion notes](../../docs/SMUGGLING_EXPANSION_NOTES.md).

Version 1.9 keeps **all personal money on death** through Antistasi's native death-money setting. Consumables now have simple flavor descriptions and short private messages after use. Marijuana steadies aim but slows/blurs you; vaping improves focus/recovery with reduced stamina capacity; cocaine improves sprint/recovery but causes jitters and a crash. **Rapid narcotic use can cause overdose**: repeated cannabis causes temporary sickness; three cocaine doses within three minutes cause death after a ten-second warning, and mixed narcotics also count. Zyn's carrying bonus is unchanged and says **"You feel stronger."** No cocaine damage-resistance/injury handler remains. See [balance, overdose and death-money notes](../../docs/CONSUMABLES_REBALANCE_NOTES.md).

Version 1.8 adds inventory-only **Marijuana (300), Nicotine Vape (150), Cocaine (800), Zyn Nicotine Pouches (200), and Gold Bullion (2,500)**, with generated thumbnails and Fence sale registration. In Zeus use **Dynamic Supply Drops â†’ Spawn valuables cache**, loot the box, then use **Consume [name]** from your scroll menu while conscious/on foot. Gold is heavy and cannot be consumed. Keep valuables outside unlimited arsenals; they are not automatically added to all Antistasi mission loot tables. Every client/server needs this updated companion; restart Arma, without resetting the campaign.

Marijuana/vape last ten minutes; cocaine has a five-minute boost and five-minute crash. Zyn increases worn-container capacities and effective carrying allowance by 30% for 45 minutes; it cannot raise the engine's absolute soldier ceiling. Effects respect disabled stamina and expire on death/session end. Current exact balance and overdose rules are in the v1.9 notes above. Original item/artwork files, prompts and v1.8 test history: [loot and consumables notes](../../docs/LOOT_CONSUMABLES_NOTES.md).

Version 1.7 gives The Fence separate **Vehicles** and **Items** tabs: six vehicles and **ten distinct item offers**, targeting at least eight modded items when available. Reserved item roles cover two ArmaFPV inventory drones, a portable UAV kit, a working side-compatible control terminal and two AA launchers, with premium filler. AA launchers include five compatible missiles; a ground AA vehicle is reserved when available. Native mod deployment/controls remain intact. See [Fence tabs and stock notes](../../docs/FENCE_TABS_NOTES.md). Enable installed **ArmaFPV** on host/clients for its Crocus inventory items. No new campaign is needed; restart with the updated companion.

Final v1.7 Fence validation: **102 passes, zero failures/SQF errors**, including twenty stock selections, category/modded quotas, tab/server-index mapping, real inventory purchases, native ArmaFPV deployment, five Stinger missiles, existing wallet/sale/refund and aircraft checks. New tabs need a human visual check; prior v1.6 port acceptance remains valid for unchanged features.

Version 1.6 adapts vehicle resale/Fence pricing to Ultimate's nested black-market stock and discounts, and retains the UAV crew created by Ultimate's native vehicle initialization. Personal money, mechanic save state, direct arsenal imports, raids and the existing eleven support contracts keep their behavior. See [Ultimate port and verification notes](../../docs/ULTIMATE_PORT_NOTES.md). The user is starting a **fresh Ultimate campaign**; no Plus save conversion is needed or performed.

Final v1.6 validation: **408 Ultimate checks + 21 targeted Plus checks passed**, zero failures/SQF errors in final runs. Tested actual C-130/truck/arsenal delivery, all eleven contracts, real faction-based helicopter raids, native-initialized Fence vehicle/UAV purchases, personal prices and cross-process mechanic save/death restoration. Human multiplayer UI/JIP/pilot ownership transfer and full campaign acceptance remain for in-game testing.

The Fence is an unarmed civilian trader in a medical tent at a random flat roadside camp. He announces his first camp after discovery, then moves/announces every **45â€“95 minutes** of mission runtime. Find **The Fence** map marker and use **Trade with The Fence** within 6 m. Six vehicles and ten inventory items rotate together. Vehicles cost **2.8 times their undamaged mechanic sale value at rotation time**. FPV inventory drones cost 6,000, portable UAV kits 10,000, control terminals 5,000, and AA launcher packages 12,000 personal credits; premium filler retains its value tiers. Pools use loaded configs and preserve the DLC-free filter.

All transactions use personal credits. Request/locate the **community trade crate** before buying gear; everyone shares its contents. He **buys only registered custom valuables**, through an explicit quote/confirmation; the first valid confirmed seller receives the payout, while ordinary equipment/ammunition or mixed crates are rejected and retained. Initial mission valuable `DSDS_ValuableReceiver` (Encrypted Data Receiver) is worth 2,500 credits and reuses a free GPS visual without GPS functionality. Future model-based goods register in `DSDS_FenceGoods`. Current behavior: [v2.2 notes](../../docs/FENCE_MISSIONS_AI_NOTES.md); original trader history: [Fence notes](../../docs/FENCE_NOTES.md).

Buy fixed-wing aircraft on foot: you are placed in the pilot seat already airborne, with terrain clearance and flight speed. An empty backpack slot receives a parachute; existing backpacks are preserved, so arrange your own parachute when carrying one. UAVs receive buyer-side UAV crew and require a real UAV terminal for control. Ground vehicles/helicopters spawn in nearby dry clearings; boats need safe water within 3 km. Failed delivery refunds. Use normal Antistasi vehicle garaging/saving afterward.

Fence camps, rotation timers, offers and trade crates are session state and restart with the mission. Recover goods before quitting. Nonempty old trade crates are retained and their grid reported; empty ones can be replaced. Killing The Fence leaves him dead until the next scheduled rotation. PMC mechanic persistence and all prior features remain unchanged. No campaign faction/map/airfield settings are changed.

Final v1.5 validation: **62 Fence checks + 140 existing-feature checks = 202 passes**, zero failures/SQF errors. All 58 packed addon files matched source. Actual roadside relocation, custom-only sale/payment, gear and ground/aircraft/UAV delivery passed on dedicated servers. Human UI/network/JIP acceptance remains open. A preceding supply-crate physics failure refunded correctly; the complete repeat passed. Keep custom valuables as physical loot outside arsenal/loadout menus.

Version 1.4 adds automatic noise-triggered HQ raids. See [HQ raid behavior and notes](../../docs/HQ_NOISE_RAIDS_NOTES.md). Existing terminal, mechanic, direct arsenal imports and low strike passes remain available.

Final v1.4 validation: **83 raid checks plus 140 existing-feature checks passed**, with zero SQF errors. Actual 3CB AAF helicopter landings, dismounts and infantry advance were verified on a dedicated server. Human gunfire reporting, respawn/JIP and placed-explosive input still need in-game acceptance; see the notes for testing and limits.

Version 1.3 fixes missing personal-money HUD refreshes after purchases/support calls and lowers offensive jets to a target **150 m above terrain**, climbing ahead of rising terrain. User confirmed the AAF airfields were correct; no faction/map correction is needed or applied.

Purchases now request a silent native Antistasi HUD refresh after the server balance replicates. A local balance watcher also catches refunds and salary changes; it never changes the money value. Before/after transaction values are logged for diagnosis. Server checks verify exact 10,000 terminal and 30,000 HE deductions, including player-owner indirection. If the displayed amount is still wrong after restarting, the log can distinguish a missed HUD update from an actual balance change.

Version 1.2 doubles HE/cluster/napalm/chemical contract prices, charges 10,000 personal credits for a new terminal, transfers sale cargo directly to Antistasi's arsenal without crates, and uses fast afterburning RHS T-50s for offensive strikes. Existing terminals remain usable. Campaign factions, airbase ownership, map selection and faction templates are outside this addon's scope and are never rewritten.

Version 1.1 fixes the invisible support/dealer menus by using simple vanilla Arma controls with explicit visibility. The mechanic defaults to Independent/FIA and explicitly joins Petros's actual side on creation/restoration. Replace the companion on host/server and all clients, then restart Arma; an already hired mechanic restores on the corrected side from the normal campaign save.

## Install and use

1. In the Arma launcher, choose **Local mod** and add `A:\arma3 modding enviroment\build\@AntistasiSupportServices`.
2. Enable it alongside **Dynamic Supply Drops, Antistasi Ultimate, CBA and Zeus Enhanced** and your existing RHS mods. **Disable Antistasi Plus** when using Ultimate; load one Antistasi edition. Restart Arma. Load the same addon on the multiplayer server and every player client. This local build is unsigned; servers enforcing signatures need their own signed package/key. Plus remains an alternate supported edition.
3. Resume your campaign. Approach Petros and use **Buy / equip Support Terminal (10,000 credits)**. New terminals cost 10,000 personal credits. Equipping one you already own is free. Stow your current GPS/UAV terminal first: an occupied slot or insufficient funds is rejected without charge. The terminal uses that slot and UAV-controller model, but is a GPS item with no UAV-control ability. Failed item delivery refunds its purchase price.
4. Use **Open Support Terminal** in your action menu. Choose support, click its map target (or the start and end of a run), then request it. Paradrop boards you from your current position; its single map point is your destination. Your backpack is retained.
5. At Petros, choose **Request PMC mechanic (1,000 credits)**. Speak to the mechanic to **Move PMC mechanic**, carry him into place, and use **Place PMC mechanic here**. He remains stationary and can return fire.
6. Bring an unoccupied vehicle within 100 m of the mechanic. Stand within 6 m of him, choose **Sell a vehicle**, select it, get an offer, and confirm. Offers expire after 90 seconds or when condition changes. Any cargo goes directly into Antistasi's arsenal using its native JNA conversion, including backpack contents, attachments and loaded magazine rounds. Empty sales add nothing. Sales spawn no crates or arsenals.

All purchases use **personal money**; vehicle proceeds go to the seller. The faction account is untouched. There is one hired mechanic per campaign. His presence, location, direction and loadout are recorded through Antistasi's campaign statistics. **Use the normal Antistasi campaign save** before quitting: an unsaved hire, move or death follows the campaign's last save. A saved death stays dead; Petros can hire a replacement for another 1,000 credits.

## Noise-triggered HQ raids

Player gunfire and explosive detonations within **300 m of deployed Petros/HQ** build hidden suspicion. Ordinary shots add 1 point, suppressed shots 0.1, loud cannon/rocket fire 15 and explosive detonations 40. Smoke/flares do not count. Suspicion decays at 1 point/second; a score of 300 prepares one raid. This is weighted gunfire/explosive detection, not voice-chat, footsteps or engine-volume detection.

After a randomized **90â€“180 second preparation**, the selected occupying faction sends helicopters to land **800â€“1,200 m away**. Infantry dismount and march toward HQ, accompanied by trucks/light vehicles. Helicopter numbers use actual passenger capacity, with up to 12 assault troops per flight. Aircraft fly away after unloading.

| War level | Airborne infantry | Ground vehicles, where safe/available |
|---|---:|---:|
| 1â€“3 | 20â€“25 | 1â€“2 |
| 4â€“6 | 30â€“35 | 2â€“3 |
| 7â€“10 | 40â€“50 | 3â€“5 |

Vehicle/pilot crews are additional; trucks do not receive extra infantry squads. All assets/loadouts come from the currently selected occupier. No AAF fallback, faction/map setting changes, ownership edits, artillery or UAV call-ins are added. Native Antistasi major attacks defer this raid, and their defensive gunfire does not accumulate new suspicion.

Preparing/active raids discard noise. A raid ends on defeat/retreat, Petros loss, HQ relocation, native major-attack overlap or a 30-minute assault timeout. Its noise is consumed, followed by a 60-second recovery. **There is no timer that automatically summons another raid: fresh player noise is required afterward.** Built-in Antistasi attacks continue independently. Petros retains normal vulnerability and HQ-loss consequences. Captured/captive/player-occupied assets are protected; remaining attackers retreat and owned assets are cleaned outside player proximity/sight.

The controller starts automatically in an active Antistasi mission. Restart with the updated addon; no mission edits or placed triggers are needed. Campaign restart starts suspicion at zero and does not restore an old raid. Moving HQ clears old suspicion. Unsafe landing sites, unsuitable island/road geometry or missing occupier transports can cancel a deployment rather than substitute factions or spawn in view. Normal Antistasi friendly-fire restrictions still apply near Petros.

Settings are in `DSDS_HQRaid` in `config.cpp`. Server administrators may tune the runtime `DSDS_raidConfig` hashmap for testing. For a quick controlled test, lower `threshold` to 20 on the server, fire safely 100â€“250 m from Petros, then restore 300; preparation/flight travel still take time. Do not test with grenades beside Petros. `scripts/Test-HQNoiseRaid.ps1` runs an isolated mission/profile with installed 3CB AAF templates and real AI helicopter landings.

## Contracts

| Support | Personal credits | Map selection |
|---|---:|---|
| Smoke barrage | 5,000 | Target |
| Flare barrage | 5,000 | Target |
| Randomized supply drop | 5,000 | Target |
| Light vehicle airdrop | 7,500 | Run start, destination |
| Recon plane | 8,000 | Run start, destination |
| Paradrop | 10,000 | Landing destination |
| Loot helicopter | 10,000 | Run start, collection area |
| HE bombing | 30,000 | Run start, destination |
| Cluster bombing | 40,000 | Run start, destination |
| Napalm bombing | 40,000 | Run start, destination |
| Chemical bombing | 50,000 | Run start, destination |

These are the installed Fire Support tab's eleven services, isolated from commander/airfield/radio/point/cooldown restrictions. Ordinary validity checks still apply: a living rebel user, equipped terminal, valid map points and funds. Supply crates need dry land. Costs are server-authoritative. Failed deployment refunds once; a completed strike or delivered crate is not insured against later enemy action. Successful calls send no broadcast or supply announcement.

The supply option reuses the working DLC-free randomized inventory, five compatible magazines per weapon, parachute delivery and Antistasi loading/arsenal integration. Aircraft use the installed RHS C-130J where appropriate; loot recovery uses a helicopter. Aircraft fly away after service. Loot recovery gathers nearby dropped weapons and eligible bodies into a returned crate; it does not teleport items directly into the arsenal. The item offers the same service list through a simple vanilla display; the original commander display remains unchanged.

Offensive bombing uses the installed RHS T-50 at about **1,440 km/h**, with full throttle and its validated afterburner animation. It follows a straight route around **150 m above local terrain**, planning climbs using terrain ahead, and continues away after dropping its payload. It can fly higher where terrain requires a climb; this is not obstacle avoidance for every building/tree/modded structure. `DSDS_StrikeFlight` in `config.cpp` controls terrain clearance, speed and look-ahead distance. The aircraft config has the native sonic-boom soundset; what a ground player hears depends on the sound engine, distance and settings and needs an in-game listen. No synthetic boom is broadcast to every player. If the RHS strike jet is unavailable, that contract fails/refunds rather than using a cargo aircraft. Supply, vehicle and passenger transports remain separate from offensive jets.

## Mechanic pricing and protection

Vehicle config inheritance, weapons/turrets, armor, utility, configured cost and damage determine offers. New mod vehicles are discovered automatically; there is no sale whitelist. Civilian vehicles are cheapest, utility/military trucks higher, armed/armored vehicles higher again, and tanks/helicopters/planes highest. Known Antistasi shop prices cap resale to prevent profitable buy/sell loops. Unusual mod configs may need tuning.

Occupied vehicles, another player's personally owned vehicle, protected HQ assets, contractor aircraft and vehicles carrying attached, sling, rope, native-logistics or vehicle-in-vehicle cargo must be emptied/disconnected before sale. Wrecks have a reduced salvage value. The mechanic wears a custom black uniform, black vest/cap and a validated DLC-free mod rifle (RHS preferred).

## Source and extension

- `addons/dsds_support/config.cpp`: item/NPC classes, 61 function registrations, narrow remote-execution entries, support catalogue/prices, strike-flight, raid and Fence settings.
- `addons/dsds_support/terminal.hpp`: simple support/dealer display using vanilla Arma controls, with explicit visible fade settings.
- `addons/dsds_support/functions/`: descriptive SQF functions for actions/UI, authenticated server transactions, personal wallets, contracts/delivery, vehicle valuation/sales and campaign persistence.
- `addons/dsds_support/functions/HQRaid/`: noise reporting/scoring, faction-aware raid planning, spawning, landing, assault, retreat and cleanup.
- `addons/dsds_support/functions/Fence/` and `fence.hpp`: roaming trader, goods whitelist, vehicle/gear catalogue, server transactions/delivery and vanilla UI.
- `mod.cpp`: launcher metadata.
- Workspace `scripts/Build-SupportServices.ps1`: validate and package into the separate local mod.
- Workspace `scripts/Test-SupportServicesServer.ps1`, `scripts/Test-SupportServicesUI.ps1` and `tests/support_services/dsds_validation.VR/`: isolated dedicated-server/client verification, including separate-process save/reload checks and UI/side regressions.

The catalogue keeps the item extensible. Support contracts retain the native Antistasi functions. Version3.0 adds a narrow configuration adapter for the native convoy entry point; its explicit attack/intel calls delegate to the installed original. Napalm has a local adapter for a sound-command type error in the installed version; it reuses Antistasi's particle and damage functions.

## Verification and remaining acceptance

The v1.0 backend passed 106 assertions covering all eleven services and mechanic save/reload, but missed invisible client controls subsequently reported in-game. Version 1.1 passed 18 side/visibility server regression checks; the user subsequently confirmed both menus and the mechanic work in-game. The isolated graphical test client stalled at startup, so automated human-client UI/network testing remains unavailable. Version 1.2 passed **131 full runtime assertions plus 18 side/visibility regressions**, with zero failures or SQF errors, covering purchase pricing/protection, direct JNA imports with no crates, measured supersonic jet speed/afterburners, and unchanged faction/airfield markers. See [development notes](../../docs/ANTISTASI_SUPPORT_SERVICES_NOTES.md) for detailed results and limits.

After restarting, check that a noncommander can collect/equip the terminal, open its menu and call support; then open the mechanic's sale menu, obtain an offer and confirm. Save/reload your campaign to check the restored mechanic stays friendly. Your friend/server also needs the updated companion folder. To run the disposable real-client test with a visible window yourself, close Arma first and run `scripts/Test-SupportServicesUI.ps1 -Visible -Edition Ultimate`; it uses its own profile and test mission. Test helpers default to Ultimate; `-Edition Plus` selects the previous edition and separate profile. Other Antistasi versions/updates and custom remote-execution allowlists need separate compatibility checks.

Version 1.3 passed **140 full server assertions plus 5 real Altis terrain-flight checks**, with zero failures/SQF errors. Flat-map strike releases measured 150 m clearance at 1,440 km/h. The Altis test survived a route across 335.5 m of elevation change with minimum measured clearance about 104 m. The lower flight calculation includes sea-surface clearance on water approaches. Human HUD rendering and sonic-boom audibility still need in-game confirmation. Repeat the separate terrain test with `scripts/Test-SupportServicesTerrain.ps1` after removing any prior owned fixture and stopping its server.









