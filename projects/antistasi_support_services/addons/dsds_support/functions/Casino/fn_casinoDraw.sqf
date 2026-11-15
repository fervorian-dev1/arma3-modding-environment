params ["_s"];private _deck=_s getOrDefault ["deck",[]];if (_deck isEqualTo []) then {_deck=[] call DSDS_fnc_casinoShoe;};private _card=_deck deleteAt 0;_s set ["deck",_deck];_card
