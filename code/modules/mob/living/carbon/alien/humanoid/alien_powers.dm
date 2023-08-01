/datum/action/innate/alien_nightvision_toggle
	name = "Toggle Night Vision"
	button_icon_state = "meson"


/datum/action/innate/alien_nightvision_toggle/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		return

	if(!host.nightvision)
		host.see_in_dark = 8
		host.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		host.nightvision = TRUE
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
		host.update_sight()
		return

	if(host.nightvision)
		host.see_in_dark = initial(host.see_in_dark)
		host.lighting_alpha = initial(host.lighting_alpha)
		host.nightvision = FALSE
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"
		host.update_sight()
		return


/proc/playsound_xenobuild(object)
	var/turf/object_turf = get_turf(object)

	if(!object_turf)
		return

	playsound(object_turf, pick('sound/creatures/alien/xeno_resin_build1.ogg', \
								'sound/creatures/alien/xeno_resin_build2.ogg', \
								'sound/creatures/alien/xeno_resin_build3.ogg'), 30)


//Small sprites
/datum/action/innate/small_sprite_alien
	name = "Переключить спрайт"
	desc = "Остальные продолжат видеть вас огромным."
	button_icon_state = "mech_cycle_equip_off"
	check_flags = AB_CHECK_CONSCIOUS
	var/small = FALSE
	var/small_icon = 'icons/mob/alien.dmi'
	var/small_icon_state = "alienq_running"


/datum/action/innate/small_sprite_alien/praetorian
	small_icon_state = "aliens_running"


/datum/action/innate/small_sprite_alien/Trigger()
	. = ..()
	if(!.)
		return

	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance("smallsprite", I, list(owner))
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE

