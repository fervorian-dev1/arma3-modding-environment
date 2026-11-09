# Environment inventory

Checked November 6, 2026 (America/Chicago).

## Located and checked

- Arma 3: A:\SteamLibrary\steamapps\common\Arma 3 (arma3_x64.exe exists).
- Arma 3 Tools: A:\SteamLibrary\steamapps\common\Arma 3 Tools.
- CfgConvert, FileBank, BankRev: executed successfully against the workspace sample.
- AddonBuilder, Binarize, ObjectBuilder, TerrainBuilder, TexView2, ImageToPAA and signing utilities: present; functionality not yet tested.
- Git: C:\Program Files\Git\cmd\git.exe.
- Python on PATH: C:\Python310\python.exe.
- Workshop mods: A:\SteamLibrary\steamapps\workshop\content\107410 (14 directories).
- User documents: C:\Users\mamaj\OneDrive\Documents.
- Arma profiles: Arma 3 and Arma 3 - Other Profiles under the documents directory.
- Existing game logs: C:\Users\mamaj\AppData\Local\Arma 3.

## Workshop names read from local metadata

3CB Factions, Zeus Enhanced, CUP Terrains Core/Maps/Maps 2.0, Antistasi Plus, CBA_A3, RHSAFRF, RHSUSAF, RHSGREF, RHSSAF. Three additional directories did not expose a simple name assignment in the checked metadata. Mod presence does not establish dependency completeness or runtime compatibility.

## Not established yet

- No P: drive was mounted when inspected. Model/terrain work may need additional work-drive setup; none has been changed.
- Mikero tools were not found at the two standard Program Files locations checked. HEMTT and armake2 were not on PATH. This was a targeted inventory, not a complete search of every file on the computer.
- No Arma-specific VS Code extension was found in the checked extension directories.
- Arma 3 Tools Steam metadata reports LastPlayed=0; first-launch setup may still be needed for some graphical tools.
- Game launch and in-game addon loading remain untested.
- No target mod or gameplay change has been selected.

## Verified sample

projects/environment_smoke/addons/env_smoke/config.cpp passed CfgConvert -test. FileBank produced build/@environment_smoke/addons/env_smoke.pbo. BankRev listed config.cpp in that archive. Run scripts/Test-Environment.ps1 to repeat.
