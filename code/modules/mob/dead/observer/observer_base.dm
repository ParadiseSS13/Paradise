#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

GLOBAL_LIST_EMPTY(ghost_images)

GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

GLOBAL_DATUM_INIT(ghost_crew_monitor, /datum/ui_module/crew_monitor/ghost, new)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = GHOST_LAYER
	plane = GAME_PLANE
	stat = DEAD
	density = FALSE
	alpha = 127
	move_resist = INFINITY	//  don't get pushed around
	invisibility = INVISIBILITY_OBSERVER
	blocks_emissive = FALSE // Ghosts are transparent, duh
	hud_type = /datum/hud/ghost
	speaks_ooc = TRUE
	var/can_reenter_corpse
	var/bootime = FALSE
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	universal_speak = TRUE
	var/image/ghostimage = null //this mobs ghost image, for deleting and stuff
	var/ghostvision = TRUE //is the ghost able to see things humans can't?
	var/seedarkness = TRUE
	var/seerads = FALSE     // can the ghost see radiation?
	/// Defines from __DEFINES/hud.dm go here based on which huds the ghost has activated.
	var/list/data_hud_seen = list()
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/health_scan = FALSE //does the ghost have health scanner mode on? by default it should be off
	///toggle for ghost gas analyzer
	var/gas_scan = FALSE
	///toggle for ghost plant analyzer
	var/plant_analyzer = FALSE
	var/datum/orbit_menu/orbit_menu
	/// The "color" their runechat would have had
	var/alive_runechat_color = "#FFFFFF"
	/// UID of the mob which we are currently observing
	var/mob_observed

/mob/dead/observer/New(mob/body=null, flags=1)
	set_invisibility(GLOB.observer_default_invisibility)

	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER_AI_EYE
	see_in_dark = 100
	add_verb(src, list(
		/mob/dead/observer/proc/dead_tele,
		/mob/dead/observer/proc/jump_to_ruin,
		/mob/dead/observer/proc/open_spawners_menu))

	// Our new boo spell.
	AddSpell(new /datum/spell/boo(null))

	can_reenter_corpse = flags & GHOST_CAN_REENTER
	started_as_observer = flags & GHOST_IS_OBSERVER

	set_stat(DEAD)

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log_old = body.attack_log_old	//preserve our attack logs by copying them to our ghost
		alive_runechat_color = body.get_runechat_color()

		var/mutable_appearance/MA = copy_appearance(body)
		if(body.mind && body.mind.name)
			MA.name = body.mind.name
		else if(body.real_name)
			MA.name = body.real_name
		else
			if(gender == MALE)
				MA.name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
			else
				MA.name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.
		appearance = MA

	ghostimage = image(icon = icon, loc = src, icon_state = icon_state)
	ghostimage.overlays = overlays
	ghostimage.dir = dir
	ghostimage.appearance_flags |= KEEP_TOGETHER
	ghostimage.alpha = alpha
	appearance_flags |= KEEP_TOGETHER
	GLOB.ghost_images |= ghostimage
	updateallghostimages()
	if(!T)
		T = pick(GLOB.latejoin)			//Safety in case we cannot find the body's position
	forceMove(T)

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name

	//starts ghosts off with all HUDs.
	toggle_all_huds_on(body)
	RegisterSignal(src, COMSIG_MOB_HUD_CREATED, PROC_REF(set_ghost_darkness_level)) //something something don't call this until we have a HUD
	..()
	plane = GAME_PLANE
	add_observer_verbs()
	ADD_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)

/mob/dead/observer/Destroy()
	toggle_all_huds_off()
	UnregisterSignal(src, COMSIG_MOB_HUD_CREATED)
	if(ghostimage)
		GLOB.ghost_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()
	if(orbit_menu)
		SStgui.close_uis(orbit_menu)
		QDEL_NULL(orbit_menu)
	if(seerads)
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
	if(seerads)
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
/mob/dead/observer/proc/copy_appearance(mutable_appearance/COPY)
	var/mutable_appearance/MA = new(src)

	MA.appearance_flags = COPY.appearance_flags
	MA.blend_mode = COPY.blend_mode
	MA.color = COPY.color
	MA.dir = COPY.dir
	MA.icon = COPY.icon
	MA.icon_state = COPY.icon_state
	MA.layer = COPY.layer
	MA.maptext = COPY.maptext
	MA.maptext_width = COPY.maptext_width
	MA.maptext_height = COPY.maptext_height
	MA.maptext_x = COPY.maptext_x
	MA.maptext_y = COPY.maptext_y
	MA.mouse_opacity = COPY.mouse_opacity
	MA.overlays = COPY.overlays
	if(!isicon(MA.icon) && !LAZYLEN(MA.overlays)) // Gibbing/dusting/melting removes the icon before ghostize()ing the mob, so we need to account for that
		MA.icon = initial(icon)
		MA.icon_state = initial(icon_state)
	MA.underlays = COPY.underlays
	MA.layer = GHOST_LAYER
	MA.plane = GAME_PLANE
	. = MA

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0)
	return 1


/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/
/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	for(var/mob/living/silicon/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	return 1

/mob/proc/ghostize(flags = GHOST_CAN_REENTER, user_color, ghost_name)
	if(!key)
		return
	if(player_logged) // if they have disconnected we want to remove their SSD overlay
		overlays -= image('icons/effects/effects.dmi', icon_state = "zzz_glow")
	if(GLOB.non_respawnable_keys[ckey])
		flags &= ~GHOST_CAN_REENTER
	var/mob/dead/observer/ghost = new(src, flags) // Transfer safety to observer spawning proc.
	ghost.timeofdeath = src.timeofdeath // BS12 EDIT
	if(ghost.can_reenter_corpse)
		ADD_TRAIT(ghost, TRAIT_RESPAWNABLE, GHOSTED)
	else
		GLOB.non_respawnable_keys[ckey] = 1

	// mods, mentors, and the like will have admin observe anyway, so this is moot
	if(((key in GLOB.antag_hud_users) || (key in GLOB.roundstart_observer_keys)) && !check_rights(R_MOD | R_ADMIN | R_MENTOR, FALSE, src))
		ghost.verbs |= /mob/dead/observer/proc/do_observe
		ghost.verbs |= /mob/dead/observer/proc/observe
	if(user_color)
		add_atom_colour(user_color, ADMIN_COLOUR_PRIORITY)
		ghost.color = user_color
	if(ghost_name)
		ghost.name = ghost_name
	ghost.key = key

	ghost.client?.init_verbs()

	for(var/mob/dead/observer/obs in observers)
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
			var/mob/dead/observer/ghost = ghostize(TRUE) // Keep them respawnable
			ghost.can_reenter_corpse = FALSE // but keep them out of their old body
			ghost.timeofdeath = world.time	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
			return
		ghostize(TRUE)
		return
	if(P)
		if(TOO_EARLY_TO_GHOST)
			warningmsg = "It's too early in the shift to enter cryo"
	else if(suiciding && TOO_EARLY_TO_GHOST)
		warningmsg = "You have committed suicide too early in the round"
	else if(stat != DEAD)
		warningmsg = "You are alive"
		if(isAI(src))
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
		var/mob/dead/observer/ghost = ghostize(FALSE)	// FALSE parameter stops them re-entering their body
		ghost.timeofdeath = world.time	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
	else
		// Respawnable
		ghostize(TRUE)

	// If mob in cryopod, despawn mob
	if(P)
		if(!P.control_computer)
			P.find_control_computer(urgent=1)
		if(P.control_computer)
			P.despawn_occupant()
	return

// Ghosts have no momentum, being massless ectoplasm
/mob/dead/observer/Process_Spacemove(movement_dir)
	return 1

/mob/dead/observer/Move(NewLoc, direct)
	update_parallax_contents()
	setDir(direct)
	ghostimage.dir = dir

	if(NewLoc)
		forceMove(NewLoc, direct)
	else
		forceMove(get_turf(src), direct)  //Get out of closets and such as a ghost
		if((direct & NORTH) && y < world.maxy)
			y++
		else if((direct & SOUTH) && y > 1)
			y--
		if((direct & EAST) && x < world.maxx)
			x++
		else if((direct & WEST) && x > 1)
			x--

/mob/dead/observer/can_use_hands()	return 0

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
	if(!can_reenter_corpse)
		to_chat(src, "<span class='warning'>You cannot re-enter your body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return

	mind.current.key = key

	SEND_SIGNAL(mind.current, COMSIG_LIVING_REENTERED_BODY)

	return 1


/mob/dead/observer/proc/notify_cloning(message, sound, atom/source)
	if(message)
		to_chat(src, "<span class='ghostalert'>[message]</span>")
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("\ref[source]_notify_cloning", /atom/movable/screen/alert/notify_cloning)
			if(A)
				if(client && client.prefs && client.prefs.UI_style)
					A.icon = ui_style2icon(client.prefs.UI_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.overlays += source
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, "<span class='ghostalert'><a href=byond://?src=[UID()];reenter=1>(Click to re-enter)</a></span>")
	if(sound)
		SEND_SOUND(src, sound(sound))

/mob/dead/observer/proc/show_me_the_hud(hud_index)
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	H.add_hud_to(src)
	data_hud_seen |= hud_index

/mob/dead/observer/proc/remove_the_hud(hud_index) //remove old huds
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	H.remove_hud_from(src)
	data_hud_seen -= hud_index

/mob/dead/observer/verb/open_hud_panel()
	set category = "Ghost"
	set name = "Ghost HUD Panel"
	if(!client)
		return
	GLOB.ghost_hud_panel.ui_interact(src)

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
	if(!check_rights((R_ADMIN | R_MOD), FALSE, user))
		return
	antagHUD = TRUE
	GLOB.antag_hud_users |= user.ckey
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		H.add_hud_to(src)

/**
 * Toggles off all HUDs for the ghost player.
 */
/mob/dead/observer/proc/toggle_all_huds_off()
	remove_the_hud(DATA_HUD_DIAGNOSTIC_ADVANCED)
	remove_the_hud(DATA_HUD_SECURITY_ADVANCED)
	remove_the_hud(DATA_HUD_MEDICAL_ADVANCED)
	antagHUD = FALSE
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		H.remove_hud_from(src)

/mob/dead/observer/proc/set_radiation_view(enabled)
	if(enabled)
		seerads = TRUE
		START_PROCESSING(SSobj, src)
	else
		seerads = FALSE
		STOP_PROCESSING(SSobj, src)

/mob/dead/observer/verb/set_dnr()
	set name = "Set DNR"
	set category = "Ghost"
	set desc = "Prevent your character from being revived."

	if(!isobserver(src)) // Somehow
		return
	if(!can_reenter_corpse)
		to_chat(src, "<span class='warning'>You are already set to DNR!</span>")
		return
	if(!mind || QDELETED(mind.current))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.stat != DEAD)
		to_chat(src, "<span class='warning'>Your body is still alive!</span>")
		return

	var/choice = tgui_alert(src, "If you enable this, your body will be unrevivable for the remainder of the round.", "Do Not Revive!", list("Yes", "No"))
	if(choice == "Yes")
		to_chat(src, "<span class='boldnotice'>Do Not Revive state enabled.</span>")
		create_log(MISC_LOG, "DNR Enabled")
		can_reenter_corpse = FALSE
		if(!QDELETED(mind.current)) // Could change while they're choosing
			mind.current.remove_status_effect(STATUS_EFFECT_REVIVABLE)
		SEND_SIGNAL(mind.current, COMSIG_LIVING_SET_DNR)

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!isobserver(usr))
		to_chat(usr, "Not when you're not dead!")
		return
	var/target = tgui_input_list(usr, "Area to teleport to", "Teleport to a location", SSmapping.ghostteleportlocs)
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
		forceMove(get_turf(landmark))
		update_parallax_contents()

/mob/dead/observer/proc/teleport(area/A)
	if(!A || !isobserver(usr))
		return

	var/list/turfs = list()
	for(var/turf/T in get_area_turfs(A.type))
		turfs += T

	if(!length(turfs))
		to_chat(src, "<span class='warning'>Nowhere to jump to!</span>")
		return
	forceMove(pick(turfs))
	update_parallax_contents()

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	if(!orbit_menu)
		orbit_menu = new(src)

	orbit_menu.ui_interact(src)

/mob/dead/observer/verb/crew_monitor()
	set category = "Ghost"
	set name = "Crew Monitor"
	set desc = "Use a ghastly crew monitor that lets you follow people you select."

	GLOB.ghost_crew_monitor.ui_interact(src)

/mob/dead/observer/proc/add_observer_verbs()
	verbs.Add(
		/mob/dead/observer/proc/ManualFollow,
	)

/mob/dead/observer/proc/remove_observer_verbs()
	verbs.Remove(
		/mob/dead/observer/proc/ManualFollow,
		// these might not necessarily be here, but we want to make sure they're gonezo anyway
		/mob/dead/observer/proc/observe,
		/mob/dead/observer/proc/do_observe
	)

// This is the ghost's follow verb with an argument.
// We need to do the usr check on this verb itself, but the logic follows.
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	set name = "\[Observer\] Orbit"
	set desc = "Orbits the specified movable atom."
	set category = null

	// this usr check is apparently necessary for security
	if(!isobserver(usr))
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

	var/icon/I = icon(target.icon, target.icon_state, target.dir)

	var/orbitsize = (I.Width() + I.Height())*0.5

	if(orbitsize == 0)
		orbitsize = 40

	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)

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
	orbit(target, orbitsize, FALSE, 20, rot_seg)

/mob/dead/observer/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lock_in_orbit = FALSE, force_move = FALSE, orbit_layer = GHOST_LAYER)
	setDir(2)//reset dir so the right directional sprites show up
	return ..()

/mob/dead/observer/proc/jump_to_mob(mob/M)
	if(!M || !isobserver(usr))
		return
	var/mob/A = src			 //Source mob
	var/turf/T = get_turf(M) //Turf of the destination mob

	if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
		A.forceMove(T)
		M.update_parallax_contents()
		return
	to_chat(A, "This mob is not located in the game world.")

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/toggle_health_scan()
	set name = "Toggle Health Scan"
	set desc = "Toggles whether you health-scan living beings on click"
	set category = "Ghost"

	if(health_scan) //remove old huds
		to_chat(src, "<span class='notice'>Health scan disabled.</span>")
		health_scan = FALSE
	else
		to_chat(src, "<span class='notice'>Health scan enabled.</span>")
		health_scan = TRUE

/mob/dead/observer/verb/toggle_gas_scan()
	set name = "Toggle Gas Scan"
	set desc = "Toggles whether you analyze gas contents on click"
	set category = "Ghost"

	gas_scan = !gas_scan
	if(gas_scan)
		to_chat(src, "<span class='notice'>Gas scan enabled.</span>")
	else
		to_chat(src, "<span class='notice'>Gas scan disabled.</span>")

/mob/dead/observer/verb/toggle_plant_anaylzer()
	set name = "Toggle Plant Analyzer"
	set desc = "Toggles wether you can anaylze plants and seeds on click"
	set category = "Ghost"

	if(plant_analyzer)
		to_chat(src, "<span class='notice'>Plant Analyzer disabled.</span>")
		plant_analyzer = FALSE
	else
		to_chat(src, "<span class='notice'>Plant Analyzer enabled. Click on a plant or seed to analyze.</span>")
		plant_analyzer = TRUE

/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"
	GLOB.generic_crew_manifest.ui_interact(usr)

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over) return
	if(isobserver(usr) && usr.client && usr.client.holder)
		if(usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/proc/ghost_follow_link(atom/target, atom/ghost)
	if((!target) || (!ghost)) return
	if(isAI(target)) // AI core/eye follow links
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

//BEGIN TELEPORT HREF CODE
/mob/dead/observer/Topic(href, href_list)
	if(usr != src)
		return

	if(href_list["track"])
		var/atom/target = locate(href_list["track"])
		if(target)
			ManualFollow(target)

	if(href_list["follow"])
		var/atom/target = locate(href_list["follow"])
		if(target)
			ManualFollow(target)

	if(href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		var/mob/A = usr
		to_chat(A, "Teleporting to [target]...")
		//var/mob/living/silicon/ai/A = locate(href_list["track2"]) in GLOB.mob_list
		if(target && target != usr)
			spawn(0)
				var/turf/pos = get_turf(A)
				var/turf/T=get_turf(target)
				if(T != pos)
					if(!T)
						return
					if(!client)
						return
					forceMove(T)

	if(href_list["reenter"])
		reenter_corpse()

	..()
//END TELEPORT HREF CODE
/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	update_sight()
	to_chat(usr, "You [(ghostvision?"now":"no longer")] have ghost vision.")

/mob/dead/observer/verb/pick_darkness(desired_dark as num)
	set name = "Pick Darkness"
	set desc = "Choose how much darkness you want to see, (0 - 255). Higher numbers being darker."
	set category = "Ghost"
	if(isnull(desired_dark))
		return
	if(!client)
		return
	client.prefs.ghost_darkness_level = clamp(desired_dark, 0, 255)
	client.prefs.save_preferences(src)
	lighting_alpha = client.prefs.ghost_darkness_level
	update_sight()

/mob/dead/observer/update_sight()
	if(!ghostvision)
		see_invisible = SEE_INVISIBLE_LIVING
	else
		see_invisible = SEE_INVISIBLE_OBSERVER

	updateghostimages()
	. = ..()

/mob/dead/observer/proc/updateghostsight()
	if(!seedarkness)
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	else
		see_invisible = SEE_INVISIBLE_OBSERVER
		if(!ghostvision)
			see_invisible = SEE_INVISIBLE_LIVING

	updateghostimages()

/mob/dead/observer/advanced_reagent_vision()	// Ghosts can see all the reagents inside things.
	return TRUE

/proc/updateallghostimages()
	for(var/mob/dead/observer/O in GLOB.player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if(!client)
		return
	if(seedarkness || !ghostvision)
		client.images -= GLOB.ghost_images
	else
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		client.images |= GLOB.ghost_images
		if(ghostimage)
			client.images -= ghostimage //remove ourself

/mob/proc/can_admin_interact()
	return FALSE

/mob/proc/can_advanced_admin_interact()
	return FALSE

/mob/dead/observer/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

/mob/dead/observer/can_advanced_admin_interact()
	if(!can_admin_interact())
		return FALSE

	if(client && client.advanced_admin_interaction)
		return TRUE

	return FALSE

/mob/dead/observer/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE)
	return TRUE

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/run_pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return FALSE

	for(var/mob/M in range(7, src))
		if(M.see_invisible < invisibility)
			continue //can't view the invisible
		var/follow_link
		if(invisibility) // Only show the button if the ghost is not visible to the living
			follow_link = " ([ghost_follow_link(A, M)])" // Ghost needs to be link clicker, otherwise it breaks
		M.show_message("<span class='deadsay'><b>[src]</b> points to [A][follow_link].</span>", EMOTE_VISIBLE)

	return TRUE

/mob/dead/observer/proc/incarnate_ghost()
	if(!client)
		return

	var/mob/living/carbon/human/new_char = new(get_turf(src))
	client.prefs.active_character.copy_to(new_char)
	if(mind)
		mind.active = TRUE
		mind.transfer_to(new_char)
	else
		new_char.key = key

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

/proc/set_observer_default_invisibility(amount, message=null)
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.set_invisibility(amount)
		if(message)
			to_chat(G, message)
	GLOB.observer_default_invisibility = amount

/mob/dead/observer/proc/open_spawners_menu()
	set name = "Mob spawners menu"
	set desc = "See all currently available ghost spawners"
	set category = "Ghost"

	var/datum/spawners_menu/menu = new /datum/spawners_menu(src)
	menu.ui_interact(src)

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
	set_sight(initial(sight))
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

#undef GHOST_CAN_REENTER
#undef GHOST_IS_OBSERVER
