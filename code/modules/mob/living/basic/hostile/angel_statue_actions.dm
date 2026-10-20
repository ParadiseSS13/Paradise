/datum/action/cooldown/mob_cooldown/statue/flicker_lights
	name = "Flicker Lights"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state =  "telerune"
	desc = "Flicker a large amount of lights around you."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 90 SECONDS
	shared_cooldown = NONE
	var/aoe_range = 14

/datum/action/cooldown/mob_cooldown/statue/flicker_lights/Activate(atom/target)
	var/mob/living/basic/hostile/statue/caster = owner

	for(var/turf/T in aoe_range)
		for(var/obj/machinery/light/L in T)
			L.forced_flicker()
