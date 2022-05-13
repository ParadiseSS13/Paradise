/obj/effect/proc_holder/spell/reaper_lighter
	name = "Reaper's Lighter"
	desc = "Use this spell next to a vent to turn to smoke and crawl through it, even if the vents are welded. If you do not leave the vents within 12 seconds, you will be pulled back to where you started."

	school = "transmutation"
	charge_max = 12 SECONDS
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	level_max = 0 //cannot be improved
	should_recharge_after_cast = FALSE //We start recharging manually once we leave the vent system
	nonabstract_req = TRUE
	sound = 'sound/items/zippolight.ogg'
	action_icon_state = "lighter"

	var/max_ventcrawl_time = 12 SECONDS
	var/ventcrawl_warning_time = 6 SECONDS
	var/time_to_leave = 0 //Set when cast, if you are still in vent by that time, you're pulled back
	var/time_to_warn = 0 //Set when cast, warn the user they're going to leave soon.
	var/warned = FALSE //So we dont repeat warnings over and over
	var/in_progress = FALSE //Are we ventcrawling right now?
	var/turf/starting_vent_turf

/obj/effect/proc_holder/spell/reaper_lighter/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.allowed_type = /obj/machinery/atmospherics/unary
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/reaper_lighter/valid_target(obj/machinery/atmospherics/unary/target, user)
	return is_type_in_list(target, GLOB.ventcrawl_machinery)

/obj/effect/proc_holder/spell/reaper_lighter/cast(list/targets, mob/living/user = usr)
	var/obj/machinery/atmospherics/unary/target = targets[1]

	if(!target)
		charge_counter = charge_max
		return FALSE
	user.apply_status_effect(STATUS_EFFECT_REAPER_LIGHTER)
	in_progress = TRUE
	spawn_smoke(get_turf(target))
	starting_vent_turf = get_turf(target)
	user.handle_ventcrawl(target, TRUE)
	time_to_leave = world.time + max_ventcrawl_time
	time_to_warn = world.time + ventcrawl_warning_time
	START_PROCESSING(SSfastprocess, src)

/obj/effect/proc_holder/spell/reaper_lighter/process()
	var/mob/living/user = action.owner
	if(in_progress)
		if(!warned && world.time > time_to_warn)
			warned = TRUE
			to_chat(user, "<span class='warning'>You will be pulled back to your entry vent soon!</span>")
		if(world.time > time_to_leave)
			user.remove_status_effect(STATUS_EFFECT_REAPER_LIGHTER)
			in_progress = FALSE
			warned = FALSE
			start_recharge()
			spawn_smoke(starting_vent_turf)
			user.forceMove(starting_vent_turf)
			starting_vent_turf = null
	else
		..()

/obj/effect/proc_holder/spell/reaper_lighter/proc/spawn_smoke(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, 0, T)
	smoke.start()
