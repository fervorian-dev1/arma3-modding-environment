# Mystic Industrial Isotopes stash - v2.9

Updated 2026-11-08. User requested reusing Fence's contraband-stash mission with Industrial Isotopes loot and changing as little else as possible.

## Behavior

Mystic's existing menu now has **Source Industrial Isotopes stash**. Speak to him in person/on foot, as for his other actions. The lead is free, like Fence's existing stash lead. It queues the exact existing scheduled stash worker through the existing authenticated request/mission dispatcher. A real **Industrial Isotopes Stash** task and orange map marker identify the location.

Retained unchanged: roadside search distances and terrain safety checks, environment-matching rubbish/sacks/pallet containers, current occupying-faction infantry, three procedurally named guard squads, twelve-to-eighteen guards with0.85 intended skill, patrol behavior, task completion when guards are cleared, failure on container destruction, normal cleanup and45-minute cooldown. Fence's original fifteen seeded plus fifteen randomized drug items remain unchanged.

Only the new variant's cargo is replaced: **10 Shielded Industrial Isotopes**, with no drug/valuables filler. The count respects the existing1500-mass container and150-mass isotope consignments; it is capped at the original30-item total if container/item capacities ever differ. No container class/capacity alteration. Items retain existing Fence sale value and Mystic offering behavior; requesting/clearing the mission itself grants no money or isotope-progress credit.

Both vendors deliberately share the **existing single active stash and45-minute cooldown**. An active stash is re-marked/referenced rather than duplicated; clearing one does not bypass its cooldown. Mission persistence is unchanged from Fence (session mission state, not a new campaign mission-save system).

The existing automatic Zeus registry also exposes **Modules -> DEBUG -> Start Industrial Isotopes Stash**, with no settings dialog. It uses the same worker/variant. Player-facing mission text does not say DEBUG. Like the existing debug stash starter, this bypasses the normal cooldown/uses the module position's nearby roads for developer testing; it still does not duplicate an active stash.

No nuclear/chemical blast hooks, reinforcement changes, new dependencies, faction/map edits, prices, medicinal changes or reward rebalancing.

## Minimal source changes

Under `projects/antistasi_support_services/addons/dsds_support/`:

- `mystic.hpp`: one button in the existing dialog.
- `functions/Mystic/fn_mysticTransaction.sqf`: one authenticated STASH branch after existing vendor proximity/UID checks.
- `debug.hpp`: `ISOTOPE_STASH` entry pointing to **the same** `DSDS_fnc_requestContrabandStash`, variant `INDUSTRIAL`.
- `functions/Debug/fn_queueCustomMission.sqf`: allow the new stash kind through the same pending lock/non-debug gate; do not count it as a convoy.
- `functions/Debug/fn_initCustomMissions.sqf`: existing failed-worker unlock also recognizes the isotope variant.
- `functions/Smuggling/fn_requestContrabandStash.sqf`: optional fourth variant defaults to original STASH; select isotope cargo and mission text only. Shared placement/guards/task/cooldown path is reused, not copied.
- `functions/Smuggling/fn_initSmuggling.sqf`: completion marker uses the stored stash title, with original Contraband Stash fallback.
- `config.cpp`, `functions/fn_initServices.sqf`, project `mod.cpp`: version2.9 metadata only. Function count remains164, packed-file count200.
- Project/root README and handoff updated. No Workshop or original supply-drop addon change.

Test-only additions: `scripts/Test-MysticStash.ps1`, `tests/support_services/dsds_mystic_stash.Altis/{mission.sqm,description.ext,initServer.sqf}`.

## Validation

Focused dedicated Ultimate test: **20 PASS/0 FAIL**, `logs/mystic-stash-validation-ultimate/arma3server_x64_2026-11-08_05-39-30.rpt`. Tests the actual Mystic private transaction -> real queue -> real scheduled worker, proximity and duplicate rejection, task/marker, ten valid isotope-only items within capacity, retained faction/squad skill/names, zero charge, shared pending/cooldown/active state, real guard-clear completion, and a subsequent original Fence stash with all30 original contraband items.

Broader dedicated Ultimate regression: **208 PASS/0 FAIL**, `logs/expansion-validation-ultimate/arma3server_x64_2026-11-08_05-39-30.rpt`. Both final logs contain zero SQF expression errors. Baseline extraction confirms exactly the nine intended addon files differ from published v2.8; the other191 packed files (including all injector/nuclear functions) are byte-identical. Publication hash is added below. CfgConvert validates config, all164 functions are registered, changed SQF/config delimiters reviewed, and the build helper extracts and hash-compares all200 source files against the PBO.

Dedicated engine verification does not visually render the new button or replace remote-human multiplayer acceptance. The action follows the existing Mystic request authorization and UI conventions. Restart host/server and every client with the updated full companion folder; no campaign reset. To check: visit Mystic, press **Source Industrial Isotopes stash**, follow the map task, defeat the original guard force and loot the same disguised container. Keep the normal45-minute shared cooldown in mind when returning to either vendor.

## Publication

Published standard **v2.9** in `build/@AntistasiSupportServices`, **164 functions /200 packed files**, config and full extraction/hash comparison passed. Companion PBO SHA256 **EA75585F170312BF3D399AE55B452B2381CDABCC21AEB9545CC7DE22A6338A6E**. Original supply-drop PBO unchanged: **F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6**. Owned localhost test processes and verified copied Mystic-stash/expansion fixtures were cleaned; source fixtures/logs retained. No normal user game stopped, campaign reset, Workshop edit or Git commit. Friends need the whole updated companion folder.
