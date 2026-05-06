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
	set_real_name(flock_realname(FLOCK_TYPE_TRACE))
	flock.add_unit(src)
	flock.stat_traces_made++

/mob/camera/flock/trace/Destroy()
	flock?.free_unit(src)
	return ..()

/mob/camera/flock/trace/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		span_flocksay("<b>###=- Ident confirmed, data packet received.</b>"),
		span_flocksay("<b>ID:</b> [real_name]"),
		span_flocksay("<b>Flock:</b> [flock.name || "N/A"]"),
		span_flocksay("<b>Bandwidth:</b> [flock.bandwidth.has_points()]"),
		span_flocksay("<b>System Integrity: [flock.get_total_health_percentage()]%</b>"),
		span_flocksay("<b>Cognition:</b> SYNAPTIC PROCESS"),
		span_flocksay("<b>###=-</b>"),
	)

/mob/camera/flock/trace/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, bandwidth_provided))
			flock?.bandwidth.adjust_points(-bandwidth_provided)
			..()
			flock?.bandwidth.adjust_points(bandwidth_provided)
			return TRUE

	return ..()
