/datum/action/cooldown/flock/partition_mind
	name = "Partition Mind"
	button_icon_state = "partition_mind"
	cooldown_time = 60 SECONDS

	var/awaiting_partition = FALSE

/datum/action/cooldown/flock/partition_mind/New()
	..()
	desc = "Divide our computational power, creating a Flocktrace. Requires [FLOCK_COMPUTE_COST_FLOCKTRACE] total bandwidth per trace."

/datum/action/cooldown/flock/partition_mind/is_valid_target(atom/cast_on)
	var/mob/camera/flock/overmind/ghost_bird = owner
	if(awaiting_partition)
		to_chat(ghost_bird, span_warning("We are currently partitioning."))
		return FALSE

	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		to_chat(ghost_bird, span_warning("The Flock does not have enough spare computaional power to support another thread."))
		return FALSE

	if(length(ghost_bird.flock.traces) >= ghost_bird.flock.max_traces)
		if(length(ghost_bird.flock.traces) < floor(FLOCK_COMPUTE_COST_RELAY / FLOCK_COMPUTE_COST_FLOCKTRACE))
			to_chat(ghost_bird, span_warning("The Flock needs more total computational power to support another thread."))
		else
			to_chat(ghost_bird, span_warning("The Flock has hit it's thread limit."))
		return FALSE
	return TRUE

/datum/action/cooldown/flock/partition_mind/Activate(atom/target)
	. = ..()
	do_partition()

/datum/action/cooldown/flock/partition_mind/proc/do_partition()
	set waitfor = FALSE

	awaiting_partition = TRUE
	var/mob/camera/flock/overmind/ghost_bird = owner

	to_chat(ghost_bird, span_flocksay("Partitioning initiated, stand by..."))

	message_admins("Sending Flocktrace offer to ghosts, they have [30 SECONDS] to respond.")
	var/list/candidates = poll_ghost_candidates("Would you like to join the Flock as a new partition?", ROLE_FLOCK, ROLE_FLOCK, 30 SECONDS, flashwindow = TRUE)

	awaiting_partition = FALSE

	if(QDELETED(owner))
		message_admins("The Flockmind lost before the partition could complete.")
		return

	if(!length(candidates))
		message_admins("No ghosts responded to the flocktrace offer from [ghost_bird.real_name]")
		to_chat(ghost_bird, span_flocksay("Partition failure: unable to coalesce sentience."))
		return

	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		message_admins("The Flock was unable to support another flocktrace, partition aborted.")
		to_chat(ghost_bird, span_flocksay("Partition failure: bandwidth required is unavailable."))
		return


	var/mob/candidate = pick(candidates)
	message_admins("[key_name_admin(candidate)] respawned as a Flocktrace.")

	var/mob/camera/flock/trace/new_ghostbird = new(get_turf(ghost_bird), ghost_bird.flock)
	new_ghostbird.PossessByPlayer(candidate.key)
	new_ghostbird.mind.add_antag_datum(/datum/antagonist/flock)
