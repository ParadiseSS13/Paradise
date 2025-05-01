/// Temperature at which objects contaminated by viruses are disinfected
#define DISINFECTION_TEMP T0C + 60
/// Sent when the conditions to disinfect an atom are met
#define COMSIG_ATOM_DISINFECTED "atom_disinfected"
/// Sent when something is eaten or drunk by a mob
#define COMSIG_MOB_REAGENT_EXCHANGE "mob_reaget_exchange"

/// The maximum amount of symptoms a virus can have
#define VIRUS_SYMPTOM_LIMIT	6

//Visibility Flags
#define HIDDEN_SCANNER	(1<<0)
#define HIDDEN_PANDEMIC	(1<<1)

//Disease Flags
#define CURABLE		(1<<0)
#define CAN_CARRY	(1<<1)
#define CAN_RESIST	(1<<2)

//Spread Flags
#define SPREAD_SPECIAL  (1<<0)
#define SPREAD_NON_CONTAGIOUS	(1<<1)
#define SPREAD_BLOOD			(1<<2)
#define SPREAD_CONTACT_FEET	(1<<3)
#define SPREAD_CONTACT_HANDS	(1<<4)
#define SPREAD_CONTACT_GENERAL	(1<<5)
#define SPREAD_AIRBORNE		(1<<6)


//Severity Defines
#define NONTHREAT	"No threat"
#define MINOR		"Minor"
#define MEDIUM		"Medium"
#define HARMFUL		"Harmful"
#define DANGEROUS 	"Dangerous!"
#define BIOHAZARD	"BIOHAZARD THREAT!"
