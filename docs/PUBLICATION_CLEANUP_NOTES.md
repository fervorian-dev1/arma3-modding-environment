# Consolidated v2.5 publication and response cleanup

Completed2026-11-08 at the user's request to address resume-audit items1,5,6, including copied test-fixture housekeeping. Standard release: `build/@AntistasiSupportServices`. Restart host/server and clients using this folder; friends need the complete updated folder. No new campaign or launcher re-add is needed. Enable one companion copy only. The earlier `@AntistasiSupportServices-IsotopeThumbnails` and temp candidates remain historical backups, not the current release.

## Publication

The normal folder now contains both isotope thumbnails, the v2.5 medical/convoy/response features, and Copilot's later visual/Morphine/Adrenaline changes. The build helper passed CfgConvert, packed a fresh candidate, extracted it, compared every file against source and confirmed the final copied PBO hash. **132 registered functions /165 packed files**. Copilot's artwork and gameplay changes were preserved, not replaced with the older logistics candidate.

```text
Antistasi Support Services v2.5:
EE9C8E91DE99B93000BFAD6E7CDEDECAFCB320A007337032944260050578C1BA

Dynamic Supply Drops (unchanged):
F9656DFB9A999A9053A0B649A4DFEF108D31D631E3C470FB398BCB68C79CF4F6
```

## Cleanup change

Previously, the contamination response checked once at the end and skipped anything within1200m of players. Skipped assets were never revisited. The end-of-response code now starts a private, scheduled and deduplicated cleanup worker:

- First pass immediately; retry every30seconds while owned assets remain deferred. Query the current player list each pass, so moving players and JIP are respected.
- Retain assets within1200m of players. Once they leave, remove only this response's vehicles, crew, dismounted units and empty groups.
- Permanently release captured vehicles and their passengers; preserve player-controlled/connected UAVs, player or friendly crew, captives, and vehicles with unrelated occupants. A response unit that boards an unrelated vehicle is released without touching that vehicle.
- Keep original asset lists for diagnostics and separate pending/protected lists for cleanup. Empty queues stop the worker; repeated calls cannot start duplicate jobs.
- Two private server functions were registered, with no new remotely callable API or dependency. The optional observer argument exists solely for trusted server engine fixtures; normal gameplay uses the live player list.

No response duration, drone replacement policy, combat behavior, medical effect, reward price, faction relationship, map, save or Workshop content was changed in this finalization.

## Exact files

Addon root: `projects/antistasi_support_services/addons/dsds_support`.

- Created `functions/Smuggling/fn_cleanupContaminationResponse.sqf` and `fn_cleanupContaminationTick.sqf`.
- Modified `functions/Smuggling/fn_contaminationResponse.sqf` to dispatch the retry worker instead of one cleanup pass; modified `config.cpp` to register both functions.
- Created `tests/support_services/dsds_cleanup.Altis/mission.sqm`, `description.ext`, `initServer.sqf` and `scripts/Test-ResponseCleanup.ps1`.
- Reconciled current versions, hashes, counts and status in `docs/HANDOFF.md`, `docs/LOGISTICS_RESPONSE_NOTES.md`, `docs/RESUME_REVIEW_2026-11-08.md`, `docs/CONTRABAND_VISUALS_NOTES.md`, root README and project README. Added historical/current pointers to expansion notes and archived the pre-consolidation handoff at `docs/HANDOFF_PRE_CONSOLIDATION_2026-11-08.md`.
- Standard build PBO and copied README/mod.cpp refreshed by the existing build helper. No original mod or image file was deleted/overwritten by a substitute.

## Verification and housekeeping

**16 PASS/0 FAIL**, with no SQF expression errors, in `logs/cleanup-validation-ultimate/arma3server_x64_2026-11-08_01-36-25.rpt`. Actual engine objects tested: active-response protection; near-observer retention; deletion after leaving; vehicle/crew/foot/group cleanup; captured ownership, friendly crew, unrelated occupants and vehicles; captive protection; actual30-second worker retry; duplicate-job prevention. The observer was an isolated AI surrogate, not a human client; actual human UAV controls and remote HC ownership remain acceptance work.

The worker logged completion after two passes, deleting two owned units and one vehicle after the observer moved away. All function registrations/references were checked; final source-to-PBO and standard-folder publication hashes match.

Only owned server PID76512 was stopped after validating executable, profile and port24426. Four copied mission directories were inspected for exact absolute paths, non-reparse directories, expected three-file inventories and mission/test ownership markers, then their named files and empty directories were removed: `dsds_contacts.Altis`, `dsds_expansion.Altis`, `dsds_logistics.Altis`, `dsds_cleanup.Altis`. Source fixtures and all test RPTs remain. No normal user game process was stopped. No Git commit was created.

Historical test provenance remains explicit: Copilot's expansion201/0 predates this cleanup; earlier logistics40/1 was followed by corrected contact4/0. This focused cleanup test is not a new full logistics or human medical/visual acceptance run. Remaining resume-audit items2,3,4 are unchanged: actual Adrenaline/PiR multiplayer rescue, rendered effects/pictures and combined logistics/HC/JIP/player attribution testing.
