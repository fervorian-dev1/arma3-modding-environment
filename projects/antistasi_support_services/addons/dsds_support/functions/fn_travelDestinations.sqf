/* Keep human teammates visible even while temporarily unsafe; server checks safety on submit. */
params [["_requester",player]];
private _side=missionNamespace getVariable ["teamPlayer",side group _requester];
private _candidates=allPlayers + (playableUnits select {isPlayer _x});
_candidates=_candidates arrayIntersect _candidates;
_candidates select {
 _x!=_requester && {isPlayer _x} && {!(_x isKindOf "HeadlessClient_F")} && {getPlayerUID _x!=""} && {alive _x} && {side group _x==_side}
}
