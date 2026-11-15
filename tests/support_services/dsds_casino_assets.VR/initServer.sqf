[] spawn {sleep 3;
 {diag_log format ['[CASINO54 BODY] %1 label=%2 nakedUniform=%3 uniform=%4 model=%5',configName _x,getText(_x>>'displayName'),getText(_x>>'nakedUniform'),getText(_x>>'uniformClass'),getText(_x>>'model')];} forEach ("((toLower configName _x) find 'gen_')>=0 || {((toLower getText(_x>>'displayName')) find 'underwear')>=0}" configClasses(configFile>>'CfgVehicles'));
 diag_log '[CASINO54 ASSET] DONE';
};
