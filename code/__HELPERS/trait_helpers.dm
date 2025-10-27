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
#define HAS_MIND_TRAIT(target, trait) (istype(target, /datum/mind) ? HAS_TRAIT(target, trait) : (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))
/// Gives a unique trait source for any given datum
#define UNIQUE_TRAIT_SOURCE(target) "unique_source_[target.UID()]"
/// Returns a list of trait sources for this trait. Only useful for wacko cases and internal futzing
/// You should not be using this
#define GET_TRAIT_SOURCES(target, trait) (target.status_traits?[trait] || list())

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//***** MOB TRAITS *****//
#define TRAIT_RESPAWNABLE		"can_respawn_as_ghost_roles"
#define TRAIT_BEING_OFFERED     "offered"
#define TRAIT_BLIND 			"blind"
#define TRAIT_PARAPLEGIC		"paraplegic"
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
#define TRAIT_GOTTAGOFAST		"gottagofast" // -1 slowdown. Trait given by meth and similar substances for running fast.
#define TRAIT_GOTTAGONOTSOFAST	"gottagonotsofast" // -0.5 slowdown. Trait given by nuka cola and umbrae shade, for a slight speed/
#define TRAIT_GOTTAGOSLOW		"gottagoslow" // +1 slowdown. Trait given by being a zombie.
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
#define TRAIT_EXPLOSION_PROOF	"explosion_proof" // Note, this only works for humans.
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
#define TRAIT_PRESSURE_VISION	"pressure_vision"
#define TRAIT_FLASH_PROTECTION	"flash_protection"
#define TRAIT_NIGHT_VISION		"night_vision"
#define TRAIT_EMOTE_MUTE		"emote_mute"
#define TRAIT_HYPOSPRAY_IMMUNE	"hypospray_immune" // For making crew-accessable hyposprays not pierce your clothing
#define TRAIT_RSG_IMMUNE		"rsgimmune" //prevents RSG syringes from piercing your clothing
#define TRAIT_DRASK_SUPERCOOL	"drask_supercool"

/// trait determines if this mob can breed given by /datum/component/breeding
#define TRAIT_MOB_BREEDER "mob_breeder"

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
#define TRAIT_IPC_JOINTS_MAG "ipc_joints_mag" // IPC has weaker limbs but can re-attach them with ease
#define TRAIT_IPC_JOINTS_SEALED "ipc_joints_sealed" // The IPC's limbs will not pop off bar sharp damage (aka like a human), but will take slightly more stamina damage
#define TRAIT_IPC_CAN_EAT "ipc_can_eat" // IPC can eat food
#define TRAIT_HAS_GPS "has_gps" // used for /Stat
#define TRAIT_CAN_VIEW_HEALTH "can_view_health" // Also used for /Stat
#define TRAIT_MAGPULSE "magpulse" // Used for anything that is magboot related
#define TRAIT_NOSLIP "noslip"
#define TRAIT_SCOPED "user_scoped"
#define TRAIT_MEPHEDRONE_ADAPTED "mephedrone_adapted" // Trait that changes the ending effects of twitch leaving your system
#define TRAIT_NOKNOCKDOWNSLOWDOWN "noknockdownslowdown" //If this person has this trait, they are not slowed via knockdown, but they can be hit by bullets like a self knockdown
#define TRAIT_CAN_STRIP "can_strip" // This mob can strip other mobs.
#define TRAIT_CLING_BURSTING "cling_bursting" // This changeling is about to burst into a headslug, block cremation / gibber to prevent nullspace issues
#define TRAIT_I_WANT_BRAINS "mob_zombie" // A general trait for tracking if the mob is a zombie.
#define TRAIT_NON_INFECTIOUS_ZOMBIE "non_infectious_zombie" // A trait for checking if a zombie shouldn't be able to infect other people
#define TRAIT_PLAGUE_ZOMBIE "plague_zombie" // For checking if this is a wizard plague zombie
#define TRAIT_NPC_ZOMBIE "npc_zombie" // A trait for checking if a zombie should act like an NPC and attack
#define TRAIT_ABSTRACT_HANDS "abstract_hands" // Mobs with this trait can only pick up abstract items.
#define TRAIT_LANGUAGE_LOCKED "language_locked" // cant add/remove languages until removed (excludes babel because fuck everything i guess)
#define TRAIT_BSG_IMMUNE "bsg_immune" // Granted by BSG when held, prevents BSG AOE from hitting you
#define TRAIT_PLAYING_CARDS "playing_cards"
#define TRAIT_EMP_IMMUNE "emp_immune" //The mob will take no damage from EMPs
#define TRAIT_EMP_RESIST "emp_resist" //The mob will take less damage from EMPs
#define TRAIT_MINDFLAYER_NULLIFIED "flayer_nullified" //The mindflayer will not be able to activate their abilities, or drain swarms from people
#define TRAIT_FLYING "flying"
#define TRAIT_MED_MACHINE_HALLUCINATING "med_machine_hallucinating"  // medical machines (currently just scanners) will look strange.
/// This mob is antimagic, and immune to spells / cannot cast spells
#define TRAIT_ANTIMAGIC "anti_magic"
/// This allows a person who has antimagic to cast spells without getting blocked
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
/// This mob recently blocked magic with some form of antimagic
#define TRAIT_RECENTLY_BLOCKED_MAGIC "recently_blocked_magic"
#define TRAIT_UNKNOWN "unknown" // The person with this trait always appears as 'unknown'.
#define TRAIT_CRYO_DESPAWNING "cryo_despawning" // dont adminbus this please
#define TRAIT_EXAMINE_HALLUCINATING "examine_hallucinating"
#define TRAIT_WIRE_BLIND "wire_blind" // This doesn't block someone from seeing wires or recalling their position, but randomizes name / function to the user
#define TRAIT_BOOTS_OF_JUMPING "boots_of_jumping" // Mob can do the jump emote without losing stamina

/// Whether or not the user is in a MODlink call, prevents making more calls
#define TRAIT_IN_CALL "in_call"

/// Trait given when a mob has been tipped
#define TRAIT_MOB_TIPPED "mob_tipped"
/// Trait given to mobs that have the basic eating element
#define TRAIT_MOB_EATER "mob_eater"
#define TRAIT_XENOBIO_SPAWNED "xenobio_spawned"

/// Trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "trait_ai_paused"

//***** MIND TRAITS *****/
#define TRAIT_HOLY "is_holy" // The mob is holy in regards to religion
#define TRAIT_TABLE_LEAP "table_leap" // Lets bartender and chef mount tables faster
#define TRAIT_NEVER_MISSES_DISPOSALS "trait_never_misses_disposals" // For janitors landing disposal throws
#define TRAIT_SLEIGHT_OF_HAND "sleight_of_hand"
#define TRAIT_KNOWS_COOKING_RECIPES "knows_cooking_recipes"
#define TRAIT_XENOBIO_SPAWNED_HUMAN "xenobio_spawned_human" // The mob is from xenobio/cargo/botany that has evolved into their greater form. They do not give vampires usuble blood and cannot be converted by cult.

/// used for dead mobs that are observing, but should not be afforded all the same platitudes as full ghosts.
/// This is a mind trait because ghosts can be frequently deleted and we want to be sure this sticks.
#define TRAIT_MENTOR_OBSERVING "mentor_observe"

//***** ITEM AND MOB TRAITS *****//
/// Show what machine/door wires do when held.
#define TRAIT_SHOW_WIRE_INFO "show_wire_info"
///Immune to the SM / makes you immune to it when worn
#define TRAIT_SUPERMATTER_IMMUNE "supermatter_immune"

//***** ITEM TRAITS *****//
#define TRAIT_CMAGGED "cmagged"
/// An item that is being wielded.
#define TRAIT_WIELDED "wielded"
/// Wires on this will have their titles randomized for those with SHOW_WIRES
#define TRAIT_OBSCURED_WIRES "obscured_wires"
/// Makes the item no longer spit out a visible message when thrown
#define TRAIT_NO_THROWN_MESSAGE "no_message_when_thrown"
/// Makes the item not display a message on storage insertion
#define TRAIT_SILENT_INSERTION "silent_insertion"
/// Makes an item active, this is generally used by energy based weapons or toggle based items.
#define TRAIT_ITEM_ACTIVE "item_active"
/// Forbids running broadcast_examine() in examinate().
#define TRAIT_HIDE_EXAMINE "hide_examine"

/// A surgical tool; when in hand in help intent (and with a surgery in progress) won't attack the user
#define TRAIT_SURGICAL			"surgical_tool"

/// An advanced surgical tool. If a surgical tool has this flag, it will be able to automatically repeat steps until they succeed.
#define TRAIT_ADVANCED_SURGICAL	"advanced_surgical"

/// A surgical tool; If a surgical tool has this flag it can be used as an alternative to an open hand in surgery
#define TRAIT_SURGICAL_OPEN_HAND "surgical_hand_alternative"

/// Surgical tools with this trait have their prob_success set to 100 (but is still able to fail from other factors)
#define TRAIT_SURGICAL_CANNOT_FAIL	"surgical_cannot_fail"

/// A wearable item that protects the covered areas from viral infection
#define TRAIT_ANTI_VIRAL "anti_viral"

/// Given to items that have something that absorbs radiation in them that is neither the item or in it's contents
#define TRAIT_ABSORB_RADS "absorb_rads"

/// Prevent mobs on the turf from being affected by anything below that turf, such as a pulse demon going under it. Added by a /obj/structure with creates_cover set to TRUE
#define TRAIT_TURF_COVERED "turf_covered"

///An item that is oiled. If sprayed with water, it's slowdown reverts to normal.
#define TRAIT_OIL_SLICKED "oil_slicked"

///An item that can be pointed at mobs, while on non-help intent.
#define TRAIT_CAN_POINT_WITH "can_point_with"

///An organ that was inserted into a dead mob, that has not been revived yet
#define TRAIT_ORGAN_INSERTED_WHILE_DEAD "organ_inserted_while_dead"

/// Prevents stripping this equipment or seeing it in the strip menu
#define TRAIT_NO_STRIP "no_strip"

/// Prevents seeing this item on examine when on a mob, or seeing it in the strip menu. It's like ABSTRACT, without making the item fail to interact in several ways. The item can still be stripped however, combine with no_strip unless you have a reason not to.
#define TRAIT_SKIP_EXAMINE "skip_examine"

/// A general trait for tracking whether a zombie owned the organ or limb
#define TRAIT_I_WANT_BRAINS_ORGAN "zombie_organ"

/// Trait given by /datum/element/relay_attacker
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"

/// Trait applied to a mob when it gets a required "operational datum" (components/elements). Sends out the source as the type of the element.
#define TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM "element-required"

//****** ORGAN TRAITS *****//

/// Does this person produce loud runechat
#define TRAIT_LOUD "loud"

//***** JOB TRAITS *****//

// med traits

/// allows user to do_after to give bone and IB locations
#define TRAIT_MED_EXAMINE "med_examine"
/// Grants a 85% chance to NOT catch a disease when contract() is called. You'll probably still catch it though with exposure
#define TRAIT_GERMOPHOBE "germophobe"
/// user wont vomit around corpses
#define TRAIT_CORPSE_RESIST "corpse_resist"
/// user will take 25% less tox damage
#define TRAIT_QUICK_HEATER "quick_heater"
/// user can drive the ambulance cart to push people out of the way
#define TRAIT_SPEED_DEMON "speed_demon"

// sci traits

/// user can craft things from the crafting menu in 1/4 time
#define TRAIT_CRAFTY "crafty"
/// User is alloted a higher genetics budget
#define TRAIT_GENETIC_BUDGET "genetic_budget"
/// allows the user to quick-charge borgs by using a battery on them
#define TRAIT_CYBORG_SPECIALIST "cyborg_specialist"

// service traits

/// Allows user to pick weeds with their bare hands
#define TRAIT_GREEN_THUMB "green_thumb"
/// Allows user to use mops faster, and have galoshes slow less
#define TRAIT_JANITOR "janitor"

// Engi traits

/// Allows user to to quick-repair unlocked APCs with a frame and board, and quick-swap cells.alist
#define TRAIT_ELECTRICAL_SPECIALIST "electrical_specialist"
/// Allows user to spray extinguishers further, and gives precisions  = 1 during spray
#define TRAIT_FIRE_FIGHTER "fire_fighter"

// cargo traits

/// allows the user to stuff more items in lockers/crates and wrap them faster
#define TRAIT_PACK_RAT "pack_rat"
/// Allows the user to ????
#define TRAIT_SMITH "tait_smith"
/// Allows faster butchering times
#define TRAIT_BUTCHER "butcher"

/// How much faster pack rats are in wrapping packages as a percentage
#define PACK_RAT_WRAP_SPEEDUP 0.375

// sec traits

/// Gives the user a new tab for being able to open up space law/sop book pages
#define TRAIT_JUDICIAL "judicial"

// command traits

/// Allows user to drink coffee to point rapidly to get others to do what you want
#define TRAIT_COFFEE_SNOB "coffee_snob"


//****** OBJ TRAITS *****//

///An /obj that should not increase the "depth" of the search for adjacency,
///e.g. a storage container or a modsuit.
#define TRAIT_ADJACENCY_TRANSPARENT "adjacency_transparent"

/// A trait for items that will not break glass tables if the user is buckled to them.
#define TRAIT_NO_BREAK_GLASS_TABLES "no_break_glass_tables"

//****** ATOM/MOVABLE TRAITS *****//
/// A trait for determining if a atom/movable is currently crossing into another z-level by using of /turf/space z-level "destination-xyz" transfers
#define TRAIT_CURRENTLY_Z_MOVING "currently_z_moving" // please dont adminbus this

//****** TURF TRAITS *****//
#define TRAIT_RUSTY "rust_trait"

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
#define ZOMBIE_TRAIT "zombie"
#define CHANGELING_TRAIT "changeling"
#define LYING_DOWN_TRAIT "lying_down"
#define SLIME_TRAIT "slime"
#define BERSERK_TRAIT "berserk"
#define EYES_OF_GOD "eyes_of_god"
#define GHOSTED		"isghost"
#define GHOST_ROLE	"ghost_role"
#define ORGAN_TRAIT "organ"
#define JOB_TRAIT "job_trait"

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
#define VEHICLE_TRAIT "vehicle"
#define STAT_TRAIT "stat_trait"
#define TRANSFORMING_TRAIT "transforming"
#define BUCKLING_TRAIT "buckled"
#define TRAIT_WAS_BATONNED "batonged"
#define CLOWN_EMAG "clown_emag"
#define MODSUIT_TRAIT "modsuit_trait"
#define STATION_TRAIT "station-trait"
#define ENFORCER_GLOVES "enforcer_gloves"
#define HOLO_CIGAR "holo_cigar"
#define GLADIATOR "gladiator"
#define PULSEDEMON_TRAIT "pulse_demon"
#define TRAIT_CLOWN_CAR_SQUISHED "squished_by_car"
/// Mentor observing
#define MENTOR_OBSERVING "mobserving"
#define TIPPED_OVER "tipped_over"

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE	"alcohol_tolerance"

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
#define TRAIT_FROM_TENDRIL "from_tendril"
#define TRAIT_TENTACLE_IMMUNE "tentacle_immune"

///Traits given by station traits
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_TRANQUILITE_SHIPMENTS "station_trait_tranquilite_shipments"
#define STATION_TRAIT_UNNATURAL_ATMOSPHERE "station_trait_unnatural_atmosphere"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_CYBERNETIC_REVOLUTION "station_trait_cybernetic_revolution"
#define STATION_TRAIT_BIGGER_PODS "station_trait_bigger_pods"
#define STATION_TRAIT_SMALLER_PODS "station_trait_smaller_pods"
#define STATION_TRAIT_BIRTHDAY "station_trait_birthday"
#define STATION_TRAIT_SPIDER_INFESTATION "station_trait_spider_infestation"
#define STATION_TRAIT_REVOLUTIONARY_TRASHING "station_trait_revolutionary_trashing"
#define STATION_TRAIT_RADIOACTIVE_NEBULA "station_trait_radioactive_nebula"
#define STATION_TRAIT_FORESTED "station_trait_forested"
#define STATION_TRAIT_VENDING_SHORTAGE "station_trait_vending_shortage"
#define STATION_TRAIT_MESSY "station_trait_messy"
#define STATION_TRAIT_TRIAI "station_trait_triai"

//***** TURF TRAITS *****//
/// Removes slowdown while walking on these tiles.
#define TRAIT_BLUESPACE_SPEED "bluespace_speed_trait"

// turf trait sources
#define FLOOR_EFFECT_TRAIT "floor_effect_trait"

/// A web is being spun on this turf presently
#define TRAIT_SPINNING_WEB_TURF "spinning_web_turf"

//***** EFFECT TRAITS *****//
// Causes the effect to go through a teleporter instead of being deleted by it.
#define TRAIT_EFFECT_CAN_TELEPORT "trait_effect_can_teleport"

//***** MOVABLE ATOM TRAITS *****//
// Prevents the atom from being transitioned to another Z level when approaching the edge of the map.
#define TRAIT_NO_EDGE_TRANSITIONS "trait_no_edge_transitions"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"
///every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

//***** PROC WRAPPERS *****//
/// Proc wrapper of add_trait. You should only use this for callback. Otherwise, use the macro.
/proc/callback_add_trait(datum/target, trait, source)
	ADD_TRAIT(target, trait, source)

/// Proc wrapper of remove_trait. You should only use this for callback. Otherwise, use the macro.
/proc/callback_remove_trait(datum/target, trait, source)
	REMOVE_TRAIT(target, trait, source)
