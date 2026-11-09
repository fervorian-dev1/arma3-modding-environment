# Parachute support seating — v3.1, 2026-11-08

User reported arriving in the C-130 cockpit and being able to replace the pilot. They requested boarding in the back with no pilot-seat access.

Reviewed installed RHS C-130 config, the support aircraft worker, passenger owner-local boarding, jump routine and contract server flow. Previous boarding used automatic `moveInCargo` without explicit index and did not lock crew stations. Final code selects the highest available non-turret cargo index from actual `fullCrew`, assigns that exact cargo index, boards there and verifies the resulting role/index. No free cargo returns false/logs; no driver/turret fallback or passenger displacement. This selects a rear cargo proxy in the installed transport; other models may arrange proxies differently.

Only PARADROP aircraft lock the driver and all turret/copilot stations after the AI crew is created. Existing crew remains aboard. Cargo exit and scripted parachute jump remain available. Other support aircraft and purchased Fence aircraft retain previous behavior. Multiplayer: aircraft locks applied by its spawning server, passenger placement remains on passenger owner with existing server-only RPC check. No new handlers/functions/dependencies or polling.

Modified addon files: `functions/fn_boardSupportPassenger.sqf`, `functions/fn_spawnSupportAircraft.sqf`, `config.cpp` (version3.1 only). Existing runSupportContract, jumpSupportPassenger, backpack handling and all other addon files unchanged. Project README/mod metadata and HANDOFF updated. Existing focused fixture extended with8 relevant checks.

Dedicated engine validation **45 PASS/0 FAIL**, including actual installed support transport, highest cargo index, retained AI driver, locked pilot/all turret stations and real parachute transfer: `logs/convoy-defenses-validation-ultimate/arma3server_x64_2026-11-08_07-34-46.rpt`. Includes prior37 convoy/containment checks. No SQF expression errors. Server-local AI passenger exercises the actual placement/jump helpers; a remote human's rendered seat position and interaction menu still need acceptance. Tests establish native lock state, not every third-party scripted seat-teleport override.

CfgConvert passed; build helper extracted and hash-compared every packed source file. Published standard `build/@AntistasiSupportServices`,166 DSDS functions/203 packed files. PBO SHA256 `A53BC8A69DC6A144B1241CED575B89737017FEFFE06A103C1AC451EF4437AE99`. Original Dynamic Supply Drops unchanged. Owned test server stopped; reusable test fixture copy/logs retained. No user game stopped or campaign changed.

Restart host/server and all clients with updated companion. Request parachute transport, verify back/cargo seating and absence of pilot/copilot switching, then confirm automatic jump. Existing Launcher folder entry stays valid; no campaign reset.
