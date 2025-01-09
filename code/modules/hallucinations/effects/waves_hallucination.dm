/**
	* Hallucination - Waves
	*
	* Makes the owner's screen all funky and wavy.
*/
#define WAVES_HALLUCINATION_FILTER "ripple_hallucination"
#define WAVE_VERTICAL 0

/obj/effect/hallucination/no_delete/waves

/datum/hallucination_manager/waves
	initial_hallucination = /obj/effect/hallucination/no_delete/waves
	trigger_time = 20 SECONDS
	/// How many wave filters the hallucination spawns.
	var/amount_spawned
	// Maximum distortion size in pixels
	var/size
	/// Phase of wave, in periods
	var/phase_offset
	/// How many pixels each wave will be off in the y direction
	var/x_offset
	/// How many pixels each wave will be off in the y direction
	var/y_offset
	/// If the filter will be sideways or vertical
	var/orientation
	var/atom/movable/plane_master_controller/game_plane_master_controller

/datum/hallucination_manager/waves/spawn_hallucination()
	game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		log_debug("No plane master controller found for [owner], ending hallucination.")
		return
	hallucination_list |= initial_hallucination
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_trigger)), trigger_time, TIMER_DELETE_ME) // Put the timer first so in case something goes wrong the filters still get deleted
	on_spawn()

/datum/hallucination_manager/waves/on_spawn()
	amount_spawned = roll("4d3-3") // Results in a normal distribution from 1-9. 5 is the most likely result at ~23%
	for(var/i in 1 to amount_spawned)
		randomize_pulse()
		game_plane_master_controller.add_filter(WAVES_HALLUCINATION_FILTER, 1, wave_filter(x_offset, y_offset, size, phase_offset, orientation))
	game_plane_master_controller.transition_filter(WAVES_HALLUCINATION_FILTER, 20 SECONDS, list("x" = x_offset + 15, "y" = y_offset - 15, "offset" = phase_offset + 1), BOUNCE_EASING|EASE_IN|EASE_OUT)

/datum/hallucination_manager/waves/proc/randomize_pulse()
	size = rand() * 2.5 + 0.5 //between .05 and 3 pixels
	phase_offset = rand()
	var/x_sign = pick(-1, 1)
	var/y_sign = pick(-1, 1)
	orientation = pick(WAVE_SIDEWAYS, WAVE_VERTICAL)
	x_offset = roll(5) * x_sign
	y_offset = roll(5) * y_sign

/datum/hallucination_manager/waves/on_trigger()
	game_plane_master_controller.remove_filter(WAVES_HALLUCINATION_FILTER)
	qdel(src)

#undef WAVES_HALLUCINATION_FILTER
#undef WAVE_VERTICAL
