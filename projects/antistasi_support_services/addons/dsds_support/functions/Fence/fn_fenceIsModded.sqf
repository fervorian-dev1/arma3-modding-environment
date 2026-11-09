/* Class origin, not later compatibility patches on a vanilla class. */
params ["_class",["_section","CfgWeapons"]];
private _sources=configSourceAddonList (configFile >> _section >> _class);
if (_sources isEqualTo []) exitWith {false};
private _origin=toLower (_sources select 0);
!(_origin select [0,3] == "a3_") && {!(_origin select [0,4] in ["cba_","zen_"])}
