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

