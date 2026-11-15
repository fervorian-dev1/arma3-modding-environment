# Casino update 5.4 — 2026-11-15

## Behavior

- Fixed the floating hall: native `Land_Hangar_F` is grounded with `setPosATL [x,y,0]`. Its bounding-box minimum is -7.34637m; adding that offset was the cause of the roughly seven-metre lift.
- HQ **Place / move casino** now offers **Find suitable location**. Click a search area first, or search near HQ. The search is read-only and authorized by the existing short-lived placement token; choosing a suggestion does not charge/place anything. Review the map and press **Place casino**.
- Replaced the old broad 80m flatness exclusion with an oriented plot: 40m wide, 72m long, centered 6m toward the front of the hall. Allows up to 8m total relief. Server grades a local level pad with an 8m blended boundary; hides trees/bushes inside the plot. Water, structures, rocks, roads and vehicles are protected blockers. It does not delete map objects or change faction ownership.
- Moving/packing restores original terrain and plants. Terrain cells subsequently altered by another system are left alone. Original/applied terrain grids persist in casino schema 3; schemas 1/2 still load. Hidden terrain objects are rediscovered each session rather than serializing handles. Plot grading is global/JIP through native `setTerrainHeight`; full multi-human/JIP validation remains outstanding.
- Grounded exterior decoration: `Land_Statue_03_F` (**Woman Statue**, verified native asset), two `Land_FlowerPot_01_F`, two `Land_Bench_F`. No interior furniture. Removed with casino; prize collection crate retains earlier cargo/moving behavior.
- Dealers now use the native **Gendarmerie** body (`B_GEN_Soldier_F`), stripped to its configured underwear, and existing Timberwolf female heads. Native naked uniform is `U_BasicBody`; no separately named equippable 'Underwear (Gendarmerie)' uniform exists in the tested configuration. No invented class or additional dependency. Dealer respawn logic unchanged.
- Roxie: 'Kill one of my ex-boyfriends and I might slip you a wheel token as a thank-you.' No token probability disclosed in her dialogue; actual kill/drop logic unchanged.
- Roulette: transparent generated PAA wheel/ball/chip, European pocket order, clickable 0–36/outside/dozen/column betting table. One selected bet per spin, existing stake limits/payouts unchanged. Eight-second server spin followed by client-only easing/ball landing. Winning pocket is published only after settlement, and final ball alignment matches that pocket. No client financial authority.
- Lucky Wheel: existing weighted wheel graphic now spins, decelerates and settles on its actual weighted reward sector; seven-second server spin, about 2.5s client finish. Aspect-correct wheel rendering. No reward-weight or money change.
- These are 2D in-game graphical interfaces, not physical 3D roulette furniture. No code/assets copied from Gamble With Your Friends.

## Files for this update

New Casino functions: `casinoSitePlan`, `casinoPrepareSite`, `casinoRestoreSite`, `casinoFindSite`, `rouletteVisual`, `luckyVisual`.
Changed Casino functions: `casinoSpawn`, `casinoSpawnDealer`, `casinoClear`, `casinoValidateSite`, `casinoSave`, `casinoLoad`, `casinoRequest`, `casinoClient`, `casinoUI`, `casinoSnapshot`, `casinoRoulette`, `luckyRequest`, `luckyUI`.
Configuration/art: `config.cpp`, `casino.hpp`, `lucky.hpp`, project `mod.cpp`; three new `ui/roulette_*_ca.paa` sprites. Repeatable native drawing/conversion helper `scripts/Build-CasinoVisualArt.ps1`.
Validation: `scripts/Test-Casino54Client.ps1`, `scripts/Test-Casino54Terrain.ps1`, fixtures `tests/support_services/dsds_casino54.VR` and `.Altis`. Casino asset probe updated to inspect installed body configuration. Documentation/root/project/build README, handoff, default player-package version, compiled PBO/mod metadata.
Prior uncommitted 5.3 hotfixes are preserved; see HOTFIX_53_NOTES.md for their separate file scope.

## Verification

Final player-client workflow: **20 passed, 0 failed**, covering search RPC/UI, sloped placement, grounded models, roulette bet/debit/spin/pocket alignment, Lucky Wheel reward alignment and full packing cleanup. No SQF expression errors in the final client run. Native CfgConvert and fresh PBO extraction/source-hash verification passed on staged addon (238 registered function files).
Real Altis forest/hillside server test: **6 passed, 0 failed** (placement, grounding, clearing, complete tree/terrain restoration, protected vehicle rejection). VR player workflow initial 19/1: the one failure was a synthetic terrain test's coordinate rounding expectation; corrected to compare native pre/post measurements, with no terrain implementation change.

## Updating/testing your campaign

Restart host/server and every client with the updated local companion. Load the existing campaign, then use HQ **Place / move casino ? Find suitable location ? Place casino** if relocating it. Existing hall positions are reconstructed at ground level after loading. Save campaign normally. No campaign/save files manually edited for 5.4. GitHub is not published by this task; latest public release remains 5.2 until requested.

Full multiplayer/JIP, subjective appearance on Green Sea and every terrain/mod combination remain unverified. Very steep land or protected structures still require another plot; search cannot guarantee a buildable location everywhere.
