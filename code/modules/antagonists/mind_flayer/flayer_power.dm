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
 	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/mindflayer/flayer
	/// Determines whether the power is always given to the changeling or if it must be purchased.
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	/// The cost of purchasing the power.
	var/swarm_cost = 0
	/// What `stat` value the changeling needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS

// Behold, a copypaste from changeling, might need some redoing

/obj/effect/proc_holder/spell/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

/*
 * Mindflayer code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
 */

/obj/effect/proc_holder/spell/flayer/proc/on_purchase(mob/user, datum/antagonist/mindflayer/C, datum/path)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !C)
		qdel(src)
		return
	flayer = C
	flayer.add_ability(path)
	return TRUE

/datum/mindflayer_passive
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///All passives start at level on
	var/level = 1
	var/mob/living/owner

/datum/mindflayer_passive/proc/on_apply(datum/antagonist/mindflayer/flayer)
	return

/datum/mindflayer_passive/proc/on_remove(datum/antagonist/mindflayer/flayer)
	return

// Retractable weapons code

/obj/effect/proc_holder/spell/flayer/weapon
	name = "This really shouldn't be here"
	power_type = FLAYER_UNOBTAINABLE_POWER
	var/weapon_type
	var/weapon_name_simple

/obj/effect/proc_holder/spell/flayer/weapon/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/flayer/weapon/cast(list/targets, mob/user)
	if(istype(user.l_hand, weapon_type) || istype(user.r_hand, weapon_type))
		retract(user, TRUE)
		return
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE
	var/obj/item/W = new weapon_type(user, src)
	user.put_in_hands(W)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)
	return W

/obj/effect/proc_holder/spell/flayer/weapon/proc/retract(atom/target, any_hand = TRUE, mob/owner = src)
	SIGNAL_HANDLER
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	if(owner.l_hand && istype(owner.l_hand, weapon_type))
		qdel(owner.l_hand)
		owner.update_inv_l_hand()
	if(owner.r_hand && istype(owner.r_hand, weapon_type))
		qdel(owner.r_hand)
		owner.update_inv_r_hand()
