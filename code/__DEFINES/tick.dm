#define TICK_LIMIT_RUNNING 90
#define TICK_LIMIT_TO_RUN 85

#define TICK_CHECK ( world.tick_usage > TICK_LIMIT_RUNNING ? stoplag() : 0 )
#define CHECK_TICK if(world.tick_usage > TICK_LIMIT_RUNNING)  stoplag()