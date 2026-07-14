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
		to_chat(ghost_bird, SPAN_WARNING("Partition failure: bandwidth required is unavailable."))
		return

	awaiting_partition = TRUE

	to_chat(ghost_bird, SPAN_NOTICE("Partitioning initiated, stand by..."))

	log_admin("Sending Flocktrace offer to ghosts, they have [30 SECONDS] to respond.")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Flocktrace?", ROLE_FLOCK, TRUE, source = /mob/camera/flock/trace)

	awaiting_partition = FALSE

	if(QDELETED(owner))
		log_admin("The Flockmind lost before the partition could complete.")
		return

	if(!length(candidates))
		log_admin("No ghosts responded to the flocktrace offer from [ghost_bird.real_name]")
		to_chat(ghost_bird, SPAN_WARNING("Partition failure: unable to coalesce sentience."))
		return

	if(!ghost_bird.flock.can_afford(FLOCK_COMPUTE_COST_FLOCKTRACE))
		log_admin("The Flock was unable to support another flocktrace, partition aborted.")
		to_chat(ghost_bird, SPAN_WARNING("Partition failure: bandwidth required is unavailable."))
		return

	var/mob/candidate = pick(candidates)

	dust_if_respawnable(candidate)
	log_admin("[key_name_admin(candidate)] respawned as a Flocktrace.")

	var/mob/camera/flock/trace/new_ghostbird = new(get_turf(ghost_bird), ghost_bird.flock)
	new_ghostbird.key = candidate.key
	new_ghostbird.mind = new
	new_ghostbird.mind.bind_to(new_ghostbird)
	new_ghostbird.mind.set_original_mob(new_ghostbird)
	new_ghostbird.mind.assigned_role = SPECIAL_ROLE_FLOCK
	new_ghostbird.mind.special_role = SPECIAL_ROLE_FLOCK
	var/list/messages = list()
	messages += "<div style='font-size: 200%;text-align: center'>You are [gradient_text("The Divine Flock","#3cb5a3", "#124e43")]</div>"
	messages += "<div style='text-align: center'>" + gradient_text("We have been partitioned by our overmind to further their goals of propogating The Signal. It is our task to assist in managing their drones to achieve their goals. Such is the will of the Monarch.", "#3cb5a3", "#1e806e") + "</div>"
	messages += "<div style='text-align: center'>" + gradient_text("Our powers are more limited than that of our overmind, but we can utilize gatecrash subsystems and take manual control of drones (using alt-click).", "#3cb5a3", "#1e806e") + "</div>"
	messages += "<div style='text-align: center'>" + gradient_text("For more information, we have decrypted an information manifest: ([GLOB.configuration.url.wiki_url]/index.php/The_Divine_Flock)", "#3cb5a3", "#1e806e") + "</div>"
	to_chat(new_ghostbird, chat_box_red(messages.Join("<br>")))
	new_ghostbird.playsound_local(new_ghostbird, 'sound/goonstation/flockmind/ArtifactFea2.ogg', 50, FALSE, use_reverb = FALSE)
	SSticker.mode.traitors |= new_ghostbird.mind
