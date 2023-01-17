/obj/structure/clockwork/functional/celestial_gateway
	name = "Ark of the Clockwork Justicar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	max_integrity = 500
	mouse_opacity = MOUSE_OPACITY_ICON
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_default"
	light_range = 2
	light_power = 4
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY

	var/seconds_until_activation = 0
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/purpose_fulfilled = FALSE
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/clockwork/functional/celestial_gateway/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	GLOB.poi_list |= src
	visible_message("<span class='boldwarning'>[src] shudders and roars to life, its parts beginning to whirr and screech!</span>")
	GLOB.ark_of_the_clockwork_justiciar = src
	if(!countdown)
		countdown = new(src)
		countdown.start()

/obj/structure/clockwork/functional/celestial_gateway/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(SSticker.mode.clocker_objs.clock_status != RATVAR_HAS_RISEN)
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, "<span class='clocklarge'>The Ark has fallen!</span>")
	if(countdown)
		qdel(countdown)
		countdown = null
	GLOB.poi_list.Remove(src)
	GLOB.ark_of_the_clockwork_justiciar = null
	for(var/mob/M as anything in GLOB.mob_list)
		M.stop_sound_channel(CHANNEL_JUSTICAR_ARK)
	. = ..()

/obj/structure/clockwork/functional/celestial_gateway/deconstruct(disassembled)
	if(!disassembled)
		resistance_flags |= INDESTRUCTIBLE
		countdown.stop()
		visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
		sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/magic/clockwork/clockcult_gateway_disrupted.ogg'))
		icon_state = "clockwork_gateway_disrupted"
		resistance_flags |= INDESTRUCTIBLE
		sleep(2.7 SECONDS)
		explosion(src, 1, 3, 8, 8)
		sound_to_playing_players('sound/effects/explosionfar.ogg', volume = 50)
	qdel(src)

/obj/structure/clockwork/functional/celestial_gateway/ex_act(severity)
	var/damage = max((obj_integrity * 0.7) / severity, 100)
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/clockwork/functional/celestial_gateway/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		to_chat(user, "<span class='warning'>You can't unsecure this large set of parts! It would be even dangerous to do!</span>")
		return FALSE
	..()

/obj/structure/clockwork/functional/celestial_gateway/examine(mob/user)
	. = ..()
	if(isclocker(user) || isobserver(user))
		switch(seconds_until_activation)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				to_chat(user, "<span class='heavy_brass'>The Ark is feeding power into the bluespace field.</span>")
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				to_chat(user, "<span class='heavy_brass'>The field is ripping open a copy of itself in Ratvar's prison.</span>")
			if(GATEWAY_RATVAR_COMING to INFINITY)
				to_chat(user, "<span class='heavy_brass'>With the bluespace field established, Ratvar is preparing to come through!</span>")
	else
		switch(seconds_until_activation)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				to_chat(user, "<span class='warning'>You see a swirling bluespace anomaly steadily growing in intensity.</span>")
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				to_chat(user, "<span class='warning'>The anomaly is stable, and you can see flashes of something from it.</span>")
			if(GATEWAY_RATVAR_COMING to INFINITY)
				to_chat(user, "<span class='boldwarning'>The anomaly is stable! Something is coming through!</span>")

/obj/structure/clockwork/functional/celestial_gateway/process()
	adjust_clockwork_power(10)
	if(!obj_integrity)
		return
	for(var/turf/simulated/wall/W in RANGE_TURFS(2, src))
		W.dismantle_wall()
	for(var/obj/O in orange(1, src))
		if(!O.pulledby && !istype(O, /obj/effect) && O.density)
			if(!step_away(O, src, 2) || get_dist(O, src) < 2)
				O.take_damage(50, BURN, "bomb")
			O.update_icon()
	seconds_until_activation += GATEWAY_SUMMON_RATE
	switch(seconds_until_activation)
		if(-INFINITY to GATEWAY_REEBE_FOUND)
			if(!first_sound_played)
				sound_to_playing_players('sound/magic/clockwork/invoke_general.ogg', 30, FALSE)
				sound_to_playing_players(volume = 20, channel = CHANNEL_JUSTICAR_ARK, pressure_affected = FALSE, S = sound('sound/magic/clockwork/clockcult_gateway_charging.ogg', TRUE))
				first_sound_played = TRUE
				icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!second_sound_played)
				sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, pressure_affected = FALSE, S = sound('sound/magic/clockwork/clockcult_gateway_active.ogg', TRUE))
				second_sound_played = TRUE
				icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!third_sound_played)
				sound_to_playing_players(volume = 40, channel = CHANNEL_JUSTICAR_ARK, pressure_affected = FALSE, S = sound('sound/magic/clockwork/clockcult_gateway_closing.ogg', TRUE))
				third_sound_played = TRUE
				icon_state = "clockwork_gateway_closing"
		if(GATEWAY_RATVAR_ARRIVAL to INFINITY)
			if(!purpose_fulfilled)
				countdown.stop()
				resistance_flags |= INDESTRUCTIBLE
				purpose_fulfilled = TRUE
				animate(src, transform = matrix() * 1.5, alpha = 255, time = 12.5 SECONDS)
				sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, pressure_affected = FALSE, S = sound('sound/effects/ratvar_rises.ogg')) //End the sounds
				sleep(12.5 SECONDS)
				animate(src, transform = matrix() * 3, alpha = 0, time = 0.5 SECONDS)
				QDEL_IN(src, 0.3 SECONDS)
				sleep(0.3 SECONDS)
				new /obj/singularity/ratvar(get_turf(src))
