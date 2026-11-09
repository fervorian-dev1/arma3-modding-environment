# Inventory valuables and consumables — Support Services v1.8

**Historical v1.8 notes. Current v1.9 balance, simple item text, private messages, overdose and death-money protection supersede the effect rules below: [current notes](CONSUMABLES_REBALANCE_NOTES.md).** User accepted fitting gameplay effects instead of exact ADS/reload modifications. Item classes, generated artwork, sale values and loot placement remain.

Requested 2026-11-07. Companion addon only; no Workshop, faction, map, airfield, campaign ownership, supply-drop loot pool or existing support/vehicle price changes.

## Items and balance

| Display name | Classname | Fence sale | Inventory mass | Effect |
|---|---|---:|---:|---|
| Marijuana | `DSDS_Marijuana` | 300 | 2 | Ten minutes: 25% less sway and mild blurred vision |
| Nicotine Vape | `DSDS_NicotineVape` | 150 | 0.2 | Ten minutes: +15% observed stamina recovery, +5% movement animation speed, -20% available maximum stamina |
| Cocaine | `DSDS_Cocaine` | 800 | 1 | Five minutes: +20% sprint animation speed, +30% observed stamina recovery, 20% reduction to new vanilla damage; followed by five-minute crash |
| Zyn Nicotine Pouches | `DSDS_Zyn` | 200 | 0.5 | 45 minutes: +30% current uniform/vest/backpack capacities and effective carrying allowance through loadCoef / 1.3 |
| Gold Bullion | `DSDS_GoldBullion` | 2,500 | 275 | Nonconsumable; approximately 12.5 kg using Arma's mass convention |

Crash: movement animation speed -15%, sway +30%, available maximum stamina -20%. The user specified a crash beginning five minutes after consumption but not its duration or exact penalties; these are initial balancing defaults. Marijuana/vape durations, their exact sway/blur intensity, and cocaine resistance magnitude were also selected defaults. Values/timings are in `DSDS_Consumables` in config.cpp. These are fictional game effects, not claims about real substances.

Repeated marijuana/vape/Zyn refresh their end time, without multiplying effects or adding duration. Cocaine cannot be redosed until its boost **and** crash have ended, preventing postponement of the crash. Overlapping stamina-regeneration boosts use the stronger value; movement bonuses do not multiply. Stamina-cap penalties do not compound. Other combinations multiply their aim coefficients. Expiry and death restore captured native mission/role values; later external coefficient changes are adopted as a new baseline.

## Practical limits, intentionally explicit

- **Requested ADS zoom-speed changes and vape magazine-reload acceleration are not implemented.** `setAnimSpeedCoef` changes body/locomotion animations, not general weapon reload gestures or optic zoom. `setWeaponReloadingTime` changes the shot cycle, not magazine reload time. No global weapon/gesture overrides, artificial ammunition transfers, or false reload-speed claims were added. Raising/handling animations may follow the movement coefficient, but that is not a promised ADS bonus or penalty. Those two requested details remain future work requiring a dedicated animation solution and weapon-by-weapon verification.
- **Zyn is a practical carrying bonus, not a change to Arma's fixed global soldier inventory ceiling.** Its worn-container capacities increase by 30% and its effective encumbrance coefficient decreases by the equivalent carrying factor. The engine's absolute soldier ceiling remains. On expiry/swap/drop/death/disconnect, server capacity records restore original containers without deleting their contents; overfull inventory may need unloading before accepting more items. A capacity changed independently by another mod is not overwritten during restoration.
- **Cocaine damage resistance applies only with vanilla medical handling.** Installed PiR uses its own HandleDamage calculations; ACE medical likewise owns injuries. If `CfgPatches/PiR` or `ace_medical` is present, this addon leaves that system authoritative and does not install its damage handler. Resistance is therefore absent with those medical mods. Other cocaine effects still run. Medical-system-specific resistance needs a separate integration.
- Stamina effects respect `isStaminaEnabled`; they do not turn stamina back on if the mission disabled it. ACE advanced fatigue/custom movement systems are not claimed compatible with the exact vanilla percentages. Animation-speed changes are approximate physical speed changes on real terrain, affected by engine movement, stance and injury.
- Effects are mission-session/body state. They do not persist through campaign save/restart or transfer to a new respawn body. Server tracking restores capacity on disconnected bodies rather than preserving drugs across reconnect. Ordinary stored inventory uses the mission's normal inventory persistence. Fence trade crates remain session state.

## Using the items

1. Restart the game/server with the rebuilt **@AntistasiSupportServices** and the existing **@DynamicSupplyDrops**, CBA, ZEN and one Antistasi edition. Every player needs the updated companion. No new campaign or save reset is needed.
2. In Zeus, select **Dynamic Supply Drops → Spawn valuables cache** from the modules tree and place it on dry land. A ZEN context-menu action with the same name also spawns a cache at its selected position. The box has ten random items drawn from these five classes. The server validates the curator and map position; duplicate requests are rate-limited.
3. Open the box inventory and pick up items normally. With a consumable in your inventory and while conscious/on foot, use the scroll-menu **Consume [name]** action. One item is removed from its owning client, then confirmed by the server before effects start. Gold has no consume action. No public drug-use announcements are sent.
4. To sell, request your personal trade crate at The Fence, deposit the valuables, request a quote, then confirm it. One of each new item totals **3,950 personal credits**. Ordinary gear in the same trade crate still causes sale rejection, preserving unsupported cargo.

For mission scripts, execute on the server:

```sqf
[_existingCrate, 10] call DSDS_fnc_fillLootContainer;
// Or select exact goods:
_existingCrate addItemCargoGlobal ["DSDS_GoldBullion", 1];
```

The helper adds to existing cargo without clearing it. Random-count input is clamped to 1–50. These items are **not automatically inserted into all native Antistasi missions, enemy inventories or supply drops**. Zeus placement and the helper are the current mission-loot entry points; no native mission generator was overwritten. Runtime item definitions are hidden from unrestricted arsenal discovery (`scope=1`, `scopeArsenal=0`) to avoid converting valuables into infinitely unlocked resale goods. Keep valuables outside the Antistasi arsenal; ordinary inventory, backpacks and loot crates support them.

## Architecture and changed files

New runtime files under `projects/antistasi_support_services/addons/dsds_support/`:

- `loot.hpp`: five portable CBA miscellaneous item definitions, existing free placeholder model; no custom physical object required.
- `ui/loot/{marijuana,nicotine_vape,cocaine,zyn,gold}.jpg`: five generated 256-pixel inventory thumbnails.
- `functions/Loot/fn_initLoot.sqf`: guarded initialization, Zeus registration, four self actions, client/server loops.
- `fn_lootRequest.sqf`: player-owner authentication, server nonce/consumption validation, curator cache requests.
- `fn_lootClient.sqf`: server-sender guard, exactly-one local removal, duplicate-token rejection, acknowledgement.
- `fn_lootConsume.sqf`: on-foot player entry point.
- `fn_lootCommit.sqf`: private server ledger and duration/refresh rules.
- `fn_lootModifiers.sqf`: shared calculation of active boost/crash multipliers.
- `fn_lootTick.sqf`: owner-local animation/sway/encumbrance/stamina/blur/damage updates.
- `fn_lootCleanup.sqf`: restores only coefficients still matching this addon's last write; removes only its own event handler/postprocess handle.
- `fn_lootCapacity.sqf`: server-owned worn-container expansion/restoration, swap tracking.
- `fn_lootDamage.sqf`: vanilla new-injury reduction; never heals an existing injury.
- `fn_fillLootContainer.sqf`: server-side additive mission helper.

Modified runtime `config.cpp`: version, five weapon exports, include, eleven CfgFunctions registrations, two restricted RemoteExec entries, five Fence goods entries and balance configuration. Existing Fence stock/price/transaction and supply-drop functions unchanged. `functions/fn_initServices.sqf` and project `mod.cpp`: version text only.

New development assets: `art/loot/*.png` full-resolution generated masters and `PROMPTS.json` exact prompts/method; `scripts/Build-LootThumbnails.ps1` reproducible JPEG conversion; `scripts/Test-Loot.ps1`; `tests/support_services/dsds_loot.VR/{mission.sqm,description.ext,initServer.sqf,initPlayerLocal.sqf}`. Updated root/project READMEs and docs/HANDOFF.md; this notes file is new. Generated PBO/README/mod.cpp published under build/@AntistasiSupportServices.

Images used the OpenAI **built-in image generation** tool, individually prompted, with a consistent isolated inventory-object style. Source alpha PNGs are retained unchanged. Runtime JPEGs flatten alpha onto dark grey and resize through System.Drawing; no API-key workflow or external image service was used. Arma `getTextureInfo` verifies all five runtime thumbnails load at 256×256. ImageToPAA was attempted but its installed conversion registry entry was missing; an ordinary registration attempt lacked access, so no elevation/permission request was made. The game-supported JPEG path avoids that dependency.

## API references

- [Arma stamina model](https://community.bohemia.net/wiki/Arma_3_Stamina), [setUnitTrait](https://community.bistudio.com/wiki/setUnitTrait), [setMaxLoad](https://community.bistudio.com/wiki/setMaxLoad), [getTextureInfo](https://community.bistudio.com/wiki/getTextureInfo).
- [setWeaponReloadingTime](https://community.bistudio.com/wiki/setWeaponReloadingTime), [reload gesture limitation](https://forums.bohemia.net/forums/topic/234093-need-fast-reload-advice/), [switchGesture](https://community.bistudio.com/wiki/switchGesture), [getUnitMovesInfo](https://community.bistudio.com/wiki/getUnitMovesInfo). Seeking gesture support did not establish a safe general magazine-reload speed implementation; no speculative command was added.
- Installed PiR config/functions extracted read-only under ignored reference/pir for inspection; no installed PiR file changed.

## Verification

**Final: 175 dedicated-server passes, zero failures/SQF errors.** Config validated with CfgConvert; all 72 functions registered and new SQF compiled by Arma; fresh PBO candidate extracted and all 81 packed files compared to source by hash.

- New loot fixture: **73 passes**, `logs/loot-validation-ultimate/arma3server_x64_2026-11-07_09-22-42.rpt`. All five classes/thumbnails loaded; exact Fence values and actual 3,950-credit sale/removal/repeat rejection; non-DLC metadata; additive loot helper; durations/refresh/crash boundaries; existing coefficient preservation; actual cocaine sprint animation speed; vanilla new-injury reduction; single damage-handler ownership; recovery and maximum-stamina math; 30% worn-container expansion/noncompounding/restoration; external capacity preservation; death cleanup and rejection of a nonplayer RPC actor.
- Existing Fence regression: **102 passes**, `logs/fence-validation-ultimate/arma3server_x64_2026-11-07_09-18-17.rpt`, with v1.8 items/config loaded. All old stock/tab/purchase/deployment/payment/refund/aircraft checks passed. Later changes only hardened private Loot entry points; existing Fence runtime source remained unchanged.
- Initial 67-pass and expanded 71-pass loot runs remain as intermediate logs; do not add them again to the final 175 count.
- Isolated hidden Arma client PID 128816/profile `logs/loot-client-validation-ultimate` stalled before creating a game window/joining. No client fixture completion occurred. It was stopped by checking its exact PID/name/profile/port. **Positive human consumption RPC, consume-menu visibility, blur appearance, actual ADS/reload feel, JIP/respawn and the full user medical/mod list remain unverified.** Dedicated checks cannot establish these. `initPlayerLocal.sqf` retains a client handshake/blur/token/inventory test for a future real joining client. ADS/reload timing is explicitly unimplemented, not merely unverified.
- No full 45-minute wall-clock test: effect boundaries were checked using the injectable timestamp and native container/trait changes directly. Physical movement depends on terrain and animations; feel/balance needs human testing.
- AI fixture wallet messages can log null RemoteExec targets after test actors are deleted, and Arma logs a deleted object reference; these are fixture teardown notices, not SQF exceptions. Existing unrelated Workshop model/stringtable warnings remain.

Final companion SHA256: `7866CD64F0443A8B23DDCEF8CB29B3F977ED2CAAFEC00533A158ED1EFB17A423`.
Original DSD SHA256 remains `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.

Owned test processes were stopped and copied `dsds_loot.VR`/`dsds_fence.Altis` fixtures removed after marker/path/file-list validation; logs and source fixtures remain. No user game process was stopped. No campaign save was opened or changed.
