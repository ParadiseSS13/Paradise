/**
	* Hallucination - Pulse
	* Spawns random gravitational anomaly warping effects around the player.
*/
#define PULSATING_HALLUCINATION_FILTER "ripple_hallucination"

/obj/effect/hallucination/no_delete/pulsating

/datum/hallucination_manager/pulsating
	initial_hallucination = /obj/effect/hallucination/no_delete/pulsating
	/// How many ripples the hallucination spawns.
	var/amount_spawned
	// These are all variables used by ripple_filter, I'll eventually figure out what they all do
	var/radius
	var/size
	var/falloff
	var/repeat
	var/x_offset
	var/y_offset
	var/atom/movable/plane_master_controller/game_plane_master_controller

/datum/hallucination_manager/pulsating/spawn_hallucination()
	game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		log_debug("No plane master controller found for [owner], ending hallucination.")
		return

	hallucination_list |= initial_hallucination
	on_spawn()
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_trigger)), trigger_time, TIMER_DELETE_ME)

/datum/hallucination_manager/pulsating/on_spawn()
	amount_spawned = roll("4d3-3") // Results in a normal distribution from 1-9. 5 is the most likely result at ~23%
	for(var/i in 1 to amount_spawned)
		randomize_pulse()
		game_plane_master_controller.add_filter(PULSATING_HALLUCINATION_FILTER, 1, ripple_filter(radius, size, falloff, repeat, x_offset, y_offset))
		log_debug("Added pulse effect with params radius = [radius], size = [size], falloff = [falloff], repeat = [repeat], x_offset = [x_offset], y_offset = [y_offset]")
	for(var/filter in game_plane_master_controller.get_filters(PULSATING_HALLUCINATION_FILTER))
		animate(filter, loop = 0, size = 0, time = 5 SECONDS, easing = BOUNCE_EASING)

/datum/hallucination_manager/pulsating/proc/randomize_pulse()
	radius = roll(6)
	size = roll(3)
	falloff = roll(3)
	repeat = roll(3) - 1
	var/x_sign = pick(-1, 1)
	var/y_sign = pick(-1, 1)
	x_offset = roll(50) * x_sign
	y_offset = roll(50) * y_sign

/datum/hallucination_manager/pulsating/on_trigger()
	game_plane_master_controller.remove_filter(PULSATING_HALLUCINATION_FILTER)
	..()


/obj/effect/hallucination/no_delete/pulsating/proc/end_screen_effect(mob/living/carbon/hallucination_target)


#undef PULSATING_HALLUCINATION_FILTER
