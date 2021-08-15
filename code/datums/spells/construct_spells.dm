//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	action_icon_state = "artificer"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = 0
	return T


/obj/effect/proc_holder/spell/aoe_turf/conjure/build/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor"
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	charge_max = 20
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	summon_type = list(/turf/simulated/floor/engine/cult)
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall"
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	charge_max = 100
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	summon_type = list(/turf/simulated/wall/cult/artificer) //we don't want artificer-based runed metal farms
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"
	school = "conjuration"
	charge_max = 300
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	delay = 50

	summon_type = list(/turf/simulated/wall/r_wall)

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Redspace, summoning one of the legendary fragments across time and space"
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	charge_max = 3000
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

	summon_type = list(/obj/item/soulstone)

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/soulstone/holy
	action_icon_state = "summonsoulstone_holy"

	summon_type = list(/obj/item/soulstone/anybody/purified)

/obj/effect/proc_holder/spell/aoe_turf/conjure/build/pylon
	name = "Cult Pylon"
	desc = "This spell conjures a fragile crystal from Redspace. Makes for a convenient light source."
	action_icon_state = "pylon"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	charge_max = 200
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel

	summon_type = list(/obj/structure/cult/functional/pylon)


/obj/effect/proc_holder/spell/aoe_turf/conjure/build/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200

/obj/effect/forcefield/cult
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force"
	name = "eldritch wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_PURE_RED

/obj/effect/proc_holder/spell/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_cult"
	charge_max = 200
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	jaunt_in_time = 12
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out

/obj/effect/proc_holder/spell/ethereal_jaunt/shift/do_jaunt(mob/living/target)
	target.set_light(0)
	..()
	if(isconstruct(target))
		var/mob/living/simple_animal/hostile/construct/C = target
		if(C.holy)
			C.set_light(3, 5, LIGHT_COLOR_DARK_BLUE)
		else
			C.set_light(2, 3, l_color = SSticker.cultdat ? SSticker.cultdat.construct_glow : LIGHT_COLOR_BLOOD_MAGIC)

/obj/effect/proc_holder/spell/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return

/obj/effect/proc_holder/spell/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	action_background_icon_state = "bg_cult"
	school = "evocation"
	charge_max = 400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	proj_lifespan = 10

/obj/effect/proc_holder/spell/projectile/magic_missile/lesser/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.random_target = TRUE
	T.max_targets = 6
	return T

/obj/effect/proc_holder/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	charge_max = 200
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 3
	smoke_amt = 10
