params ["_uid","_index"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _p=[_uid] call DSDS_fnc_luckyProfile;
  private _reward=("true" configClasses (configFile >> "DSDS_LuckyWheel" >> "Rewards")) select _index;
  _p set ["result",_index];_p set ["message","Roxie: "+getText (_reward >> "label")+"!"];
  switch (getText (_reward >> "kind")) do {
   case "CASH": {[_uid,getNumber (_reward >> "amount")] call DSDS_fnc_casinoCredit;};
   case "SPIN": {_p set ["tokens",(_p get "tokens")+1];};
   case "CAR": {_p set ["cars",(_p get "cars")+1];_p set ["message","Roxie: Free Hellcat! Press Collect Hellcat and I'll have it parked outside."];};
   case "RAID": {[_uid] spawn DSDS_fnc_luckyRaid;};
   case "ITEM": {
    private _item=[] call DSDS_fnc_luckyMystery;
    if (_item isEqualTo []) then {_p set ["tokens",(_p get "tokens")+1];_p set ["message","Roxie: No mystery stock ready for you, darling. Keep your token."];} else {
     (_p get "items") pushBack _item;_p set ["message",format ["Roxie: Mystery item: %1! Press Collect items.",getText (configFile >> (_item select 0) >> (_item select 1) >> "displayName")]];
    };
   };
  };

[] call DSDS_fnc_luckySave;[] call DSDS_fnc_casinoSave;
