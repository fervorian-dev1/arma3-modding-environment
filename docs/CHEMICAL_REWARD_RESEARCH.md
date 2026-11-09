# Chemical Warfare PLUS reward research

2026-11-07. Read-only inspection of installed Workshop3295358796/PHAN_CW via extracted configs/scripts under `reference/chemical/PHAN_CW`. No reward tables, addon PBOs, faction settings or missions changed. This is a recommendation/catalogue, not a completed loot integration or runtime test of every item.

## Verified portable candidates

| Item | Actual config class | Use |
|---|---|---|
| Gas-mask filter | `CBRN_gasmaskFilter` | Replenishes native mask filter durability; actual change-filter action consumes it. |
| Duct tape | `CBRN_DuctTape` | Native mask repair action consumes it. |
| ATNAA antidote injector | `PHEN_ATNAA_Injector` | Vanilla inventory-clickable version; clears native CWP exposure, not permanent immunity. Separate ACE compatibility exists, but user currently uses PiR. |
| Sealant tube | `CBRN_sealant` | Native Seal leak action on objects with `CBRN_leak_active`. Does not automatically stop our separately registered isotope-wreck cloud. |
| M50 Promask | `G_CBRN_M50` | Facewear; native protection bits1+2, explicit DLC empty. |
| M50 with hood | `G_CBRN_M50_Hood` | Native protection1+2+4; inherits mod-owned mask and empty DLC. |
| M04 Promask / hood | `G_CBRN_M04`, `G_CBRN_M04_Hood` | Alternate masks; hood adds head coverage. |
| S10 with hood | `G_CBRN_S10` | Alternative hooded mask, bits1+2+4. |
| Military protective uniform | `U_CBRN_A_multicam`, `U_CBRN_A_woodland` | AN_CBRN uniform definitions have protection8; need complementary mask/head coverage. Mod also has black/blue/green and civilian variants plus vests/facewear. |
| White/yellow NBCD suits | `JCA_U_NBCD_Suit_01_White_F`, `JCA_U_NBCD_Suit_01_Yellow_F` | Protection8. Hood variants `JCA_U_NBCD_Suit_01_hood_White_F` / `_Yellow_F` have4+8. |

Uniform DLC/side/model usability must be checked on the final selected loaded classes before granting rewards: the pack mixes own models with vanilla/Contact retextures. Do not promise every suit, detector or CBRN vehicle is DLC-free just because it is in a mod. The already-approved no-DLC loot rule remains. Mask config explicitly clears DLC; the utility items use base/free asset paths.

## Other installed content

`cbrn_weapons/config.cpp` defines hand grenades and40mm/3GL rounds for CS, asphyxiant, nerve, blister and Nova gas. Confirmed magazine examples: `PHEN_FSPLUS_ChemGrenade_RiotCSGasGrenade`, `PHEN_FSPLUS_ChemGrenade_AsphyxiantGasGrenade`, and their `_40mm` variants. The pack also contains chemical mortar ammunition,230mm rockets, rocket-launcher ammunition, IEDs and aircraft bomb/pylon magazines. These are separate ammo families, not generic inventory bombs usable by any weapon.

There are CBRN-themed vans, offroads, utility drones, helicopters/trucks/pods; scenery containers/signs/screens; protective uniforms/vests/facewear; editor units/factions/modules and detector integration. Some are retextures or extensions of vanilla/DLC assets. Many editor objects are not inventory loot. No new faction should be enabled or substituted just to reward gear.

The author describes five gas tiers: CS; asphyxiant; nerve; blister; Nova. Nova has a WebKnight zombie/creature dependency and is outside the current recommended reward pool. Chemical detector integration uses the vanilla Contact-era detector; avoid assuming it is an unrestricted mod-created device.

## Suggested balance (proposal only)

For a squad of four, a practical isotope-convoy reward: **4 hooded M50/M04/S10 masks,8 spare filters,4 ATNAA injectors and2 rolls of duct tape**. Masks provide initial capability; finite consumables keep future convoy rewards useful. Scale masks roughly one per participating player. Protective uniforms can be a rarer specialist bundle after DLC/usability validation.

Optional offensive reward:2–4 CS grenades initially;1–2 asphyxiant grenades as a rarer premium find once masks/filters are available. Nerve/blister rounds and chemical aircraft/artillery ammunition belong in exceptional mission rewards, with platform compatibility and gameplay balance checked first. Existing finite-loot/unlimited-arsenal behavior must be considered before introducing any of these into an Antistasi arsenal.

Sealant is best saved for a future live-leak repair objective; it does not currently disarm our isotope truck or remove its wreck cloud. Protective gear rewards complement the current isotope mission without requiring that new objective.

Source evidence: `cbrn_gear/config.cpp`, `cbrn_gear/functions/fn_changegasmaskfilter.sqf`, `fn_repairgasmask.sqf`, `fn_createsealaction.sqf`, `cbrn_gear/bootstrap/phen_inventoryitems.sqf`; `an_cbrn/config.cpp`, `nbcd_suit_standalone/config.cpp`, `cbrn_weapons/config.cpp`, `cbrn_vehicles/config.cpp`, `cbrn_assets/config.cpp`. Additional configs were converted from extracted BIN files into ignored research copies only.

Author's primary description: [Chemical Warfare PLUS](https://steamcommunity.com/sharedfiles/filedetails/?id=3295358796). It documents gear, tiers, native injector/filter functions, weapons and optional Nova dependency; the installed files are the authority for the exact classnames above.
