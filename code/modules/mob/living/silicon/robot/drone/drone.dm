#define EMAG_TIMER 3000
/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	desc = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: 'Nanotrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
	icon = 'icons/mob/robots.dmi'
	icon_state = "repairbot"
	maxHealth = 35
	health = 35
	bubble_icon = "machine"
	universal_speak = 0
	universal_understand = 1
	gender = NEUTER
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = 0
	density = 0
	has_camera = FALSE
	req_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)
	ventcrawler = VENTCRAWLER_ALWAYS
	magpulse = 1
	mob_size = MOB_SIZE_SMALL
	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	modules_break = FALSE

	drain_act_protected = TRUE

	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/plastic/stack_plastic = null
	var/obj/item/matter_decompiler/decompiler = null

	// What objects can drones bump into
	var/static/list/allowed_bumpable_objects = list(/obj/machinery/door, /obj/machinery/recharge_station, /obj/machinery/disposal/deliveryChute,
													/obj/machinery/teleport/hub, /obj/effect/portal, /obj/structure/transit_tube/station)

	//Used for self-mailing.
	var/mail_destination = 0
	var/reboot_cooldown = 60 // one minute
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
//	var/sprite[0]


/mob/living/silicon/robot/drone/New()
	..()

	remove_language("Robot Talk")
	remove_language("Galactic Common")
	add_language("Drone Talk", 1)
	add_language("Drone", 1)

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

	verbs -= /mob/living/silicon/robot/verb/Namepick
	module = new /obj/item/robot_module/drone(src)

	//Allows Drones to hear the Engineering channel.
	module.channels = list("Engineering" = 1)
	radio.recalculateChannels()

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in src.module
	stack_wood = locate(/obj/item/stack/sheet/wood) in src.module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in src.module
	stack_plastic = locate(/obj/item/stack/sheet/plastic) in src.module

	//Grab decompiler.
	decompiler = locate(/obj/item/matter_decompiler) in src.module

	//Some tidying-up.
	scanner.Grant(src)
	update_icons()

/mob/living/silicon/robot/drone/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/drone()
	connected_ai = null

	aiCamera = new/obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = ";"

	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

//Redefining some robot procs...
/mob/living/silicon/robot/drone/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

/mob/living/silicon/robot/drone/get_default_name()
	return "maintenance drone ([rand(100,999)])"

/mob/living/silicon/robot/drone/update_icons()
	overlays.Cut()
	if(stat == CONSCIOUS)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

	hat_icons()

/mob/living/silicon/robot/drone/choose_icon()
	return


/mob/living/silicon/robot/drone/pick_module()
	return

/mob/living/silicon/robot/drone/can_be_revived()
	. = ..()
	if(emagged)
		return FALSE

//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/borg/upgrade/))
		to_chat(user, "<span class='warning'>The maintenance drone chassis not compatible with \the [W].</span>")
		return

	else if(istype(W, /obj/item/crowbar))
		to_chat(user, "The machine is hermetically sealed. You can't open the case.")
		return

	else if(W.GetID())
		if(stat == DEAD)
			if(!config.allow_drone_spawn || emagged || health < -35) //It's dead, Dave.
				to_chat(user, "<span class='warning'>The interface is fried, and a distressing burned smell wafts from the robot's interior. You're not rebooting this one.</span>")
				return

			if(!allowed(W))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return

			var/delta = (world.time / 10) - last_reboot
			if(reboot_cooldown > delta)
				var/cooldown_time = round(reboot_cooldown - ((world.time / 10) - last_reboot), 1)
				to_chat(usr, "<span class='warning'>The reboot system is currently offline. Please wait another [cooldown_time] seconds.</span>")
				return

			user.visible_message("<span class='warning'>\the [user] swipes [user.p_their()] ID card through [src], attempting to reboot it.</span>", "<span class='warning'>You swipe your ID card through [src], attempting to reboot it.</span>")
			last_reboot = world.time / 10
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
				if(D.key && D.client)
					drones++
			if(drones < config.max_maint_drones)
				request_player()
			return

		else
			var/confirm = alert("Using your ID on a Maintenance Drone will shut it down, are you sure you want to do this?", "Disable Drone", "Yes", "No")
			if(confirm == ("Yes") && (user in range(3, src)))
				user.visible_message("<span class='warning'>\the [user] swipes [user.p_their()] ID card through [src], attempting to shut it down.</span>", "<span class='warning'>You swipe your ID card through \the [src], attempting to shut it down.</span>")

				if(emagged)
					return

				if(allowed(W))
					shut_down()
				else
					to_chat(user, "<span class='warning'>Access denied.</span>")

		return

	..()

/mob/living/silicon/robot/drone/emag_act(user as mob)
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

	to_chat(src, "<span class='warning'>You feel a sudden burst of malware loaded into your execute-as-root buffer. Your tiny brain methodically parses, loads and executes the script. You sense you have five minutes before the drone server detects this and automatically shuts you down.</span>")

	message_admins("[ADMIN_LOOKUPFLW(H)] emagged drone [key_name_admin(src)].  Laws overridden.")
	add_attack_logs(user, src, "emagged")
	add_conversion_logs(src, "Converted as a slave to [key_name_log(H)]")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [H.name]([H.key]) emagged [name]([key])")
	addtimer(CALLBACK(src, .proc/shut_down, TRUE), EMAG_TIMER)

	emagged = 1
	density = 1
	pass_flags = 0
	icon_state = "repairbot-emagged"
	holder_type = /obj/item/holder/drone/emagged
	update_icons()
	lawupdate = 0
	connected_ai = null
	clear_supplied_laws()
	clear_inherent_laws()
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Only [H.real_name] and people [H.real_name] designates as being such are Syndicate Agents.")

	to_chat(src, "<b>Obey these laws:</b>")
	laws.show_laws(src)
	to_chat(src, "<span class='boldwarning'>ALERT: [H.real_name] is your new master. Obey your new laws and [H.real_name]'s commands.</span>")
	return

/mob/living/silicon/robot/drone/ratvar_act(weak)
	if(client)
		var/mob/living/silicon/robot/cogscarab/cog = new (get_turf(src))
		if(mind)
			SSticker.mode.add_clocker(mind)
			mind.transfer_to(cog)
		else
			cog.key = client.key
	spawn_dust()
	gib()

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()
	health = maxHealth - (getBruteLoss() + getFireLoss() + (suiciding ? getOxyLoss() : 0))
	update_stat("updatehealth([reason])", should_log)

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

/mob/living/silicon/robot/drone/proc/shut_down(force=FALSE)
	if(stat == DEAD)
		return

	if(emagged && !force)
		to_chat(src, "<span class='warning'>You feel a system kill order percolate through your tiny brain, but it doesn't seem like a good idea to you.</span>")
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
		if(cannotPossess(O))
			continue
		if(jobban_isbanned(O,"nonhumandept") || jobban_isbanned(O,"Drone"))
			continue
		if(O.client)
			if(ROLE_PAI in O.client.prefs.be_special)
				question(O.client,O)

/mob/living/silicon/robot/drone/proc/question(var/client/C,var/mob/M)
	spawn(0)
		if(!C || !M || jobban_isbanned(M,"nonhumandept") || jobban_isbanned(M,"Drone"))	return
		var/response = alert(C, "Someone is attempting to reboot a maintenance drone. Would you like to play as one?", "Maintenance drone reboot", "Yes", "No")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)

/mob/living/silicon/robot/drone/proc/transfer_personality(var/client/player)

	if(!player) return

	mind = new
	mind.current = src
	mind.original = src
	mind.assigned_role = "Drone"
	SSticker.minds += mind
	mind.key = player.key
	key = player.key

	lawupdate = 0
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
	updateicon()

	choose_icon(6,sprite)
*/


/mob/living/silicon/robot/drone/Bump(atom/movable/AM, yes)
	if(is_type_in_list(AM, allowed_bumpable_objects))
		return ..()

/mob/living/silicon/robot/drone/Bumped(atom/movable/AM)
	return

/mob/living/silicon/robot/drone/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)

	if(is_type_in_list(AM, pullable_drone_items))
		..(AM, force = INFINITY) // Drone power! Makes them able to drag pipes and such

	else if(istype(AM,/obj/item))
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
	src.verbs |= silicon_subsystems

/mob/living/silicon/robot/drone/remove_robot_verbs()
	src.verbs -= silicon_subsystems

/mob/living/silicon/robot/drone/update_canmove(delay_action_updates = 0)
	. = ..()
	density = emagged //this is reset every canmove update otherwise

/mob/living/simple_animal/drone/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
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
		new/obj/effect/decal/cleanable/blood/oil(get_turf(src))
		C.stored_comms["metal"] += 15
		C.stored_comms["glass"] += 15
		C.stored_comms["wood"] += 5
		qdel(src)
		return TRUE
	return ..()
