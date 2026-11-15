# Casino and fiber-optic drones — v5.0

## Player use

Enable Task Force Timberwolf Female Characters (Workshop 2021778690) and KVN Fiber-Optic FPV Drone (3533734689), alongside the existing mod setup. All players and the server need the matching companion update; restart Arma after installing it.

At the HQ flag, choose **Buy casino (100,000 credits)**. This uses the buyer's personal money. Select a map location and heading, then place it. Placement is unrestricted by HQ distance, but needs a clear, flat, dry site roughly 30 metres across, away from people, vehicles, trees and other buildings. Canceling or invalid placement costs nothing. Only one faction casino is supported initially.

The **Aurum Casino** is a furnished white hotel, marked on the map. Approach a dealer and select Play. Stakes range from 100 to 10,000 personal credits. The five dealers are Vivienne (Blackjack), Celeste (Roulette), Sable (Crash), Marina (Craps), and Iris (Baccarat).

The installed Timberwolf addon provides female **heads**, not female bodies or dealer uniforms. Dealers use its verified Carter/Medrano heads on unarmed civilian bodies. There are four supplied face variants and five distinct named dealers. The white hotel and furniture use existing Arma assets; no third-party model files are bundled.

## Rules

- Blackjack: six-deck shoe, natural 3:2, dealer stands on soft 17, Hit/Stand/Double. No split or insurance. Closing stands the hand.
- European roulette: single zero, straight numbers and standard outside bets. Profits are 35:1 straight, 2:1 dozen/column, 1:1 even-money; zero loses outside bets.
- Crash: server-controlled hidden crash point, increasing multiplier, cash-out button. Closing attempts cash-out at the authoritative server multiplier; death, distance and timeout forfeit. Maximum 100x, approximately 3% house edge.
- Craps: pass-line betting with standard come-out and point rules. Closing completes the rolls automatically.
- Baccarat: standard punto banco third-card rules. Player 1:1, Banker 0.95:1, Tie 8:1; ties push Player/Banker bets. Returns displayed include the original stake; fractional credits round down.

Each player has an independent round. Dealers are shared, but this first version does not synchronize a multiplayer table round or offer player-to-player gambling. Games use a dedicated black/gold/green dialog; cards and dice are represented in that dialog rather than animated physical props.

## Architecture and safeguards

`addons/dsds_support/casino.hpp` defines building choices, purchase/stake limits, the extensible game/dealer registry, and dialogs. `functions/Casino/` contains separate game engines, dealer/building creation, placement validation, client UI, server requests, native campaign persistence, wallet crediting and the bounded update worker. CfgFunctions and two restricted RPCs are registered in config.cpp. Further games can add a handler and registry entry without replacing existing games.

The server authenticates the caller, faction, proximity, class, stake, choice and balance. Single-use bet tokens plus round/revision checks reject duplicate requests. Clients do not receive the hidden deck, Blackjack hole card or Crash point. Settlement marks a round before crediting, preventing duplicate payouts. Offline/dead-player winnings queue by UID. Interrupted stakes and interrupted construction charges are refunded once on reload.

The casino's building, location, heading, queued credits and active-stake escrow use Antistasi's native saved-stat API under `DSDS_casinoState`. **Save the campaign normally** to write that state to disk. Loading recreates the building, furnishings and staff, without purchasing again. A killed dealer is replaced after five minutes in the original role; the building/furniture are protected from damage. No faction, terrain, road, HQ, existing mission or save-file data is rewritten.

Gamble With Your Friends is installed as a separate Unity game. No code or assets were copied from it; these are independent SQF implementations of standard casino rules.

## Fence fiber-optic inventory

The installed KVN config and deployment function were inspected directly. `fn_fenceCatalogue.sqf` registers the four `Item_KVN_AT/AP/AT_TI/AP_TI` magazine kits and matching faction backpack variants under a new FIBER role, only when the native deployment function is loaded. `fn_fenceBuildStock.sqf` reserves one of the existing ten item offers for FIBER, while retaining ordinary FPV, UAV, controller and AA roles. `fn_fencePrice.sqf` supplies its base price (4,000, then the existing stock pricing multiplier).

The kits use the mod's native deployment and UAV controls. Existing stock refreshes naturally; this update does not forcibly replace a campaign's already displayed stock. Fence's custom-valuables-only buyback restrictions remain unchanged.

## Files

Created: casino.hpp and all functions under functions/Casino; Test-CasinoAssets.ps1, Test-CasinoServer.ps1, Test-CasinoClient.ps1; corresponding three isolated VR test missions; this note.

Modified: addon config.cpp; Fence catalogue, stock and price functions; project mod.cpp/README; root README and docs/HANDOFF.md. The companion build is regenerated. Dynamic Supply Drops remains v1.2 and its source is unchanged.

## Validation

Official CfgConvert validation and FileBank/BankRev source-versus-PBO verification passed for the staged build (211 functions). Installed-engine asset inspection verified the selected hotel, furniture, female faces and native KVN classes.

Latest isolated dedicated test: **55 passed, 0 failed**, including game rules, 1,500 roulette outcomes, 800 Craps rounds, payout-once, escrow refund-once, native saved placement, actual five-dealer creation, dealer replacement, above-ground positions and guaranteed Fence fiber stock. Log: `logs/casino-server-ultimate/arma3server_x64_2026-11-15_07-38-57.rpt`.

Actual isolated player-client workflow: **25 passed, 0 failed**, covering HQ purchase/map placement, all five dialogs and game resolution, exact personal-wallet accounting, duplicate bet/action rejection, hidden Blackjack card, native saved record and casino/staff recreation without a second charge. Initial fixture failures were caused by standing outside the flag range; corrected and rerun. Full multi-human/network latency/JIP and a real campaign disk-save/restart have not been independently played through. The native save record and restoration path are exercised in isolated fixtures, not by modifying the user's campaign.

