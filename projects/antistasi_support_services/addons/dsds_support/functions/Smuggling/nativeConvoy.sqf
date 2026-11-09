/* CfgFunctions entry adapter: installed Ultimate compiles A3A functions final.
   All explicit native calls delegate to the installed original worker. */
if (hasInterface && {!isServer}) exitWith {};
if (isNil "DSDS_nativeConvoyOriginal") exitWith {diag_log "[DSDS Convoy] Native worker not initialized; request cancelled.";};
if (!(missionNamespace getVariable ["DSDS_nativeConvoyAdapter",false]) || {count _this!=2}) exitWith {_this call DSDS_nativeConvoyOriginal};
// Ultimate's scheduler remoteExecs even to itself. Drain on the server outside
// that RPC context; an HC forwards this narrow mission request to the server.
if (!isServer) exitWith {_this remoteExec ["A3A_fnc_convoy",2];};
if (isRemoteExecuted) exitWith {
 if (remoteExecutedOwner in ([2]+(missionNamespace getVariable ["hcArray",[]]))) then {DSDS_petrosConvoyQueue pushBack (+_this);} else {_this call DSDS_nativeConvoyOriginal;};
};
if (missionNamespace getVariable ["A3A_convoyInProgress",false]) exitWith {};
private _dsdsPetrosConvoySelection=[_this] call DSDS_fnc_selectPetrosConvoy;
private _dsdsConsumeConvoyRotation=true;
if ((_dsdsPetrosConvoySelection select 0)=="") exitWith {_this call DSDS_nativeConvoyOriginal};
private _args=+_this;
_args set [2,"Ammunition"];
_args call DSDS_nativeCargoConvoy
