if (missionNamespace getVariable ["DSDS_lootInitialized",false]) exitWith {};
DSDS_lootInitialized=true;
if (isServer) then {[] spawn {
    private _tracked=[];
    while {true} do {
        private _active=allPlayers select {(_x getVariable ["DSDS_lootEffects",[]]) isNotEqualTo [] || {(_x getVariable ["DSDS_lootOverdose",[]]) isNotEqualTo []} || {count (_x getVariable ["DSDS_stimEffects",createHashMap])>0}};
        {
            private _ends=_x getVariable ["DSDS_lootEffects",[0,0,0,0,0]];
            private _present=alive _x && {_x in allPlayers};
            if (_present) then {[_x] call DSDS_fnc_lootOverdoseTick;} else {_x setVariable ["DSDS_lootOverdose",nil,true];_x setVariable ["DSDS_lootDoses",nil];};
            private _stim=[_x] call DSDS_fnc_stimModifiers;
            [_x] call DSDS_fnc_lootMorphineHealTick;
            [_x,_present && {(_ends select 4)>serverTime || {(_stim get "carry")>1}}] call DSDS_fnc_lootCapacity;
            if (!_present || {!(_stim get "active")}) then {_x setVariable ["DSDS_stimEffects",nil,true];};
            if (!_present || {(_ends findIf {_x>serverTime})<0}) then {_x setVariable ["DSDS_lootEffects",nil,true];};
        } forEach ((_tracked+_active) arrayIntersect (_tracked+_active));
        _tracked=_active;
        sleep 1;
    };
};};
if (hasInterface) then {[] spawn {
    waitUntil {sleep 0.2;!isNull player};
    // Same installed ZEN APIs as the supply-drop addon; register once per mission.
    if (!isNil "zen_custom_modules_fnc_register") then {
        ["Dynamic Supply Drops","Spawn valuables cache",{["CACHE",player,_this select 0] remoteExecCall ["DSDS_fnc_lootRequest",2];}] call zen_custom_modules_fnc_register;
        private _action=["DSDS_Valuables","Spawn valuables cache","",{["CACHE",player,_this select 0] remoteExecCall ["DSDS_fnc_lootRequest",2];},{true}] call zen_context_menu_fnc_createAction;
        [_action,[],101] call zen_context_menu_fnc_addAction;
    };
    private _previous=objNull;
    while {true} do {
        if (_previous!=player) then {
            if (!isNull _previous) then {[_previous] call DSDS_fnc_lootCleanup;{_previous removeAction _x;} forEach (_previous getVariable ["DSDS_lootActions",[]]);};
            _previous=player;
            if (!isNull player) then {
                private _ids=[];
                {
                    private _class=_x;
                    private _label="Consume "+getText (configFile >> "CfgWeapons" >> _class >> "displayName");
                    private _condition=format ["alive _this && isNull objectParent _this && lifeState _this != 'INCAPACITATED' && '%1' in items _this",_class];
                    _ids pushBack (player addAction [_label,{params ["_target","_caller","_id","_class"];[_class] call DSDS_fnc_lootConsume;},_class,0.5,false,true,"",_condition]);
                } forEach ([] call DSDS_fnc_consumableClasses);
                player setVariable ["DSDS_lootActions",_ids];
            };
        };
        if (!isNull player) then {
            private _rescueCheck=player getVariable ["DSDS_adrenalineRescueCheck",0];
            if (diag_tickTime>=_rescueCheck && {([player] call DSDS_fnc_lootRescueClass)!=""}) then {
                player setVariable ["DSDS_adrenalineRescueCheck",diag_tickTime+3];
                ["RESCUE_BEGIN",player,[]] remoteExecCall ["DSDS_fnc_lootRequest",2];
            };
            [player] call DSDS_fnc_lootTick;
        };
        sleep 0.1;
    };
};};
