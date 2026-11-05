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

	for(var/turf/T in oview(aoe_range, caster))
		for(var/obj/machinery/light/L in T)
			L.forced_flicker()

/datum/action/cooldown/mob_cooldown/statue/blindness
	name = "Blindness"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "blind"
	desc = "Blind nearby victims to advance on them."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 60 SECONDS
	shared_cooldown = NONE
	var/aoe_range = 10

/datum/action/cooldown/mob_cooldown/statue/blindness/Activate(atom/target)
	var/mob/living/basic/hostile/statue/caster = owner

	for(var/mob/living/L in view(aoe_range, caster))
		if(istype(L, /mob/living/basic/hostile/statue))
			continue
		L.EyeBlind(8 SECONDS)
	to_chat(owner, SPAN_WARNING("Your eyes briefly flare, causing blindness in those around you!"))

/datum/action/cooldown/mob_cooldown/statue/night_vision
	name = "Night Vision"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "genetic_view"
	desc = "Toggle enhanced vision in darkness."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 30 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/statue/night_vision/Activate(atom/target)
	var/mob/living/basic/hostile/statue/caster = owner
	switch(caster.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	caster.update_sight()
	to_chat(owner, SPAN_NOTICE("You toggle your night vision."))
	return TRUE
