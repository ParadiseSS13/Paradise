#define PW_CHANNEL_EQUIPMENT	1
#define PW_CHANNEL_LIGHTING		2
#define PW_CHANNEL_ENVIRONMENT	3

#define PW_ALWAYS_UNPOWERED       (1 << 0)
#define PW_ALWAYS_POWERED         (1 << 1)

#define MACHINE_FLICKER_CHANCE 0.05 // roughly 1/2000 chance of a machine flickering on any given tick. That means in a two hour round each machine will flicker on average a little less than two times.

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//APC charging
#define APC_NOT_CHARGING 0
#define APC_IS_CHARGING 1
#define APC_FULLY_CHARGED 2
