/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"

/datum/action/innate/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/innate/minedrone/toggle_light/Activate()
	var/mob/living/basic/mining_drone/user = owner

	if(user.light_on)
		user.set_light(0)
	else
		user.set_light(6)
	user.light_on = !user.light_on
	to_chat(user, "<span class='notice'>You toggle your light [user.light_on ? "on" : "off"].</span>")

/datum/action/innate/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "meson"

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/user = owner
	var/active = TRUE
	if(HAS_TRAIT_FROM(user, TRAIT_MESON_VISION, "minebot"))
		active = FALSE
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "minebot")
	else
		ADD_TRAIT(user, TRAIT_MESON_VISION, "minebot")

	update_user_sight(user)
	to_chat(user, "<span class='notice'>You toggle your meson vision [!active ? "on" : "off"].</span>")

/datum/action/innate/minedrone/toggle_meson_vision/proc/update_user_sight(mob/living/user)
	user.sight = initial(user.sight)
	user.lighting_alpha = initial(user.lighting_alpha)
	if(HAS_TRAIT(user, TRAIT_MESON_VISION))
		user.sight |= SEE_TURFS
		user.lighting_alpha = min(user.lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

/datum/action/innate/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/basic/mining_drone/user = owner
	user.drop_ore()
