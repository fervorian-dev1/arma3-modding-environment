# Arma 3 modding workspace

This workspace contains editable projects, local build output, and setup notes. Original game and Workshop files are kept outside the workspace.

**Start here:** [current status and complete handoff](docs/HANDOFF.md). It records current builds, completed features, user decisions, test evidence, limitations and sharing instructions.

- projects/: editable addon source; one directory per project.
- reference/: local copies or extracted reference material (ignored by Git).
- build/@DynamicSupplyDrops/ and build/@AntistasiSupportServices/: current, ready-to-use mod folders (tracked by Git).
- Other build/: generated packages and temporary outputs (ignored by Git).
- logs/: test profiles and logs (ignored by Git).
- temp/: disposable working files (ignored by Git).
- scripts/: repeatable local build helpers.

Current companion: **v4.7**, with Dynamic Supply Drops **v1.2**. Includes expanded Zeus DEBUG tools, Mystic persistence, civilian vehicle discounts, updated loot and friendly parachute travel (150 m enemy exclusion). See [handoff notes](docs/HANDOFF.md).


## Download and play

Download the ready-to-play ZIP from [GitHub Releases](https://github.com/fervorian-dev1/arma3-modding-environment/releases/latest). Extract it, then add both **@DynamicSupplyDrops** and **@AntistasiSupportServices** through **Arma 3 Launcher > Mods > Local mod**. Select each folder, not its PBO file. Everyone needs the same custom-mod version and the host's Steam Workshop mod list. The source-code ZIP alone is not an installed mod.

The player package contains both compiled custom addons, installation instructions and PBO checksums. It does not redistribute Arma or third-party Workshop content. Host/server and all clients must restart after updating; no campaign reset is needed.

## Build a player download

Build the two addons with their project scripts, then run `scripts/Build-GitHubDownload.ps1`. The versioned player ZIP is written to `build/releases/` and published on GitHub Releases. The current ready-to-use mod folders are also tracked in Git; temporary build output, test profiles/logs, local reference extracts and signing keys are excluded.
## Verify the environment

From this directory in PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-Environment.ps1
```

Add `-Launch` to start Arma 3 with the sample addon and a separate log/profile directory under logs/smoke-profile. Steam must be available. This section describes the initial tooling sample, which registers env_smoke and adds no gameplay content. Later gameplay/runtime verification is recorded in the handoff and project notes.

The sample uses CfgConvert to validate its config and FileBank to pack a PBO, then BankRev to inspect the archive. It does not validate SQF runtime behavior or provide a binarization pipeline for models and textures. Those build requirements will be established for the selected mod.

## Workflow

Choose the target mod and requested change. Prefer its original source when available. Keep reference copies separate, edit source under projects/, build into build/, and test locally. Preserve dependencies and inspect the game's RPT logs. Keep changes in Git. Do not edit Steam Workshop files directly: Steam updates can replace them.

See docs/ENVIRONMENT.md for discovered paths and verification details.

## Dynamic Supply Drops

The first gameplay addon is built and user-confirmed working. See [its instructions](projects/dynamic_supply_drops/README.md) and [development notes](docs/SUPPLY_DROPS_NOTES.md). Build with `scripts/Build-SupplyDrops.ps1`; generated mod output is under `build/@DynamicSupplyDrops`.

## Antistasi Support Services

The companion adds Petros's Support Terminal and persistent PMC vehicle dealer. See [installation and testing](projects/antistasi_support_services/README.md) and [development notes](docs/ANTISTASI_SUPPORT_SERVICES_NOTES.md). Build with `scripts/Build-SupportServices.ps1`; enable `build/@AntistasiSupportServices` alongside the existing supply-drop addon.

**Current target: Antistasi Ultimate 12.0.3, fresh campaign.** The v1.6 port introduced support for Ultimate and Plus; enable only one edition. See [Ultimate compatibility port](docs/ULTIMATE_PORT_NOTES.md). Dynamic Supply Drops' existing PBO works with Ultimate without a gameplay rebuild.

Historical companion **v2.5** consolidated the medical/isotope convoys, Watchkeeper/Osprey response, both isotope pictures and Copilot's visual/medical changes. The standard mod folder is current; response cleanup retries after players leave and preserves captured assets. See [publication, cleanup tests and remaining acceptance](docs/PUBLICATION_CLEANUP_NOTES.md).

Previous companion **v2.3** repairs isotope trucks, accessible injector loot, native chemical release and kinetic door-gun escorts; scales convoy defenses with owning-side aggression; selects distinct precious-metal/tech/jewelry manifests; and removes DEBUG from player-facing mission text. See [files, 239 passing component checks and remaining human checks](docs/CONVOY_REVISION_NOTES.md).

Previous companion **v2.2** fixes Fence's remote stash request, adds camouflaged contraband containers and named high-skill guard squads, replaces personal trade crates with one community crate, integrates the three installed AI mods and adds **Zeus Modules â†’ DEBUG** mission starters. See [current files, behavior and321 passing checks](docs/FENCE_MISSIONS_AI_NOTES.md). Injector medical loot and400â€“750 Fence payouts remain; see [v2.1 notes](docs/MEDICAL_LOOT_NOTES.md). The boats, varied vehicles, gems/industrial valuables/meth, rare Special/Isotope Convoys, artwork, death-money and consumable rules remain documented in the earlier notes.

**Campaign preservation:** gameplay services must preserve selected maps, faction templates, side relationships and airfield/location ownership. Do not reset a campaign or change faction selections to implement or troubleshoot these features. Record any campaign-state concern in the development notes before taking action.

Version 1.4 adds automatic noise-triggered occupier raids near HQ. See [raid configuration, behavior and verification](docs/HQ_NOISE_RAIDS_NOTES.md).

Version 1.5 adds **The Fence**, a roaming civilian trader with roadside medical-tent camps, custom-valuable sales, rotating premium gear and six vehicle offers. See [Fence behavior and development notes](docs/FENCE_NOTES.md).
