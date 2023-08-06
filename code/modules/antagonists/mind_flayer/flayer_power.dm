// OOORAAAH WE HAVE POWERS

// Defines below to be used with the `power_type` var.
/// Denotes that this power is free and should be given to all changelings by default.
#define FLAYER_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define FLAYER_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/datum/action/flayer/weapon].
#define FLAYER_UNOBTAINABLE_POWER	3

/datum/action/flayer
	name = "ERROR 404: ACTION NOT FOUND"
	desc = "" // Fluff
	background_icon_state = "bg_changeling" // TODO: flayer background
 	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/mindflayer/flayer
	/// Determines whether the power is always given to the changeling or if it must be purchased.
	var/power_type = CHANGELING_UNOBTAINABLE_POWER
	/// A description of what the power does.
	var/helptext = ""
	/// The cost of purchasing the power.
	var/swarm_cost = 0
	/// What `stat` value the changeling needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS
	/// If this power is active or not. Used for toggleable abilities.
	var/active = FALSE

// Behold, a copypaste from changeling, might need some redoing

/*
 * Changeling code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
 */
/datum/action/flayer/proc/on_purchase(mob/user, datum/antagonist/changeling/C)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !C)
		qdel(src)
		return
	flayer = C
	Grant(user)
	return TRUE

/datum/action/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

/datum/action/flayer/Trigger()
	try_to_sting(owner)

/datum/action/flayer/proc/try_to_sting(mob/user, mob/target)
	user.changeNext_click(5)
	if(!can_sting(user, target))
		return
	if(sting_action(user, target))
		sting_feedback(user, target)

/datum/action/flayer/proc/sting_action(mob/user, mob/target)
	return FALSE

/datum/action/flayer/proc/sting_feedback(mob/user, mob/target)
	return FALSE

/datum/action/flayer/proc/can_sting(mob/user, mob/target)
	SHOULD_CALL_PARENT(TRUE)
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return FALSE
	return TRUE

// Retractable weapons code

/datum/action/flayer/weapon
	name = "Non-Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	power_type = FLAYER_UNOBTAINABLE_POWER
	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/datum/action/flayer/weapon/try_to_sting(mob/user, mob/target)
	if(istype(user.l_hand, weapon_type) || istype(user.r_hand, weapon_type))
		retract(user, TRUE)
		return
	..(user, target)

/datum/action/flayer/weapon/sting_action(mob/user)
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE
	var/obj/item/W = new weapon_type(user, silent, src)
	user.put_in_hands(W)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)
	return W

/datum/action/flayer/weapon/proc/retract(atom/target, any_hand = FALSE)
	SIGNAL_HANDLER
/*	if(!ischangeling(owner))
		return*/ // TODO: Replace with an isflayer() check later
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	var/done = FALSE
	if(istype(owner.l_hand, weapon_type))
		qdel(owner.l_hand)
		owner.update_inv_l_hand()
		done = TRUE
	if(istype(owner.r_hand, weapon_type))
		qdel(owner.r_hand)
		owner.update_inv_r_hand()
		done = TRUE
	if(done && !silent)
		owner.visible_message("<span class='warning'>With a sickening crunch, [owner] reforms [owner.p_their()] [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
