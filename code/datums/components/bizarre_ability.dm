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
	// A separate effect for the stand, as you can't animate overlays reliably and constantly removing and adding overlays is spamming the subsystem.
	var/obj/effect/stand_overlay = null
	var/stand_icon = 'icons/obj/bizarre_debris.dmi'
	var/stand_icon_state = "repair"
	var/image/aura_underlay = null
	var/aura_icon_state = "pinkaura"
	// A list of abilities this stand will grant the user
	var/list/datum/action/stand/manifest/ability_actions = list(/datum/action/stand/testability1, /datum/action/stand/testability2)
	// A list containing the newly created actions given to the user, for deletion
	var/list/datum/action/current_abilities = list()

/datum/action/stand/manifest/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	stand_overlay.dir = new_dir
	if(new_dir == SOUTH)
		stand_overlay.layer = owner.layer - 0.01
		stand_overlay.pixel_x = 8
		stand_overlay.pixel_y = 8
	if(new_dir == NORTH)
		stand_overlay.layer = owner.layer + 0.01
		stand_overlay.pixel_x = -8
		stand_overlay.pixel_y = 8
	if(new_dir == EAST)
		stand_overlay.layer = owner.layer - 0.01
		stand_overlay.pixel_x = -6
		stand_overlay.pixel_y = 10
	if(new_dir == WEST)
		stand_overlay.layer = owner.layer + 0.01
		stand_overlay.pixel_x = 10
		stand_overlay.pixel_y = 6

/datum/action/stand/manifest/Trigger(left_click)
	if(!manifested)
		manifested = TRUE
		RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
		stand_overlay = new
		stand_overlay.icon = stand_icon
		stand_overlay.icon_state = stand_icon_state
		stand_overlay.dir = owner.dir
		stand_overlay.layer = owner.layer - 0.01
		stand_overlay.mouse_opacity = 0 // This thing covers half the player's sprite
		aura_underlay = image(stand_icon, aura_icon_state, layer = owner.layer - 0.01)
		on_dir_change(owner, null, owner.dir)
		playsound(owner.loc, 'sound/misc/bizarresummon.ogg', 50, FALSE)
		stand_overlay.alpha = 0
		animate(stand_overlay, alpha = 255, 0.2 SECONDS)
		owner.vis_contents += stand_overlay
		owner.underlays += aura_underlay
		for(var/item in ability_actions)
			var/datum/action/A = new item
			A.Grant(owner)
			current_abilities += A
	else
		manifested = FALSE
		UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
		if(stand_overlay)
			qdel(stand_overlay)
			stand_overlay = null
		if(aura_underlay)
			owner.underlays -= aura_underlay
			aura_underlay = null
		for(var/datum/action/A in current_abilities)
			A.Remove(owner)
		current_abilities.Cut()

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
