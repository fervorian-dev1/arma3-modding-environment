# Roxie's Lucky Wheel — v5.1

## Player use

Update/restart the companion on the host/server and all clients. Existing purchased casinos gain a sixth dealer when recreated on campaign load; no second purchase or campaign reset is required. **Task Force Timberwolf Female Characters (2021778690)** remains the character dependency. **Dodge Charger SRT Hellcat 2018 (3386639372)** supplies the car prize. The existing containment-response Osprey comes from **3CB Factions (1673456286)** and its normal RHS dependencies. Missing car assets preserve the unclaimed prize; an unavailable raid returns the spin token.

Visit **Roxie** and choose **Play Lucky Wheel**. Her introduction:

> Darling, half the occupying army are my exes. The other half are on the waiting list. Drop one and there's a one-in-a-hundred chance I owe you a token. Bring it here; we'll see whether you're lucky or just my type.

She uses the installed Medrano tactical female head (`B_female_bun_04`) and a different civilian outfit. Timberwolf only supplies four face variants, not six distinct female bodies; the new dealer does not add an invented model. Existing five dealer assignments remain ordered as before.

Every credited hostile infantry kill rolls independently at **1%**. This is not a guaranteed token every hundred kills. Friendly/civilian kills, animal/vehicle destruction and duplicate callbacks do not grant tokens. Attribution uses the engine's instigator, with UAV-controller and vehicle roadkill fallbacks. NPC squad kills are not automatically awarded to the squad leader. A personal token HUD counter, local chime and short personal message appear when one is earned. Tokens survive death, reconnect and campaign save/load.

The wheel costs one token and spins for five seconds. Outcomes and accounting are server-owned. Closing the menu does not cancel a spin. Saved interrupted spins refund one token on load, once. Opening the menu, buying candy or collecting prizes uses the same authenticated casino dealer/proximity checks as existing games. Single-use request nonces prevent duplicate charges, spins and claims.

| Prize | Chance per spin |
|---|---:|
| 1,000 personal credits | 33% |
| 2,500 personal credits | 25% |
| 10,000 personal credits | 10% |
| Free Hellcat | 5% |
| HQ raid | 6% |
| Free spin (one token returned) | 12% |
| Mystery item | 8.9% |
| 100,000 personal credits | 0.1% |

The wheel graphic uses these actual weighted sector sizes; the full odds are also visible in the dialog. This is an animated UI wheel at Roxie's table, not a new animated 3D world model.

Cash goes to the winner's personal wallet, with existing offline/dead-player queued credit handling. **Collect Hellcat** parks one of the verified installed Charger variants on a clear site outside the hotel. Vehicle ownership follows native Antistasi conventions. Failed/blocked delivery retains the prize for another attempt. It does not teleport the winner into the vehicle.

Mystery chooses one portable equipment item that is not unlimited/unlocked in the **current faction arsenal**, using the merged supply pools and existing no-DLC checks. It excludes custom DSDS items (including paid Oswald and nuclear content). It does not unlock that item globally. If no eligible equipment or initialized arsenal exists, the token is returned. The winner collects the item from one shared casino collection crate outside; the same crate handles candy, avoiding a new crate for every purchase. Collection crates and placed/collected goods use normal mission-world persistence limitations; **uncollected prize entitlements** are explicitly saved per UID.

## Raid result

Reuses the HQ noise raid lifecycle, combat AI, dismount, HQ assault and cleanup. This wheel variant plans **four V-22 Ospreys**, each with **12 NATO woodland CBRN specialists** on the current hostile occupying side (48 total). Aircraft start roughly **900–1,200 metres from HQ**, at staggered altitudes and bearings; clear walkable landing zones are **180–500 metres** away. No aircraft or people are spawned directly onto players or buildings. VTOL transports use the already verified `landAt` insertion convention.

This is a deliberate wheel-triggered raid, independent of noise score. It may trigger during normal raid recovery, but never overlaps an active/preparing HQ raid or native major attack. Normal post-raid recovery remains 60 minutes, and ordinary HQ-noise detection, faction relations and map ownership are unchanged. All four nearby landing zones/assets must be available; otherwise the token returns instead of substituting incorrect aircraft. This variant does not create chemical explosions, radiation or a separate Watchkeeper hunt.

## Bag of Gummy Bears

Roxie sells one bag for **150 personal credits**. Collect it outside and use **Consume Bag of Gummy Bears** on foot through the existing server-verified consumption handshake. Short notification: **Sugar rush. Your ride feels lively.**

Duration: **10 minutes**, refreshable but not stackable; death ends that body's effect. Ground vehicles occupied by a buffed living player receive assistance when driven by a human player with this addon. The owning driver's client applies forward PhysX impulses with a target ceiling of **135% of the vehicle's configured maximum speed**, plus extra uphill acceleration. The buff can come from a passenger; it does not require every occupant to consume a bag. Braking, reverse, stopped engines, water, air time, aircraft and static weapons are excluded. Native engine/handling configs are not permanently modified. AI-driven transport is not boosted by this version. Actual attained top speed varies with vehicle physics, traction, terrain and other handling mods; the 35% figure is the assisted speed allowance rather than a guarantee on every slope.

Candy stays hidden from arsenal unlock pools and is rejected by Fence's custom-valuables buyback filter. It has no narcotic toxicity, overdose, aim or stamina effect.

## Development / files

New `lucky.hpp` contains odds, rewards, Hellcat variants, duration and the wheel dialog. `lucky_hud.hpp` supplies the small token counter via the existing RscTitles container. Modular `functions/Casino/fn_lucky*.sqf` files handle persistence/profile, kill attribution, weighted selection, authoritative requests, settlement, deliveries, mystery selection, raid planning, presentation and vehicle-assist calculations. Existing casino request/client/load/tick/dealer functions dispatch to them. No extra publicly callable reward or token RPC is exposed.

Minimal existing edits: CfgFunctions/item/forbidden registrations and version; casino dealer registry; two optional HQ-raid plan/VTOL hooks; consumable class/commit hooks; arsenal blocker; curator DEBUG registry/handler. Existing game engines and betting prices are unchanged. Dynamic Supply Drops source remains unchanged.

New DEBUG entries: **Casino - grant yourself one lucky token** and **Casino - start four-Osprey HQ raid**. They use the existing curator-only authenticated DEBUG queue. No global DEBUG announcements are added.

## Artwork

Used the built-in imagegen tool, following [imagegen skill](C:/Users/mamaj/.codex/skills/.system/imagegen/SKILL.md). Prompt:

> Use case: product-mockup. Asset type: square inventory thumbnail for an Arma 3 game item. Create a high quality realistic product photograph of one small resealable clear plastic bag filled with colorful translucent gummy bears, red orange yellow green, standing upright centered with the entire bag visible. Simple cream paper label reading exactly 'GUMMY BEARS'. Dark charcoal seamless background, soft studio lighting, crisp identifiable candy shapes, no other objects, no logo, no watermark. Optimized to remain legible as a small inventory icon.

Original saved in `projects/antistasi_support_services/art/loot/gummy_bears.png`; game thumbnail in `addons/dsds_support/ui/loot/gummy_bears.jpg` (512 square). The weighted wheel diagram is generated by `scripts/Build-LuckyWheelArt.ps1` from the configured weights with standard drawing tools and saved as `ui/lucky_wheel.jpg`. The PNG source is retained; no third-party mod assets are redistributed.

## Validation and limits

Official config compilation and candidate-PBO extraction/source hashes passed (227 registered functions). Extended isolated player-client run: **39 passed, 0 failed**, including existing five games, new wheel/introduction, enemy-only 1% boundary checks and duplicate kill rejection, actual five-second spin, duplicate nonce protection, exact 150-credit candy debit, shared-crate delivery, inventory consumption/10-minute expiry, genuine Hellcat spawn and single-item collection, plus casino restoration. Full multi-human network/JIP, a real campaign disk-save/restart, measured vehicle top speed and a completed four-aircraft landing/assault remain human acceptance checks.

Broad dedicated validation: **94 passed, 0 failed**, including actual four-Osprey/48-specialist deployment and correct hostile-side woodland uniforms. The installed UK3CB Osprey emitted `hitfuell_leads` / `hitfuelr_leads` fuel-animation configuration errors when its model loaded; deployment still passed. These originate in the third-party model, and no Workshop files were edited. Log: `logs/casino-server-ultimate/arma3server_x64_2026-11-15_08-16-11.rpt`.

Final UI/client repeat: **39/0** on the later dealer-order/ownership build, log `logs/casino-client-validation/arma3_x64_2026-11-15_08-21-15.rpt`. Focused optimized-selector checks **6/0**; all eligible selection filtering now uses the previously DLC-validated cached pools and hash-map unlock lookup instead of expensive repeated mod-source checks. If catalogue discovery is incomplete, return a token without rebuilding inside the casino worker. Final focused run: **8 passed/0 failed**, including all four Ospreys and48specialists alive after initial deployment with explicit initial VTOL engine/airspeed. Standard local companion rebuilt to **v5.1** with official config/PBO/source-hash verification. All owned tests stopped after completion.

Earlier failures: corrected a missing boolean-expression parenthesis in Roxie's introduction handler; the first raid-asset fixture omitted 3CB, then added the installed mod and RHS dependencies. Final server/deployment results are also recorded in HANDOFF.md. Isolated fixtures do not edit the user's campaign files.

Engine conventions were checked against [Bohemia's EntityKilled documentation](https://community.bistudio.com/wiki/Arma_3:_Mission_Event_Handlers#EntityKilled). Physics applies impulse units, not a repeated velocity multiplier, and uses one owning client to avoid multiplayer multiplication.
