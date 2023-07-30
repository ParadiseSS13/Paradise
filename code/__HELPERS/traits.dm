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
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
			} \
		} \
	} while (0)


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
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)


/**
 * Removes all status traits from a target datum which were NOT added by `sources`.
 *
 * Arguments:
 * * target - The datum to remove the traits from.
 * * sources - The trait source which is being searched for.
 */
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T } \
				};\
				if (!length(_L)) { \
					target.status_traits = null\
				};\
		}\
	} while (0)


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
					if(!target.status_traits) \
						break; \
				} \
			} \
			if(!length(target.status_traits)) { \
				target.status_traits = null; \
			} \
		} \
	} while (0)


#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)


#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)


#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)


#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)


/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//atom traits
/// Trait used to prevent an atom from component radiation emission (see radioactivity.dm)
#define TRAIT_BLOCK_RADIATION	"block_radiation"

//mob traits
#define TRAIT_PACIFISM			"pacifism"
#define TRAIT_WATERBREATH		"waterbreathing"
#define TRAIT_BLOODCRAWL		"bloodcrawl"
#define TRAIT_BLOODCRAWL_EAT	"bloodcrawl_eat"
#define TRAIT_JESTER			"jester"
#define TRAIT_ELITE_CHALLENGER 	"elite_challenger"
#define TRAIT_MUTE				"mute"
#define TRAIT_DEAF				"deaf"
#define TRAIT_SECDEATH			"secdeath"
#define TRAIT_AI_UNTRACKABLE	"AI_untrackable"
#define TRAIT_FAKEDEATH			"fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_XENO_HOST			"xeno_host"	//Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_GOTTAGOFAST		"gottagofast"
#define TRAIT_GOTTAGONOTSOFAST	"gottagonotsofast"
#define TRAIT_CHUNKYFINGERS		"chunkyfingers" //means that you can't use weapons with normal trigger guards.
#define TRAIT_FORCE_DOORS 		"force_doors"

//item traits
#define TRAIT_CMAGGED "cmagged"
#define CMAGGED "clown_emag"
#define ABSTRACT_ITEM_TRAIT "abstract-item"
/// The items needs two hands to be carried
#define TRAIT_NEEDS_TWO_HANDS "needstwohands"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"

//
// common trait sources
#define TRAIT_GENERIC "generic"
#define MAGIC_TRAIT "magic"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define CULT_TRAIT "cult"
#define CLOCK_TRAIT "clockwork_cult"
#define INNATE_TRAIT "innate"
#define CHANGELING_TRAIT "changeling"
#define VAMPIRE_TRAIT "vampire"
#define EAR_DAMAGE "ear_damage"

// unique trait sources
#define CULT_EYES "cult_eyes"
#define CLOCK_HANDS "clock_hands"

// Healing traits
/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

//traits that should be properly converted to genetic mutations one day
#define TRAIT_LASEREYES "laser_eyes"
