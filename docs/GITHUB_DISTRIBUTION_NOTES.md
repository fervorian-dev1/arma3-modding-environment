## Latest published update: v4.9 (2026-11-14)

Published source and compiled mod folders on main (release commit4c379e9). Latest release: https://github.com/fervorian-dev1/arma3-modding-environment/releases/tag/v4.9

Player ZIP: https://github.com/fervorian-dev1/arma3-modding-environment/releases/download/v4.9/Arma3-Custom-Mods-v4.9.zip (407077 bytes). Companion4.9 + Supply Drops1.2. Public download hash matched local artifact. Release notes retain local-client validation and multiplayer limitation. Private saves/backups excluded.

## Latest published update: v4.8 (2026-11-14)

Published source/build folders on main (release commit d3d8207). Latest public release: https://github.com/fervorian-dev1/arma3-modding-environment/releases/tag/v4.8

Player ZIP: https://github.com/fervorian-dev1/arma3-modding-environment/releases/download/v4.8/Arma3-Custom-Mods-v4.8.zip (405576 bytes), companion4.8 + Supply Drops1.2. Public download hash matched local artifact. Release notes retain the multiplayer testing limitation. Private saves/backups excluded.

## Latest published update: v4.7 (2026-11-13)

Source pushed to main (release commit2c59dbc). Public latest release: https://github.com/fervorian-dev1/arma3-modding-environment/releases/tag/v4.7

Ready player ZIP: https://github.com/fervorian-dev1/arma3-modding-environment/releases/download/v4.7/Arma3-Custom-Mods-v4.7.zip (404578 bytes). Contains companion4.7 and Supply Drops1.2. Downloaded public asset and verified its SHA256 equals local ZIP. Replaces v3.6 as latest. Both compiled mod folders also updated on main. Private campaign saves/backups remain excluded.

﻿# GitHub distribution

The user requested the whole project on GitHub so friends can download it, and explicitly chose a **public download repository**.

## Player download prepared

`scripts/Build-GitHubDownload.ps1` packages both current compiled custom mods with portable installation instructions and SHA256SUMS.txt. It verifies the PBO copies and required ZIP entries. Output: `build/releases/Arma3-Custom-Mods-v3.6.zip` (397542 bytes).

ZIP SHA256: `FC45183DBD1BBC113FF65A3E818D4334343514BDED3573DD11829F1904CD8E89`.

Included PBOs:
- Dynamic Supply Drops: `F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6`.
- Support Services v3.6: `F7EFDFBE03F47CEB0D6E6084E7B6DAFDBBE1A2805FE10C4244EC958BF4677C74`.

Friends extract the release ZIP and add both @ folders through Launcher > Mods > Local mod. They still need the host's Steam Workshop mod list. GitHub's source-code ZIP alone is not ready to load in Launcher.

## Published

- Public source repository: https://github.com/fervorian-dev1/arma3-modding-environment
- Player downloads: https://github.com/fervorian-dev1/arma3-modding-environment/releases/latest
- Release `v3.6` includes `Arma3-Custom-Mods-v3.6.zip` with the SHA256 above.

## Source upload preparation

The repository includes editable projects/artwork, build/test scripts and documentation. Existing ignores exclude generated build output, logs/profiles, temporary files, extracted third-party references, PBOs/signatures/private signing keys. Compiled mods will be attached to a release, not mixed into source history. No >100MiB files or recognized access-token/private-key patterns were found in the upload set.

The source was published on the `main` branch after verifying the initial upload set. The repository excludes local build output, logs/profiles, temporary files, extracted references and signing keys. The `v3.6` player ZIP is attached to the public release.

Latest v4.7 ZIP SHA256: 3D13E4C499712FFB72DA37D39D9208616DABDD88A4D36C4A8B4ABD418B573331

Latest v4.8 ZIP SHA256: 1E8BA073FDA1FBD2B5D76F40A181335EB5F5B855AA78E5B60ED97FB83BBEFFA0

Latest v4.9 ZIP SHA256: 21C09BC3851593C8FE9DE4F538ACBA261BEC3F218733462729BADFAFED9DA06D
