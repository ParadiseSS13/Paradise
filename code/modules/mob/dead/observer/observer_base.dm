GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

GLOBAL_DATUM_INIT(ghost_crew_monitor, /datum/ui_module/crew_monitor/ghost, new)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" // jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = GHOST_LAYER
	stat = DEAD
	density = FALSE
	alpha = 127
	see_in_dark = 100
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	blocks_emissive = FALSE // Ghosts are transparent, duh
	hud_type = /datum/hud/ghost
	speaks_ooc = TRUE
	universal_speak = TRUE
	/// Defines from __DEFINES/hud.dm go here based on which huds the ghost has activated.
	var/list/data_hud_seen = list()
	/// Shape we orbit in. Other values are unused currently..
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	/// The "color" their runechat would have had
	var/alive_runechat_color = "#FFFFFF"
	/// UID of the mob which we are currently observing
	var/mob_observed
	/// Ghost flags. Being set on Initialize
	var/ghost_flags

/mob/dead/observer/Initialize(mapload, flags = GHOST_FLAGS_DEFAULT)
	set_stat(DEAD)
	set_invisibility(GLOB.observer_default_invisibility)
	add_verb(src, list(
		/mob/dead/observer/proc/dead_tele,
		/mob/dead/observer/proc/jump_to_ruin,
		/mob/dead/observer/proc/open_spawners_menu,
	))

	var/turf/location
	var/mob/body = loc
	if(istype(body))
		location = get_turf(body) // Where is the body located?
		attack_log_old = body.attack_log_old // preserve our attack logs by copying them to our ghost
		mind = body.mind // we don't transfer the mind but we keep a reference to it.
		alive_runechat_color = body.get_runechat_color()
		toggle_all_huds_on(body)


		var/mutable_appearance/new_appearance = copy_appearance(body)
		if(mind?.name)
			new_appearance.name = mind.name
		else if(body.real_name)
			new_appearance.name = body.real_name
		else
			if(gender == MALE)
				new_appearance.name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
			else
				new_appearance.name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

		appearance = new_appearance

	appearance_flags |= KEEP_TOGETHER
	if(!location)
		location = pick(GLOB.latejoin) // Safety in case we cannot find the body's position
	abstract_move(location)

	RegisterSignal(src, COMSIG_MOB_HUD_CREATED, PROC_REF(set_ghost_darkness_level)) // something something don't call this until we have a HUD
	. = ..()
	if(!name) // To prevent nameless ghosts
		name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name
	add_observer_verbs()

	ghost_flags = flags
	if(ghost_flags & GHOST_RESPAWNABLE)
		ADD_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)
	else
		GLOB.non_respawnable_keys[ckey] = TRUE

	// Our new boo spell.
	AddSpell(new /datum/spell/boo)

/mob/dead/observer/Destroy()
	toggle_all_huds_off()
	UnregisterSignal(src, COMSIG_MOB_HUD_CREATED)
	if(ghost_flags & GHOST_SEE_RADS)
		STOP_PROCESSING(SSobj, src)
	remove_observer_verbs()
	if(mob_observed)
		cleanup_observe()
	return ..()

/mob/dead/observer/examine(mob/user)
	. = ..()
	if(!invisibility)
		. += "It seems extremely obvious."

/mob/dead/observer/process()
	show_rads(5)

/mob/dead/observer/proc/set_ghost_darkness_level()
	if(!client)
		return
	UnregisterSignal(src, COMSIG_MOB_HUD_CREATED)
	lighting_alpha = client.prefs.ghost_darkness_level //Remembers ghost lighting pref
	update_sight()

// This seems stupid, but it's the easiest way to avoid absolutely ridiculous shit from happening
// Copying an appearance directly from a mob includes it's verb list, it's invisibility, it's alpha, and it's density
// You might recognize these things as "fucking ridiculous to put in an appearance"
// You'd be right, but that's fucking BYOND for you.
/mob/dead/observer/proc/copy_appearance(mutable_appearance/copy_from)
	var/mutable_appearance/appearance = new(src)

	appearance.appearance_flags = copy_from.appearance_flags
	appearance.blend_mode = copy_from.blend_mode
	appearance.color = copy_from.color
	appearance.dir = copy_from.dir
	appearance.icon = copy_from.icon
	appearance.icon_state = copy_from.icon_state
	appearance.overlays = copy_from.overlays
	if(!isicon(appearance.icon) && !LAZYLEN(appearance.overlays)) // Gibbing/dusting/melting removes the icon before ghostize()ing the mob, so we need to account for that
		appearance.icon = initial(icon)
		appearance.icon_state = initial(icon_state)
	appearance.maptext = copy_from.maptext
	appearance.maptext_width = copy_from.maptext_width
	appearance.maptext_height = copy_from.maptext_height
	appearance.maptext_x = copy_from.maptext_x
	appearance.maptext_y = copy_from.maptext_y
	appearance.mouse_opacity = copy_from.mouse_opacity
	appearance.underlays = copy_from.underlays
	appearance.layer = GHOST_LAYER
	appearance.plane = GAME_PLANE

	return appearance

/mob/dead/CanPass(atom/movable/mover, border_dir)
	return TRUE

/mob/proc/ghostize(flags = GHOST_FLAGS_DEFAULT, ghost_name, ghost_color)
	if(!key)
		return

	if(player_logged) // if they have disconnected we want to remove their SSD overlay
		overlays -= image('icons/effects/effects.dmi', icon_state = "zzz_glow")

	var/mob/dead/observer/ghost = new(src, flags) // Transfer safety to observer spawning proc.

	// mods, mentors, and the like will have admin observe anyway, so this is moot
	if(((key in GLOB.antag_hud_users) || (key in GLOB.roundstart_observer_keys)) && !check_rights(R_MOD | R_ADMIN | R_MENTOR, FALSE, src))
		ghost.verbs |= /mob/dead/observer/proc/do_observe
		ghost.verbs |= /mob/dead/observer/proc/observe

	if(ghost_color)
		add_atom_colour(ghost_color, ADMIN_COLOUR_PRIORITY)
		ghost.color = ghost_color
	if(ghost_name)
		ghost.name = ghost_name

	ghost.timeofdeath = src.timeofdeath
	ghost.key = key
	ghost.client?.init_verbs()

	for(var/mob/dead/observer/obs as anything in observers)
		obs.cleanup_observe()

	return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	var/mob/M = src
	var/warningmsg = null
	var/obj/machinery/cryopod/P = istype(loc, /obj/machinery/cryopod) && loc

	if(frozen)
		to_chat(src, "<span class='warning'>You cannot do this while admin frozen.</span>", MESSAGE_TYPE_WARNING)
		message_admins("[key_name_admin(src)] tried to ghost while admin frozen")
		return

	if(HAS_TRAIT(M, TRAIT_RESPAWNABLE))
		if(isdrone(M))//We do not punish maint drones for leaving early, *but* we don't want them ghosting, finding damage, respawning / rentering over and over.
			var/mob/dead/observer/ghost = ghostize(GHOST_FLAGS_NO_REENTER)
			ghost.timeofdeath = world.time	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
			return
		ghostize()
		return
	if(isbrain(M))
		// let a brain ghost out if they want to, but also let them freely re-enter their brain.
		var/response = tgui_alert(src, "Ghosting from this brain means you'll be respawnable but will be kicked out of your brain, which someone else could take over. Is this what you want?", "Ghost", list("Stay in Brain", "Ghost"))
		if(response == "Ghost")
			ghostize()
			log_admin("[key_name(M)] has ghosted as a brain-mob, but is keeping respawnability.")
		return
	if(P)
		if(TOO_EARLY_TO_GHOST)
			warningmsg = "It's too early in the shift to enter cryo"
	else if(suiciding && TOO_EARLY_TO_GHOST)
		warningmsg = "You have committed suicide too early in the round"
	else if(stat != DEAD)
		warningmsg = "You are alive"
		if(is_ai(src))
			warningmsg = "You are a living AI! You should probably use OOC -> Wipe Core instead."
	else if(GLOB.non_respawnable_keys[ckey])
		warningmsg = "You have lost your right to respawn"

	if(warningmsg)
		var/response
		var/alertmsg = "Are you -sure- you want to ghost?\n([warningmsg]. If you ghost now, you probably won't be able to rejoin the round! You can't change your mind, so choose wisely!)"
		response = tgui_alert(src, alertmsg, "Ghost", list("Stay in body", "Ghost"))
		if(response != "Ghost")
			return

	if(stat == CONSCIOUS)
		if(!is_admin_level(z))
			player_ghosted = 1
		if(mind && mind.special_role)
			message_admins("[key_name_admin(src)] has ghosted while alive, with special_role: [mind.special_role]")

	if(warningmsg)
		// Not respawnable
		var/mob/dead/observer/ghost = ghostize(GHOST_FLAGS_OBSERVE_ONLY)
		ghost.timeofdeath = world.time	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
	else
		// Respawnable
		ghostize()

	// If mob in cryopod, despawn mob
	if(P)
		if(!P.control_computer)
			P.find_control_computer(urgent=1)
		if(P.control_computer)
			P.despawn_occupant()
	return

// Ghosts have no momentum, being massless ectoplasm
/mob/dead/observer/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/dead/observer/Move(atom/newloc, direct = 0, glide_size_override = 0, update_dir = TRUE, momentum_change = TRUE)
	setDir(direct)

	if(glide_size_override)
		set_glide_size(glide_size_override)

	if(newloc)
		abstract_move(newloc)
	else
		var/turf/destination = get_turf(src)

		if((direct & NORTH) && y < world.maxy)
			destination = get_step(destination, NORTH)

		else if((direct & SOUTH) && y > 1)
			destination = get_step(destination, SOUTH)

		if((direct & EAST) && x < world.maxx)
			destination = get_step(destination, EAST)

		else if((direct & WEST) && x > 1)
			destination = get_step(destination, WEST)

		abstract_move(destination) // Get out of closets and such as a ghost

/mob/dead/observer/forceMove(atom/destination)
	abstract_move(destination) // move like the wind
	return TRUE

/mob/dead/observer/can_use_hands()
	return FALSE

/mob/dead/observer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Respawnability:", "[HAS_TRAIT(src, TRAIT_RESPAWNABLE) ? "Yes" : "No"]")

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	if(!client)
		return
	if(!mind || QDELETED(mind.current))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(!(ghost_flags & GHOST_CAN_REENTER))
		to_chat(src, "<span class='warning'>You cannot re-enter your body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key, 1, 2) != "@")	// makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return

	mind.current.key = key

	SEND_SIGNAL(mind.current, COMSIG_LIVING_REENTERED_BODY)

	return TRUE

/mob/dead/observer/proc/notify_cloning(message, sound, atom/source)
	if(message)
		to_chat(src, "<span class='ghostalert'>[message]</span>")
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("[source.UID()]_notify_cloning", /atom/movable/screen/alert/notify_cloning)
			if(A)
				if(client && client.prefs && client.prefs.UI_style)
					A.icon = ui_style2icon(client.prefs.UI_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, "<span class='ghostalert'><a href=byond://?src=[UID()];reenter=1>(Click to re-enter)</a></span>")
	if(sound)
		SEND_SOUND(src, sound(sound))

/mob/dead/observer/proc/show_me_the_hud(hud_index)
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	H.add_hud_to(src)
	data_hud_seen |= hud_index

// remove old huds
/mob/dead/observer/proc/remove_the_hud(hud_index)
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	H.remove_hud_from(src)
	data_hud_seen -= hud_index

/mob/dead/observer/verb/open_hud_panel()
	set category = "Ghost"
	set name = "Ghost HUD Panel"

	if(!client)
		return

	GLOB.ghost_hud_panel.ui_interact(src)

/mob/dead/observer/verb/respawn_character()
	set name = "Respawn as New Character"
	set category = "Ghost"

	var/mob/dead/observer/O = usr
	if(!isobserver(O))
		to_chat(O, "<span class='warning'>You are not dead!</span>")
		return

	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(O, "<span class='warning'>You can't respawn before the game starts!</span>")
		return

	if(GAMEMODE_IS_WIZARD || GAMEMODE_IS_NUCLEAR || GAMEMODE_IS_RAGIN_MAGES)
		to_chat(O, "<span class='warning'>You can't respawn for this gamemode.</span>")
		return

	var/death_time = world.time - O.timeofdeath
	if(!HAS_TRAIT(O, TRAIT_RESPAWNABLE) && !check_rights(R_ADMIN, FALSE))
		to_chat(O, "<span class='warning'>You don't have respawnability!</span>")
		return

	var/death_time_minutes = round(death_time / 600)
	var/plural_check = "minutes"
	if(death_time_minutes == 0)
		plural_check = ""
	else if(death_time_minutes == 1)
		plural_check = "[death_time_minutes] minute and"
	else if(death_time_minutes > 1)
		plural_check = "[death_time_minutes] minutes and"
	var/death_time_seconds = round((death_time - death_time_minutes * 600) / 10, 1)

	if(death_time_minutes < GLOB.configuration.general.respawn_delay / 600 && !check_rights(R_ADMIN, FALSE))
		to_chat(O, "<span class='notice'>You have been dead for [plural_check] [death_time_seconds] second\s.</span>")
		to_chat(O, "<span class='warning'>You must wait [GLOB.configuration.general.respawn_delay / 600] minute\s before you can respawn.</span>")
		return

	if(!O.check_ahud_rejoin_eligibility())
		to_chat(O, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return FALSE
	if(tgui_alert(O, "Are you sure you want to respawn?\n(If you do this, you won't be able to be cloned!)", "Respawn?", list("Yes", "No")) != "Yes")
		return

	log_and_message_admins("[key_name(O)][O.mind?.current? (O.mind.current.mind.special_role? " (<font color='red'>[O.mind.current.mind.special_role]</font>)" : "") : ""] has chosen to respawn as a new character.")

	var/list/warning = list()
	warning.Add("<span class='big'>You have chosen to respawn as a new character!</span>")
	warning.Add("<b>You will not remember anything from your previous life or time as a ghost.</b>")
	warning.Add("<span class='boldwarning'>You MUST choose a different character slot to respawn as!</span>")
	to_chat(O, chat_box_notice(warning.Join("<br>")))

	if(!O.client)
		log_game("[key_name(O)] respawn failed due to disconnect.")
		return

	var/mob/new_player/NP = new()
	GLOB.non_respawnable_keys -= O.ckey
	NP.ckey = O.ckey
	qdel(O)
	NP.chose_respawn = TRUE

/**
 * Toggles on all HUDs for the ghost player.
 *
 * Enables antag HUD only if the ghost belongs to an admin.
 *
 * Arguments:
 * * user - A reference to the ghost's old mob. This argument is required since `src` does not have a `client` at this point.
 */
/mob/dead/observer/proc/toggle_all_huds_on(mob/user)
	show_me_the_hud(DATA_HUD_DIAGNOSTIC_ADVANCED)
	show_me_the_hud(DATA_HUD_SECURITY_ADVANCED)
	show_me_the_hud(DATA_HUD_MEDICAL_ADVANCED)
	show_me_the_hud(DATA_HUD_MALF_AI)
	if(!check_rights((R_ADMIN | R_MOD), FALSE, user))
		return

	antagHUD = TRUE
	GLOB.antag_hud_users |= user.ckey
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		hud.add_hud_to(src)

/**
 * Toggles off all HUDs for the ghost player.
 */
/mob/dead/observer/proc/toggle_all_huds_off()
	remove_the_hud(DATA_HUD_DIAGNOSTIC_ADVANCED)
	remove_the_hud(DATA_HUD_SECURITY_ADVANCED)
	remove_the_hud(DATA_HUD_MEDICAL_ADVANCED)
	remove_the_hud(DATA_HUD_MALF_AI)
	antagHUD = FALSE
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		H.remove_hud_from(src)

/mob/dead/observer/proc/toggle_rad_view()
	ghost_flags ^= GHOST_SEE_RADS
	if(ghost_flags & GHOST_SEE_RADS)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/dead/observer/verb/set_dnr()
	set name = "Set DNR"
	set category = "Ghost"
	set desc = "Prevent your character from being revived."

	if(!isobserver(src)) // Somehow
		return
	if(!(ghost_flags & GHOST_CAN_REENTER))
		to_chat(src, "<span class='warning'>You are already set to DNR!</span>")
		return
	if(!mind || QDELETED(mind.current))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.stat != DEAD)
		to_chat(src, "<span class='warning'>Your body is still alive!</span>")
		return

	if(tgui_alert(src, "If you enable this, your body will be unrevivable for the remainder of the round.", "Do Not Revive!", list("Yes", "No")) == "Yes")
		to_chat(src, "<span class='boldnotice'>Do Not Revive state enabled.</span>")
		create_log(MISC_LOG, "DNR Enabled")
		ghost_flags &= ~GHOST_CAN_REENTER
		if(!QDELETED(mind.current)) // Could change while they're choosing
			mind.current.remove_status_effect(STATUS_EFFECT_REVIVABLE)
		SEND_SIGNAL(mind.current, COMSIG_LIVING_SET_DNR)

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!isobserver(src))
		to_chat(src, "Not when you're not dead!")
		return

	var/target = tgui_input_list(src, "Area to teleport to", "Teleport to a location", SSmapping.ghostteleportlocs)
	teleport(SSmapping.ghostteleportlocs[target])

/mob/dead/observer/proc/jump_to_ruin()
	set category = "Ghost"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."

	if(!isobserver(usr))
		to_chat(usr, "Not when you're not dead!")
		return

	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = tgui_input_list(usr, "Select ruin", "Jump to Ruin", names)

	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		abstract_move(get_turf(landmark))
		update_parallax_contents()

		var/list/messages = list(
			"<span class='notice'>Jumped to <b>[landmark.ruin_template.name]</b>:</span>",
			"<span class='notice'>[landmark.ruin_template.description]</span>"
		)
		to_chat(usr, chat_box_examine(messages.Join("<br />")))

/mob/dead/observer/proc/teleport(area/A)
	if(!A || !isobserver(usr))
		return

	var/list/turfs = list()
	for(var/turf/T in get_area_turfs(A.type))
		turfs += T

	if(!length(turfs))
		to_chat(src, "<span class='warning'>Nowhere to jump to!</span>")
		return
	abstract_move(pick(turfs))
	update_parallax_contents()

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	GLOB.orbit_menu.ui_interact(src)

/mob/dead/observer/verb/crew_monitor()
	set category = "Ghost"
	set name = "Crew Monitor"
	set desc = "Use a ghastly crew monitor that lets you follow people you select."

	GLOB.ghost_crew_monitor.ui_interact(src)

/mob/dead/observer/proc/add_observer_verbs()
	verbs.Add(
		/mob/dead/observer/proc/manual_follow,
	)

/mob/dead/observer/proc/remove_observer_verbs()
	verbs.Remove(
		/mob/dead/observer/proc/manual_follow,
		// these might not necessarily be here, but we want to make sure they're gonezo anyway
		/mob/dead/observer/proc/observe,
		/mob/dead/observer/proc/do_observe
	)

// This is the ghost's follow verb with an argument.
// We need to do the src check on this verb itself, but the logic follows.
/mob/dead/observer/proc/manual_follow(atom/movable/target)
	set name = "\[Observer\] Orbit"
	set desc = "Orbits the specified movable atom."
	set category = null

	// this check is apparently necessary for security
	if(!isobserver(src))
		return

	return do_manual_follow(target)

// We need to check usr when calling the verb, but we still want this logic to be accessible elsewhere
/mob/dead/observer/proc/do_manual_follow(atom/movable/target)
	if(!get_turf(target))
		return

	if(!target || target == src)
		return

	if(src in target.get_orbiters())
		return

	var/list/icon_dimensions = get_icon_dimensions(target.icon)
	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * 0.5
	if(orbitsize == 0)
		orbitsize = 40
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else // Circular
			rot_seg = 36 // 360/10 bby, smooth enough aproximation of a circle

	to_chat(src, "<span class='notice'>Now following [target].</span>")
	orbit(A = target, radius = orbitsize, rotation_segments = rot_seg)

/mob/dead/observer/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE, orbit_layer = GHOST_LAYER)
	setDir(SOUTH) // reset dir so the right directional sprites show up
	return ..()

/mob/dead/observer/memory()
	set hidden = TRUE
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = TRUE
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/toggle_health_scan()
	set name = "Toggle Health Scan"
	set desc = "Toggles whether you health-scan living beings on click"
	set category = "Ghost"

	ghost_flags ^= GHOST_HEALTH_SCAN
	to_chat(src, "<span class='notice'>Health scan [ghost_flags & GHOST_HEALTH_SCAN ? "en" : "dis"]abled.</span>")

/mob/dead/observer/verb/toggle_gas_scan()
	set name = "Toggle Gas Scan"
	set desc = "Toggles whether you analyze gas contents on click"
	set category = "Ghost"

	ghost_flags ^= GHOST_GAS_SCAN
	to_chat(src, "<span class='notice'>Gas scan [ghost_flags & GHOST_GAS_SCAN ? "en" : "dis"]abled.</span>")

/mob/dead/observer/verb/toggle_plant_anaylzer()
	set name = "Toggle Plant Analyzer"
	set desc = "Toggles wether you can anaylze plants and seeds on click"
	set category = "Ghost"

	ghost_flags ^= GHOST_PLANT_ANALYZER
	to_chat(src, "<span class='notice'>Plant Analyzer [ghost_flags & GHOST_PLANT_ANALYZER ? "en" : "dis"]abled.</span>")

/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	GLOB.generic_crew_manifest.ui_interact(usr)

// this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over)
		return
	if(isobserver(usr) && usr.client && usr.client.holder)
		if(usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/proc/ghost_follow_link(atom/target, atom/ghost)
	if(!istype(target) || !istype(ghost))
		return
	if(is_ai(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		. = "<a href='byond://?src=[ghost.UID()];follow=[A.UID()]'>core</a>"
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|<a href='byond://?src=[ghost.UID()];follow=[A.eyeobj.UID()]'>eye</a>"
		return
	else if(isobserver(target))
		var/mob/dead/observer/O = target
		. = "<a href='byond://?src=[ghost.UID()];follow=[target.UID()]'>follow</a>"
		if(O.mind && O.mind.current)
			. += "|<a href='byond://?src=[ghost.UID()];follow=[O.mind.current.UID()]'>body</a>"
		return
	else
		return "<a href='byond://?src=[ghost.UID()];follow=[target.UID()]'>follow</a>"

/mob/dead/observer/Topic(href, href_list)
	if(usr != src)
		return

	if(href_list["track"])
		var/atom/target = locate(href_list["track"])
		manual_follow(target)

	if(href_list["follow"])
		var/atom/target = locate(href_list["follow"])
		manual_follow(target)

	if(href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		to_chat(src, "Teleporting to [target]...")
		if(target != usr)
			var/turf/source_turf = get_turf(src)
			var/turf/target_turf = get_turf(target)
			if(source_turf != target_turf)
				if(!target_turf)
					return
				if(!client)
					return
				abstract_move(target_turf)

	if(href_list["reenter"])
		reenter_corpse()

	return ..()

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"

	ghost_flags ^= GHOST_VISION
	update_sight()
	to_chat(src, "<span class='notice'>Ghost vision [ghost_flags & GHOST_VISION ? "en" : "dis"]abled.</span>")

/mob/dead/observer/verb/pick_darkness()
	set name = "Pick Darkness"
	set desc = "Choose how much darkness you want to see, (0 - 255). Higher numbers being darker."
	set category = "Ghost"

	if(!client)
		return

	var/darkness_level = tgui_input_list(src, "Choose your darkness", "Pick Darkness", list("Darkness", "Twilight", "Brightness", "Custom"))
	if(!darkness_level)
		return

	var/new_darkness
	switch(darkness_level)
		if("Darkness")
			new_darkness = LIGHTING_PLANE_ALPHA_VISIBLE
		if("Twilight")
			new_darkness = 210
		if("Brightness")
			new_darkness = LIGHTING_PLANE_ALPHA_INVISIBLE
		if("Custom")
			new_darkness = tgui_input_number(src, "Choose how much darkness you want to see (0 - 255). Higher numbers being darker", "Pick Darkness", lighting_alpha, LIGHTING_PLANE_ALPHA_VISIBLE, LIGHTING_PLANE_ALPHA_INVISIBLE)

	if(isnull(new_darkness))
		return

	client.prefs.ghost_darkness_level = new_darkness
	client.prefs.save_preferences(src)
	lighting_alpha = client.prefs.ghost_darkness_level
	update_sight()

/mob/dead/observer/update_sight()
	see_invisible = ghost_flags & GHOST_VISION ? SEE_INVISIBLE_OBSERVER : SEE_INVISIBLE_OBSERVER_NO_OBSERVERS
	return ..()

// Ghosts can see all the reagents inside things.
/mob/dead/observer/advanced_reagent_vision()
	return TRUE

/mob/proc/can_admin_interact()
	return FALSE

/mob/dead/observer/can_admin_interact()
	return check_rights(R_ADMIN, FALSE, src)

/mob/proc/can_advanced_admin_interact()
	return FALSE

/mob/dead/observer/can_advanced_admin_interact()
	return client?.advanced_admin_interaction && can_admin_interact()

/mob/dead/observer/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE)
	return TRUE

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/run_pointed(atom/A)
	if(!..())
		return FALSE

	for(var/mob/M in range(7, src))
		if(M.see_invisible < invisibility)
			continue // can't view the invisible
		var/follow_link
		if(invisibility) // Only show the button if the ghost is not visible to the living
			follow_link = " ([ghost_follow_link(A, M)])" // Ghost needs to be link clicker, otherwise it breaks
		M.show_message("<span class='deadsay'><b>[src]</b> points to [A][follow_link].</span>", EMOTE_VISIBLE)

	return TRUE

/mob/dead/observer/proc/incarnate_ghost(datum/mind/from_mind)
	if(!client)
		return

	var/mob/new_char
	if(from_mind)
		new_char = json_to_object(from_mind.destroyed_body_json, get_turf(src))
		from_mind.transfer_to(new_char)
	else
		new_char = new /mob/living/carbon/human(get_turf(src))
		client.prefs.active_character.copy_to(new_char)
	if(!new_char.ckey)
		new_char.ckey = ckey

	return new_char

/mob/dead/observer/is_literate()
	return TRUE

/mob/dead/observer/proc/set_invisibility(value)
	invisibility = value
	if(!value)
		set_light(1, 2)
	else
		set_light(0, 0)

/mob/dead/observer/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "invisibility")
		set_invisibility(invisibility) // updates light

/proc/set_observer_default_invisibility(amount, message)
	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		ghost.set_invisibility(amount)
		if(message)
			to_chat(ghost, message)
	GLOB.observer_default_invisibility = amount

/mob/dead/observer/proc/open_spawners_menu()
	set name = "Mob spawners menu"
	set desc = "See all currently available ghost spawners"
	set category = "Ghost"

	GLOB.ghost_spawners_menu.ui_interact(src)

/**
 * Check if a player has antag-hudded, and if so, if they can rejoin.
 * Returns TRUE if the player can rejoin, and FALSE if the player is ineligible to rejoin.
 * If allow_roundstart_observers is FALSE (TRUE by default), then any observers who were able to ahud due to joining roundstart will be excluded as well.
 */
/mob/dead/observer/proc/check_ahud_rejoin_eligibility(allow_roundstart_observers = TRUE)
	if(check_rights(R_ADMIN | R_MOD, FALSE, src))
		return TRUE

	if(!GLOB.configuration.general.restrict_antag_hud_rejoin || !has_ahudded())
		return TRUE

	if(is_roundstart_observer())
		return allow_roundstart_observers
	return FALSE

/mob/dead/observer/get_runechat_color()
	return alive_runechat_color

/mob/dead/observer/proc/observe()
	set name = "Observe"
	set desc = "Observe a mob."
	set category = "Ghost"

	var/list/possible_targets = list()
	for(var/mob/living/L in GLOB.player_list)
		if(!L.mind)
			continue
		possible_targets.Add(L)

	if(!length(possible_targets))
		to_chat(src, "<span class='warning'>There's nobody for you to observe!</span>")
		return

	var/mob/target = tgui_input_list(usr, "Please, select a player!", "Observe", possible_targets)
	if(!istype(target) || QDELETED(target))
		return
	do_observe(target)

/mob/dead/observer/proc/do_observe(mob/mob_eye)
	set name = "\[Observer\] Observe"
	set desc = "Observe the target mob."
	set category = null

	if(isnewplayer(mob_eye))
		to_chat(src, "<span class='warning'>You can't observe someone in the lobby.</span>")
		return

	if(isobserver(mob_eye))
		to_chat(src, "<span class='warning'>You can't observe a ghost.</span>")
		return

	if(!mob_eye.mind)
		to_chat(src, "<span class='notice'>You can only observe mobs that have been or are being inhabited by a player!</span>")
		return

	if(mob_eye == src)
		to_chat(src, "<span class='warning'>You can't observe yourself!</span>")
		return

	if(mob_observed)
		// clean up first
		stop_orbit()
		cleanup_observe()

	// Istype so we filter out points of interest that are not mobs
	if(client && ismob(mob_eye))
		// follow the mob so they're technically right there for visible messages n stuff
		// call the sub-proc since the base one checks for usr
		do_manual_follow(mob_eye)
		client.set_eye(mob_eye)
		add_attack_logs(src, mob_eye, "observed", ATKLOG_ALMOSTALL)
		client.perspective = EYE_PERSPECTIVE
		if(mob_eye.hud_used)
			client.clear_screen()
			LAZYOR(mob_eye.observers, src)
			mob_eye.hud_used?.show_hud(mob_eye.hud_used.hud_version, src)
			mob_observed = mob_eye.UID()

		// mentor observing grants you this trait, and provides its own signal handler for this
		if(!HAS_MIND_TRAIT(src, TRAIT_MENTOR_OBSERVING))
			RegisterSignal(src, COMSIG_ATOM_ORBITER_STOP, PROC_REF(on_observer_orbit_end), override = TRUE)
		else
			if(!check_rights(R_MENTOR, FALSE, src))
				log_debug("[key_name(src)] has the the mobserve trait while observing, but isn't a mentor. This is likely an error, and may result in them getting stuck")

/// Clean up observing
/mob/dead/observer/proc/cleanup_observe()
	if(isnull(mob_observed))
		return

	var/mob/target = locateUID(mob_observed)
	add_attack_logs(src, target, "un-observed", ATKLOG_ALL)
	mob_observed = null
	reset_perspective(null)
	client?.perspective = initial(client.perspective)
	update_sight()
	UnregisterSignal(src, COMSIG_ATOM_ORBITER_STOP)

	if(s_active)
		var/obj/item/storage/bag = s_active
		s_active = null
		bag.update_viewers(src)

	if(!QDELETED(target) && istype(target))
		hide_other_mob_action_buttons(target)
		target.observers -= src

/mob/dead/observer/proc/on_observer_orbit_end(mob/follower, atom)
	SIGNAL_HANDLER	// COMSIG_ATOM_ORBITER_STOP
	if(HAS_MIND_TRAIT(src, TRAIT_MENTOR_OBSERVING))
		log_debug("[key_name(src)] ended up in regular cleanup_observe rather than the mentor cleanup observe despite having TRAIT_MENTOR_OBSERVING. This is likely a bug and may result in them being stuck outside of their bodies.")
	cleanup_observe()
