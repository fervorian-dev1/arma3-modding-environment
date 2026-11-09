("true" configClasses (configFile >> "DSDS_SupportActions")) apply {
    [configName _x, getText (_x >> "label"), getNumber (_x >> "cost"), getNumber (_x >> "points")]
}
