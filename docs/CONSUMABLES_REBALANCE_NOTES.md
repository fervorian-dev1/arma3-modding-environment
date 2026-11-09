# Death money, simple consumables and overdose — v1.9

**Historical v1.9 baseline. Current v2.0 adds meth/injectors, raises gold to3,200 and expands missions/trading: [current notes](SMUGGLING_EXPANSION_NOTES.md). Death-money protection, Zyn and the original drug behavior remain.**

2026-11-07. User accepted fitting gameplay buffs/debuffs instead of precise ADS/reload changes, then requested no personal-money loss on death, flavor-only item descriptions, short private notifications after consumption, unchanged Zyn with exact wording **"You feel stronger."**, and overdose from rapid narcotic use. This supersedes the v1.8 effect-balance/remaining-ADS-work discussion in LOOT_CONSUMABLES_NOTES.md; artwork, item classes, values and distribution remain.

## Personal money on death

Installed Ultimate 12.0.3 and Plus 2.3.2 both read `deathPenalty` in their native `A3A_fnc_onPlayerRespawn` money calculation:

```sqf
_moneyX = _oldUnit getVariable ["moneyX",0];
_moneyX = round (_moneyX - (_moneyX * (deathPenalty / 100)));
```

The companion now enforces **deathPenalty=0** on server and clients. Initialization, incoming-public-variable handling, a local EntityRespawned mission handler and a one-second recheck cover parameter initialization/load/JIP and respawn timing. A per-mission guard prevents duplicate handlers. The server republishes only when the value needed changing. Old saved setup parameters may still display a previous percentage; runtime enforcement takes precedence while this addon is enabled.

No wallet snapshots/refunds or money minting: actual spending, income, transfer, purchases and transaction authentication remain unchanged. No alteration to faction funds, HR, score, other death penalties, territory, relationships or native respawn scripts. No campaign reset or direct save edit. Ordinary native save behavior continues. Disable the addon if you later want the campaign's selected death-money penalty to apply again.

## Current balance (developer notes, not item descriptions)

| Item | Duration | Gameplay effects | Private consumption text |
|---|---|---|---|
| Marijuana | 10 minutes | Sway -25%; movement animation speed -10%; available max stamina -10%; mild blur | You feel calm, but sluggish. |
| Nicotine Vape | 10 minutes | Sway -5%; observed vanilla stamina recovery +15%; available max stamina -10%; no movement bonus | You feel a little more focused. |
| Cocaine | 5-minute boost | Sprint animation speed +15%; observed vanilla recovery +25%; sway +15% (jitters) | You feel wired and restless. |
| Cocaine crash | Following 5 minutes | Movement -15%; sway +35%; available max stamina -30%; recovery -20% | You feel drained and shaky. |
| Zyn Nicotine Pouches | 45 minutes | Unchanged: worn-container capacity +30%, equivalent effective carrying allowance through loadCoef / 1.3 | You feel stronger. |
| Gold Bullion | None | Unchanged: nonconsumable, heavy (275 mass, approximately 12.5 kg) | None |

Values remain Marijuana300, Vape150, Cocaine800, Zyn200, Gold2500. Existing thumbnails and exact classnames remain, so stored loot still resolves. Gold has no consumption action. Descriptions contain flavor only: no percentages, timers, technical explanations or sale prices. Consumption messages are sent privately to the consuming player only **after server-confirmed removal**. Warning/overdose text replaces the ordinary message when applicable. Crash text is shown once on transition into the crash; it is not repeated every tick.

The former cocaine damage resistance/HandleDamage implementation was **removed completely**, allowing the same gameplay balance with PiR/ACE present. No native injury handler is added/replaced. No artificial ADS/reload manipulation is attempted or promised. Stamina-disabled missions stay stamina-disabled; exact native stamina benefits remain subject to custom fatigue systems. Zyn still cannot change Arma's global absolute soldier ceiling. These fictional balance choices are not real-world physiological claims.

Repeated marijuana/vape/Zyn refresh their own effects without multiplying bonuses. Cocaine **can now be taken again during its current boost/crash**, but doing so does not extend or postpone either timer; every confirmed dose still counts toward toxicity. Multiple regeneration boosts use the stronger boost, then crash penalties multiply it. Movement penalties take precedence over the cocaine sprint boost when cannabis or sickness is active.

## Overdose rules

Only server-confirmed narcotic consumption records a dose on the current body. This version's narcotics are Marijuana and Cocaine; Vape and Zyn do not contribute, preserving the requested Zyn behavior.

- Rolling window: **180 seconds**. Doses at or beyond the window's boundary expire.
- Cocaine contributes **3 toxicity points**, marijuana **1**.
- Pure cannabis: **3 or more doses within the window** causes **120 seconds of nonfatal sickness**. Additional use refreshes sickness, never makes cannabis-only overdose fatal. Sickness gives heavy blur, movement multiplier0.65, sway multiplier1.6, available max-stamina multiplier0.4.
- If recent cocaine is present, **6 points** produces: **"Your heart is racing. You should stop."** Two rapid cocaine doses therefore warn.
- With recent cocaine present, **9 points** produces a **fatal overdose after ten seconds**: **"You took too much. Something is very wrong."** Three cocaine doses within three minutes meet this threshold; mixed narcotics contribute too (for example, two cocaine plus three cannabis doses).
- Pending fatal overdose cannot be postponed by redosing. Further consumption requests are rejected while it is pending. There is no antidote/rescue treatment in this version. The server applies `setDamage 1` once at the deadline; this is intended to be an actual death, including with alternate medical mods, and does not replace their ordinary injury handling.
- Death clears toxicity/overdose state; a new respawn body starts clean. Nonfatal sickness expires and restores coefficients normally. Server watchdog is polled once per second, so the fatal deadline may be applied up to roughly one tick later.

Settings live in `DSDS_Consumables`. This is a simple deterministic gameplay system, not a probability simulation or realistic dosing model. Future narcotic items require explicit dose registration in `lootDose` plus their consumption/effect mapping; there is no automatic classification of arbitrary Workshop inventory items.

## Files

New:

- `functions/fn_applyDeathMoney.sqf`: narrow native-setting enforcement, no balance writes.
- `functions/fn_initDeathMoney.sqf`: guarded all-machine initialization/PV/respawn hooks and recheck.
- `functions/Loot/fn_lootDose.sqf`: private server rolling-dose ledger and warning/sickness/fatal scheduling.
- `functions/Loot/fn_lootOverdoseTick.sqf`: private server overdose expiry/death cleanup and fatal deadline.

Modified under `projects/antistasi_support_services/addons/dsds_support/`:

- `config.cpp`: v1.9, four registrations minus retired damage helper (75 total functions), revised effect settings and private text.
- `loot.hpp`: all five descriptions simplified; item classnames/weights/prices/art unchanged.
- `functions/Loot/fn_lootCommit.sqf`: confirmed-use messages, dose recording, redose timing rule.
- `functions/Loot/fn_lootRequest.sqf`: permit cocaine redose; reject consumption during pending fatal overdose.
- `functions/Loot/fn_lootModifiers.sqf`: revised trade-offs/combinations.
- `functions/Loot/fn_lootTick.sqf`: sickness effects, once-only crash message, adjustable blur strength, no medical handler.
- `functions/Loot/fn_initLoot.sqf`: server overdose watchdog and body/disconnect cleanup.
- `functions/fn_initServices.sqf`: version log only.

Removed: `functions/Loot/fn_lootDamage.sqf` and its function registration; it only implemented the retired resistance buff. Legacy handle cleanup remains harmless for local states that might already have owned a damage handler.

Other updated files: project `mod.cpp`, root/project READMEs, `docs/HANDOFF.md`, historical-loot-notes supersession banner, this notes file, `tests/support_services/dsds_loot.VR/initServer.sqf`. Existing Fence/support/raid/DSD functions and Workshop originals were not modified. Build output contains 84 source-matched files.

## Testing and update status

Build helper staged and verified the candidate but Windows initially blocked publication because the user's running game held the old PBO open. User explicitly replied **"Game is closed"**; publication then succeeded through the existing helper. No user process was terminated. Every client/server must receive the updated companion and restart Arma. Original DSD is unchanged; no new save is needed.

**Final: 198 checks passed, zero failures/SQF errors** — 99 on Ultimate12.0.3 and99 on Plus2.3.2, in separate processes with one Antistasi edition loaded at a time.

- Ultimate: `logs/loot-validation-ultimate/arma3server_x64_2026-11-07_15-15-10.rpt`.
- Plus: `logs/loot-validation-plus/arma3server_x64_2026-11-07_15-16-42.rpt`.
- Native money calculation is read directly from each installed edition's PBO at runtime and executed with deathPenalty0 for balances0,137,10000; each retained the exact amount. A real50-credit debit remained spent after applying death protection. Reinitialization did not duplicate the respawn handler.
- All item/thumbnail/value/cargo/Fence-sale safeguards reran, including real3950-credit quote/sale/removal and duplicate-sale rejection. Updated stamina/aim/movement/crash calculations and actual sprint coefficient passed; Zyn capacity/duration/external-change preservation remained valid. Exact Zyn message and flavor-only item descriptions checked from loaded config.
- Overdose checks: one cocaine dose safe, second warns, third schedules death; further dose cannot postpone it; test body survives before deadline then actually dies at the deadline; death clears records. Old doses expire; pure cannabis produces temporary movement/aim sickness and recovers; vape/Zyn do not add narcotic doses; mixed use crosses threshold.
- An initial fixture printed three SQF errors because it declared `private _moneyX` instead of initializing a private variable when extracting the native formula. Fixed **fixture only** to `private _moneyX=0`; final logs above have zero SQF errors. Intermediate99-pass runs with that fixture error are not counted as clean validation.
- CfgConvert config validation passed. All75 functions registered; all84 packed files match source hashes. Published PBO SHA256: **`53F560F8B9542B20F354E97D6A46F81ACEA1975BA1D99411765197D87637D70A`**. Original DSD still **`F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`**.
- Overdose/effect boundary tests inject timestamps rather than waiting for complete180-second/45-minute periods. Actual server damage, containers and body coefficients execute in Arma. There is no claim that a dedicated AI fixture establishes actual human client input/notification/blur/JIP or full respawn callback ordering. The native formula is tested, not the entire human respawn procedure.
- **Human acceptance:** confirm funds before/after a real player death, short private consumption/crash/warning messages, actual blur/feel, two-client consumption, respawn/JIP and full PiR/ACE/mod-stack behavior. Full unrelated services/raid/flight regressions were not repeated for this narrow revision; earlier records remain historical evidence.

Owned test servers stopped after exact PID/name/profile/port checks; copied dsds_loot.VR fixture removed after explicit file/path/marker verification. Source fixture and logs remain. No user process or campaign save was altered.

References: installed read-only native `reference/{ultimate,antistasi}/core/functions/proxy/fn_onplayerrespawn.sqf`; [official mission event handler documentation](https://community.bistudio.com/wiki/Arma_3%3A_Mission_Event_Handlers); [official multiplayer command locality examples](https://community.bistudio.com/wiki/Multiplayer_Scripting) document that server-side `setDamage 1` also kills a remotely owned unit. No remote damage effect is delegated to an untrusted client request.
