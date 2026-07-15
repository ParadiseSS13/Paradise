/mob/camera/flock
	name = "BROKEN VERY BAD"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "flockmind"
	base_icon_state = "flockmind"

	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	invisibility = INVISIBILITY_FLOCK

	appearance_flags = parent_type::appearance_flags | RESET_COLOR
	blend_mode = BLEND_ADD

	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = 100
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	hud_type = /datum/hud/flockghost

	simulated = FALSE

	/// Flock datum
	var/datum/flock/flock
	var/list/actions_to_grant = list()

	/// The drone we're controlling if we are controlling one
	var/mob/living/basic/flock/drone/controlling_bird

/mob/camera/flock/Initialize(mapload, join_flock)
	. = ..()

	flock = join_flock || get_default_flock()

	for(var/action_path in actions_to_grant)
		var/datum/action/action = new action_path
		action.Grant(src)

	add_language("Symphonic")
	set_default_language(GLOB.all_languages["Symphonic"])
	ADD_TRAIT(src, TRAIT_HEAR_THROUGH_WALLS, INNATE_TRAIT)

/mob/camera/flock/Destroy()
	if(controlling_bird)
		controlling_bird.release_control()
	flock = null
	return ..()

/mob/camera/flock/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)

/mob/camera/flock/Logout()
	update_z(null)
	return ..()

/mob/camera/flock/Move(atom/newloc, direct, glide_size_override, update_dir, momentum_change)
	var/turf/next_step = get_turf(get_step(src, direct))
	setDir(direct)
	if(next_step)
		set_loc(next_step)

/mob/camera/flock/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!href_list["origin"])
		return

	var/atom/movable/origin = locate(href_list["origin"])
	if(QDELETED(origin))
		return

	if(isflockdrone(origin))
		var/mob/living/basic/flock/drone/other_bird = origin
		if(other_bird.flock != flock)
			return

	forceMove(get_turf(origin))

	if(href_list["ping"])
		origin.AddComponent(/datum/component/flock_ping)

/mob/camera/flock/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	switch(flock.flock_game_status)
		if(NONE)
			var/turf_status = min(100, floor((length(flock.claimed_floors) + length(flock.claimed_walls)) / FLOCK_TURFS_FOR_RELAY * 100))
			var/bandwith_status = min(100, floor(flock.available_bandwidth() / FLOCK_COMPUTE_COST_RELAY * 100))
			status_tab_data[++status_tab_data.len] = list("Bandwidth Progress: ", "[bandwith_status]%")
			status_tab_data[++status_tab_data.len] = list("Area Progress: ", "[turf_status]%")
			status_tab_data[++status_tab_data.len] = list("Total Relay Progress: ", "[(bandwith_status + turf_status) / 2]%")
		if(FLOCK_ENDGAME_RELAY_BUILT)
			status_tab_data[++status_tab_data.len] = list("Time until Broadcast: ", "[(flock.built_relay.started_time + flock.built_relay.win_time - world.time) / 10] second\s")

		if(FLOCK_ENDGAME_RELAY_ACTIVATING, FLOCK_ENDGAME_VICTORY)
			status_tab_data[++status_tab_data.len] = list("Time until Broadcast: ", "!!! TRANSMITTING !!!")

/mob/camera/flock/broadcast_examine(atom/examined)
	return

/mob/camera/flock/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents)
	. = ..()
	update_z(new_turf?.z)

	if(flock && !flock.is_on_safe_z(src))
		var/turf/destination = get_turf(get_safe_random_station_turf())

		forceMove(destination)
		to_chat(src, SPAN_WARNING("You feel your consciousness weaking as you are ripped further from your rift, and you retreat back to safety."))

/mob/camera/flock/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	..()
	if(isliving(speaker) && !isflockmob(speaker))
		var/mob/living/L = speaker
		var/message = combine_message(message_pieces, verb, L)
		var/name_used = L.GetVoice()
		var/rendered = "<i><span class='game say'>Relayed Speech: [SPAN_NAME("[name_used]")] [message]</span></i>"
		if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
			var/message_clean = combine_message(message_pieces, null, L)
			create_chat_message(locateUID(L.runechat_msg_location), message_clean)
		show_message(rendered, 2)

/mob/camera/flock/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z != new_z)
		if(registered_z)
			SSmobs.flock_cameras_by_zlevel[registered_z] -= src
		if(client)
			if(new_z)
				SSmobs.flock_cameras_by_zlevel[new_z] += src
			registered_z = new_z
		else
			registered_z = null

/mob/camera/flock/proc/get_flock_data()
	var/list/data = list()
	data["name"] = real_name
	data["area"] = get_area_name(src, TRUE) || "???"
	data["ref"] = ref(src)

	if(controlling_bird)
		data["host"] = controlling_bird.real_name
		data["health"] = controlling_bird.get_damage_percent()
	else
		data["host"] = null
		data["health"] = 100

	return data

/mob/camera/flock/proc/so_very_sad_death()
	if(client)
		to_chat(src, SPAN_ALERT("You cease to exist."))

	if(controlling_bird)
		controlling_bird.release_control()

	icon_state = "[base_icon_state]-ghost"
	ghostize(FALSE)
	flock?.free_unit(src)

	invisibility = 0
	notransform = TRUE
	icon_state = "blank"
	flick("[base_icon_state]-death", src)
	addtimer(CALLBACK(src, PROC_REF(cleanup)), 2 SECONDS)

/mob/camera/flock/proc/cleanup(datum/source)
	qdel(src)
