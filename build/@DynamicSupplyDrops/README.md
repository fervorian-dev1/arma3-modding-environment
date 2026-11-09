# Dynamic Supply Drops for Zeus Enhanced

Version 1.1.0. Native ZEN context-menu integration with server-owned aircraft, DLC-free randomized cargo, parachute descent, and optional Antistasi Ultimate/Plus logistics/arsenal integration. Existing Workshop PBOs are unchanged.

## Install for regular use

1. In the Arma 3 Launcher, choose Mods > Local mod and select `A:\arma3 modding enviroment\build\@DynamicSupplyDrops`.
2. Enable CBA_A3 and Zeus Enhanced. Enable RHS USAF and its normal dependencies to use its C-130. RHS is optional; the default falls back to the vanilla Ghost Hawk when its C-130 class is unavailable.
3. Load this addon on the server and Zeus clients. Loading it on every client is recommended for consistent joining and diagnostics. No new mission objects or mission scripting are required.
4. Enter any mission where you have an assigned Zeus curator. This addon grants no Zeus access by itself.
5. Open Zeus, open the map, point at dry land, and press the configured **ZEN context menu** key (default **V** in the installed ZEN). Select **Dynamic Supply Drops > Spawn Randomized Supply Drop**.
6. Accept the defaults or adjust the six native ZEN dialog fields. Delivery runs silently: there are no call-in, inbound, release, or landing messages. Diagnostics and failure details are written to the server RPT.

The same action is also available in the Zeus modules tree under Dynamic Supply Drops. Place that module at the desired location. Context-menu conditions are independent of selected objects, faction, and mission time.

The local build is unsigned. Servers enforcing addon signatures need it signed with their own accepted key before deployment.

## An already running mission

Arma cannot mount a newly installed PBO into an existing process. For an existing session with CBA and ZEN already loaded:

1. Open `LIVE_BOOTSTRAP.sqf` in this folder and copy its entire contents.
2. In Zeus, place ZEN's **Execute Code** module, paste the code, select **Global and JIP**, and execute it once. Keep the resulting module logic in the mission so ZEN retains its JIP execution. The server and Zeus clients must receive it. This needs the mission/server's existing permission to use ZEN Execute Code.
3. Use the context menu as above. No mission restart is needed. The bundle contains the same functions as the addon, without reading any new files on remote machines.

Bootstrap initialization is idempotent: re-execution does not add duplicate menus or event handlers. **Global** also works for currently connected machines, but requires re-execution for later joiners without the addon. **Global and JIP** covers late joiners while its module logic remains. The bootstrap does not install itself for future missions; use the addon for future sessions. The build script regenerates the bundle from source.

For an active-session upgrade from 1.0, remove the old Execute Code/JIP bootstrap module before running the new bundle, so future joiners receive only the new version. Old loot caches and notification handlers are cleared automatically. Existing crate contents are preserved. To use the updated PBO normally, reload Arma and the server with the same local mod folder enabled.

## Defaults and limits

| Option | Default | Limits |
| --- | --- | --- |
| Crate | `B_supplyCrate_F` | Existing `ReammoBox_F` descendant with capacity |
| Aircraft | `RHS_C130J` when loaded, otherwise `B_Heli_Transport_01_F` | Existing crewed aircraft with valid configured pilot |
| Unique cargo selections | 50 | 20-100; includes ammunition selections |
| Altitude | 300 m AGL | 150-1000 m |
| Approach | 4000 m | 2000-8000 m; must fit inside terrain |
| Green smoke on landing | Enabled | On/off |

Quantity is one per weapon/equipment selection, with 2-4 for initial grenades, medical supplies, and unrelated ammunition selections. **Every distinct weapon gets at least five compatible primary-muzzle ballistic magazines.** Shared ammunition allowances accumulate: two different weapons allocated the same magazine class receive at least ten magazines in total. Magazine quantities can therefore exceed four; other items retain the previous small quantities. The unique-selection slider counts classnames, not physical units.

Every available category is represented first, followed by random additions without repeated classnames. The server discovers loaded gear at runtime, caches its pools, and remembers manifest signatures so an identical manifest is not delivered twice in the same mission. A tiny gear pool may supply fewer unique selections than requested; failure to generate a new manifest aborts the drop.

Official DLC assets are excluded from every gear category and matching ammunition, even if the server or Zeus owns that DLC. The filter checks the class's DLC tag/registered app ID, class entitlement information, and underlying model. This also excludes official DLC reskins that reuse a base-game model. Free mod equipment such as RHS remains eligible. These changes apply to newly generated drops; existing crates are not stripped of their gear.

Freely usable platform-update variants that the installed game identifies as base Arma 3, with no DLC tag or entitlement, remain eligible. A khaki colour alone does not establish a DLC requirement; ownership/access metadata governs the filter.

## Antistasi Ultimate / Plus transport and HQ collection

The unchanged adapter supports the installed **Antistasi Ultimate 12.0.3** and **Plus 2.3.2** APIs and activates only in an initialized Antistasi mission. It adds Antistasi's normal **Load cargo** action after the crate lands. The default `B_supplyCrate_F` already has a native logistics definition and occupies **two slots**, so use a truck with at least two available cargo slots and unoccupied required seats. Custom crates need their own existing Antistasi logistics definition; this addon does not alter truck or cargo configurations.

Drive the crate within **20 metres of the current HQ arsenal box**, then stop. Within about five seconds the adapter transfers its actual inventory through Antistasi's native JNA cargo-to-arsenal function and runs its normal arsenal management. The crate can remain loaded in the truck, or you can unload it normally before collection. Vehicles moving faster than 1 km/h, loading/unloading operations, locked native inventory transfers, and crates more than six metres above/below the arsenal are deferred.

The **empty crate stays in its truck slot** so the game's cargo, seat and mass bookkeeping stays intact. Unload it normally when you want the slots back. Collection happens once per drop; reuse of an emptied crate follows Antistasi's normal manual transfer workflow. Cargo amounts are stored in the arsenal for loadouts and count toward the mission's existing unlock thresholds. The adapter does not grant unlimited equipment or change those thresholds. Use Antistasi's normal campaign save to persist recovered inventory; airborne/field crates are not given a new cross-session persistence system.

The feature has no Antistasi hard dependency. Other missions still get silent DLC-free drops. Other Antistasi forks are not guaranteed compatible; native APIs and initialized HQ/arsenal state must exist. No campaign saves or installed Antistasi files are modified by the addon.

## Locality and lifecycle

Menus/dialogs run on Zeus clients. CBA server events send requests to the server, which validates the assigned player curator, position, classes, ranges, cooldown and four-delivery concurrency limit. Server-created AI, crate, parachute, and smoke are globally visible. Cargo uses Global commands. Delivery notifications stay in the server RPT; the legacy client notification handler is removed on upgrade. CBA is already required by ZEN; no extra networking library or changes to mission CfgRemoteExec are needed.

The CBA event channel is intended for trusted cooperative missions; it is not an anti-cheat authentication boundary. A modified client can forge event payloads. Normal requests must name a player with an assigned curator, but the event API does not independently authenticate the transport sender.

Transport flies through an inbound waypoint and then toward an egress waypoint beyond the target. Cargo releases only when the actual aircraft reaches a 180 m corridor, not by teleporting the crate to the click. Wind and forward motion can move the landing point. Choose an open, flat field away from water, trees and buildings. This version does not guide the parachute or clear terrain objects. AI flights may fail in mountains, combat, heavy server load, or with unusual aircraft mods; failure is logged and temporary delivery objects are removed.

The parachute is removed on landing. Green smoke is removed within 120 seconds. The aircraft flies away and is removed after at least 90 seconds once over 3.5 km away, with a seven-minute upper cleanup bound. Destroyed aircraft are retained at least two minutes. Player-occupied transport is exempt from deletion. Landed crates persist for the mission or until Zeus/mission cleanup removes them. New Zeus assignments after landing may need the mission's normal Add Editable Objects operation to edit an older crate.

The initial crate is protected from damage during descent, then normal damage is restored. Small custom crates may have impractical cargo volume; choose a full-sized supply crate for the default load. Client/server mod lists should match. The aircraft and optional smoke remain visible/audible; turn smoke off in the existing dialog if desired.

## Build and tests

```powershell
.\scripts\Build-SupplyDrops.ps1
.\scripts\Test-SupplyDropsServer.ps1
```

Run from the workspace root. The second command starts a hidden loopback-only dedicated server on port 24322 and copies the included automated validation mission into the game's MPMissions directory. That mission is a development test only; the gameplay addon requires no custom mission. RPT output goes to `logs\supply-validation`. Stop the test server after use and remove only its `dsd_validation.VR` test copy.

Use `-ReuseTestMission` to refresh a previous test copy after stopping its server. Use `-LiveBootstrap` to run without the addon and initialize from the self-contained bundle instead (port 24324, `logs\supply-live-validation`, test mission `dsd_live_validation.VR`). This verifies server-side initialization after mission start, not the remote Zeus UI interaction.

Add `-Antistasi -Edition Ultimate` to exercise actual native truck loading/unloading and JNA transfers in an isolated test HQ. Ultimate is the default edition; `-Edition Plus` selects the previous fork. The test does not load or change your campaign save. For a gameplay acceptance test, collect a drop with a two-slot-capable truck, stop within 20 m of your HQ arsenal, verify its gear in the loadout system, then unload the empty crate. The Ultimate port passed 98 supply/logistics checks without changing this PBO; see [port notes](../../docs/ULTIMATE_PORT_NOTES.md).

Development notes, exact file inventory, test results and remaining verification are in `docs/SUPPLY_DROPS_NOTES.md` in the workspace root.
