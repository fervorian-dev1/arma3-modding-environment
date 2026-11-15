/* Owner-local self treatment. Native teammate revive and PiR AI remain separate. */
if (!hasInterface || {isRemoteExecuted} || {isNull player} || {!local player} || {!alive player} || {lifeState player=="INCAPACITATED"} || {!isNull objectParent player} || {player getVariable ["DSDS_selfTreatBusy",false]} || {damage player<0.001 && {(((getAllHitPointsDamage player) param [2,[]]) findIf {_x>0.01})<0}}) exitWith {};
private _u=player;
private _kits=(missionNamespace getVariable ["PiR_changeMedKit",[]])+["PiR_apteka"];
private _bandages=(missionNamespace getVariable ["PiR_changeIFAK",[]])+["PiR_bint"];
private _kit=(_kits arrayIntersect items _u) param [0,""];
private _bandage=(_bandages arrayIntersect items _u) param [0,""];
if (_kit=="" && {_bandage==""}) exitWith {};
_u setVariable ["DSDS_selfTreatBusy",true];_u setVariable ["DSDS_selfTreatCancel",false];
private _cancel=_u addAction ["Cancel self-treatment",{(_this select 1) setVariable ["DSDS_selfTreatCancel",true];},nil,7,true,true,"","true",2];
private _baseline=getAllHitPointsDamage _u;private _startDamage=damage _u;private _origin=getPosATL _u;private _start=diag_tickTime;
_u playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
private _valid={alive _u && {player==_u} && {lifeState _u!="INCAPACITATED"} && {isNull objectParent _u} && {_u distance2D _origin<2} && {!(_u getVariable ["DSDS_selfTreatCancel",false])} && {damage _u<=_startDamage+0.001} && {(_kit!="" && {_kit in items _u}) || {_bandage!="" && {_bandage in items _u}}}};
waitUntil {sleep 0.1;!(call _valid) || {diag_tickTime-_start>=8}};
if (call _valid) then {
 if !(_kit!="" && {_kit in items _u}) then {_u removeItem _bandage;};
 // Preserve wounds incurred during treatment; no invulnerability or down-state change.
 private _now=getAllHitPointsDamage _u;private _oldDamage=damage _u;
 _u setDamage ((_oldDamage-_startDamage) max 0);
 {private _index=_forEachIndex;private _prior=(_baseline select 2) param [_index,0];_u setHitPointDamage [_x,(((_now select 2) param [_index,0])-_prior) max 0];} forEach (_now select 0);
 systemChat "Treatment complete.";
};
_u removeAction _cancel;_u setVariable ["DSDS_selfTreatBusy",false];
if (alive _u && {lifeState _u!="INCAPACITATED"} && {isNull objectParent _u}) then {_u playMoveNow "AmovPknlMstpSrasWrflDnon";};
