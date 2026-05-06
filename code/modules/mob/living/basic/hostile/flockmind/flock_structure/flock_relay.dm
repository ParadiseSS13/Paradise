/obj/structure/flock/relay
	icon = 'goon/icons/obj/featherzone-160x160.dmi'
	icon_state = "structure-relay"

	name = "titanic polyhedron"
	desc = "The sight of the towering geodesic sphere fills you with dread. A thousand voices whisper to you."

	pixel_x = -64
	pixel_y = -64

	flock_desc = "Your goal and purpose. Defend it until it can broadcast the Signal."
	flock_id = "Signal Relay Broadcast Amplifier"

	max_integrity = 500
	move_resist = MOVE_FORCE_OVERPOWERING

	resource_cost = 750

	allow_flockpass = FALSE
	no_flock_decon = TRUE

	/// Time the structure started.
	var/tmp/started_time
	/// How long it takes until the signal is broadcast and the flock wins :D
	var/tmp/win_time = 360 SECONDS
	var/tmp/flock_won_da_game = FALSE

	/// Radius for turf conversion. Automatically increments during processing.
	var/tmp/conversion_radius = 1

	var/tmp/list/turfs_to_convert = list()

/obj/structure/flock/relay/Initialize(mapload, datum/flock/join_flock)
	. = ..()

	started_time = world.time
	flock.set_flock_game_status(FLOCK_ENDGAME_RELAY_BUILT)

	log_game("The Flock ([flock?.name || "NULL"]) has constructed a relay at [AREACOORD(src)].")
	message_admins("The Flock has constructed the relay at [ADMIN_VERBOSEJMP(src)].")
	SSshuttle.registerHostileEnvironment(src, FALSE)

	to_chat(
		flock.overmind,
		span_flocksay(span_big("You pool the collective processing power of The Flock to transmit The Signal. If the relay is destroyed, so to will be The Flock!"))
	)

	flock_talk(null, "THE RELAY HAS BEEN CONSTRUCTED! DEFEND IT AT ALL COSTS, BRING FORTH THE FULL BREADTH OF THE DIVINE FLOCK!", flock)
	addtimer(CALLBACK(src, PROC_REF(announce_relay)), 10 SECONDS)

	START_PROCESSING(SSprocessing, src)

/obj/structure/flock/relay/Destroy()
	SSshuttle.clearHostileEnvironment(src)
	STOP_PROCESSING(SSprocessing, src)

	if(flock && !flock_won_da_game)
		flock.free_structure(src)
		flock.game_over(completely_destroy = TRUE)

	turfs_to_convert = null
	return ..()

/obj/structure/flock/relay/do_hurt_animation()
	return

/obj/structure/flock/relay/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration, allow_break)
	. = ..()
	if(. >= 5)
		var/alpha_min = clamp(255 - . * 6, 100, 255)
		animate(src, time = 0.1 SECONDS, color = list(1.5,0,0,0, 0,1.5,0,0, 0,0,1.5,0, 0,0,0,alpha_min/255, 0,0,0,0))
		animate(time = 0.3 SECONDS, color = null, alpha = 255)

/obj/structure/flock/relay/examine(mob/user)
	. = ..()
	if(flock_won_da_game && !isflockmob(user))
		. += span_flocksay("Your life flashes before your eyes.")

/obj/structure/flock/relay/flock_structure_examine(mob/user)
	var/timeleft = (started_time + win_time - world.time) / 10
	if(timeleft)
		return list(
			span_flocksay("<b>Broadcast In:</b> [(started_time + win_time - world.time) / 10] second\s.")
		)
	else
		return list(
			span_flocksay("<b><i>BROADCASTING IN PROGRESS.</i></b>")
		)

/obj/structure/flock/relay/update_info_tag()
	if(!flock_won_da_game)
		info_tag?.set_text("Broadcast in: [(started_time + win_time - world.time) / 10] second\s")
	else
		info_tag?.set_text("Transmitting")

/obj/structure/flock/relay/process(delta_time)
	if(world.time >= (started_time + win_time))
		lorimer_burst()
		return PROCESS_KILL

	update_info_tag()

	var/turf/base = get_turf(src)

	/// Get a chebyshev ring without gigantic list ops.
	if(!length(turfs_to_convert))
		for(var/xo in -conversion_radius to conversion_radius)
			var/turf/potential_turf = locate(base.x + xo, base.y + conversion_radius, base.z)
			if(potential_turf)
				turfs_to_convert += potential_turf

			potential_turf = locate(base.x - xo, base.y - conversion_radius, base.z)
			if(potential_turf)
				turfs_to_convert += potential_turf

		for(var/yo in -conversion_radius to conversion_radius)
			var/turf/potential_turf = locate(base.x + conversion_radius, base.y + yo, base.z)
			if(potential_turf)
				turfs_to_convert += potential_turf

			potential_turf = locate(base.x - conversion_radius, base.y - yo, base.z)
			if(potential_turf)
				turfs_to_convert += potential_turf

		conversion_radius++

	// Convert 5 turfs per second.
	for(var/i in 1 to min(5, length(turfs_to_convert)))
		var/turf/conversion_target = turfs_to_convert[length(turfs_to_convert)]
		turfs_to_convert.len--
		if(!isflockturf(conversion_target) && !isspaceturf(conversion_target) && !isopenspaceturf(conversion_target))
			flock.claim_turf(conversion_target)

/obj/structure/flock/relay/proc/alert_organics()
	var/list/z_levels = SSmapping.get_zstack(z)
	for(var/mob/M as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in z_levels) && M.can_hear())
			M.playsound_local(M, 'goon/sounds/flockmind/Flock_Reactor.ogg', 30, FALSE)
			to_chat(M, span_flocksay("<b>A horrible, otherworldly wave eminates from the <i>[dir2text(get_dir(mob_turf, loc))]</i>."))

/obj/structure/flock/relay/proc/announce_relay()
	var/message = stars("The Signal is coming.", 10)
	priority_announce(
		message,
		null,
		null,
		ANNOUNCER_SPANOMALIES,
		FALSE,
		TRUE,
	)

/// GG
/obj/structure/flock/relay/proc/lorimer_burst()
	set waitfor = FALSE
	flock_won_da_game = TRUE
	flock.set_flock_game_status(FLOCK_ENDGAME_RELAY_ACTIVATING)

	log_game("The Flock ([flock?.name || "NULL"]) has successfully broadcast The Signal at [AREACOORD(src)].")
	add_overlay("structure_relay_sparks")

	flock_talk(null, "!!! TRASMITTING SIGNAL !!!", flock)
	visible_message(gradient_text("[src] begins sparking wildly! The air is charged with static!", "#3cb5a3", "#124e43"))

	var/sound_len = SSsound_cache.get_sound_length('goon/sounds/flockmind/flock_broadcast_charge.ogg')

	for(var/mob/M as anything in GLOB.player_list)
		if(M.can_hear())
			M.playsound_local(M, 'goon/sounds/flockmind/flock_broadcast_charge.ogg', 30, FALSE)

	sleep(sound_len)

	for(var/mob/M as anything in GLOB.player_list)
		if(M.can_hear())
			M.playsound_local(M, 'goon/sounds/flockmind/flock_broadcast_kaboom.ogg', 30, FALSE)

		if(isliving(M))
			var/mob/living/L = M
			L.flash_act(3, TRUE, TRUE, TRUE, length = 3 SECONDS)

	sleep(2 SECONDS)

	flock.set_flock_game_status(FLOCK_ENDGAME_VICTORY)
	explosion(src, 50, ignorecap = TRUE, explosion_cause = src)

	sleep(2 SECONDS)

	for(var/obj/machinery/telecomms/T in GLOB.telecomms_list)
		T.emp_act(EMP_HEAVY)

	for(var/obj/item/radio/radio as anything in INSTANCES_OF(/obj/item/radio))
		radio.emped = INFINITY
		radio.set_on(FALSE)

		playsound(
			radio,
			pick('goon/sounds/radio_sweep1.ogg','goon/sounds/radio_sweep2.ogg','goon/sounds/radio_sweep3.ogg','goon/sounds/radio_sweep4.ogg','goon/sounds/radio_sweep5.ogg'),
			70,
			TRUE,
		)

		if(!radio.equipped_to)
			continue

		to_chat(radio.equipped_to, span_warning("A final scream of horrific static bursts from your [radio.name]."))
		if(radio.equipped_to.soundbang_act(3, 0))
			radio.equipped_to.Disorient(60 SECONDS, 0, TRUE, 6 SECONDS, 3 SECONDS)

		if(prob(20))
			sleep(0.1 SECONDS)

