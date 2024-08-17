#define MECHA_INT_FIRE			(1<<0)
#define MECHA_INT_TEMP_CONTROL	(1<<1)
#define MECHA_INT_SHORT_CIRCUIT	(1<<2)
#define MECHA_INT_TANK_BREACH	(1<<3)
#define MECHA_INT_CONTROL_LOST	(1<<4)

#define MECHA_MELEE 			(1<<0)
#define MECHA_RANGED 			(1<<1)

#define MECHAMOVE_RAND 			(1<<0)
#define MECHAMOVE_TURN 			(1<<1)
#define MECHAMOVE_STEP 			(1<<2)

#define MECHA_FRONT_ARMOUR 		1
#define MECHA_SIDE_ARMOUR 		2
#define MECHA_BACK_ARMOUR 		3

#define MECHA_MAINT_OFF         0
#define MECHA_MAINT_ON          1
#define MECHA_BOLTS_UP          2
#define MECHA_OPEN_HATCH        3
#define MECHA_BATTERY_UNSCREW   4

/// Defines for mecha panel dismantling states
#define MECHA_PANEL_0 "untarnished"
#define MECHA_PANEL_1 "welded1" // welder
#define MECHA_PANEL_2 "crowbared1" // crowbar
#define MECHA_PANEL_3 "welded2" // welder
#define MECHA_PANEL_4 "crowbared2" // crowbar
#define MECHA_PANEL_5 "wirecutter" // wirecutter
#define MECHA_PANEL_6 "opened"

#define MECH_STRAFING_BACKWARDS (1<<0)
#define MECH_STRAFING_SIDEWAYS (1<<1)
