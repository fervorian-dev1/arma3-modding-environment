# Mystic nuclear reward - v2.7

Updated 2026-11-08. Implements the reward now specified by the user; supersedes v2.6's intentionally unimplemented reward. Campaign progress remains shared; purchases use personal money. No map/faction/territory or Workshop originals changed.

## Behavior

After the faction has offered 40 Industrial Isotopes, Mystic's menu shows **Accept Mystic's reward**. The first player to accept receives the one shared reward. He says exactly:

> Stay still, child. Surrender doubt. Surrender fear. Surrender yourself. Embrace your enemy.

This is private written dialogue using the existing vendor message path, not generated voice acting. The reward is a real attached chest prop using the installed native IED model. It is not inventory equipment, so removing/changing armor, clothing or backpacks cannot take it off. If the prop is deleted/detached, the server restores it. Armor/cargo remain usable. The wearable is bound to that player UID and the armed state survives normal campaign save/load. Disconnecting parks the armed reward until the same player returns; it does not explode merely because the engine deletes the disconnected unit.

The wearer has a scroll-menu **Touch off chest device** action. Detonating it, or actual character death, dispatches a nuclear blast at that character's ASL position. Incapacitation alone is not death. The quest consumes its armed state before dispatch so its own damage/death cannot recurse. After successful dispatch, **Nuclear IED**, priced **174,000 personal credits**, becomes available beside Oswald at Mystic for everyone. Reward status and stock unlock are saved. The one-time chest reward cannot be claimed repeatedly.

The Nuclear IED is an actual native remote-explosive magazine/ammo subclass with the ordinary IED model and a new Put muzzle. Place it through normal explosive placement and detonate with normal **Touch Off** controls. A real explosion triggers one nuclear dispatch. Defusing/deleting an intact mine must not count as detonation. It retains ordinary explosive behavior, including vulnerability to being destroyed; it is not restricted to a vendor-created dummy or a separate placement UI. Your supplied bottle artwork is used only for the thumbnail; no new 3D model was generated.

## Installed framework

Uses the existing **Zeus Enhanced Atomic Bomb** event, exactly as the installed Zeus module does:

`["zen_modules_moduleNuke", [positionASL, 500, 300, false]] call CBA_fnc_globalEvent`

That dispatches installed `zen_modules_fnc_moduleNukeLocal` on each current machine. ZEN handles server destruction and client particles/flash/shake. Destruction radius is **500m**, processing up to **300 objects per second**. ZEN color corrections are disabled to avoid overwriting the custom consumable effects; its native particles/light/shake remain. No invented nuclear API, separate blast simulation or additional radiation system. The installed ZEN event/function is internal (not a promised stable public API), so future ZEN changes may require updating this small adapter. Verified against the installed source under `reference/zen/zen_modules/functions/fnc_modulenuke.sqf`, `fnc_modulenukelocal.sqf`, and `xeh_postinit.sqf`. Mod dependency now explicitly includes `zen_modules` and native `A3_Weapons_F_Explosives`.

## Authority and saving

Raw blast and reward functions are private server helpers. Manual requests authenticate the real player owner and operate only on the server-bound wearer. Mine callbacks authenticate current/last projectile owner, registered mine ID, recent server-observed location and dead status; arbitrary positions/intact mines are rejected. Per-mine records are consumed before dispatch. Config init hooks plus owner/server discovery cover placed mines, without duplicate Explode handlers. Deletion alone has no blast callback. Temporary dead mine records expire.

Mystic's existing owner-machine delivery/confirmation/refund path now supports the IED magazine alongside the bracelet and isotope offerings. Server config supplies classes/prices. Validated callbacks set private server authorization flags before delegated blast/exchange helpers; Arma preserves remote-execution context through scheduled delegates, so private guards must recognize that validated path. Raw helpers are not whitelisted as RPCs. The existing 10-field version-1 campaign record is accepted; three optional trailing fields add reward state, bound UID and nuclear-stock unlock. Existing locations/counts/paid leads remain intact. Use normal Antistasi campaign saving to flush native saved statistics. Placed mines themselves follow normal mission/Antistasi explosive persistence; this feature does not add a new persistent mine system.

## Exact source changes

New `projects/antistasi_support_services/addons/dsds_support/functions/Nuclear/`:

- `fn_initNuclear.sqf`: guarded lifecycle, death/disconnect handlers, discovery/ticks.
- `fn_nuclearBlast.sqf`: private ZEN dispatch adapter and diagnostic counter.
- `fn_nuclearClaim.sqf`: one-time shared reward claim, UID binding, exact dialogue.
- `fn_nuclearDetonateVest.sqf`: atomic spend/dispatch/unlock and cleanup.
- `fn_nuclearRequest.sqf`: authenticated wearer action.
- `fn_nuclearTick.sqf`: attach/restore chest prop, restore bound player and maintain mine registry.
- `fn_nuclearClientTick.sqf`: one local action per player object, including respawn.
- `fn_nuclearIEDInit.sqf`: one Explode hook per local mine and server registration.
- `fn_nuclearIEDReport.sqf`: verified owner explosion report/deduplication.

New art: `art/loot/nuclear_ied.png` (unaltered supplied PNG), `addons/dsds_support/ui/loot/nuclear_ied.jpg` (512px black-letterboxed thumbnail). Original Downloads file retained.

Modified addon files: `config.cpp` (v2.7, 9 registrations, dependencies, custom ammo/magazine/Put muzzle, two restricted RPCs); `mystic.hpp` (hidden nuclear offer and reward button); `functions/Mystic/fn_mysticTransaction.sqf`, `fn_mysticInventory.sqf`, `fn_mysticFinishTrade.sqf` (magazine handshake/reward routing); `fn_mysticRequest.sqf` (authorized delegated acknowledgements); `fn_mysticLoad.sqf`, `fn_mysticSave.sqf`, `fn_mysticPublish.sqf` (backward-compatible saved/shared fields); `fn_mysticOpen.sqf`, `fn_mysticRefresh.sqf` (unlocked stock, thumbnail, reward visibility); `functions/fn_initServices.sqf` plus project `mod.cpp` (version metadata). Readmes/handoff updated. Existing Fence/convoy/supply-drop behavior is retained.

Tests added: `scripts/Test-Nuclear.ps1` and `tests/support_services/dsds_nuclear.Altis/{mission.sqm,description.ext,initServer.sqf}`, using separate localhost port 24446/profile and isolated native save key. Existing Mystic test is rerun against the candidate. No normal user game is stopped.

## Validation and limitations

Final nuclear engine suite: **40 PASS/0 FAIL**, `logs/nuclear-validation-ultimate/arma3server_x64_2026-11-08_04-21-19.rpt`. It exercises old ten-field saves, chest deletion/detachment repair, saved binding, real ZEN destruction, native Put magazine consumption, actual Touch Off explosion -> one nuclear callback, exact174,000 deduction, intact-mine rejection, intact-mine deletion without detonation, wearer death and saved stock unlock. Final Mystic regression: **60 PASS/0 FAIL**, `logs/mystic-validation-ultimate/arma3server_x64_2026-11-08_04-21-20.rpt`, plus the existing **inconclusive** Oswald AA acquisition experiment (unprotected sensor control had no contact). No SQF expression errors in either final run.

Earlier staged failures were corrected before publication: extended inventory validation initially rejected isotope deliveries; fixture save lacked a valid vendor position; an underwater fixture prevented approach; the scripted native Put test initially used incorrect fire arguments. The end-to-end native IED test then exposed remote-context inheritance blocking the private nuclear helper, fixed with validated private authorization flags. The same pattern now authorizes Mystic delivery acknowledgements. Do not cite the earlier failed runs as passing evidence. No normal user save was touched. Official CfgConvert validates config; all **159** SQF functions are registered; new/modified SQF/config delimiters reviewed. The build helper extracts the PBO and hash-compares every packed source file.

Human acceptance still needs actual rendered chest alignment, first-person/vehicle clipping, native player action presentation and remote multiplayer/HC/JIP effects. Dedicated-server tests can prove native server destruction/event routing and actual explosive controls, not client rendering. Standard Arma/Antistasi god mode, safe zones or external damage-protection mods may affect ZEN's damage; no attempt is made to override them. No claim that nuclear effects are performance-free. Existing Oswald mod-specific lock limitations remain.

To test after updating everyone: finish the shared forty-isotope offering, accept Mystic's reward, inspect the attached device and action, then touch it off away from HQ or die. Revisit Mystic and purchase/place/detonate a Nuclear IED with native controls. Check the exact 174,000 personal deduction and save/reload unlock. No campaign reset needed.

## Publication

Published standard **v2.7** in `build/@AntistasiSupportServices`, with **159 functions/195 packed files** verified against source extraction. PBO SHA256: **B08607E6D0BED00E182AB600AD5A805431F2DFE60AEFD6328BC2E28641E4D840**. Original supply-drop PBO unchanged: **F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6**. Only the verified owned localhost test processes and copied Mystic/Nuclear mission fixtures were cleaned. Source fixtures/logs retained. No normal game was stopped, no campaign reset, no Git commit. Restart host/server and clients; send friends the complete updated mod folder.
