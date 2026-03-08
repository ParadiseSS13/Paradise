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
		stand_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		aura_underlay = image(stand_icon, aura_icon_state, layer = 3.79)
		on_dir_change(owner, null, owner.dir)
		playsound(owner.loc, 'sound/misc/bizarresummon.ogg', 50, TRUE)
		stand_overlay.alpha = 0
		animate(stand_overlay, alpha = 255, 0.2 SECONDS)
		owner.vis_contents += stand_overlay
		owner.underlays += aura_underlay
		for(var/spell in ability_spells)
			var/datum/spell/A = new spell
			owner.AddSpell(A)
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
		for(var/datum/spell/A in current_spells)
			owner.RemoveSpell(A)

// MARK: STANDS

/datum/action/stand/manifest/repair
	stand_icon_state = "repair"
	aura_icon_state = "pinkaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/repair)

/datum/action/stand/manifest/bomb
	stand_icon_state = "bomb"
	aura_icon_state = "purpleaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/repair)

/datum/action/stand/manifest/timestop
	stand_icon_state = "timestop"
	aura_icon_state = "yellowaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/timestop)

/datum/action/stand/manifest/timeskip
	stand_icon_state = "timeskip"
	aura_icon_state = "redaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/timeskip)

/datum/action/stand/manifest/metal
	stand_icon_state = "metal"
	aura_icon_state = "whiteaura"
	ability_spells = list(/datum/spell/stand/repair)

/datum/action/stand/manifest/erasure
	stand_icon_state = "erasure"
	aura_icon_state = "blueaura"
	ability_spells = list(/datum/spell/stand/barrage, /datum/spell/stand/erasure, /datum/spell/stand/greater_erasure)

// MARK: STAND ABILITIES

/datum/spell/stand
	name = "Stand Ability"
	desc = "If you see this button, something has gone wrong!"

	base_cooldown = 0
	starts_charged = FALSE
	clothes_req = FALSE
	action_icon = 'icons/obj/bizarre_debris.dmi'
	action_icon_state = "repair"
	action_background_icon = 'icons/mob/actions/actions.dmi'
	action_background_icon_state = "bg_pulsedemon"

/datum/spell/stand/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T

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

	base_cooldown = 20 SECONDS
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

	base_cooldown = 10 SECONDS
	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "spacetime"

/datum/spell/stand/timeskip/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/stand/timeskip/cast(list/targets, mob/user)
	var/dir = user.dir
	var/turf/current = get_turf(user)
	var/turf/next
	var/turf/last_valid = current

	for(var/i = 1 to 7)
		next = get_step(current, dir)
		if(!next)
			break
		if(next.density)
			break
		var/blocked = FALSE
		for(var/atom/movable/A in next)
			if(!isliving(A) && A.density)
				blocked = TRUE
				break
		if(blocked)
			break
		last_valid = next
		current = next

	if(last_valid != get_turf(user))
		user.forceMove(last_valid)

	for(var/mob/living/M in view(7, user))
		var/m_dir = M.dir
		var/turf/m_current = get_turf(M)
		var/turf/m_next
		var/turf/m_last_valid = m_current

		for(var/i = 1 to 7)
			m_next = get_step(m_current, m_dir)
			if(!m_next)
				break
			if(m_next.density)
				break

			var/m_blocked = FALSE
			for(var/atom/movable/A in m_next)
				if(!isliving(A) && A.density)
					m_blocked = TRUE
					break

			if(m_blocked)
				break

			m_last_valid = m_next
			m_current = m_next

		if(m_last_valid != get_turf(M))
			M.forceMove(m_last_valid)

		if(!M.client)
			continue

		var/atom/movable/screen/fullscreen/stretch/cursor_catcher/timeskip/C
		C = M.overlay_fullscreen("timeskip", /atom/movable/screen/fullscreen/stretch/cursor_catcher/timeskip, 0)
		C.assign_to_mob(M)
		M.playsound_local(M.loc, 'sound/misc/bizarretimeskip.ogg', 75, FALSE)
		addtimer(CALLBACK(src, PROC_REF(remove_timeskip_overlay), M), 1 SECONDS)


/datum/spell/stand/timeskip/proc/remove_timeskip_overlay(mob/M)
	if(!M)
		return
	M.clear_fullscreen("timeskip")


/atom/movable/screen/fullscreen/stretch/cursor_catcher/timeskip
	icon = 'icons/mob/screen_timeskip.dmi'
	icon_state = "timeskip"

/datum/spell/stand/erasure
	name = "Space Erasure"
	desc = "Erase a pocket of space above a selected tile, at a distance calculated such that it will only pull you in."

	base_cooldown = 5 SECONDS
	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "emp"

/datum/spell/stand/erasure/cast(list/targets, mob/user)
	var/turf/cast_on = targets[1]
	space_erasure(cast_on, user)

/datum/spell/stand/erasure/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.range = 7
	T.allowed_type = /turf/simulated/floor
	T.use_turf_of_user = TRUE
	return T

/datum/spell/stand/erasure/proc/space_erasure(turf/T, mob/user)
	new /obj/effect/temp_visual/space_erasure(T)
	playsound(T, 'sound/misc/bizarreerasure.ogg', 50, TRUE)
	user.throw_at(T, 20, 1)

/datum/spell/stand/greater_erasure
	name = "Greater Erasure"
	desc = "Erase a pocket of space above a selected tile, pulling in everything around it, including you!"

	base_cooldown = 10 SECONDS
	action_icon = 'icons/mob/actions/actions.dmi'
	action_icon_state = "pd_emp"

/datum/spell/stand/greater_erasure/cast(list/targets, mob/user)
	var/turf/cast_on = targets[1]
	greater_space_erasure(cast_on)

/datum/spell/stand/greater_erasure/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.range = 7
	T.allowed_type = /turf/simulated/floor
	T.use_turf_of_user = TRUE
	return T

/datum/spell/stand/greater_erasure/proc/greater_space_erasure(turf/T)
	new /obj/effect/temp_visual/space_erasure(T)
	playsound(T, 'sound/misc/bizarreerasure.ogg', 50, TRUE)
	for(var/atom/movable/X in view(7, T))
		if(iseffect(X))
			continue
		if(X && !X.anchored && X.move_resist <= MOVE_FORCE_DEFAULT)
			X.throw_at(T, 20, 1)

/obj/effect/temp_visual/space_erasure
	icon_state = "m_shield"
	duration = 0.8 SECONDS
