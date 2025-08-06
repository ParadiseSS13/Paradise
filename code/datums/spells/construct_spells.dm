//////////////////////////////Construct Spells/////////////////////////

/datum/spell/aoe/conjure/construct/lesser
	base_cooldown = 1800
	action_background_icon_state = "bg_cult"

/datum/spell/aoe/conjure/build
	aoe_range = 0

/datum/spell/aoe/conjure/build/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor."
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"
	base_cooldown = 20
	clothes_req = FALSE
	invocation = "none"
	summon_type = list(/turf/simulated/floor/engine/cult)
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

/datum/spell/aoe/conjure/build/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall."
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	clothes_req = FALSE
	invocation = "none"
	summon_type = list(/turf/simulated/wall/cult/artificer) //we don't want artificer-based runed metal farms
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

/datum/spell/aoe/conjure/build/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall."
	base_cooldown = 300
	delay = 50

	summon_type = list(/turf/simulated/wall/r_wall)

/datum/spell/aoe/conjure/build/soulstone
	name = "Summon Soulstone"
	desc = "This spell uses vile sorcery to create a spirit-trapping soulstone."
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_cult"
	base_cooldown = 3000
	clothes_req = FALSE
	invocation = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

	summon_type = list(/obj/item/soulstone)

/datum/spell/aoe/conjure/build/soulstone/holy
	action_icon_state = "summonsoulstone_holy"

	summon_type = list(/obj/item/soulstone/anybody/purified)

/datum/spell/aoe/conjure/build/soulstone/any
	summon_type = list(/obj/item/soulstone/anybody)

/datum/spell/aoe/conjure/build/pylon
	name = "Cult Pylon"
	desc = "This spell uses dark magic to craft an unholy beacon. Heals cultists, and makes a handy light source."
	action_icon_state = "pylon"
	action_background_icon_state = "bg_cult"
	base_cooldown = 200
	clothes_req = FALSE
	invocation = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

	summon_type = list(/obj/structure/cult/functional/pylon)


/datum/spell/aoe/conjure/build/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire."
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	base_cooldown = 300
	clothes_req = FALSE
	invocation = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200

/obj/effect/forcefield/cult
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force."
	name = "eldritch wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_PURE_RED

/datum/spell/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls."
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_cult"
	base_cooldown = 200
	clothes_req = FALSE
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	jaunt_in_time = 12
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out
	jaunt_type_path = /obj/effect/dummy/spell_jaunt/wraith

/datum/spell/ethereal_jaunt/shift/do_jaunt(mob/living/target)
	target.set_light(0)
	..()
	if(isconstruct(target))
		var/mob/living/simple_animal/hostile/construct/C = target
		if(C.holy)
			C.set_light(3, 5, LIGHT_COLOR_DARK_BLUE)
		else
			C.set_light(2, 3, l_color = GET_CULT_DATA(construct_glow, LIGHT_COLOR_BLOOD_MAGIC))

/datum/spell/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return

/datum/spell/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	action_background_icon_state = "bg_cult"
	base_cooldown = 400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	proj_lifespan = 10
	proj_step_delay = 5
	proj_type = /obj/item/projectile/magic/magic_missile/lesser

/datum/spell/projectile/magic_missile/lesser/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.random_target = TRUE
	T.max_targets = 6
	return T

/obj/item/projectile/magic/magic_missile/lesser
	name = "lesser magic missile"
	knockdown = 6 SECONDS
	weaken = 0

/datum/spell/smoke/disable
	name = "Paralyzing Smoke"
	desc = "This spell spawns a cloud of paralyzing smoke."
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"
	base_cooldown = 200
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

	smoke_type = SMOKE_SLEEPING
