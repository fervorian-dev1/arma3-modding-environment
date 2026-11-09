/* ZEN 1.15.1 public APIs; context callback element 0 is position ASL. */
if (!hasInterface || {missionNamespace getVariable ["DSD_menuRegistered", false]}) exitWith {};
if (isNil "zen_context_menu_fnc_createAction" || {isNil "zen_dialog_fnc_create"}) exitWith {
    diag_log "[DSD] ERROR: ZEN context menu/dialog APIs unavailable.";
};
private _folder = ["DSD_SupplyDrops", "Dynamic Supply Drops", "", {}, {true}] call zen_context_menu_fnc_createAction;
private _path = [_folder, [], 100] call zen_context_menu_fnc_addAction;
if (_path isEqualTo []) exitWith {diag_log "[DSD] ERROR: Menu registration failed.";};
private _action = ["DSD_SpawnRandom", "Spawn Randomized Supply Drop", "", {
    [_this select 0] call DSD_fnc_openSupplyDialog;
}, {true}] call zen_context_menu_fnc_createAction;
[_action, _path, 100] call zen_context_menu_fnc_addAction;
// Also expose the same position-based operation in the native Zeus modules tree.
["Dynamic Supply Drops", "Spawn Randomized Supply Drop", {
    [_this select 0] call DSD_fnc_openSupplyDialog;
}] call zen_custom_modules_fnc_register;
DSD_menuRegistered = true;
