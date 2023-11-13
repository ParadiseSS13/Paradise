#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines

/**
 * Adds a status trait to the target datum.
 *
 * Arguments: (All Required)
 * * target - The datum to add the trait to.
 * * trait - The trait which is being added.
 * * source - The source of the trait which is being added.
 */
#define ADD_TRAIT(target, trait, source) \
	do { \
		LAZYINITLIST(target.status_traits); \
\
		if(!target.status_traits[trait]) { \
			target.status_traits[trait] = list(source); \
		} else { \
			target.status_traits[trait] |= list(source); \
		} \
\
		SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
	} while(0)

/**
 * Removes a status trait from a target datum.
 *
 * `ROUNDSTART_TRAIT` traits can't be removed without being specified in `sources`.
 * Arguments:
 * * target - The datum to remove the trait from.
 * * trait - The trait which is being removed.
 * * sources - If specified, only remove the trait if it is from this source. (Lists Supported)
 */
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		if(target.status_traits && target.status_traits[trait]) { \
			var/list/SOURCES = sources; \
			if(sources && !islist(sources)) { \
				SOURCES = list(sources); \
			} \
\
			for(var/TRAIT_SOURCE in target.status_traits[trait]) { \
				if((!SOURCES && (TRAIT_SOURCE != ROUNDSTART_TRAIT)) || (TRAIT_SOURCE in SOURCES)) { \
					if(length(target.status_traits[trait]) == 1) { \
						SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
					} \
					LAZYREMOVEASSOC(target.status_traits, trait, TRAIT_SOURCE); \
				} \
			} \
		} \
	} while(0)

/**
 * Removes all status traits from a target datum which were NOT added by `sources`.
 *
 * Arguments:
 * * target - The datum to remove the traits from.
 * * sources - The trait source which is being searched for.
 */
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		if(target.status_traits) { \
			var/list/SOURCES = sources; \
			if(!islist(sources)) { \
				SOURCES = list(sources); \
			} \
\
			for(var/TRAIT in target.status_traits) { \
				if(!target.status_traits[TRAIT]) \
					continue; \
				target.status_traits[TRAIT] &= SOURCES; \
				if(!length(target.status_traits[TRAIT])) { \
					target.status_traits -= TRAIT; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(TRAIT), TRAIT); \
					if(!target.status_traits) \
						break; \
				} \
			} \
			if(!length(target.status_traits)) { \
				target.status_traits = null; \
			} \
		} \
	} while(0)

/**
 * Removes all status traits from a target datum which were added by `sources`.
 *
 * Arguments:
 * * target - The datum to remove the traits from.
 * * sources - The trait source which is being searched for.
 */
#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		if(target.status_traits) { \
			var/list/SOURCES = sources; \
			if(!islist(sources)) { \
				SOURCES = list(sources); \
			} \
\
			for(var/TRAIT in target.status_traits) { \
				if(!target.status_traits[TRAIT]) \
					continue; \
				target.status_traits[TRAIT] -= SOURCES; \
				if(!length(target.status_traits[TRAIT])) { \
					target.status_traits -= TRAIT; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(TRAIT)); \
					if(!target.status_traits) \
						break; \
				} \
			} \
			if(!length(target.status_traits)) { \
				target.status_traits = null; \
			} \
		} \
	} while(0)


#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)
/// A simple helper for checking traits in a mob's mind
#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))
/// Gives a unique trait source for any given datum
#define UNIQUE_TRAIT_SOURCE(target) "unique_source_[UID(target)]"

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//***** MOB TRAITS *****//
#define TRAIT_RESPAWNABLE		"can_respawn_as_ghost_roles"
#define TRAIT_BLIND 			"blind"
#define TRAIT_MUTE				"mute"
#define TRAIT_DEAF				"deaf"
#define TRAIT_NEARSIGHT			"nearsighted"
#define TRAIT_FAT				"fat"
#define TRAIT_HUSK				"husk"
#define TRAIT_BADDNA			"baddna"
#define TRAIT_SKELETONIZED		"skeletonized"
#define TRAIT_CLUMSY			"clumsy"
#define TRAIT_CHUNKYFINGERS		"chunkyfingers" //means that you can't use weapons with normal trigger guards.
#define TRAIT_PACIFISM			"pacifism"
#define TRAIT_IGNORESLOWDOWN	"ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
#define TRAIT_GOTTAGOFAST		"gottagofast"
#define TRAIT_GOTTAGONOTSOFAST	"gottagonotsofast"
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_SHOCKIMMUNE		"shock_immunity"
#define TRAIT_TESLA_SHOCKIMMUNE	"tesla_shock_immunity"
#define TRAIT_TELEKINESIS 		"telekinesis"
#define TRAIT_RESISTHEAT		"resist_heat"
#define TRAIT_RESISTHEATHANDS	"resist_heat_handsonly" //For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTCOLD		"resist_cold"
#define TRAIT_RESISTHIGHPRESSURE	"resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE	"resist_low_pressure"
#define TRAIT_RADIMMUNE			"rad_immunity"
#define TRAIT_GENELESS  		"geneless"
#define TRAIT_VIRUSIMMUNE		"virus_immunity"
#define TRAIT_PIERCEIMMUNE		"pierce_immunity"
#define TRAIT_NOFIRE			"nonflammable"
#define TRAIT_NOHUNGER			"no_hunger"
#define TRAIT_NOBREATH			"no_breath"
#define TRAIT_NOCRITDAMAGE		"no_crit"
#define TRAIT_XRAY_VISION       "xray_vision"
#define TRAIT_THERMAL_VISION    "thermal_vision"
#define TRAIT_XENO_IMMUNE		"xeno_immune" //prevents xeno huggies implanting skeletons
#define TRAIT_BLOODCRAWL		"bloodcrawl"
#define TRAIT_BLOODCRAWL_EAT	"bloodcrawl_eat"
#define TRAIT_DWARF				"dwarf"
#define TRAIT_SILENT_FOOTSTEPS	"silent_footsteps" //makes your footsteps completely silent
#define TRAIT_MESON_VISION		"meson_vision"
#define TRAIT_FLASH_PROTECTION	"flash_protection"
#define TRAIT_NIGHT_VISION		"night_vision"
#define TRAIT_EMOTE_MUTE		"emote_mute"
#define TRAIT_PUNCTURE_IMMUNE	"punctureimmune" //prevents RSG syringes from piercing your clothing

#define TRAIT_NO_BONES 			"no_bones"
#define TRAIT_STURDY_LIMBS		"sturdy_limbs"
#define TRAIT_BURN_WOUND_IMMUNE "burn_immune"
#define TRAIT_IB_IMMUNE			"ib_immune"

#define TRAIT_COMIC_SANS		"comic_sans"
#define TRAIT_CHAV				"chav"
#define TRAIT_NOFINGERPRINTS	"no_fingerprints"
#define TRAIT_SLOWDIGESTION		"slow_digestion"
#define TRAIT_COLORBLIND		"colorblind"
#define TRAIT_WINGDINGS			"wingdings"
#define TRAIT_WATERBREATH		"waterbreathing"
#define TRAIT_NOFAT				"no_fatness"
#define TRAIT_NOGERMS			"no_germs"
#define TRAIT_NODECAY			"no_decay"
#define TRAIT_NOEXAMINE			"no_examine"
#define TRAIT_NOPAIN			"no_pain"
#define TRAIT_FORCE_DOORS 		"force_doors"
#define TRAIT_AI_UNTRACKABLE	"AI_untrackable"
#define TRAIT_REPEATSURGERY		"master_surgeon"  // Lets you automatically repeat surgeries regardless of tool
#define TRAIT_EDIBLE_BUG		"edible_bug" // Lets lizards and other animals that can eat bugs eat ya
#define TRAIT_ELITE_CHALLENGER "elite_challenger"
#define TRAIT_SOAPY_MOUTH		"soapy_mouth"
#define TRAIT_UNREVIVABLE 		"unrevivable" // Prevents changeling revival
#define TRAIT_CULT_IMMUNITY		"cult_immunity"
#define TRAIT_FLATTENED			"flattened"
#define SM_HALLUCINATION_IMMUNE "supermatter_hallucination_immune"
#define TRAIT_NOSELFIGNITION_HEAD_ONLY "no_selfignition_head_only"
#define TRAIT_CONTORTED_BODY	"contorted_body"
#define TRAIT_DEFLECTS_PROJECTILES "trait_deflects_projectiles"
#define TRAIT_XENO_INTERACTABLE	"can_be_interacted_with_by_xenos"
#define TRAIT_DODGE_ALL_OBJECTS "dodges_all_objects" /// Allows a mob to dodge all thrown objects
#define TRAIT_BADASS "trait_badass"
#define TRAIT_FORCED_STANDING "forced_standing" // The mob cannot be floored, or lie down
#define TRAIT_HAS_GPS "has_gps" // used for /Stat
#define TRAIT_CAN_VIEW_HEALTH "can_view_health" // Also used for /Stat

//***** MIND TRAITS *****/
#define TRAIT_HOLY "is_holy" // The mob is holy in regards to religion

//***** ITEM AND MOB TRAITS *****//
/// Show what machine/door wires do when held.
#define TRAIT_SHOW_WIRE_INFO "show_wire_info"
///Immune to the SM / makes you immune to it when worn
#define TRAIT_SUPERMATTER_IMMUNE "supermatter_immune"

//***** ITEM TRAITS *****//
#define TRAIT_BUTCHERS_HUMANS "butchers_humans"
#define TRAIT_CMAGGED "cmagged"
/// An item that is being wielded.
#define TRAIT_WIELDED "wielded"
/// Wires on this will have their titles randomized for those with SHOW_WIRES
#define TRAIT_OBSCURED_WIRES "obscured_wires"
/// Forces open doors after a delay specific to the item
#define TRAIT_FORCES_OPEN_DOORS_ITEM "forces_open_doors_item_varient"

/// A surgical tool; when in hand in help intent (and with a surgery in progress) won't attack the user
#define TRAIT_SURGICAL			"surgical_tool"

/// An advanced surgical tool. If a surgical tool has this flag, it will be able to automatically repeat steps until they succeed.
#define TRAIT_ADVANCED_SURGICAL	"advanced_surgical"

/// Prevent mobs on the turf from being affected by anything below that turf, such as a pulse demon going under it. Added by a /obj/structure with creates_cover set to TRUE
#define TRAIT_TURF_COVERED "turf_covered"

///An item that is oiled. If sprayed with water, it's slowdown reverts to normal.
#define TRAIT_OIL_SLICKED "oil_slicked"

//
// common trait sources
#define TRAIT_GENERIC "generic"
#define EYE_DAMAGE "eye_damage"
#define EAR_DAMAGE "ear_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_TRAIT "magic"
#define SPECIES_TRAIT "species"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define CLOTHING_TRAIT "clothing"
#define CULT_TRAIT "cult"
#define INNATE_TRAIT "innate"
#define VAMPIRE_TRAIT "vampire"
#define CHANGELING_TRAIT "changeling"
#define LYING_DOWN_TRAIT "lying_down"
#define SLIME_TRAIT "slime"
#define BERSERK_TRAIT "berserk"
#define EYES_OF_GOD "eyes_of_god"
#define GHOSTED		"isghost"
#define GHOST_ROLE	"ghost_role"

// unique trait sources
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
#define TRAIT_HULK "hulk"
#define STASIS_MUTE "stasis"
#define SCRYING "scrying" // for mobs that have ghosted, but their ghosts are allowed to return to their body outside of aghosting (spirit rune, scrying orb, etc)
#define SCRYING_ORB "scrying-orb"
#define CULT_EYES "cult_eyes"
#define DOGGO_SPACESUIT "doggo_spacesuit"
#define FLOORCLUWNE "floorcluwne"
#define LOCKDOWN_TRAIT "lockdown"
#define STAT_TRAIT "stat_trait"
#define TRANSFORMING_TRAIT "transforming"
#define BUCKLING_TRAIT "buckled"
#define TRAIT_WAS_BATONNED "batonged"
#define CLOWN_EMAG "clown_emag"
#define MODSUIT_TRAIT "modsuit_trait"
#define ENFORCER_GLOVES "enforcer_gloves"
#define HOLO_CIGAR "holo_cigar"
#define GLADIATOR "gladiator"
#define PULSEDEMON_TRAIT "pulse_demon"


//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"
#define TRAIT_TABLE_LEAP "table_leap"

//traits that should be properly converted to genetic mutations one day
#define TRAIT_LASEREYES "laser_eyes"

//status effec traits
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things.
#define TRAIT_CANNOT_PULL "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"

//***** TURF TRAITS *****//
/// Removes slowdown while walking on these tiles.
#define TRAIT_BLUESPACE_SPEED "bluespace_speed_trait"

// turf trait sources
#define FLOOR_EFFECT_TRAIT "floor_effect_trait"
