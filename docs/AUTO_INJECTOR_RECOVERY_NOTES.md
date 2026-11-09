# Automatic injector recovery / PiR compatibility - v2.8

Updated 2026-11-08. User reported that carried Adrenaline did not provide a second life and requested Morphine auto-injection for PiR crawling/incapacitation. The installed mod is **Project injury Reaction (PiR)**, Workshop1665585720. No Workshop files/settings, faction/map/territory, wallets, Mystic rewards or convoy loot pools are changed.

## Gameplay

- A living incapacitated player automatically uses **one carried Adrenaline** and returns to full body/leg health and consciousness. If none is carried, **Morphine** provides the recovery instead.
- A living player in PiR's forced-crawl state automatically uses **one Morphine**, falling back to Adrenaline if necessary. Ordinary voluntary prone/crawling is not a medical trigger.
- If both are carried, one is selected, not both. Short five-second recovery holdoff and pending/receipt tokens prevent duplicate consumption. Manual injection requests made while down use the same rescue path, with mutual exclusion against other consumption transactions.
- An actual dead character is not resurrected; these are second chances while alive/down. No injector means no rescue. Existing nuclear vest behavior on actual death is unchanged.
- Full healing happens once. No invulnerability or repeated health refill. PiR's delayed animations are settled for up to18seconds, stopping immediately on new damage (>=0.05), death, loss of locality or replacement by a newer rescue. A fresh wound is not cleared by the previous rescue worker. Temporary PiR completion/stop flags are also cleared when settling ends so a subsequent untreated knockdown cannot inherit a free recovery.
- PiR's successful-treatment flags stop forced animations and bleeding. Its own cleanup returns weapons/throwables it temporarily removed; no cached full-loadout replay that could duplicate gear or restore consumed syringes. Existing armor and mod settings remain intact.
- Automatic lifesaving use does not add overdose toxicity; it keeps the syringe's normal timed effect ledger and short private **"You're back on your feet."** message. Manual healthy use and all narcotic overdose rules retain their existing behavior. Manual Morphine still has its prior gradual-heal effect; auto-rescue adds the requested immediate get-up.

## Why the earlier implementation failed

The old gate only checked generic unconsciousness plus `dam_uncondition_injured0`. In installed PiR that variable is an **animation-stop/treatment flag**, not a reliable active down-state indicator. It missed forced creep/crawl states and then cleared a flag needed to stop the unconscious-animation loop. Morphine had no automatic rescue route. Calling `PiRrespawn` during treatment reinitialized hit handlers and was inappropriate for a living casualty, so that call has been removed.

The new detector recognizes native life state, Antistasi/ACE unconscious flags and PiR's actual active injury gate plus `PIR_Creep*`, `ApanPpne*` and unconscious animations. It does not treat a lone stale PiR stop flag or ordinary prone as injury. The recovery uses the installed successful-treatment semantics: `dam_conec_istorii0=true`, `dam_uncondition_injured0=true`, a stopped crawl/treatment state, stopped bleeding, normal pulse/breathing and **blood status5**. It releases PiR's injury gate and captive state according to PiR's own setting, without calling a respawn initializer. A narrow runtime wrapper retains the original installed `Uncondition0` and delegates every normal/fresh injury to it. Only a recently rescued, fully healed unit whose active injury gate has already been released is excluded from a stale crawl-to-unconscious transition. No PiR file or global gameplay setting is edited.

Reference files inspected: `reference/pir/PiR/functions/crawl0.sqf`, `crawlanim0.sqf`, `uncondition0.sqf`, `unconditionanim0.sqf`, `unconditionfind0.sqf`, `unconditionfunction0.sqf`, `unconditionkilleffect0.sqf`, `pirrespawn.sqf`, `pirrespawn0.sqf`, `pir0.sqf`, `pirinitstart0.sqf`. Installed PBO SHA256 **31EAAC823634F9B8F6DBE0001DE67AD2A2DC17DFBFA99A8854980A58D8026043** at inspection. PiR remains optional; generic living incapacitation still works without it. ACE-specific full treatment is not claimed.

## Locality and accounting

The server authenticates the player/owner, chooses the class from actual inventory/state and issues a unique rescue nonce. The existing server-origin client dispatcher invokes owner-local removal and recovery; receipt replay cannot consume an additional syringe. The server checks replicated item-count reduction before committing the effect ledger. The selected class is retained in the pending record, so Morphine acknowledgements cannot be applied as Adrenaline. Multiplayer sender/owner checks remain strict; legitimate local single-player calls normalize to the local unit owner rather than rejecting `remoteExecutedOwner=0`.

## Source inventory

Under `projects/antistasi_support_services/addons/dsds_support/functions/Loot/`:

- New `fn_initPiRRescue.sqf`: one server-side stale-transition wrapper, with original installed code retained.
- New `fn_lootDownState.sqf`: actual PiR/generic state detection.
- New `fn_lootRescueClass.sqf`: item selection, fallback and holdoff.
- New `fn_lootRescueTake.sqf`: idempotent owner inventory transaction/recovery.
- New `fn_lootRecover.sqf`: once-only healing, native treatment flags and guarded delayed-animation settling.
- Modified `fn_lootCanRevive.sqf`: existing Adrenaline predicate delegates to corrected state detection.
- Modified `fn_initLoot.sqf`: automatic loop considers both syringe types.
- Modified `fn_lootClient.sqf`: generalized selected-class rescue and local-SP authorization.
- Modified `fn_lootRequest.sqf`: selected-class handshake, shared consume locks, manual-down routing and local-SP ownership.
- Modified `fn_lootCommit.sqf`: automatic rescue message and toxicity exemption; other consumable logic retained.

Also modified addon `config.cpp` (v2.8/five registrations), `effects.hpp` (Adrenaline's reviveDamage metadata0), `functions/fn_initServices.sqf` and project `mod.cpp` (version metadata), project/root README and handoff.

Tests: `scripts/Test-RescueServer.ps1`, `tests/support_services/dsds_rescue_server.Altis/{mission.sqm,description.ext,initServer.sqf}`; `scripts/Test-RescueClient.ps1`, `tests/support_services/dsds_rescue.Altis/{mission.sqm,description.ext,init.sqf}`. Client tests use Arma's documented **autotest** mode and a separate profile, not the user's campaign. Existing expansion fixture waits for the existing asynchronous AI Accuracy Fix integration before judging stash skill; its earlier immediate check raced that integration. Gameplay guard settings were not changed.

## Validation

**Final forced-branch actual-player engine run:19 PASS/0 FAIL**, `logs/rescue-client-validation/arma3_x64_2026-11-08_04-56-04.rpt`, including the narrow native-transition wrapper and temporary-flag cleanup. The fixture forces PiR's post-crawl unconscious chance to100% locally, records the stale transition being suppressed, verifies one dose/equipment counts, and proves a later native knockdown stays incapacitated without an injector. No SQF expression errors in this final run.

Initial successful real game-client run with the installed PiR: **17 PASS/0 FAIL**, `logs/rescue-client-validation/arma3_x64_2026-11-08_04-47-24.rpt`. This uses an actual local player, automatic client polling and the real owner/server handshake, then the installed full `Crawl0` and `Uncondition0` player routines. It observes recovery after25seconds, confirms the player stays alive/healthy/mobile, preserves the other syringe and original rifle, and restores throwables without duplication. It is automated single-player engine acceptance, not a claim that two remote human clients were tested.

Focused dedicated PiR tests (before the final temporary-flag cleanup and stale-transition guard): **23 PASS/0 FAIL**, `logs/rescue-server-validation-ultimate/arma3server_x64_2026-11-08_04-45-35.rpt`, covering actual native animation callbacks, damage/hitpoint restoration, priority/fallback, replay rejection, cooldown, no free/dead rescue and fresh damage ending the old treatment flags. Expansion regression (before that final temporary-flag cleanup and stale-transition guard): **207 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_04-48-12.rpt`. Earlier206/1 expansion runs checked stash skill before the existing asynchronous accuracy integration settled; the corrected fixture waits up to45seconds and all guards then had0.85 general skill. No production AI change was made.

Final client/server/rescue and expansion logs contain no SQF expression errors. Official CfgConvert/build verification checks config, all164 function registrations and every packed file against extracted source. Earlier client-launch attempts had quoting/path issues before entering a mission; these are not live gameplay evidence. The first real-player run exposed single-player authorization and fixture missing arguments to native PiR routines. An old packed test mission also initially shadowed the updated unpacked fixture; the launcher now packs a fresh fixture each run. These were corrected before the final17/0 run. Temporary playMission/CfgMissions harness attempts were not shipped. A later19-check control run at04-52-11 had17 PASS/2 FAIL: it exposed PiR's random post-crawl unconscious transition, extra syringe use and duplicated returned throwables. The final test explicitly forces that branch at100% in its isolated fixture; production settings remain unchanged. The runtime wrapper addresses that actual compatibility bug.

Remaining acceptance includes two distinct human clients on a dedicated host and any user-specific PiR setting combinations. No promise of restoring a character after an instant fatal headshot or nuclear death. Keep injectors in the player's personal inventory, not nearby crates/vehicle cargo. Restart host/server and every client with the updated companion; **no campaign reset**.

## Publication / cleanup

Published standard **v2.8**: `build/@AntistasiSupportServices/addons/dsds_support.pbo`, SHA256 **C04B91CE148927B2219ED4A3692056A3227B4E4939A287CA27BC4713F1507688**. **164 functions /200 packed files**, official config check and full source-to-extracted-PBO hash comparison passed. Original supply-drop PBO unchanged: **F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6**. Only owned test processes, copied mission folders, hash-verified rescue mission PBO and marked autotest config were removed from the game directory. Logs/source fixtures and failed-launch harness history under temp remain. No normal user game was stopped; no save reset or Git commit.
