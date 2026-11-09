params ["_raid"];
if (!isServer || {isRemoteExecuted}) exitWith {};
sleep (DSDS_raidConfig get "cleanupDelay");
private _pending = +((_raid get "units") + (_raid get "vehicles"));
private _deadline = diag_tickTime + 3600;
while {_pending isNotEqualTo [] && {diag_tickTime < _deadline}} do {
    private _again = [];
    {
        private _object = _x;
        if (!isNull _object) then {
            private _protected = isPlayer _object || {captive _object} || {(_object getVariable ["ownerX",""]) isNotEqualTo ""} || {!isNull attachedTo _object} || {attachedObjects _object isNotEqualTo []};
            if (_object isKindOf "Man") then {
                _protected = _protected || {side group _object != Occupants};
                private _parent = objectParent _object;
                if (!isNull _parent) then {
                    _protected = _protected || {_parent getVariable ["DSDS_raidID",-1] != _raid get "id"} || {(_parent getVariable ["ownerX",""]) isNotEqualTo ""} || {{isPlayer _x || {side group _x != Occupants}} count crew _parent > 0};
                };
            } else {
                _protected = _protected || {{isPlayer _x || {side group _x != Occupants}} count crew _object > 0} || {ropeAttachedObjects _object isNotEqualTo []} || {!isNull ropeAttachedTo _object} || {!isNull isVehicleCargo _object} || {getVehicleCargo _object isNotEqualTo []};
            };
            // Captured/towed/captive assets are deliberately relinquished, not deleted.
            if (!_protected) then {
                private _visible = (allPlayers findIf {alive _x && {_x distance2D _object < DSDS_raidConfig get "cleanupDistance" || {_x distance2D _object < 2500 && {([objNull,"VIEW"] checkVisibility [eyePos _x,getPosASL _object vectorAdd [0,0,1]]) > 0.1}}}}) >= 0;
                if (_visible) then {_again pushBack _object;} else {deleteVehicle _object;};
            };
        };
    } forEach _pending;
    _pending = _again;
    if (_pending isNotEqualTo []) then {sleep 30;};
};
{if (!isNull _x) then {deleteVehicle _x;};} forEach (_raid get "pads");
{if (!isNull _x && {units _x isEqualTo []}) then {deleteGroup _x;};} forEach (_raid get "groups");
