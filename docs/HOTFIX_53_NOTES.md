# Casino, persistence and medical hotfix — v5.3

## What to do after updating

Fully restart Arma on the host/server and every client. On the first load, the old hotel casino becomes **packed but still owned**; it is not recreated in the obstructing location. At the HQ flag choose **Place / move casino**, select a clear flat location and heading, and place it without buying again.

Zeus Modules → DEBUG now includes **Casino - pack / despawn** and **Casino - move HERE**. Packing removes the building and all dealers, preserves ownership, and returns unfinished ordinary table stakes. Lucky Wheel spins still resolve. The HQ placement action is available only once the casino is owned; the purchase action is hidden once owned. Moving and packing do not change player balances, token counts or prize entitlements. The shared prize crate and its contents are retained; an untethered crate moves beside the relocated casino. A loaded/attached crate is not forcibly pulled out of another vehicle.

## Casino layout and wheel

The hotel is replaced with the verified base-game **Land_Hangar_F**: one large ground-level hall, no furnished interior. All six dealers stand in one clearly visible row **outside the front wall**, directly on terrain. No hotel building positions, upper floors, tables, sofas or decorative furniture are used. Placement needs roughly80m of clear flat dry space. Native geometry bounds determine the building's ground offset and the dealer row; NPC positions explicitly use ground altitude.

Dead dealers are scheduled for replacement after295seconds, leaving scheduling margin inside the requested five-minute limit. The same game slot and identity are reused, without duplicate dealers. Packing intentionally prevents replacement until the casino is placed again.

Roxie no longer mentions the token probability. The explanatory token-drop rate is also removed from her menu; the backend remains **1% per credited enemy infantry kill**. Her revised line says: **Make one disappear and you might find a little thank-you from me.** The counter is half as wide, smaller text, transparent, and near the upper-right edge below campaign status. Prize probabilities are unchanged.

An additional defect found in the real game RPT is fixed: EntityKilled supplies a boolean fourth argument (`useEffects`), while the internal deterministic test helper expected an optional numeric roll. Non-numeric fourth arguments now use a normal random roll, avoiding boolean-versus-number errors on actual enemy kills.

## Mystic and permanently unlocked Oswald

**Root cause:** the currently installed Ultimate save loop creates a new `A3A_saveDataHM` during every save. Periodic calls to `setStatVariable` alone are not reliable plugin persistence: custom keys can be discarded when that map is rebuilt. Earlier isolated tests exercised writes/reads but did not reproduce that reset and a full process restart.

The hotfix uses the installed, documented **A3A_event_serverGameSave** and **A3A_event_serverGameLoad** plugin events through CBA. Before the native reset, it captures current DSDS state into the namespaced `saveDataPlugins/DSDS_SupportServices` payload. The load event restores those keys before vendor/casino initialization. A once-per-selected-campaign fallback supports initialization after the load event. This also preserves custom casino, token/prize and extra-garage-slot data. Native save/load code, factions and map ownership are not overridden.

Oswald's paid unlock has a separate monotonic per-campaign flag. It is restored from that flag, the vendor save record, or an existing unlimited/unlocked legacy arsenal entry. A finite carried bracelet alone does not grant a new campaign-wide unlock. The arsenal sanitizer waits until Mystic's state is loaded instead of removing Oswald before the paid flag can be read. Once unlocked, it restores the unlimited watch entry using Antistasi's native JNA API.

Mystic retains location, lead/reveal flags, offerings and reward progress. The loader accepts legacy records with no position without discarding an otherwise valid Oswald entitlement; position can then be selected normally. Spawning checks for usable ground and forces the object visible and simulated. A deleted object is restored immediately rather than being mistaken for a death; a genuinely killed Mystic still follows his existing30-minute respawn delay. Invalid water sites are replaced. No player progress is inferred beyond the specific Green Sea repair described below.

## Current Green Sea save repair

The selected existing Green Sea save was read while the user's game was closed, backed up under `backups/campaigns/`, and repaired with the official CfgConvert tool. Only that campaign's Mystic schema, lead/reveal/alive flags and previously unlocked Oswald boolean were changed. Position, money, offerings, nuclear reward state, factions, equipment and all other campaigns were retained. No missing isotope progress or nuclear unlock was invented.

The rebuilt profile was decoded again and compared in full with the intended text. The only converter-only normalization was IEEE negative zero to zero. Before installation, the original live file's hash had to match the backed-up source; the installed repair then had to match the verified candidate. Temporary decoded profiles and backups remain ignored by Git. The new runtime plugin path is required to keep subsequent saves reliable.

## Self-treatment

While conscious, injured and on foot with PiR medical supplies, use **Treat yourself**. Treatment takes8seconds and uses the normal medic animation. The reusable **PiR medkit** is retained; a PiR bandage is consumed once if no medkit is present. Canceling, moving away, entering a vehicle, becoming incapacitated or receiving further overall damage aborts without consuming supplies. New hitpoint injuries are not erased by the end-of-treatment calculation. No invulnerability, automatic player knockdown or respawn operation is added.

PiR's medkit is a miscellaneous item restricted to backpack storage, so Arma's vanilla medkit treatment action does not automatically recognize it. The explicit action bridges that gap without restoring PiR's player medical/down system. Existing teammate Revive, PiR medical-item lists, injector behavior and the stale R-to-respawn protections remain. AI injury animations stay enabled as in5.2.

## Vehicles and gummy bears

Hellcat classes (`DCH18_UCG_*`) are excluded from civilian-car discovery and template additions, filtered out of the native HQ/garage buy menu, and rejected by the native HQ purchase entry point before payment or placement. Existing owned/stored Hellcats are not deleted or blocked from garage retrieval. Wheel car rewards and Fence's existing stock rules remain.

The display name is now **Verstappen Gummy Bears**. The item classname, artwork,150-credit price and10-minute vehicle effect remain, so existing bags continue working.

## Files and validation

Added: Compatibility `fn_initCampaignPersistence.sqf`, `fn_restoreCampaignData.sqf`, `fn_selfTreat.sqf`, `nativeHQVehicleList.sqf`, `nativeHQPurchase.sqf`; Casino `fn_casinoClear.sqf`, `fn_casinoPack.sqf`; `scripts/Test-Hotfix53Client.ps1` and `tests/support_services/dsds_hotfix53.VR`.

Modified: config/version/function registrations; casino spawn/load/save/request/tick/UI/init/site validation; Lucky Wheel dialogue/HUD/crate delivery/kill-argument handling; Mystic load/save/spawn/tick; Oswald arsenal guard; PiR medical action initialization; civilian transport discovery; extra-slot load fallback; DEBUG registry/handler; gummy display name; README/handoff. All packed source files are checked against the extracted candidate PBO. Original Supply Drops stays1.2 and Workshop sources are untouched.

Isolated actual-player workflow: **27 passed,0 failed**, including hall placement, six ground-level dealers, no furniture, free relocation with retained crate cargo, packing/migration, replacement timing, native garage/HQ Hellcat exclusion, renamed item/HUD, real medkit and bandage healing/cancellation, visible Mystic, native unlimited Oswald, and official save-event capture across a simulated native map reset. The first fixture lacked a backpack for the backpack-only medkit and a market initialization variable; those fixture issues were corrected and the full workflow rerun.

Actual process shutdown/restart using a written mission profile: **4 passed,0 failed** for Mystic visibility, paid Oswald/offerings, hall state and existing custom garage slots. Logs: `logs/hotfix53-client/arma3_x64_2026-11-15_15-06-25.rpt` and `arma3_x64_2026-11-15_15-08-34.rpt`. No SQF expression errors in these successful runs. Final ownership/action-label polish was statically reviewed and packaged after the workflow tests.

Full multi-human/JIP, an entire native campaign save under live combat, subjective building appearance on Green Sea, and medical-mod combinations beyond the installed setup still need player acceptance. The disk test validates the actual serialized custom-plugin payload in a separate profile; it does not claim an unattended full campaign playthrough. No GitHub upload is part of this hotfix request.
