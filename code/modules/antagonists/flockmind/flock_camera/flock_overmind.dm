/mob/camera/flock/overmind
	name = "Flockmind"
	desc = "TODO"
	icon_state ="flockmind"

	invisibility = INVISIBILITY_FLOCK
	see_invisible = SEE_INVISIBLE_FLOCK

	actions_to_grant = list(
		/datum/action/cooldown/flock/create_rift,
	)

	/// Granted after create_rift is cast.
	var/list/grant_upon_start = list(
		/datum/action/cooldown/flock/control_panel,
		/datum/action/cooldown/flock/create_structure,
		/datum/action/cooldown/flock/partition_mind,
		/datum/action/cooldown/flock/diffract_drone,
		/datum/action/cooldown/flock/control_drone,
		/datum/action/cooldown/flock/designate_tile,
		/datum/action/cooldown/flock/designate_deconstruct,
		/datum/action/cooldown/flock/designate_enemy,
		/datum/action/cooldown/flock/designate_ignore,
		/datum/action/cooldown/flock/ping,
		/datum/action/cooldown/flock/radio_blast,
		/datum/action/cooldown/flock/gatecrash,
	)

/mob/camera/flock/overmind/Initialize(mapload, join_flock)
	. = ..()
	flock.register_overmind(src)
	set_real_name("Flockmind [flock.name]")

/mob/camera/flock/overmind/Destroy()
	flock?.overmind = null // This shouldnt really happen
	return ..()

/mob/camera/flock/overmind/Login()
	. = ..()
	flock.refresh_unlockables()

/mob/camera/flock/overmind/Logout()
	. = ..()
	// If we disconnect, free our homeboy
	var/datum/action/cooldown/flock/control_drone/control_drone = locate() in actions
	control_drone?.free_drone()

/mob/camera/flock/overmind/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		span_flocksay("<b>###=- Ident confirmed, data packet received.</b>"),
		span_flocksay("<b>ID:</b> [real_name]"),
		span_flocksay("<b>Flock:</b> [flock.name || "N/A"]"),
		span_flocksay("<b>Bandwidth:</b> [flock.bandwidth.has_points()]"),
		span_flocksay("<b>Substrate:</b> [flock.get_total_substrate()]"),
		span_flocksay("<b>System Integrity: [flock.get_total_health_percentage()]%</b>"),
		span_flocksay("<b>Cognition:</b> COMPUTATIONAL NEXUS"),
		span_flocksay("<b>###=-</b>"),
	)

/mob/camera/flock/overmind/get_status_tab_items()
	. = ..()
	. += ""
	. += "Total Bandwidth: [flock.bandwidth.has_points()]"
	. += "Used Bandwidth: [flock.used_bandwidth]"
	. += "Available Bandwidth: [flock.available_bandwidth()]"

/mob/camera/flock/overmind/so_very_sad_death()
	var/datum/flock/old_flock = flock
	flock = null
	old_flock?.overmind = null // to prevent infinite loop
	old_flock.game_over()
	. = ..()

/mob/camera/flock/overmind/proc/spawn_rift(turf/T)
	new /obj/structure/flock/rift(T, flock)

	var/datum/action/cooldown/flock/create_rift/rift_action = locate() in actions
	rift_action.Remove(src)

	for(var/datum/action/A as anything in grant_upon_start)
		A = new A()
		A.Grant(src)

	flock.start()
