#define MILLISECONDS *0.01

#define DECISECONDS *1 //the base unit all of these defines are scaled by, because byond uses that as a unit of measurement for some fucking reason

// So you can be all 10 SECONDS
#define SECONDS *10

#define MINUTES *600

#define HOURS *36000

#define TICKS *world.tick_lag

#define SECONDS_TO_LIFE_CYCLES /2

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)
