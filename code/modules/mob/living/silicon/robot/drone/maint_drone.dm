#define EMAG_TIMER 5 MINUTES
/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	icon_state = "repairbot"
	maxHealth = 35
	health = 35
	bubble_icon = "machine"
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = FALSE
	density = FALSE
	has_camera = FALSE
	req_one_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_SMALL
	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	modules_break = FALSE
	hat_offset_y = -15
	is_centered = TRUE
	can_be_hatted = TRUE
	can_wear_restricted_hats = TRUE
	/// Cooldown for law syncs
	var/sync_cooldown = 0


	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/plastic/stack_plastic = null
	var/obj/item/matter_decompiler/decompiler = null

	// What objects can drones bump into
	var/static/list/allowed_bumpable_objects = list(/obj/machinery/door, /obj/machinery/recharge_station, /obj/machinery/disposal/delivery_chute,
													/obj/machinery/teleport/hub, /obj/effect/portal, /obj/structure/transit_tube/station)

	var/reboot_cooldown = 1 MINUTES
	var/last_reboot
	var/list/pullable_drone_items = list(
		/obj/item/pipe,
		/obj/structure/disposalconstruct,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods,
		/obj/item/stack/sheet,
		/obj/item/stack/tile
	)

	holder_type = /obj/item/holder/drone

	var/datum/pathfinding_mover/pathfinding
	silicon_subsystems = list(
		/mob/living/silicon/robot/proc/set_mail_tag,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor)


/mob/living/silicon/robot/drone/New()
	..()

	remove_language("Robot Talk")
	remove_language("Galactic Common")
	add_language("Drone Talk", TRUE)
	add_language("Drone", TRUE)

	// Disable the microphone wire on Drones
	if(radio)
		radio.wires.cut(WIRE_RADIO_TRANSMIT)

	if(camera && ("Robots" in camera.network))
		camera.network.Add("Engineering")

	//They are unable to be upgraded, so let's give them a bit of a better battery.
	cell = new /obj/item/stock_parts/cell/high(src)

	// NO BRAIN.
	mmi = null

	//We need to screw with their HP a bit. They have around one fifth as much HP as a full borg.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.max_damage = 10

	remove_verb(src, /mob/living/silicon/robot/verb/Namepick)
	module = new /obj/item/robot_module/drone(src)
	// Give us our action button
	var/datum/action/innate/hide/drone_hide/hide = new()
	var/datum/action/innate/robot_magpulse/pulse = new()
	hide.Grant(src)
	pulse.Grant(src)

	//Allows Drones to hear the Engineering channel.
	module.channels = list("Engineering" = 1)
	radio.recalculateChannels()

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in module
	stack_wood = locate(/obj/item/stack/sheet/wood) in module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in module
	stack_plastic = locate(/obj/item/stack/sheet/plastic) in module

	//Grab decompiler.
	decompiler = locate(/obj/item/matter_decompiler) in module

	//Some tidying-up.
	flavor_text = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: 'Nanotrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
	scanner.Grant(src)
	update_icons()

	// Drones have laws to not attack people
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)

/mob/living/silicon/robot/drone/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/drone()
	set_connected_ai(null)

	aiCamera = new /obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = ";"
	ADD_TRAIT(src, TRAIT_RESPAWNABLE, UNIQUE_TRAIT_SOURCE(src))

	playsound(loc, 'sound/machines/twobeep.ogg', 50)

//Redefining some robot procs...
/mob/living/silicon/robot/drone/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

// Drones don't have a PDA.
/mob/living/silicon/robot/drone/open_pda()
	to_chat(src, "<span class='warning'>This unit does not have PDA functionality!</span>")
	return

/mob/living/silicon/robot/drone/get_default_name()
	return "maintenance drone ([rand(100, 999)])"

/mob/living/silicon/robot/drone/update_icons()
	overlays.Cut()
	if(stat == CONSCIOUS)
		overlays += "eyes-[icon_state]"
		if(pathfinding)
			overlays += "eyes-repairbot-pathfinding"
	else
		overlays -= "eyes"
	update_hat_icons()

/mob/living/silicon/robot/drone/pick_module()
	return

/mob/living/silicon/robot/drone/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>Using an emag on this drone will slave them to you for 5 minutes... until they explode in a shower of sparks.</span>"

/mob/living/silicon/robot/drone/examine_more(mob/user)//I know examine_more is for lore but the length of this description is too much
	. = ..()
	. += "<span class='notice'><i>The ever-loyal workers of Nanotrasen facilities. Known for their small and cute look, these drones seek only to repair damaged parts of the station, being lawed against hurting even a spiderling. These fine drones are programmed against interfering with any business of anyone, so they won't do anything you don't want them to.</i></span>"

//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/borg/upgrade))
		to_chat(user, "<span class='warning'>The maintenance drone chassis is not compatible with [I].</span>")
		return ITEM_INTERACT_COMPLETE

	else if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		if(stat == DEAD)
		// Currently not functional, so commenting out until it's fixed to avoid confusion
			/*if(!config.allow_drone_spawn || emagged || health < -35) //It's dead, Dave.
				to_chat(user, "<span class='warning'>The interface is fried, and a distressing burned smell wafts from the robot's interior. You're not rebooting this one.</span>")
				return

			if(!allowed(I))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return

			var/delta = (world.time / 10) - last_reboot
			if(reboot_cooldown > delta)
				var/cooldown_time = round(reboot_cooldown - ((world.time / 10) - last_reboot), 1)
				to_chat(usr, "<span class='warning'>The reboot system is currently offline. Please wait another [cooldown_time] seconds.</span>")
				return

			user.visible_message("<span class='warning'>[user] swipes [user.p_their()] ID card through [src], attempting to reboot it.</span>",
				"<span class='warning'>You swipe your ID card through [src], attempting to reboot it.</span>")
			last_reboot = world.time / 10
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
				if(D.key && D.client)
					drones++
			if(drones < config.max_maint_drones)
				request_player()*/
			return ITEM_INTERACT_COMPLETE

		else
			var/confirm = tgui_alert(user, "Using your ID on a Maintenance Drone will shut it down, are you sure you want to do this?", "Disable Drone", list("Yes", "No"))
			if(confirm == ("Yes") && (user in range(3, src)))
				user.visible_message("<span class='warning'>[user] swipes [user.p_their()] ID card through [src], attempting to shut it down.</span>",
					"<span class='warning'>You swipe your ID card through [src], attempting to shut it down.</span>")

				if(emagged)
					return
				if(allowed(I))
					shut_down()
				else
					to_chat(user, "<span class='warning'>Access denied.</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/silicon/robot/drone/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	to_chat(user, "<span class='warning'>The machine is hermetically sealed. You can't open the case.</span>")

/mob/living/silicon/robot/drone/Destroy()
	. = ..()
	QDEL_NULL(stack_glass)
	QDEL_NULL(stack_metal)
	QDEL_NULL(stack_wood)
	QDEL_NULL(stack_plastic)
	QDEL_NULL(decompiler)
	for(var/datum/action/innate/hide/drone_hide/hide in actions)
		hide.Remove(src)

/mob/living/silicon/robot/drone/emag_act(mob/user)
	if(!client || stat == DEAD)
		to_chat(user, "<span class='warning'>There's not much point subverting this heap of junk.</span>")
		return

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(emagged)
		to_chat(src, "<span class='warning'>[user] attempts to load subversive software into you, but your hacked subroutined ignore the attempt.</span>")
		to_chat(user, "<span class='warning'>You attempt to subvert [src], but the sequencer has no effect.</span>")
		return

	to_chat(user, "<span class='warning'>You swipe the sequencer across [src]'s interface and watch its eyes flicker.</span>")

	if(jobban_isbanned(src, ROLE_SYNDICATE))
		SSticker.mode.replace_jobbanned_player(src, ROLE_SYNDICATE)

	to_chat(src, "<span class='warning'>You feel a sudden burst of malware loaded into your execute-as-root buffer. Your tiny brain methodically parses, loads and executes the script. You sense you have <b>five minutes</b> before the drone server detects this and automatically shuts you down.</span>")
	REMOVE_TRAIT(src, TRAIT_RESPAWNABLE, UNIQUE_TRAIT_SOURCE(src))
	message_admins("[key_name_admin(user)] emagged drone [key_name_admin(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged drone [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [H.name]([H.key]) emagged [name]([key])")
	addtimer(CALLBACK(src, PROC_REF(shut_down), TRUE), EMAG_TIMER)

	emagged = TRUE
	density = TRUE
	pass_flags = 0
	icon_state = "repairbot-emagged"
	holder_type = /obj/item/holder/drone/emagged
	update_icons()
	set_connected_ai(null)
	clear_supplied_laws()
	clear_inherent_laws()
	laws = new /datum/ai_laws/syndicate_override
	REMOVE_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)
	set_zeroth_law("Only [H.real_name] and people [H.real_name] designates as being such are Syndicate Agents.")

	to_chat(src, "<b>Obey these laws:</b>")
	laws.show_laws(src)
	to_chat(src, "<span class='boldwarning'>ALERT: [H.real_name] is your new master. Obey your new laws and [H.real_name]'s commands.</span>")
	return TRUE

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 35
		set_stat(CONSCIOUS)
		return
	health = 35 - (getBruteLoss() + getFireLoss() + getOxyLoss())
	update_stat("updatehealth([reason])")

/mob/living/silicon/robot/drone/death(gibbed)
	. = ..(gibbed)
	adjustBruteLoss(health)

//CONSOLE PROCS
/mob/living/silicon/robot/drone/proc/law_resync()
	if(stat != DEAD)
		if(emagged)
			to_chat(src, "<span class='warning'>You feel something attempting to modify your programming, but your hacked subroutines are unaffected.</span>")
		else
			to_chat(src, "<span class='warning'>A reset-to-factory directive packet filters through your data connection, and you obediently modify your programming to suit it.</span>")
			full_law_reset()
			show_laws()

/mob/living/silicon/robot/drone/proc/shut_down(force = FALSE)
	if(stat == DEAD)
		return

	if(emagged && !force)
		to_chat(src, "<span class='warning'>You feel a system kill order percolate through your tiny brain, but it doesn't seem like a good idea to you.</span>")
		return

	if(!emagged && pathfind_to_dronefab())
		to_chat(src, "<span class='warning'>You feel a system recall order percolate through your tiny brain, and you return to your drone fabricator.</span>")
		return

	to_chat(src, "<span class='warning'>You feel a system kill order percolate through your tiny brain, and you obediently destroy yourself.</span>")
	death()

/mob/living/silicon/robot/drone/proc/full_law_reset()
	clear_supplied_laws(TRUE)
	clear_inherent_laws(TRUE)
	clear_ion_laws(TRUE)
	laws = new /datum/ai_laws/drone

//Reboot procs.

/mob/living/silicon/robot/drone/proc/request_player()
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(!O.check_ahud_rejoin_eligibility())
			continue
		if(jobban_isbanned(O, "nonhumandept") || jobban_isbanned(O, "Drone"))
			continue
		if(O.client)
			if(ROLE_PAI in O.client.prefs.be_special)
				question(O.client, O)

/mob/living/silicon/robot/drone/proc/question(client/C, mob/M)
	spawn(0)
		if(!C || !M || jobban_isbanned(M, "nonhumandept") || jobban_isbanned(M, "Drone"))
			return
		var/response = tgui_alert(C, "Someone is attempting to reboot a maintenance drone. Would you like to play as one?", "Maintenance drone reboot", list("Yes", "No"))
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)

/mob/living/silicon/robot/drone/proc/transfer_personality(client/player)
	if(!player)
		return

	ckey = player.ckey

	to_chat(src, "<b>Systems rebooted</b>. Loading base pattern maintenance protocol... <b>loaded</b>.")
	full_law_reset()
	to_chat(src, "<br><b>You are a maintenance drone, a tiny-brained robotic repair machine</b>.")
	to_chat(src, "You have no individual will, no personality, and no drives or urges other than your laws.")
	to_chat(src, "Use <b>:d</b> to talk to other drones, and <b>say</b> to speak silently in a language only your fellows understand.")
	to_chat(src, "Remember, you are <b>lawed against interference with the crew</b>. Also remember, <b>you DO NOT take orders from the AI.</b>")
	to_chat(src, "<b>Don't invade their worksites, don't steal their resources, don't tell them about the changeling in the toilets.</b>")
	to_chat(src, "<b>Make sure crew members do not notice you.</b>.")

/*
	sprite["Default"] = "repairbot"
	sprite["Mk2 Mousedrone"] = "mk2"
	sprite["Mk3 Monkeydrone"] = "mk3"
	var/icontype
	icontype = input(player,"Pick an icon") in sprite
	icon_state = sprite[icontype]

	choose_icon(6,sprite)
*/


/mob/living/silicon/robot/drone/Bump(atom/movable/AM)
	if(is_type_in_list(AM, allowed_bumpable_objects))
		return ..()

/mob/living/silicon/robot/drone/Bumped(atom/movable/AM)
	return

/mob/living/silicon/robot/drone/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)

	if(is_type_in_list(AM, pullable_drone_items))
		..(AM, force = INFINITY) // Drone power! Makes them able to drag pipes and such

	else if(isitem(AM))
		var/obj/item/O = AM
		if(O.w_class > WEIGHT_CLASS_SMALL)
			if(show_message)
				to_chat(src, "<span class='warning'>You are too small to pull that.</span>")
			return
		else
			..()
	else
		if(show_message)
			to_chat(src, "<span class='warning'>You are too small to pull that.</span>")

/mob/living/silicon/robot/drone/add_robot_verbs()
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/drone/remove_robot_verbs()
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/robot/drone/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	..()
	update_headlamp(TRUE, 0, FALSE)

/mob/living/silicon/robot/drone/flash_eyes(intensity = 1, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE)
	if(affect_silicon)
		return ..()

/mob/living/silicon/robot/drone/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!client && isdrone(user))
		to_chat(user, "<span class='warning'>You begin decompiling the other drone.</span>")
		if(!do_after(user, 5 SECONDS, target = loc))
			to_chat(user, "<span class='warning'>You need to remain still while decompiling such a large object.</span>")
			return
		if(QDELETED(src) || QDELETED(user))
			return ..()
		to_chat(user, "<span class='warning'>You carefully and thoroughly decompile your downed fellow, storing as much of its resources as you can within yourself.</span>")
		new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
		C.stored_comms["metal"] += 15
		C.stored_comms["glass"] += 15
		C.stored_comms["wood"] += 5
		qdel(src)
		return TRUE
	return ..()

/mob/living/silicon/robot/drone/do_suicide()
	ghostize()
	shut_down()

/mob/living/silicon/robot/drone/proc/pathfind_to_dronefab()
	if(pathfinding)
		return TRUE

	if(istype(get_turf(src), /turf/space))
		return FALSE // Pretty damn hard to path through space

	var/turf/target
	for(var/obj/machinery/drone_fabricator/DF in SSmachines.get_by_type(/obj/machinery/drone_fabricator))
		if(DF.z != z)
			continue
		target = get_turf(DF)
		target = get_step(target, EAST)
		break

	if(!target)
		return FALSE

	// Mimic having the hide-ability activated
	layer = TURF_LAYER + 0.2
	pass_flags |= PASSDOOR

	var/datum/pathfinding_mover/pathfind = new(src, target)

	set_pathfinding(pathfind)
	var/found_path = pathfind.generate_path(150, null, get_all_accesses())
	if(!found_path)
		set_pathfinding(null)
		return FALSE

	pathfind.on_set_path_null = CALLBACK(src, PROC_REF(pathfind_failed_cleanup))
	pathfind.on_success = CALLBACK(src, PROC_REF(at_dronefab))
	pathfind.start()
	return TRUE

/mob/living/silicon/robot/drone/proc/pathfind_failed_cleanup(pathfind)
	set_pathfinding(null)
	death()

/mob/living/silicon/robot/drone/proc/at_dronefab(pathfind)
	set_pathfinding(null)
	cryo_with_dronefab()

/mob/living/silicon/robot/drone/proc/cryo_with_dronefab(obj/machinery/drone_fabricator/drone_fab)
	if(!drone_fab)
		drone_fab = locate() in range(1, src)
	if(!drone_fab)
		return FALSE
	drone_fab.drone_progress = 100 // recycling!

	visible_message("<span class='notice'>[src] shuts down and enters [drone_fab].</span>")
	playsound(loc, 'sound/machines/twobeep.ogg', 50)
	qdel(src)
	return TRUE

/mob/living/silicon/robot/drone/proc/set_pathfinding(datum/pathfinding_mover/new_pathfind)
	if(isnull(new_pathfind) && istype(pathfinding))
		qdel(pathfinding)
	pathfinding = new_pathfind
	notransform = istype(new_pathfind) ? TRUE : FALSE // prevent them from moving themselves while pathfinding.
	update_icons()

#undef EMAG_TIMER
