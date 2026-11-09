/* Read-only native aggression, independently for the owning enemy side (0..100). */
params [["_side",missionNamespace getVariable ["Occupants",west]]];
private _inv=_side==missionNamespace getVariable ["Invaders",east];
private _aggression=(missionNamespace getVariable [if (_inv) then {"aggressionInvaders"} else {"aggressionOccupants"},0]) max 0 min 100;
private _band=(floor (_aggression/25)) min 3;
private _war=(missionNamespace getVariable ["tierWar",1]) max 1 min 10;
createHashMapFromArray [["aggression",_aggression],["band",_band],["groundEscorts",2+_band],["extraGround",_band],["passengers",2+2*_band],["skill",(0.55+0.08*_band+0.01*_war) min 0.9],["armor",_band>=2],["heavy",_band==3 && {_war>=7}],["airEscorts",1+floor (_band/2)],["responseGround",3+_band],["responsePassengers",6+2*_band],["responseHelis",1+floor (_band/2)],["spotters",2+floor (_band/3)]]
