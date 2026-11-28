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

#define MECH_PANEL_OPEN (1<<0)
#define MECH_ID_LOCK_ON (1<<1)
#define MECH_CAN_STRAFE (1<<2)
#define MECH_LIGHTS_ON (1<<3)
#define MECH_SILICON_PILOT (1<<4)
#define MECH_IS_ENCLOSED (1<<5)
#define MECH_HAS_LIGHTS (1<<6)
#define MECH_QUIET_STEPS (1<<7)
#define MECH_QUIET_TURNS (1<<8)
#define MECH_CANNOT_INTERACT (1<<9) //! blocks using equipment and melee attacking.
#define MECH_MMI_COMPATIBLE (1<<10) //! posibrains can drive this mecha
#define MECH_OMNIDIRECTIONAL_ATTACKS (1<<11) //! Can click from any direction and perform stuff
