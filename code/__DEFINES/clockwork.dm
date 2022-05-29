// Clockwork Raret (Power)
/// REMINDER: The clockwork_power(var) and clockwork_beacons(list) have been moved at _glovalvars/game_modes

//Clockwork Magic
// state for spell
#define NO_SPELL 0
#define A_SPELL 1
#define CASTING_SPELL -1

// Clockslab enchant type
#define STUN_SPELL 1
#define KNOCK_SPELL 2
#define REFORM_SPELL 3
#define TELEPORT_SPELL 4
// Ratvarian spear enchant type
#define CONFUSE_SPELL 1
#define DISABLE_SPELL 2
// Clock hammer
#define CRUSH_SPELL 1
#define KNOCKOFF_SPELL 2
// Clockwork robe
#define WEAK_REFLECT_SPELL 1
#define WEAK_ABSORB_SPELL 2
#define INVIS_SPELL 3
// armour
#define REFLECT_SPELL 1
#define FLASH_SPELL 2
#define ABSORB_SPELL 3
#define ARMOR_SPELL 4
// Clockwork gloves
#define FASTPUNCH_SPELL 1
#define STUNHAND_SPELL 2
#define FIRE_SPELL 3
//Shard
#define EMP_SPELL 1
#define TIME_SPELL 2
#define RECONSTRUCT_SPELL 3

// spell_enchant(name, type_SPELL, cost, time SECONDS(def 3), action needs)
GLOBAL_LIST_INIT(clockslab_spells, list(
	new /datum/spell_enchant("Stun", STUN_SPELL, 125, 8),
	new /datum/spell_enchant("Force Passage", KNOCK_SPELL, 100),
	new /datum/spell_enchant("Terraform", REFORM_SPELL, 40),
	new /datum/spell_enchant("Teleportation", TELEPORT_SPELL, 25) // has do_after 5 seconds
))
GLOBAL_LIST_INIT(spear_spells, list(
	new /datum/spell_enchant("Confusion", CONFUSE_SPELL, 80),
	new /datum/spell_enchant("Electrical touch", DISABLE_SPELL, 80)
))
GLOBAL_LIST_INIT(hammer_spells, list(
	new /datum/spell_enchant("Crusher", CRUSH_SPELL, 100),
	new /datum/spell_enchant("Knock off", KNOCKOFF_SPELL, 100)
))
GLOBAL_LIST_INIT(armour_spells, list(
	new /datum/spell_enchant("Reflection", REFLECT_SPELL, 100, 10),
	new /datum/spell_enchant("Flash", FLASH_SPELL, 25, spell_action = TRUE),
	new /datum/spell_enchant("Absorb", ABSORB_SPELL, 100, 10),
	new /datum/spell_enchant("Harden plates", ARMOR_SPELL, 100, 15, spell_action = TRUE)
))
GLOBAL_LIST_INIT(gloves_spell, list(
	new /datum/spell_enchant("Hands of North Star", FASTPUNCH_SPELL, 75, spell_action = TRUE),
	new /datum/spell_enchant("Stunning", STUNHAND_SPELL, 75),
	new /datum/spell_enchant("Red Flame", FIRE_SPELL, 50, spell_action = TRUE)
))
GLOBAL_LIST_INIT(shard_spells, list(
	new /datum/spell_enchant("Electromagnetic Pulse", EMP_SPELL, 500, 20),
	new /datum/spell_enchant("Stop the time", TIME_SPELL, 500, 20),
	new /datum/spell_enchant("Reconstruction", RECONSTRUCT_SPELL, 500, 20)
))
/// Power per crew for summoning. For example if 45 players on station, the Ratvar will demand 45*number.
#define CLOCK_POWER_PER_CREW 400
#define CLOCK_POWER_GAIN_MAXIMUM 1000
/// Power gains permanent
#define CLOCK_POWER_CONVERT 150
#define CLOCK_POWER_SACRIFICE 300
/// Power gains as time progresses. Goes in process() so it makes x power per second.
#define CLOCK_POWER_BEACON 2
#define CLOCK_POWER_GENERATOR 10
#define CLOCK_POWER_COG 1
#define COG_MAX_SIPHON_THRESHOLD 0.25 //The cog will not siphon power if the APC's cell is at this % of power
// amount of metal per brass
#define CLOCK_METAL_TO_BRASS 10

// Clockwork Status
/// At what population does it switch to highpop values
#define CLOCK_POPULATION_THRESHOLD 100
/// Percent for power to reveal (Lowpop)
#define CLOCK_POWER_REVEAL_LOW 0.5
/// Percent clockers to reveal (Lowpop)
#define CLOCK_CREW_REVEAL_LOW 0.25
/// Percent for power to reveal (Highpop)
#define CLOCK_POWER_REVEAL_HIGH 0.3
/// Percent clockers to reveal (Highpop)
#define CLOCK_CREW_REVEAL_HIGH 0.15

// Text
#define CLOCK_GREETING "<span class='clocklarge'>You catch a glimpse of the Realm of Ratvar, the Clockwork Justiciar. \
						You now see how flimsy the world is, you see that it should be open to the knowledge of Ratvar.</span>"

#define CLOCK_CURSES list("A fuel technician just slit his own throat and begged for death.",                                          \
			"The shuttle's navigation programming was replaced by a file containing two words, IT COMES.",                             \
			"The shuttle's custodian tore out his guts and began painting strange shapes on the floor.",                               \
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.", \
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",                \
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",                                      \
			"Steve repeatedly touched a lightbulb until his hands fell off.")

// Misc
#define CLOCK_COLOR "#ffb700"
#define CLOCK_CLOTHING list(/obj/item/clothing/suit/hooded/clockrobe, /obj/item/clothing/suit/armor/clockwork, /obj/item/clothing/gloves/clockwork, /obj/item/clothing/shoes/clockwork, /obj/item/clothing/head/helmet/clockwork)

// Clockwork objective status
#define RATVAR_IS_ASLEEP 0
#define RATVAR_DEMANDS_POWER 1
#define RATVAR_NEEDS_SUMMONING 2
#define RATVAR_HAS_RISEN 3
#define RATVAR_HAS_FALLEN -1

#define RATVAR_SUMMON_POSSIBILITIES 3

//the time amount the Gateway to the Celestial Derelict gets each process tick;
#define GATEWAY_SUMMON_RATE 1
#define GATEWAY_REEBE_FOUND 60 // First stage
#define GATEWAY_RATVAR_COMING 120 // Second stage
#define GATEWAY_RATVAR_ARRIVAL 180 // Third Stage
