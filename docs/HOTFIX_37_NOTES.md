# Hotfix v3.7 ? 2026-11-13

User explicitly requested no tests and no clarification questions. No automated tests, config validation, or game launch performed. Packaging only; functionality is unverified.

- Ultimate forbiddenItems excludes custom valuables/isotopes/other injectors from unlimited unlocks and random arsenal crate pools. Existing server arsenal sanitation now removes finite and unlimited entries for all registered custom Fence valuables except Morphine/Adrenaline, retaining Oswald protection. Repeats every 30 seconds after campaign initialization. Existing campaign disk data is NOT directly edited: load the current campaign with this update, allow at least 30 seconds, then save normally to persist cleanup. Stored inventories outside the team arsenal are untouched.
- Morphine and Adrenaline: zero Fence resale value regardless of source (including arsenal); sale refuses a crate containing either and retains contents. Each class allows two confirmed uses per player body/life, including manual and automatic rescue. A new life resets the limit. Arsenal availability remains as before; neither is prohibited from unlimited stock.
- Fence relocation moves the existing community crate and its inventory even if attached/loaded, unloading it first. Invalid safe-position result falls back beside the new tent.
- Noise-triggered HQ raid post-raid recovery changed from 60 seconds to 3600 seconds. Fresh noise after recovery remains necessary. Native Antistasi raids unaffected.

Modified: config.cpp, mod.cpp; Compatibility/fn_protectOswaldArsenal.sqf; Fence/fn_fencePrice.sqf and fn_fenceRotate.sqf; Loot/fn_lootRequest.sqf, fn_lootRescueClass.sqf, fn_lootRescueTake.sqf, fn_lootCommit.sqf.

Distribution: rebuild packaged directly with FileBank, bypassing the usual build script because it runs validation. Every client/server must update and restart. Earlier v3.6 GitHub ZIP does not contain these changes; GitHub publication/authentication task remains pending.
