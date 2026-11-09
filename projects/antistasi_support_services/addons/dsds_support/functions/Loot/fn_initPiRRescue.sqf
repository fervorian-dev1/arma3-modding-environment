/* Scope the installed PiR crawl->unconscious transition to a still-active injury.
   PiR's delayed Crawl0 callback can otherwise start Uncondition0 AFTER a successful rescue.
   All other units/real fresh injuries still use the unchanged installed function. */
if (!isServer || {isRemoteExecuted} || {missionNamespace getVariable ["DSDS_pirRescueGuard",false]} || {isNil "Uncondition0"}) exitWith {};
DSDS_pirRescueGuard=true;
DSDS_pirUnconditionOriginal=Uncondition0;
Uncondition0={
 params ["_unit"];
 if (!isNull _unit && {alive _unit} && {serverTime<(_unit getVariable ["DSDS_pirRescueUntil",0])} && {!(_unit getVariable ["dam_ignore_injured0",false])} && {damage _unit<0.05}) exitWith {
  diag_log "[DSDS PiR] Suppressed stale post-rescue crawl-to-unconscious transition.";
 };
 _this call DSDS_pirUnconditionOriginal
};
diag_log "[DSDS PiR] Installed per-casualty stale-transition guard; native settings/functions retained for other injuries.";
