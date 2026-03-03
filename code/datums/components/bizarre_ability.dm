/datum/action/stand/manifest
	name = "Manifest"
	desc = "Show off the manifestation of your soul and gain access to your abilities!"
	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'icons/obj/bizarre_debris.dmi'
	button_icon_state = "arrowhead"
	background_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_pulsedemon"

	// Is this stand currently active?
	var/manifested = FALSE
	var/mutable_appearance/stand_overlay
	var/stand_icon = 'icons/obj/bizarre_debris.dmi'
	var/stand_icon_state = "repair"
	// A list of abilities this stand will grant the user
	var/list/datum/action/stand/manifest/ability_actions = list(/datum/action/stand/testability1, /datum/action/stand/testability2)
	// A list containing the newly created actions given to the user, for deletion
	var/list/datum/action/current_abilities = list()

/datum/action/stand/manifest/Trigger(left_click)
	if(!manifested)
		manifested = TRUE
		stand_overlay = image(icon = stand_icon, icon_state = stand_icon_state, layer = owner.layer -0.01)
		owner.overlays += stand_overlay
		owner.update_icons(UPDATE_OVERLAYS)
		for(var/item in ability_actions)
			var/datum/action/A = new item
			A.Grant(owner)
			current_abilities += A
	else
		manifested = FALSE
		owner.overlays -= stand_overlay
		for(var/datum/action/A in current_abilities)
			A.Remove(owner)

/datum/action/stand/manifest/teststand

/datum/action/stand/testability1
	name = "Test Ability 1"
	desc = "Absolutely useless!"
	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'icons/obj/bizarre_debris.dmi'
	button_icon_state = "repair"
	background_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_pulsedemon"

/datum/action/stand/testability2
	name = "Test Ability 2"
	desc = "Absolutely useless!"
	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'icons/obj/bizarre_debris.dmi'
	button_icon_state = "repair"
	background_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_pulsedemon"
