/* Public group IDs, also listed in the task. Unique within this mission. */
private _used=missionNamespace getVariable ["DSDS_guardNames",[]];private _name="";
for "_i" from 1 to 40 do {
 _name=format ["%1 %2",selectRandom ["Black","Copper","Silent","Broken","Iron","Ash","Red","Night","Grey","Stone","Cold","Hidden"],selectRandom ["Jackals","Vipers","Ravens","Hounds","Wolves","Scorpions","Foxes","Talons","Crows","Serpents","Shadows","Badgers"]];
 if (!(_name in _used)) exitWith {};
};
if (_name in _used) then {_name=_name+" "+str (count _used+1);};
_used pushBack _name;DSDS_guardNames=_used;_name
