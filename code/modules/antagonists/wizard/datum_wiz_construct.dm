/datum/antagonist/wizard/construct
	name = "Magical Construct"
	special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
	antag_hud_name = "apprentice"
	antag_datum_blacklist = list(/datum/antagonist/wizard/apprentice)

	should_equip_wizard = FALSE
	should_name_pick = FALSE
	/// Temporary reference to a mob for purposes of objectives, and general text for the apprentice.
	var/mob/living/my_creator

/datum/antagonist/wizard/construct/greet()
	. = ..()
	. += "<span class='danger'>You are [my_creator.real_name]'s construct! You are bound by magic to follow [my_creator.p_their()] orders and help [my_creator.p_them()] in accomplishing [my_creator.p_their()] goals.</span>"

/datum/antagonist/wizard/construct/give_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.target = my_creator.mind
	new_objective.explanation_text = "Protect and obey [my_creator.real_name], your creator."
	add_antag_objective(new_objective)

/datum/antagonist/wizard/construct/on_gain()
	. = ..()
	my_creator = null // all uses of my_creator come before this, so lets clean up the reference.

/datum/antagonist/wizard/construct/add_owner_to_gamemode()
	SSticker.mode.apprentices |= owner

/datum/antagonist/wizard/construct/remove_owner_from_gamemode()
	SSticker.mode.apprentices -= owner

/datum/antagonist/wizard/construct/equip_wizard()
	return

/datum/antagonist/wizard/construct/full_on_wizard()
	return FALSE
