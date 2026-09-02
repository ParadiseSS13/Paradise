/mob/living/carbon/proc/use_plasma_spell(amount, mob/living/carbon/user)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(amount > vessel.stored_plasma)
		return FALSE
	add_plasma(-amount)
	return TRUE

/* add_plasma just requires the plasma amount, so admins can easily varedit it and stuff
Updates the spell's actions on use as well, so they know when they can or can't use their powers*/

/mob/living/carbon/proc/add_plasma(amount)
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(!vessel)
		return
	vessel.stored_plasma = clamp(vessel.stored_plasma + amount, 0, vessel.max_plasma)
	update_plasma_display(src)
	for(var/datum/action/spell_action/action in actions)
		action.build_all_button_icons()

/datum/spell/alien_spell
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	base_cooldown = 0
	create_attack_logs = FALSE
	/// Every alien spell creates only logs, no attack messages on someone placing weeds, but you DO get attack messages on neurotoxin and corrosive acid
	create_custom_logs = TRUE
	antimagic_flags = NONE
	/// How much plasma it costs to use this
	var/plasma_cost = 0

/// Every single alien spell uses a "spell name + plasmacost" format
/datum/spell/alien_spell/New()
	..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"
		action.name = name
		action.desc = desc
		action.build_all_button_icons()

/datum/spell/alien_spell/write_custom_logs(list/targets, mob/user)
	user.create_log(ATTACK_LOG, "Cast the spell [name]")

/datum/spell/alien_spell/create_new_handler()
	var/datum/spell_handler/alien/handler = new
	handler.plasma_cost = plasma_cost
	return handler
