# Mystic - companion v2.6

**Historical v2.6 baseline:** the reward is now implemented in v2.7; see [nuclear reward notes](MYSTIC_NUCLEAR_NOTES.md).

Updated 2026-11-08. User confirmed shared faction discovery/progress saved with the campaign; lead and artifact purchases use the buyer's personal money. Original factions, territory, maps, campaign saves and Workshop files are not changed.

## Player flow

- Mystic lives at one fixed, unmarked campaign location. The site selector scores altitude and privacy, avoids water, requires usable flat ground and avoids spawning within 800m of current players. It retries if no site is found. He is an unarmed stationary civilian; normal damage can kill him. He silently returns at the same site after 30 minutes of mission time. Remaining delay survives normal campaign saving/loading; offline time does not advance it. No player-facing respawn timer or announcement.
- A completed sale of `DSDS_IndustrialIsotopes` to Fence unlocks his associate dialogue. Quotes, medical isotopes and unsuccessful sales do not unlock it. The next Fence menu exposes **Reveal Mystic - 92,235 credits**. One successful personal payment reveals the shared marker; repeat requests do not charge again.
- Speak to Mystic in person/on foot. The first conversation per player UID in that campaign plays a roughly 4.5-second camera introduction, then opens the dark, asymmetric purple/gold menu. Death, moving away, or opening the map exits the camera and restores normal view. Subsequent conversations go straight to the menu.
- **Trinkets** initially contains only **Oswald**, priced at **62,000**. It uses the supplied bracelet image unchanged apart from thumbnail resizing/black letterboxing. The inventory item has the name only, with blank descriptions, and equips in the Watch slot. It is not added to Fence stock or normal loot pools.
- **Offer carried industrial isotopes** accepts partial batches, updates the shared counter and stops at 40, retaining excess carried items. At 40 the saved `ready` flag is true. The exceptional reward is deliberately pending the user's next specification; nothing is invented or granted yet. Isotopes in vehicles/crates must be taken into personal inventory before offering.

## Oswald behavior and limits

An alive wearer physically inside an aircraft protects that aircraft, including when seated as a passenger. Merely carrying an unequipped bracelet, standing beside an aircraft, controlling a UAV remotely, or using a parachute does not qualify.

Each machine (including server, clients, HC/JIP) applies native zero IR/radar target-size overrides to registered protected aircraft and restores prior values when protection ends. Visual target size remains unchanged. On the local missile owner, a native missile targeting the aircraft has its guidance target cleared. No faction changes, captive flags, invulnerability, projectile deletion or global enemy-weapon disabling are used. Native unguided/manual fire remains dangerous.

Native `M_Titan_AA` and `M_Air_AA` target cancellation and signature restoration passed engine tests. A separate real-AA sensor test initially failed its **unprotected control** (no sensor contact), so that run cannot establish lock prevention. It is not valid to count the empty protected-contact result as proof. Final test provenance is recorded below. Scripted/mod-specific seekers bypassing native sensors/targeting are not guaranteed; live human lock-screen, multiple remote owners and HC/JIP behavior still need acceptance. Do not describe this as universally proven immunity to every mod's missile.

API references: [setTargetSize](https://community.bistudio.com/wiki/setTargetSize), [setMissileTarget](https://community.bistudio.com/wiki/setMissileTarget), [sensor configuration](https://community.bistudio.com/wiki/Arma_3:_Sensors_Config_Reference). `setTargetSize` requires Arma 3 2.22 and has local effects, hence the worker on every machine.

## Locality, money and saving

Public requests validate player ownership, side, life state, mission readiness, distance and a rate limit. Server configuration supplies prices/classes/counts. Exchanges reserve money on the server and use owner-executed inventory delivery with unique tokens, duplicate receipts and confirmation against replicated inventory. One pending exchange per player and one offering lock prevent concurrent counting. Failed deliveries refund once; disconnect fallback retains the captured post-charge balance if no saved balance is available. Pending flags replicate for UI feedback. No shared faction wallet is charged.

`DSDS_mysticState` is written with native `A3A_fnc_setStatVariable` and read with `A3A_fnc_returnSavedStat`, scoped by the existing campaign/map save target. It stores site, direction, discovery, reveal, offering count, intro UIDs, ready flag, death state and remaining return delay. Use normal Antistasi campaign saves to flush these changes. No save override, campaign reset or unrelated save edit.

## Files

Created in `projects/antistasi_support_services/addons/dsds_support/`:

- `mystic.hpp`: prices, offer registry and dialog.
- `functions/Mystic/fn_initMystic.sqf`: guarded lifecycle and local workers.
- `fn_mysticLocation.sqf`, `fn_mysticLoad.sqf`, `fn_mysticSave.sqf`, `fn_mysticPublish.sqf`: placement/persistence/shared state.
- `fn_mysticSpawn.sqf`, `fn_mysticTick.sqf`: civilian lifecycle and transaction timeouts.
- `fn_mysticLead.sqf`: confirmed industrial sale unlock.
- `fn_mysticRequest.sqf`, `fn_mysticTransaction.sqf`, `fn_mysticInventory.sqf`, `fn_mysticFinishTrade.sqf`: authenticated exchange path.
- `fn_mysticClient.sqf`, `fn_mysticOpen.sqf`, `fn_mysticRefresh.sqf`, `fn_mysticSubmit.sqf`: private messages/camera/UI.
- `fn_oswaldAircraft.sqf`, `fn_oswaldTick.sqf`: equipped wearer registry/native anti-lock behavior.
- `ui/loot/oswald.jpg`: 256x256 thumbnail.

The function filenames above all reside in `functions/Mystic/`. Source artwork: `projects/antistasi_support_services/art/loot/oswald.png`, copied from the supplied Downloads PNG.

Modified existing source: `config.cpp` (version 2.6, item/NPC, 18 registrations, restricted RPCs and UI include); `fence.hpp` (lead button/height); `functions/Fence/fn_fenceOpen.sqf` (lead visibility); `functions/Fence/fn_fenceTransaction.sqf` (successful-sale hook); `functions/fn_initServices.sqf` and project `mod.cpp` (version log/metadata). Updated project/root README and handoff. Existing supply-drop addon is unchanged.

Test assets: `scripts/Test-Mystic.ps1`, `tests/support_services/dsds_mystic.Altis/{mission.sqm,description.ext,initServer.sqf}`. Tests use isolated profiles/fixtures and private server helper calls for test AI actors; this does not replace human multiplayer acceptance.

## Validation and acceptance

All 150 function files are registered; new SQF/config delimiters reviewed; official CfgConvert validates configuration. Build helper extracts the candidate and compares every source file hash against the PBO. Final engine run: `logs/mystic-validation-ultimate/arma3server_x64_2026-11-08_02-30-20.rpt`: **60 PASS / 0 FAIL**, plus an explicitly **inconclusive** AA sensor acquisition experiment (unprotected control had no contact). This run includes the final replicated pending flag and disconnect-refund fallback. It confirms prices, real Fence sale unlock, actual owner inventory RPC, duplicate/refund protection, partial offerings/excess retention, native saved-state restore, simulated-clock 30-minute respawn, Watch-slot/passenger rules, signature restoration and two native missile targets. UI registration is checked; rendered UI/camera and real remote-player flows are not.

Regression candidate: `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_02-23-45.rpt`: **203 PASS / 0 FAIL**, before the final pending-flag/refund-fallback adjustments. First Mystic run caught a staged registration mistake before publication; second caught an undersized test backpack. Those fixture/build failures were fixed. Third run at 02-23-45: **61 PASS / 1 FAIL**, including the failed AA sensor control described above. No assertion from that run proves AA acquisition prevention.

Human acceptance: restart host/server and every client with the single standard companion folder plus existing dependencies. No campaign reset. Sell industrial isotopes at Fence, buy his lead, visit the marked site, check the introduction/menu and equip Oswald in Watch. Offer isotopes in batches, save/reload, and verify another player sees the same marker/count. Test personal deductions on a real remote player and AA locks with the actual installed launchers/aircraft. Verify camera restoration/UI scaling visually. Future reward implementation remains intentionally open.

## Publication

Published standard v2.6: `build/@AntistasiSupportServices/addons/dsds_support.pbo`, SHA256 **F2F49375E3DEEC0FF0D71C822402C5BDBBFD32440DDA5D4E60914BF119DC91B1**. All **185** source files verified against extraction; **150** functions registered. Original supply-drop PBO remains **F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6**. Only owned copied Mystic/Expansion test missions are removed from game MPMissions; source fixtures/logs remain. No user game was stopped.
