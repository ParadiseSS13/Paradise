/// Power Channel for equipment power users
#define PW_CHANNEL_EQUIPMENT	1
/// Power chanel for lighting power users
#define PW_CHANNEL_LIGHTING		2
/// Power channel for environmental power users
#define PW_CHANNEL_ENVIRONMENT	3

/// Local powernet in this area will never be powered, even if its recieving power
#define PW_ALWAYS_UNPOWERED       (1 << 0)
/// Local powernet in this area will always have power even if its not recieving power
#define PW_ALWAYS_POWERED         (1 << 1)

/// roughly 1/2000 chance of a machine flickering on any given tick. That means in a two hour round each machine will flicker on average a little less than two times.
#define MACHINE_FLICKER_CHANCE 0.05

// bitflags for machine stat variable
/// Machine is broken
#define BROKEN		(1 << 0)
/// Machine is not recieving any power from the local powernet
#define NOPOWER		(1 << 1)
/// machine is currently under maintenance
#define MAINT		(1 << 2)
/// Machine is currently affected by EMP pulse
#define EMPED		(1 << 3)

//Power use
/// This machine is not currently consuming any power passively
#define NO_POWER_USE 0
/// This machine is consuming its idle power amount passively
#define IDLE_POWER_USE 1
/// This machine is consuming its active power amount passively
#define ACTIVE_POWER_USE 2

//APC charging
/// APC is not recieving power
#define APC_NOT_CHARGING 0
/// APC is currently recieving power and storing it
#define APC_IS_CHARGING 1
/// APC battery is at 100%
#define APC_FULLY_CHARGED 2

#define KW * 1e3
#define MW * 1e6
#define GW * 1e9

#define KJ * 1e3
#define MJ * 1e6
#define GJ * 1e9

/// Conversion ratio from Watt over a machine process tick time to Joules
#define WATT_TICK_TO_JOULE 2
