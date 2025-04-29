/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask ninjanomnom if they're around
*/

#define RAD_BACKGROUND_RADIATION 9 					// How much radiation is harmless to a mob, this is also when radiation waves stop spreading
													// WARNING: Lowering this value significantly increases SSradiation load

// apply_effect((amount * RAD_MOB_COEFFICIENT) / max(1, (radiation ** 2) * RAD_OVERDOSE_REDUCTION), IRRADIATE, blocked)
#define RAD_MOB_COEFFICIENT 0.20					// Radiation applied is multiplied by this
#define RAD_MOB_SKIN_PROTECTION ((1 / RAD_MOB_COEFFICIENT) + RAD_BACKGROUND_RADIATION)

#define RAD_LOSS_PER_TICK 0.5
#define RAD_TOX_COEFFICIENT 0.08					// Toxin damage per tick coefficient
#define RAD_OVERDOSE_REDUCTION 0.000001				// Coefficient to the reduction in applied rads once the thing, usualy mob, has too much radiation
													// WARNING: This number is highly sensitive to change, graph is first for best results
#define RAD_BURN_THRESHOLD 1000						// Applied radiation must be over this to burn
//Holy shit test after you tweak anything it's said like 6 times in here
//You probably want to plot any tweaks you make so you can see the curves visually
#define RAD_BURN_LOG_BASE 1.1
#define RAD_BURN_LOG_GRADIENT 10000
#define RAD_BURN_CURVE(X) log(1 + ((X - RAD_BURN_THRESHOLD) / RAD_BURN_LOG_GRADIENT)) / log(RAD_BURN_LOG_BASE)

#define RAD_MOB_SAFE 500							// How much stored radiation in a mob with no ill effects

#define RAD_MOB_HAIRLOSS 800						// How much stored radiation to check for hair loss

#define RAD_MOB_MUTATE 1250							// How much stored radiation to check for mutation

#define RAD_MOB_VOMIT 2000							// The amount of radiation to check for vomitting
#define RAD_MOB_VOMIT_PROB 1						// Chance per tick of vomitting

#define RAD_MOB_KNOCKDOWN 2000						// How much stored radiation to check for stunning
#define RAD_MOB_KNOCKDOWN_PROB 1					// Chance of knockdown per tick when over threshold
#define RAD_MOB_KNOCKDOWN_AMOUNT 6 SECONDS 			// Amount of knockdown when it occurs

#define RAD_MOB_GORILLIZE 1500						// How much stored radiation to check for gorillization
#define RAD_MOB_GORILLIZE_PROB 0.1					// Chance of gorillization per tick when over threshold

// Values here are for how much of the radiation is let through
#define RAD_NO_INSULATION 1.0						// Default value for Gamma and Beta insulation
#define RAD_ONE_PERCENT 0.99						// Used by geiger counters
#define RAD_MOB_INSULATION 0.98						// Default value for mobs
#define RAD_VERY_LIGHT_INSULATION 0.9
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION  0.7
#define RAD_HEAVY_INSULATION 0.6
#define RAD_VERY_HEAVY_INSULATION 0.5
#define RAD_EXTREME_INSULATION 0.4
#define RAD_VERY_EXTREME_INSULATION 0.2
#define RAD_GAMMA_WINDOW 0.4						// For directional windows that are activated by gamma radiation
#define RAD_GAMMA_FULL_WINDOW 0.16					// For full tile windows that are activated by gamma radiation
#define RAD_BETA_COLLECTOR 0.2						// Amount of Beta radiation absorbed by collectors
#define RAD_BETA_BLOCKER 0.2						// Amount of Beta radiation blocked by metallic things like walls and airlocks
#define RAD_ALPHA_BLOCKER 0.01						// default value for Alpha insulation
#define RAD_FULL_INSULATION 0						// Unused

// Contamination chance in percent. Mostly used by contaminate_adjacent(atom/source, intensity, emission_type)
#define CONTAMINATION_CHANCE_TURF 1				// Chance to contaminate things while on/in a turf
#define CONTAMINATION_CHANCE_OTHER 10			// Chance to contaminate things while in something like a bag

#define RAD_HALF_LIFE 90							// The half-life of contaminated objects

#define RAD_GEIGER_MEASURE_SMOOTHING 5
#define RAD_GEIGER_GRACE_PERIOD 2

/// The portion of a radiation wave that acts on the source tile.
#define RAD_SOURCE_WEIGHT 0.25

#define ALPHA_RAD 1
#define BETA_RAD 2
#define GAMMA_RAD 3
