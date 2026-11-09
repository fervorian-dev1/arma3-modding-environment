# Startup check - 2026-11-07

User reported apparent freeze at Initializing Addons after v2.4. Read the live normal-client RPT without stopping the game or changing addons/settings.

Log: C:\Users\mamaj\AppData\Local\Arma 3\Arma3_x64_2026-11-07_22-47-01.rpt.

Observed RHS/3CB class loading continuing through22:48:02, then GPU initialization and InitSound complete at22:48:48. Thus this launch advanced beyond addon configuration loading after roughly1 minute47 seconds; it was not permanently frozen at the reported stage during observation. CPU time and working memory increased while Windows reported Not Responding. No DSDS config error was found at that point. This does not prove full startup or exclude a later compatibility problem. Earlier successful normal-client v2.2 log20-44-30 also had a lengthy class-loading stage and reached InitSound at20:46:09.

v2.4 visuals run on consumption during a mission, not as startup preInit scripts. The new overlay config is read during addon loading, so a contribution from the addon cannot be ruled out solely on timing. Existing dedicated/config tests do not prove full-client compatibility with the larger normal mod pack (including3CB, terrain packs, PiR and Blastcore).

No code, packed addon, launcher preset, Workshop source, campaign or normal user process was changed/stopped for this check. If a repeatable prolonged stall remains, isolate with the companion disabled while retaining the other mods, then compare normal-client RPT progress. Do not claim the last logged addon is necessarily the culprit.
