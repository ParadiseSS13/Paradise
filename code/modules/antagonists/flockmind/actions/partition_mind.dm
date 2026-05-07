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
		to_chat(ghost_bird, SPAN_WARNING("We are currently partitioning."))
		return FALSE

	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		to_chat(ghost_bird, SPAN_WARNING("The Flock does not have enough spare computaional power to support another thread."))
		return FALSE

	if(length(ghost_bird.flock.traces) >= ghost_bird.flock.max_traces)
		if(length(ghost_bird.flock.traces) < floor(FLOCK_COMPUTE_COST_RELAY / FLOCK_COMPUTE_COST_FLOCKTRACE))
			to_chat(ghost_bird, SPAN_WARNING("The Flock needs more total computational power to support another thread."))
		else
			to_chat(ghost_bird, SPAN_WARNING("The Flock has hit it's thread limit."))
		return FALSE
	return TRUE

/datum/action/cooldown/flock/partition_mind/Activate(atom/target)
	. = ..()
	do_partition()

/datum/action/cooldown/flock/partition_mind/proc/do_partition()
	set waitfor = FALSE
	var/mob/camera/flock/overmind/ghost_bird = owner
	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		to_chat(ghost_bird, SPAN_FLOCKSAY("Partition failure: bandwidth required is unavailable."))
		return

	awaiting_partition = TRUE

	to_chat(ghost_bird, SPAN_FLOCKSAY("Partitioning initiated, stand by..."))

	log_admin("Sending Flocktrace offer to ghosts, they have [30 SECONDS] to respond.")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Flocktrace?", ROLE_FLOCK, TRUE, source = /mob/camera/flock/trace)

	awaiting_partition = FALSE

	if(QDELETED(owner))
		log_admin("The Flockmind lost before the partition could complete.")
		return

	if(!length(candidates))
		log_admin("No ghosts responded to the flocktrace offer from [ghost_bird.real_name]")
		to_chat(ghost_bird, SPAN_FLOCKSAY("Partition failure: unable to coalesce sentience."))
		return

	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		log_admin("The Flock was unable to support another flocktrace, partition aborted.")
		to_chat(ghost_bird, SPAN_FLOCKSAY("Partition failure: bandwidth required is unavailable."))
		return

	var/mob/candidate = pick(candidates)
	var/player_key = candidate.key
	log_admin("[key_name_admin(candidate)] respawned as a Flocktrace.")

	var/mob/camera/flock/trace/new_ghostbird = new(get_turf(ghost_bird), ghost_bird.flock)
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_ghostbird)
	dust_if_respawnable(candidate)
	player_mind.assigned_role = SPECIAL_ROLE_FLOCK
	player_mind.special_role = SPECIAL_ROLE_FLOCK
	player_mind.add_antag_datum(/datum/antagonist/flock)
	SSticker.mode.traitors |= player_mind
