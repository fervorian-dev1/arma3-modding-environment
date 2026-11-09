/* Native public garage API, without spawning a boat on land or fabricating save records. */
params ["_class","_uid"];
if (!isServer || {isRemoteExecuted && {isNil "_dsdsFenceDelivery"}} || {_uid==""} || {!(_class isKindOf "Ship")} || {isNil "HR_GRG_fnc_addVehiclesByClass"} || {isNil "HR_GRG_Vehicles"} || {isNil "HR_GRG_UID"}) exitWith {false};
private _category=[_class] call HR_GRG_fnc_getCatIndex;
if (_category<0 || {_category>=count HR_GRG_Vehicles}) exitWith {false};
private _registry=HR_GRG_Vehicles select _category;
private _before=keys _registry;
[[_class],_uid] call HR_GRG_fnc_addVehiclesByClass;
private _added=(keys _registry)-_before;
count _added==1 && {private _entry=_registry get (_added select 0);(_entry select 1)==_class && {(_entry select 2)==_uid}}
