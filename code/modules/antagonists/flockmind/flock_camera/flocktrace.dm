/mob/camera/flock/trace
	name = "Flocktrace"
	desc = "The representation of a partition of the will of the flockmind."
	icon_state = "flocktrace"
	base_icon_state = "flocktrace"

	actions_to_grant = list(
		/datum/action/cooldown/flock/gatecrash,
		/datum/action/cooldown/flock/designate_tile,
		/datum/action/cooldown/flock/designate_enemy,
		/datum/action/cooldown/flock/designate_ignore,
		/datum/action/cooldown/flock/ping,
	)

	var/bandwidth_provided = -FLOCK_COMPUTE_COST_FLOCKTRACE

/mob/camera/flock/trace/Initialize(mapload, join_flock)
	. = ..()
	real_name = flock_realname(FLOCK_TYPE_TRACE)
	flock.add_unit(src)
	flock.stat_traces_made++

/mob/camera/flock/trace/Destroy()
	flock?.free_unit(src)
	return ..()

/mob/camera/flock/trace/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> [real_name]"),
		SPAN_FLOCKSAY("<b>Flock:</b> [flock.name || "N/A"]"),
		SPAN_FLOCKSAY("<b>Bandwidth:</b> [flock.bandwidth.has_points()]"),
		SPAN_FLOCKSAY("<b>System Integrity: [flock.get_total_health_percentage()]%</b>"),
		SPAN_FLOCKSAY("<b>Cognition:</b> SYNAPTIC PROCESS"),
		SPAN_FLOCKSAY("<b>###=-</b>"),
	)

/mob/camera/flock/trace/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, bandwidth_provided))
			flock?.bandwidth.adjust_points(-bandwidth_provided)
			..()
			flock?.bandwidth.adjust_points(bandwidth_provided)
			return TRUE

	return ..()
