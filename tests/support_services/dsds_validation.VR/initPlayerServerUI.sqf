params ["_player"];
[_player] spawn {
    params ["_player"];
    waitUntil {sleep 0.2; missionNamespace getVariable ["DSDS_uiReady",false]};
    [_player] joinSilent group petros;
    _player setPosATL [4003,4002,0];
    _player setVariable ["moneyX",100000,true];
};
