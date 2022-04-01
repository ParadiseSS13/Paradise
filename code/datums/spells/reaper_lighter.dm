/obj/effect/proc_holder/spell/reaper_lighter
	name = "Reaper's Lighter"
	desc = "Use this spell next to a vent to turn to smoke and crawl through it, even if the vents are welded. If you do not leave the vents within 15 seconds, you will be pulled back to where you started."

	school = "transmutation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 30 //3 seconds reduction per rank
	should_recharge_after_cast = FALSE //We start recharging manually once we leave the vent system
	nonabstract_req = 1
	sound = 'sound/items/zippolight.ogg'
	action_icon_state = "lighter"

	var/max_ventcrawl_time = 15 SECONDS
	var/ventcrawl_warning_time = 10 SECONDS
	var/time_to_leave = 0 //Set when cast, if you are still in vent by that time, you're pulled back
	var/time_to_warn = 0 //Set when cast, warn the user they're going to leave soon.
	var/warned = FALSE //So we dont repeat warnings over and over
	var/in_progress = FALSE //Are we ventcrawling right now?
	var/turf/starting_vent_turf

/obj/effect/proc_holder/spell/reaper_lighter/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = /obj/machinery/atmospherics/unary
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/bloodcrawl/valid_target(obj/machinery/atmospherics/unary/target, user)
	return is_type_in_list(target, GLOB.ventcrawl_machinery)

/obj/effect/proc_holder/spell/reaper_lighter/cast(list/targets, mob/user = usr)
	var/obj/machinery/atmospherics/unary/target = targets[1]

	if(!target)
		return FALSE
	toggle_traits(usr)
	in_progress = TRUE
	spawn_smoke(get_turf(target))
	starting_vent_turf = get_turf(target)
	user.handle_ventcrawl(target, TRUE)
	time_to_leave = world.time + max_ventcrawl_time
	time_to_warn = world.time + ventcrawl_warning_time
	START_PROCESSING(SSfastprocess, src)

/obj/effect/proc_holder/spell/reaper_lighter/process()
	var/mob/user = action.owner
	if(in_progress)
		if(!warned && world.time > time_to_warn)
			warned = TRUE
			to_chat(user, "<span class='warning'>You will be pulled back to your entry vent soon!</span>")
		if(world.time > time_to_leave)
			toggle_traits(user)
			in_progress = FALSE
			warned = FALSE
			start_recharge()
			spawn_smoke(starting_vent_turf)
			user.forceMove(starting_vent_turf)

	else
		..()

/obj/effect/proc_holder/spell/reaper_lighter/proc/spawn_smoke(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, 0, T)
	smoke.start()

/obj/effect/proc_holder/spell/reaper_lighter/proc/toggle_traits(mob/user)
	if(!in_progress)
		ADD_TRAIT(user, TRAIT_RESISTHEAT, "reaper's lighter")
		ADD_TRAIT(user, TRAIT_RESISTCOLD, "reaper's lighter")
		ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, "reaper's lighter")
		ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, "reaper's lighter")
		ADD_TRAIT(user, TRAIT_NOBREATH, "reaper's lighter")
		ADD_TRAIT(user, TRAIT_BYPASS_WELDED_VENTS, "reaper's lighter")
	else
		REMOVE_TRAIT(user, TRAIT_RESISTHEAT, "reaper's lighter")
		REMOVE_TRAIT(user, TRAIT_RESISTCOLD, "reaper's lighter")
		REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, "reaper's lighter")
		REMOVE_TRAIT(user, TRAIT_RESISTLOWPRESSURE, "reaper's lighter")
		REMOVE_TRAIT(user, TRAIT_NOBREATH, "reaper's lighter")
		REMOVE_TRAIT(user, TRAIT_BYPASS_WELDED_VENTS, "reaper's lighter")
