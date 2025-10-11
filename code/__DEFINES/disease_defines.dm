/// Temperature at which objects contaminated by viruses are disinfected
#define VIRUS_DISINFECTION_TEMP (T0C + 60)

/// The maximum amount of symptoms a virus can have
#define VIRUS_SYMPTOM_LIMIT	6

/// The maximum amount of time a symptom will be delayed for after the treating reagents have left the body
#define VIRUS_MAX_CHEM_TREATMENT_TIMER 300
#define VIRUS_CHEM_TREATMENT_TIMER_MOD 2
#define VIRUS_MAX_PHYS_TREATMENT_TIMER 90
#define VIRUS_PHYS_TREATMENT_TIMER_MOD 30

/// Evoltion chance each cycle in percents.
/// The base chance in % that a virus will mutate as it spreads. Further modified by stage speed and the viral evolutionary acceleration trait
#define VIRUS_EVOLUTION_CHANCE 2

//Visibility Flags
#define VIRUS_HIDDEN_SCANNER	(1<<0)
#define VIRUS_HIDDEN_PANDEMIC	(1<<1)

//Disease Flags
#define VIRUS_CURABLE		(1<<0)
#define VIRUS_CAN_CARRY	(1<<1)
#define VIRUS_CAN_RESIST	(1<<2)

//Spread Flags
#define SPREAD_SPECIAL  (1<<0)
#define SPREAD_NON_CONTAGIOUS	(1<<1)
#define SPREAD_BLOOD			(1<<2)
#define SPREAD_CONTACT_FEET	(1<<3)
#define SPREAD_CONTACT_HANDS	(1<<4)
#define SPREAD_CONTACT_GENERAL	(1<<5)
#define SPREAD_AIRBORNE		(1<<6)


//Severity Defines
#define VIRUS_NONTHREAT	"No threat"
#define VIRUS_MINOR		"Minor"
#define VIRUS_MEDIUM		"Medium"
#define VIRUS_HARMFUL		"Harmful"
#define VIRUS_DANGEROUS 	"Dangerous!"
#define VIRUS_BIOHAZARD	"BIOHAZARD THREAT!"
