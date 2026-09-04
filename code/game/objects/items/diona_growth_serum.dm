/obj/item/diona_growth_serum
	name = "experimental growth serum"
	desc = "A bottle of an illegal mixture of chemicals, steroids, and stimulants that will cause rapid plant growth and gestalt formation."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	new_attack_chain = TRUE
	/// How much do we refund this for?
	var/refund_cost = 0
	/// Is this discounted?
	var/is_discounted = FALSE

/obj/item/diona_growth_serum/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	if(!isdiona(user))
		to_chat(user, SPAN_WARNING("The contents of the bottle do not react to your touch."))
		return ITEM_INTERACT_COMPLETE
	var/choice = tgui_alert(user, "Are you sure you wish to use [src]?", "Confirm", list("Yes", "No"))
	if(choice != "Yes")
		to_chat(user, SPAN_WARNING("You decide against using [src]."))
		return ITEM_INTERACT_COMPLETE
	to_chat(user, SPAN_NOTICE("You uncork [src] and pour its contents across your form."))
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as the grown gestalt clone of [user.real_name]?", ROLE_TRAITOR, FALSE, 10 SECONDS, source = src, role_cleanname = "Gestalt Clone")
	var/mob/dead/observer/theghost = null

	if(!length(candidates))
		to_chat(user, SPAN_WARNING("The dose of growth serum is ineffective. Perhaps try again later."))
		return ITEM_INTERACT_COMPLETE
	theghost = pick(candidates)
	dust_if_respawnable(theghost)
	spawn_gestalt(user, theghost.key)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/diona_growth_serum/proc/spawn_gestalt(mob/living/carbon/human/user, key)
	var/mob/living/carbon/human/diona/new_gestalt = new(get_turf(user))
	new_gestalt.change_dna(user.dna, FALSE)
	new_gestalt.key = key
	new_gestalt.mind.add_antag_datum(new /datum/antagonist/mindslave/implant(user.mind))
	log_admin("[key_name_admin(user)] has created gestalt clone [key_name_admin(new_gestalt)].")
