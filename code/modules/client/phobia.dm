/*
	Contains code that keeps track of a players phobias
	This will replace mobs ingame with other sprites to avoid trigger the phobias
*/

/datum/phobia
	/// Who owns this phobia
	var/client/owner
	/// Who is the mob the owner is playing
	var/mob/current_mob
	/// What is the key used for the alt appearance
	var/phobia_key

/datum/phobia/New(client/owner)
	..()
	src.owner = owner
	RegisterSignal(owner.mob.mind, COMSIG_MIND_TRANSER_TO, .proc/on_mob_change)
	enable()
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/on_delete_client)

/datum/phobia/Destroy(force, ...)
	if(current_mob)
		disable()
	owner = null
	. = ..()

/datum/phobia/proc/on_delete_client()
	qdel(src)

/**
 * Returns the atoms that will get a different sprite for the owner
 * Override this to return the affected atoms the phobia should mask
 */
/datum/phobia/proc/get_affected_atoms()
	return

/datum/phobia/proc/enable()
	current_mob = owner.mob
	RegisterSignal(current_mob, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_GHOSTIZED, COMSIG_OBSERVER_RE_ENTER_BODY), .proc/on_mob_change)

	var/list/self = list(current_mob)
	for(var/thing in get_affected_atoms())
		var/atom/A = thing
		A.display_alt_appearance(phobia_key, self)

/datum/phobia/proc/disable()
	if(!current_mob)
		CRASH("No current_mob while disabling phobia. Type: '[type]'")
	UnregisterSignal(current_mob, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_GHOSTIZED, COMSIG_OBSERVER_RE_ENTER_BODY))

	var/list/self = list(current_mob)
	for(var/thing in get_affected_atoms())
		var/atom/A = thing
		A.hide_alt_appearance(phobia_key, self)
	current_mob = null

/datum/phobia/proc/on_mob_change()
	disable()
	enable()

/datum/phobia/spiders
	phobia_key = PHOBIA_ARACHNOPHOBIA

/datum/phobia/spiders/get_affected_atoms()
	var/list/result = list()
	result += GLOB.ts_spiderlist
	for(var/mob/living/simple_animal/hostile/poison/giant_spider/S in GLOB.mob_living_list)
		result += S
	return result

/datum/phobia/spiders/enable()
	..()
	GLOB.arachnophobic_players += current_mob

/datum/phobia/spiders/disable()
	if(!current_mob)
		return ..()
	GLOB.arachnophobic_players -= current_mob
	..()
