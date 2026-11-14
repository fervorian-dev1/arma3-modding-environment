/* Isotope convoy chemical rewards: native CWP placeable IED magazines only. */
params ["_truck"];
if (!isServer || {isRemoteExecuted} || {isNull _truck}) exitWith {[]};
private _manifest=[];
{
 private _class=_x;
 private _cfg=configFile >> "CfgMagazines" >> _class;
 if (isClass _cfg && {getNumber (_cfg >> "scope")==2} && {getText (_cfg >> "DLC")==""} && {isClass (configFile >> "CfgAmmo" >> getText (_cfg >> "ammo"))}) then {
  private _count=round (2.25*(2+floor random 2));
  _truck addMagazineCargoGlobal [_class,_count];
  _manifest pushBack [_class,_count];
 } else {diag_log format ["[DSDS Convoy] Chemical IED reward unavailable: %1",_class];};
} forEach [
 "CBRN_IEDLandSmall_Type1_Remote_Mag",
 "CBRN_IEDLandSmall_Type2_Remote_Mag",
 "CBRN_IEDLandSmall_Type3_Remote_Mag",
 "CBRN_IEDUrbanSmall_Type1_Remote_Mag",
 "CBRN_IEDUrbanSmall_Type2_Remote_Mag",
 "CBRN_IEDUrbanSmall_Type3_Remote_Mag"
];
_manifest
