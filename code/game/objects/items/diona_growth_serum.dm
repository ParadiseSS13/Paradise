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
	var/datum/action/gestalt_communicate/host_comms = new
	var/datum/action/gestalt_communicate/clone_comms = new
	host_comms.Grant(user, new_gestalt)
	clone_comms.Grant(new_gestalt, user)
	log_admin("[key_name_admin(user)] has created gestalt clone [key_name_admin(new_gestalt)].")

/**
 * # Communicate action
 *
 * Allows the diona to communicate with their gestalt.
 */
/datum/action/gestalt_communicate
	name = "Communicate"
	desc = "Communicate telepathically with your gestalt clone."
	button_icon_state = "communicate"
	/// Our gestalt clone
	var/mob/living/carbon/human/diona/gestalt

/datum/action/gestalt_communicate/Grant(mob/M, mob/living/carbon/human/G)
	if(!G || !istype(G))
		stack_trace("/datum/action/gestalt_communicate created with no gestalt to link to.")
		qdel(src)
	gestalt = G
	return ..()

/datum/action/gestalt_communicate/Trigger(left_click)
	var/input = tgui_input_text(owner, "Enter a message to tell your gestalt:", "Message")
	if(!input || !gestalt)
		return

	// Show the message to our guardian and to host.
	to_chat(gestalt, SPAN_CHANGELING("<i>[owner]:</i> [input]"))
	to_chat(owner, SPAN_CHANGELING("<i>[owner]:</i> [input]"))
	log_say("Gestalt Speech: [input]", owner)
	owner.create_log(SAY_LOG, "Gestalt Speech: [input]", gestalt)

	// Show the message to any ghosts/dead players.
	for(var/mob/M in GLOB.dead_mob_list)
		if(M && M.client && M.stat == DEAD && !isnewplayer(M))
			to_chat(M, SPAN_CHANGELING("<i><b>[owner]</b> ([ghost_follow_link(owner, ghost=M)]): [input]</i>"))
