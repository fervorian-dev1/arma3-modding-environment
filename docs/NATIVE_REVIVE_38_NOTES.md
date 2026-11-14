# Native revive bridge v3.8 ? 2026-11-13

User requests removing PiR knockdown/crawl medical system and using existing teammate Revive with PiR medical supplies. No tests performed, per standing instruction.

Replaces earlier initPiRRescue stale-transition patch. Registers existing function at preInit and postInit. Disables installed PiR_injuriplayer_on and PiR_injuriAI_on on every machine immediately, on CBA_settingsInitialized, and after faction initialization every five seconds to survive setting synchronization. Keeps PiR_IFAK_on, inventory conversion and medical items. Adds configured PiR_changeIFAK and PiR_changeMedKit classes (plus verified default names PiR_bint/PiR_apteka, guarded by class existence) to native A3A_faction_reb firstAidKits/mediKits arrays locally on each machine. Native A3A_fnc_actionRevive consumes a bandage from medic/casualty if no reusable medkit is present. Uses existing Antistasi Revive action, treatment timing and cancellation; does not add duplicate revive actions or another damage handler. No mission file or faction selection changes. Other faction fields unchanged.

Full game/server restart REQUIRED to avoid already-running PiR injury scripts and handlers from previous mission state. Does not attempt unsafe removal of arbitrary injury/damage event handlers mid-session. Existing native Antistasi unconscious chance/bleedout rules remain; ACE medical, if enabled, still owns medical handling. Arma BIS revive is not separately enabled alongside Antistasi revive.

Changed: functions/Loot/fn_initPiRRescue.sqf, config.cpp (preInit registration/version), mod.cpp version. Existing stim rescue remains compatible with native incapacitation; v3.7 two-per-class/per-life use cap retained.

Packaged directly with FileBank, no config checks, tests or game launch. Multiplayer startup ordering, settings synchronization, actual revive and supplies require in-game acceptance; no claim of verified behavior.
