// bit flags for which kinds of cable our cable can connect to
#define CABLE_LOW_POWER (1 << 0)
#define CABLE_HIGH_POWER (1 << 1)
#define CABLE_ALL_CONNECTIONS (CABLE_LOW_POWER | CABLE_HIGH_POWER)

#define CABLE_MERGE_LOW_POWER (1 << 0)
#define CABLE_MERGE_HIGH_POWER (1 << 1)
