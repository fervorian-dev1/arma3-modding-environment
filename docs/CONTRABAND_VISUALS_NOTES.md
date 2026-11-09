# Contraband visuals — companion v2.4

Feature history, retained in consolidated v2.5. Current release counts, hashes and publication state: [handoff](HANDOFF.md).

Updated 2026-11-07. User supplied `projects/antistasi_support_services/art/loot/zyn_overlay.jpg`; the original was preserved. A 512x512 JPEG copy is packed as `ui/loot/zyn_overlay.jpg`. This is a format/size conversion of the saved picture, not generated replacement artwork. Native texture loading was verified in Arma. The installed ImageToPAA utility lacked its TextureConvert registry entry, so no system registry changes were made; the addon uses Arma's existing supported JPEG convention instead.

| Item | Visual | Fade-in | Lifetime |
|---|---|---:|---|
| Methamphetamine | Wavy screen distortion (WetDistortion) | 0.2 seconds | 4-minute boost plus 5-minute crash |
| Cocaine | Slight white tint (3.5% overlay opacity) | 0.4 seconds | 5-minute boost plus 5-minute crash |
| Marijuana | Subtle green tint (3.5% overlay opacity) | 90 seconds | 10 minutes |
| Nicotine vape | Pale yellow tint (2.5% overlay opacity) | 2 seconds | 10 minutes |
| Zyn | Supplied image stretched across full screen, 5% opacity | 180 seconds | 45 minutes |

The full-screen picture uses `safezoneXAbs/safezoneWAbs` and picture style48, deliberately stretching instead of preserving aspect ratio. Its maximum opacity is exactly configured as 0.05 (`ctrlSetFade 0.95`), after initially committing full transparency. It does not open a dialog, capture input, or require any separate player action. Post-process effects initialize from neutral values before fading in. Existing marijuana/sickness blur is preserved.

After the user reported immediate monochrome followed by a white wash, all three ColorCorrections tints were replaced with independent full-screen controls in a noninteractive RscTitles layer. Their background colors use explicit low alpha, and each control fades from transparent to its configured opacity with `ctrlSetFade`/`ctrlCommit`. Marijuana is green at 3.5% opacity with a 90-second fade; vape is pale yellow at 2.5% opacity with a 2-second fade. These conservative values need actual-client appearance retesting.

All visuals run only on the affected player's machine. Their wanted-state plan reads the same server-owned expiry ledgers used by the existing gameplay modifiers, including the stimulant crash endpoints. No parallel duration timers or RPCs were added. Each item owns its own effect handle; mixed use composes rather than replacing all other contraband effects. The slow fades are committed once on first local activation, not restarted on each 0.1-second update. Re-dosing follows existing gameplay expiry rules and does not restart a visible fade. Entering a session/retaking control with an active ledger starts the local fade when first observed.

Expiration destroys only the relevant owned handle/title or fades out only that tint control. Existing death, respawn/player replacement and locality cleanup now also clears our visuals; it does not reset other mods' effects or HUD layers. Existing buffs, debuffs, toxicity/overdose, personal money, item descriptions/messages, factions, maps, saves, Fence stock, missions and original supply drops are unchanged. No new dependencies. As a native WetDistortion limitation, the meth distortion cancels underwater; no user video settings are overridden.

## File inventory

Addon root: `projects/antistasi_support_services/addons/dsds_support`.

Created:

- `contraband_visuals.hpp`: five visual profiles, a noninteractive tint overlay layer and the Zyn RscTitles layer.
- `functions/Loot/fn_lootVisualPlan.sqf`: pure expiry-ledger selection, also testable on dedicated server.
- `functions/Loot/fn_lootVisuals.sqf`: owning-player effect/control allocation, fade commits, title recreation and per-item cleanup.
- `ui/loot/zyn_overlay.jpg`: runtime texture derived from the user-saved original.

Modified:

- `config.cpp`: version2.4, two CfgFunctions registrations, include visual config.
- `functions/Loot/fn_lootTick.sqf`: calls visuals from the existing player update.
- `functions/Loot/fn_lootCleanup.sqf`: clears visuals alongside existing modifier cleanup.
- `functions/fn_initServices.sqf` and project `mod.cpp`: release labels.
- `tests/support_services/dsds_expansion.Altis/initServer.sqf`: actual consume-ledger tests for all five lifetimes, both crash phases, mixed items, exact opacity, picture stretching and native texture dimensions.
- Project/root README and `docs/HANDOFF.md`: current release/notes. Built mod README/mod.cpp copied by normal build.

## Verification and testing

CfgConvert passed; the normal fresh-candidate build extracted its own PBO and verified every packed file against source. The original note reported stale release counts. The consolidated v2.5 build has **132 registered functions and165 packed files**; current hash/publication details are in [the handoff](HANDOFF.md). Historical pre-thumbnail build SHA256: `BA05BD85EDBD6FD28E95B25BB33CD9D2183A62AFE71D38AD94E4050B84341076`.

Expansion test RPT: `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_00-43-17.rpt`. **201 PASS, 0 FAIL**, with no SQF expression errors. Native texture, timing/stacking, tint-opacity/fade, Morphine healing and Adrenaline rescue-gate assertions passed. Dedicated tests cannot validate actual rendered visuals or the live client revive path; those remain an in-game acceptance check. No actual-client visual or revive result is claimed.

Restart host/server and every client with `build/@AntistasiSupportServices`; friends need the updated folder. No new campaign. Use the existing Zeus valuables cache for the original consumables and a contraband stash for meth, or add the relevant items using Zeus. Consume one item at a time initially: cocaine/vape should tint promptly, meth should warp promptly, marijuana should gradually become green over 90 seconds, and Zyn should gradually reveal the saved image over three minutes. Verify clearing on death/respawn and after expiration. Do not expect repeated stimulant doses to postpone the existing crash; overdose rules still apply.

API references: [native post-process effects and parameter arrays](https://community.bistudio.com/wiki/Post_Process_Effects), [control fading](https://community.bistudio.com/wiki/ctrlSetFade), [absolute screen coordinates](https://community.bistudio.com/wiki/Arma_3:_GUI_Coordinates). These support the implementation; appearance still requires human testing.
