/datum/action/stand
	name = "Stand Action"
	desc = "If you see this button, something has gone wrong!"
	check_flags = AB_CHECK_CONSCIOUS

	button_icon = 'icons/obj/bizarre_debris.dmi'
	button_icon_state = "arrowhead"
	background_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_pulsedemon"

/datum/action/stand/manifest
	name = "Manifest"
	desc = "Show off the manifestation of your soul and gain access to your abilities!"

	// Is this stand currently active?
	var/manifested = FALSE
	// A separate effect for the stand, as you can't animate overlays reliably and constantly removing and adding overlays is spamming the subsystem.
	var/obj/effect/stand_overlay = null
	var/stand_icon = 'icons/obj/bizarre_debris.dmi'
	var/stand_icon_state = "repair"
	var/image/aura_underlay = null
	var/aura_icon_state = "pinkaura"
	// A list of abilities this stand will grant the user
	var/list/datum/spell/stand/ability_spells = list(/datum/spell/stand/testability)
	// A list containing the newly created actions given to the user, for deletion
	var/list/datum/spell/current_spells = list()

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
		for(var/spell in ability_spells)
			var/datum/spell/A = new spell
			owner.mind.spell_list += A
			current_spells += A
	else
		manifested = FALSE
		UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
		if(stand_overlay)
			qdel(stand_overlay)
			stand_overlay = null
		if(aura_underlay)
			owner.underlays -= aura_underlay
			aura_underlay = null
		for(var/datum/action/A in current_spells)
			owner.mind.spell_list -= A
		current_spells.Cut()

// MARK: STANDS

/datum/action/stand/manifest/repair
	stand_icon_state = "repair"
	aura_icon_state = "pinkaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/repair)

/datum/action/stand/manifest/bomb
	stand_icon_state = "bomb"
	aura_icon_state = "purpleaura"
	ability_spells = list(/datum/spell/stand/repair)

/datum/action/stand/manifest/timestop
	stand_icon_state = "timestop"
	aura_icon_state = "yellowaura"
	ability_spells = list(/datum/spell/stand/timestop)

/datum/action/stand/manifest/timeskip
	stand_icon_state = "timeskip"
	aura_icon_state = "redaura"
	ability_spells = list(/datum/spell/stand/timeskip)

/datum/action/stand/manifest/metal
	stand_icon_state = "metal"
	aura_icon_state = "whiteaura"
	ability_spells = list(/datum/spell/stand/repair)

/datum/action/stand/manifest/erasure
	stand_icon_state = "erasure"
	aura_icon_state = "blueaura"
	ability_spells = list(/datum/spell/stand/repair)

// MARK: STAND ABILITIES

/datum/spell/stand
	name = "Stand Ability"
	desc = "If you see this button, something has gone wrong!"

	base_cooldown = 0
	clothes_req = FALSE
	action_icon = 'icons/obj/bizarre_debris.dmi'
	action_icon_state = "repair"
	action_background_icon = 'icons/mob/actions/actions.dmi'
	action_background_icon_state = "bg_pulsedemon"

/datum/spell/stand/testability
	name = "Test Ability 1"
	desc = "Absolutely useless!"
	action_icon = 'icons/obj/bizarre_debris.dmi'
	action_icon_state = "repair"
	action_background_icon = 'icons/mob/actions/actions.dmi'
	action_background_icon_state = "bg_pulsedemon"

/datum/spell/stand/barrage
	name = "Barrage"
	desc = "Click a target to send a flurry of fists their way! You must stay within 2 tiles of the target to attack."

	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "magicm"

/datum/spell/stand/repair
	name = "Repair Others"
	desc = "Repair the injuries of other creatures. Cannot be performed on its user."

	action_icon_state = "repair"

/datum/spell/stand/timestop
	name = "Stop Time"
	desc = "Stops time in a short radius. ZA WARUDO!"

	base_cooldown = 15 SECONDS
	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "time"

/datum/spell/stand/timestop/cast(list/targets, mob/user)
	var/obj/effect/timestop/stand/T = new /obj/effect/timestop/stand
	T.forceMove(get_turf(user))
	T.immune += user
	new /obj/effect/warp_effect/gravity_generator(get_turf(user))
	for(var/mob/M in range(10, src))
		if(!M.stat && !is_ai(M))\
			shake_camera(M, 3, 1)
	T.timestop()

/datum/spell/stand/timestop/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = 0
	return targeting

/obj/effect/timestop/stand

/obj/effect/timestop/stand/New()
	..()
	for(var/mob/living/M in GLOB.player_list)
		for(var/datum/spell/stand/timestop/T in M.mind.spell_list) // Other timestop users would be able to move in stopped time
			immune |= M

/datum/spell/stand/timeskip
	name = "Time Skip"
	desc = "Erase a moment of time and blink forward!"

	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "spacetime"
