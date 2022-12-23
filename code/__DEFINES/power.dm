#define PW_CHANNEL_EQUIPMENT	1
#define PW_CHANNEL_LIGHTING		2
#define PW_CHANNEL_ENVIRONMENT	3

#define PW_ALWAYS_UNPOWERED       (1 << 0)
#define PW_ALWAYS_POWERED         (1 << 1)

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

// channel numbers for power
#define EQUIP           1
#define LIGHT           2
#define ENVIRON         3
#define TOTAL           4	//for total power used only
#define STATIC_EQUIP    5
#define STATIC_LIGHT    6
#define STATIC_ENVIRON  7

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

//APC charging
#define APC_NOT_CHARGING 0
#define APC_IS_CHARGING 1
#define APC_FULLY_CHARGED 2
