// OOORAAAH WE HAVE POWERS

// Defines below to be used with the `power_type` var.
/// Denotes that this power is free and should be given to all changelings by default.
#define FLAYER_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define FLAYER_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/obj/effect/proc_holder/spell/flayer/weapon].
#define FLAYER_UNOBTAINABLE_POWER	3

/obj/effect/proc_holder/spell/flayer
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire" // TODO: flayer background
	human_req = TRUE
	clothes_req = FALSE
	/// A reference to the mind flayer's antag datum.
	var/datum/antagonist/mindflayer/flayer
	/// Determines whether the power is always given to the mind flayer or if it must be purchased.
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	/// The cost of purchasing the power.
	var/swarm_cost = 0
	/// What `stat` value the mind flayer needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS
	/// If it's only unlocked after buying a different ability, or abilities.
	var/list/prerequisite = list()


/obj/effect/proc_holder/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self
	
// Behold, a copypaste from changeling, might need some redoing

/obj/effect/proc_holder/spell/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

/*
 * Mindflayer code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec TODO: make Remove()
 */

/obj/effect/proc_holder/spell/flayer/proc/on_purchase(mob/user, datum/antagonist/mindflayer/C, datum/path)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !C)
		qdel(src)
		return
	flayer = C
	flayer.add_ability(path)
	return TRUE
