#define MAPTICK_MC_MIN_RESERVE 60
#define MAPTICK_LAST_INTERNAL_TICK_USAGE (world.map_cpu)


#define TICK_BYOND_RESERVE 2
#define TICK_LIMIT_RUNNING (max(100 - TICK_BYOND_RESERVE - MAPTICK_LAST_INTERNAL_TICK_USAGE, MAPTICK_MC_MIN_RESERVE))
#define TICK_LIMIT_TO_RUN 70
#define TICK_LIMIT_MC 70
#define TICK_LIMIT_MC_INIT_DEFAULT 98

#define TICK_USAGE world.tick_usage //for general usage
#define TICK_USAGE_REAL world.tick_usage    //to be used where the result isn't checked

#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )
