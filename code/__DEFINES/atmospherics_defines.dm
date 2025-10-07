#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)
#define GAS_A_B	(1 << 5)

//ATMOS
//stuff you should probably leave well alone!
#define R_IDEAL_GAS_EQUATION	8.31	//kPa*L/(K*mol)
#define ONE_ATMOSPHERE			101.325	//kPa
#define TCMB					2.7		// -270.3degC
#define TCRYO					215		// -58.15degC
#define T0C						273.15	// 0degC
#define T20C					293.15	// 20degC
/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP			259.15

/// -193C - Temperature used for server rooms
#define SERVER_ROOM_TEMP			80

#define MOLES_CELLSTANDARD		(ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
#define M_CELL_WITH_RATIO		(MOLES_CELLSTANDARD * 0.005) //compared against for superconductivity
#define O2STANDARD				0.21	//percentage of oxygen in a normal mixture of air
#define N2STANDARD				0.79	//same but for nitrogen
#define MOLES_O2STANDARD		(MOLES_CELLSTANDARD*O2STANDARD)	// O2 standard value (21%)
#define MOLES_N2STANDARD		(MOLES_CELLSTANDARD*N2STANDARD)	// N2 standard value (79%)
#define CELL_VOLUME				2500	//liters in a cell
//liters in a normal breath
#define BREATH_VOLUME			1
#define BREATH_PERCENTAGE		(BREATH_VOLUME/CELL_VOLUME)					//Amount of air to take a from a tile

//EXCITED GROUPS
#define MINIMUM_AIR_RATIO_TO_SUSPEND				0.005	//Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND						(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)	//Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE					(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND) //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE					(T20C+100)			//or this (or both, obviously)
#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND		0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND		4		//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER		0.5		//Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		(T20C+10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	(T20C+230)

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Capped at OPEN_HEAT_TRANSFER_COEFFICIENT, both here and in Rust.
#define WALL_HEAT_TRANSFER_COEFFICIENT		0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT		0.001
#define OPEN_HEAT_TRANSFER_COEFFICIENT		0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT	0.001
// This looks silly, but it's for clarity when reading elsewhere.
#define ZERO_HEAT_TRANSFER_COEFFICIENT		0.0

#define HEAT_CAPACITY_VACUUM				700000	//a hack to help make vacuums "cold", sacrificing realism for gameplay

//FIRE
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	(150+T0C)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	(100+T0C)
#define FIRE_SPREAD_RADIOSITY_SCALE			0.85
#define FIRE_CARBON_ENERGY_RELEASED			500000	//Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED			3000000	//Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE					40000	//For small fires

//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				4
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_UPPER_TEMPERATURE			(1370+T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

//GASES
#define MIN_TOXIC_GAS_DAMAGE				1
#define MAX_TOXIC_GAS_DAMAGE				10
#define MOLES_PLASMA_VISIBLE				0.5		//Moles in a standard cell after which plasma is visible

// Pressure limits.
#define HAZARD_HIGH_PRESSURE				550		//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE				325		//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE				50		//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE					20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT		1.5		//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.

#define BODYTEMP_NORMAL						310.15			//The natural temperature for a body
#define BODYTEMP_AUTORECOVERY_DIVISOR		12		//This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_LOW			2		//This is the divisor that handles how much you go back to your preferred body temperature, between the cold and hot damaging limits. The higher the number, the slower the recovery.
#define BODYTEMP_AUTORECOVERY_MINIMUM		10		//Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX				-30		//The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX				30		//The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT			(BODYTEMP_NORMAL + 50) // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT			(BODYTEMP_NORMAL - 50) // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELM_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MAX_TEMP_PROTECT			1500	//Thermal insulation works both ways /Malkevin
#define SPACE_SUIT_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_TEMP_PROTECT			1500

#define FIRE_SUIT_MIN_TEMP_PROTECT			60		//Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT			30000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT			60		//Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT			30000	//for fire helmet quality items (red and white hardhats)

#define FIRE_IMMUNITY_MAX_TEMP_PROTECT		35000		//what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.

#define HELMET_MIN_TEMP_PROTECT				160		//For normal helmets
#define HELMET_MAX_TEMP_PROTECT				600		//For normal helmets
#define ARMOR_MIN_TEMP_PROTECT				160		//For armor
#define ARMOR_MAX_TEMP_PROTECT				600		//For armor

#define GLOVES_MIN_TEMP_PROTECT				2.0		//For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT				1500	//For some gloves
#define SHOES_MIN_TEMP_PROTECT				2.0		//For gloves
#define SHOES_MAX_TEMP_PROTECT				1500	//For gloves

#define PRESSURE_DAMAGE_COEFFICIENT			4		//The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE			4
#define LOW_PRESSURE_DAMAGE					2		//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR				20		//Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

//PIPES
// Atmos pipe limits
#define MAX_OUTPUT_PRESSURE					4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE					200 // (L/s) Maximum speed powered equipment can work at.

//TANKS
#define TANK_LEAK_PRESSURE					(30.*ONE_ATMOSPHERE)	//Tank starts leaking
#define TANK_RUPTURE_PRESSURE				(40.*ONE_ATMOSPHERE)	//Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE				(50.*ONE_ATMOSPHERE)	//Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    			(10.*ONE_ATMOSPHERE)	//+1 for each SCALE kPa aboe threshold
#define TANK_MAX_RELEASE_PRESSURE 			(ONE_ATMOSPHERE * 3)
#define TANK_MIN_RELEASE_PRESSURE 			0
#define TANK_DEFAULT_RELEASE_PRESSURE 		16

// Atmos alarm defines
#define ATMOS_ALARM_NONE					0
#define ATMOS_ALARM_WARNING					1
#define ATMOS_ALARM_DANGER					2

//LAVALAND
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50 //what pressure you have to be under to increase the effect of equipment meant for lavaland
#define LAVALAND_TEMPERATURE 500
#define LAVALAND_OXYGEN 8
#define LAVALAND_NITROGEN 14

// Reactions
#define N2O_DECOMPOSITION_MIN_ENERGY		1400
#define N2O_DECOMPOSITION_ENERGY_RELEASED	200000
/// The coefficient a for a function of the form: 1 - (a / (x + c)^2) which gives a decomposition rate of 0.5 at 50000 Kelvin
/// And a decomposition close to 0 at 1400 Kelvin
#define N2O_DECOMPOSITION_COEFFICIENT_A 1.376651173e10
/// The coefficient c for a function of the form: 1 - (a / (x + c)^2) which gives a decomposition rate of 0.5 at 50000 Kelvin
/// And a decomposition rate close to 0 at 1400 Kelvin
#define N2O_DECOMPOSITION_COEFFICIENT_C 115930.77913
/// Agent B starts working at this temperature
#define AGENT_B_CONVERSION_MIN_TEMP 900
/// Agent B released this much energy per mole of CO2 converted to O2
#define AGENT_B_CONVERSION_ENERGY_RELEASED 20000

// From milla/src/model.rs, line 126
#define ATMOS_MODE_SPACE 0						//! Tile is exposed to space and loses air every second
#define ATMOS_MODE_SEALED 1						//! Tile has no special behaviour
#define ATMOS_MODE_EXPOSED_TO_ENVIRONMENT 2		//! Tile is exposed to the environment, ex: lavaland
#define ATMOS_MODE_NO_DECAY 3					//! Prevents hot tiles from automatically decaying towards T20C.

/// Lavaland environment: hot, low pressure.
#define ENVIRONMENT_LAVALAND "lavaland"
/// Temperate environment: Normal atmosphere, 20 C.
#define ENVIRONMENT_TEMPERATE "temperate"
/// Cold environment: Normal atmosphere, -93 C.
#define ENVIRONMENT_COLD "cold"

/// How far away should we load the pressure HUD data from MILLA?
#define PRESSURE_HUD_LOAD_RADIUS 15

/// How far away should we send the pressure HUD to the player?
#define PRESSURE_HUD_RADIUS 12

// Vent pump modes
/// Don't go over the external pressure
#define ONLY_CHECK_EXT_PRESSURE 1
/// Only release until we reach this pressure
#define ONLY_CHECK_INT_PRESSURE 2
