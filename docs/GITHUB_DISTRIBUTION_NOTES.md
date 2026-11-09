# GitHub distribution

The user requested the whole project on GitHub so friends can download it, and explicitly chose a **public download repository**.

## Player download prepared

`scripts/Build-GitHubDownload.ps1` packages both current compiled custom mods with portable installation instructions and SHA256SUMS.txt. It verifies the PBO copies and required ZIP entries. Output: `build/releases/Arma3-Custom-Mods-v3.6.zip` (397542 bytes).

ZIP SHA256: `61685F0CF4D514365ACDC425DE9CD3811A6C95070A01EFC6F2C7A58DA5CC14AB`.

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
