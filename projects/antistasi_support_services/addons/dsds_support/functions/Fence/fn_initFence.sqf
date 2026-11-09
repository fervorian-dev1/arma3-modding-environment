if (missionNamespace getVariable ["DSDS_fenceInitialized",false]) exitWith {};
DSDS_fenceInitialized=true;
if (isServer) then {
    [] spawn {waitUntil {sleep 2;missionNamespace getVariable ["serverInitDone",false]};while {true} do {[] call DSDS_fnc_tickFenceVisits;sleep 5;};};
    DSDS_fenceCommunityBox=objNull;DSDS_fenceGeneration=0;
    [] spawn {
        waitUntil {sleep 2;missionNamespace getVariable ["serverInitDone",false]};
        [] call DSDS_fnc_fenceCatalogue;
        while {true} do {
            private _ok=[] call DSDS_fnc_fenceRotate;
            private _cfg=configFile >> "DSDS_Fence";
            private _delay=if (_ok) then {getNumber (_cfg >> "intervalMin")+random (getNumber (_cfg >> "intervalMax")-getNumber (_cfg >> "intervalMin"))} else {300};
            sleep (_delay max 60);
        };
    };
};
if (hasInterface) then {[] spawn {
    while {true} do {
        private _npc=missionNamespace getVariable ["DSDS_fence",objNull];
        if (!isNull _npc && {actionIDs _npc findIf {((_npc actionParams _x) param [0,""]) == "Trade with The Fence"} < 0}) then {
            _npc addAction ["Trade with The Fence",{[] call DSDS_fnc_fenceOpen;},nil,1.5,true,true,"","alive _target && alive _this",6];
        };
        sleep 2;
    };
};};
