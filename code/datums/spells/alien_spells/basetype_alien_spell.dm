/mob/living/carbon/proc/use_plasma_spell(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(amount > vessel.stored_plasma)
		return FALSE
	add_plasma(-amount, user)
	return TRUE

/mob/living/carbon/proc/add_plasma(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	vessel.stored_plasma += amount
	if(vessel.stored_plasma > vessel.max_plasma)
		vessel.stored_plasma = vessel.max_plasma
	user.updatePlasmaDisplay()

/obj/effect/proc_holder/spell/alien_spell
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	base_cooldown = 1 // Very fast
	/// How much plasma it costs to use this
	var/plasma_cost = 0

/obj/effect/proc_holder/spell/alien_spell/Initialize(mapload)
	. = ..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"

/obj/effect/proc_holder/spell/alien_spell/create_new_handler()
	var/datum/spell_handler/alien/H = new
	H.plasma_cost = plasma_cost
	return H
