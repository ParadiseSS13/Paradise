/mob/living/carbon/proc/use_plasma_spell(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(amount > vessel.stored_plasma)
		return FALSE
	add_plasma(-amount, user)
	return TRUE

/* add_plasma requires a few things to properly work.
1. The user, because we need to add the plasma to the organ itself and check vessel maxplasma stuff
2. The actual amount of plasma, gotta add that too
Updates the spell's actions on use as well, so they know when they can or can't use their powers*/

/mob/living/carbon/proc/add_plasma(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	vessel.stored_plasma += amount
	if(vessel.stored_plasma > vessel.max_plasma)
		vessel.stored_plasma = vessel.max_plasma
	if(isalien(user))
		user.updateplasmadisplay()
	for(var/datum/action/spell_action/action in user.actions)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/alien_spell
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	/// Extremely fast cooldown, only present so the cooldown system doesn't explode
	base_cooldown = 1
	create_attack_logs = FALSE
	/// Every alien spell creates only logs, no attack messages on someone placing weeds, but you DO get attack messages on neurotoxin and corrosive acid
	create_only_logs = TRUE
	/// How much plasma it costs to use this
	var/plasma_cost = 0

/// Every single alien spell uses a "spell name + plasmacost" format
/obj/effect/proc_holder/spell/alien_spell/Initialize(mapload)
	. = ..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"

/obj/effect/proc_holder/spell/alien_spell/create_new_handler()
	var/datum/spell_handler/alien/handler = new
	handler.plasma_cost = plasma_cost
	return handler
