/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	icon = 'icons/mob/robots.dmi'
	icon_state = "repairbot"
	maxHealth = 35
	health = 35
	universal_speak = 0
	universal_understand = 1
	gender = NEUTER
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = 0
	density = 1
	req_access = list(access_engine, access_robotics)

	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/cyborg/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/mineral/plastic/cyborg/stack_plastic = null
	var/obj/item/weapon/matter_decompiler/decompiler = null

	//Used for self-mailing.
	var/mail_destination = 0

	//Used for pulling.

/mob/living/silicon/robot/drone/New()

	..()

	if(camera && "Robots" in camera.network)
		camera.network.Add("Engineering")

	//They are unable to be upgraded, so let's give them a bit of a better battery.
	cell.maxcharge = 10000
	cell.charge = 10000

	// NO BRAIN.
	mmi = null

	//We need to screw with their HP a bit. They have around one fifth as much HP as a full borg.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.max_damage = 10

	verbs -= /mob/living/silicon/robot/verb/Namepick
	module = new /obj/item/weapon/robot_module/drone(src)

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in src.module
	stack_wood = locate(/obj/item/stack/sheet/wood/cyborg) in src.module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in src.module
	stack_plastic = locate(/obj/item/stack/sheet/mineral/plastic/cyborg) in src.module

	//Grab decompiler.
	decompiler = locate(/obj/item/weapon/matter_decompiler) in src.module

	//Some tidying-up.
	flavor_text = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: 'NanoTrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
	updateicon()

/mob/living/silicon/robot/drone/init()
	laws = new /datum/ai_laws/drone()
	connected_ai = null

	aiCamera = new/obj/item/device/camera/siliconcam/drone_camera(src)
	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

//Redefining some robot procs...
/mob/living/silicon/robot/drone/updatename()
	real_name = "maintenance drone ([rand(100,999)])"
	name = real_name

/mob/living/silicon/robot/drone/updateicon()

	overlays.Cut()
	if(stat == 0)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

/mob/living/silicon/robot/drone/choose_icon()
	return

/mob/living/silicon/robot/drone/pick_module()
	return

//Drones can only use binary and say emotes. NOTHING else.
//TBD, fix up boilerplate. ~ Z
/mob/living/silicon/robot/drone/say(var/message)

	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (stat == 2)
		return say_dead(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))
	else if(length(message) >= 2)

		if(copytext(message, 1 ,3) == ":d" || copytext(message, 1 ,3) == ":D")

			if(!is_component_functioning("radio"))
				src << "\red Your radio transmitter isn't functional."
				return

			for (var/mob/living/S in living_mob_list)
				if(istype(S, /mob/living/silicon/robot/drone))
					S << "<i><span class='game say'>Drone Talk, <span class='name'>[name]</span><span class='message'> transmits, \"[message]\"</span></span></i>"

			for (var/mob/M in dead_mob_list)
				if(!istype(M,/mob/new_player) && !istype(M,/mob/living/carbon/brain))
					M << "<i><span class='game say'>Drone Talk, <span class='name'>[name]</span><span class='message'> transmits, \"[trim(copytext(message,3))]\"</span></span></i>"

		else

			var/list/listeners = hearers(5,src)
			listeners |= src

			for(var/mob/living/silicon/robot/drone/D in listeners)
				if(D.client) D << "<b>[src]</b> transmits, \"[message]\""

			for (var/mob/M in player_list)
				if (istype(M, /mob/new_player))
					continue
				else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
					if(M.client) M << "<b>[src]</b> transmits, \"[message]\""

//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/borg/upgrade/))
		user << "\red The maintenance drone chassis not compatible with \the [W]."
		return

	else if (istype(W, /obj/item/weapon/crowbar))
		user << "The machine is hermetically sealed. You can't open the case."
		return

	else if (istype(W, /obj/item/weapon/card/emag))

		if(!client || stat == 2)
			user << "\red There's not much point subverting this heap of junk."
			return

		if(emagged)
			src << "\red [user] attempts to load subversive software into you, but your hacked subroutined ignore the attempt."
			user << "\red You attempt to subvert [src], but the sequencer has no effect."
			return

		user << "\red You swipe the sequencer across [src]'s interface and watch its eyes flicker."
		src << "\red You feel a sudden burst of malware loaded into your execute-as-root buffer. Your tiny brain methodically parses, loads and executes the script."

		var/obj/item/weapon/card/emag/emag = W
		emag.uses--

		message_admins("[key_name_admin(user)] emagged drone [key_name_admin(src)].  Laws overridden.")
		log_game("[key_name(user)] emagged drone [key_name(src)].  Laws overridden.")
		var/time = time2text(world.realtime,"hh:mm:ss")
		lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")

		emagged = 1
		lawupdate = 0
		connected_ai = null
		clear_supplied_laws()
		clear_inherent_laws()
		laws = new /datum/ai_laws/syndicate_override
		set_zeroth_law("Only [user.real_name] and people he designates as being such are Syndicate Agents.")

		src << "<b>Obey these laws:</b>"
		laws.show_laws(src)
		src << "\red \b ALERT: [user.real_name] is your new master. Obey your new laws and his commands."
		return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))

		if(stat == 2)

			if(!config.allow_drone_spawn || emagged || health < -35) //It's dead, Dave.
				user << "\red The interface is fried, and a distressing burned smell wafts from the robot's interior. You're not rebooting this one."
				return

			if(!allowed(usr))
				user << "\red Access denied."
				return

			user.visible_message("\red \the [user] swipes \his ID card through \the [src], attempting to reboot it.", "\red You swipe your ID card through \the [src], attempting to reboot it.")
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/D in world)
				if(D.key && D.client)
					drones++
			if(drones < config.max_maint_drones)
				request_player()
			return

		else
			user.visible_message("\red \the [user] swipes \his ID card through \the [src], attempting to shut it down.", "\red You swipe your ID card through \the [src], attempting to shut it down.")

			if(emagged)
				return

			if(allowed(usr))
				shut_down()
			else
				user << "\red Access denied."

		return

	..()

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth()
	if(status_flags & GODMODE)
		health = 35
		stat = CONSCIOUS
		return
	health = 35 - (getBruteLoss() + getFireLoss())
	return

//Easiest to check this here, then check again in the robot proc.
//Standard robots use config for crit, which is somewhat excessive for these guys.
//Drones killed by damage will gib.
/mob/living/silicon/robot/drone/handle_regular_status_updates()

	if(health <= -35 && src.stat != 2)
		timeofdeath = world.time
		death() //Possibly redundant, having trouble making death() cooperate.
		gib()
		return
	..()

/mob/living/silicon/robot/drone/death(gibbed)

	if(module)
		var/obj/item/weapon/gripper/G = locate(/obj/item/weapon/gripper) in module
		if(G) G.drop_item()

	..(gibbed)

//DRONE MOVEMENT.
/mob/living/silicon/robot/drone/Process_Spaceslipping(var/prob_slip)
	//TODO: Consider making a magboot item for drones to equip. ~Z
	return 0

//CONSOLE PROCS
/mob/living/silicon/robot/drone/proc/law_resync()
	if(stat != 2)
		if(emagged)
			src << "\red You feel something attempting to modify your programming, but your hacked subroutines are unaffected."
		else
			src << "\red A reset-to-factory directive packet filters through your data connection, and you obediently modify your programming to suit it."
			full_law_reset()
			show_laws()

/mob/living/silicon/robot/drone/proc/shut_down()
	if(stat != 2)
		if(emagged)
			src << "\red You feel a system kill order percolate through your tiny brain, but it doesn't seem like a good idea to you."
		else
			src << "\red You feel a system kill order percolate through your tiny brain, and you obediently destroy yourself."
			death()

/mob/living/silicon/robot/drone/proc/full_law_reset()
	clear_supplied_laws()
	clear_inherent_laws()
	clear_ion_laws()
	laws = new /datum/ai_laws/drone

//Reboot procs.

/mob/living/silicon/robot/drone/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Cyborg"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_PAI)
				question(O.client)

/mob/living/silicon/robot/drone/proc/question(var/client/C)
	spawn(0)
		if(!C || jobban_isbanned(C,"Cyborg"))	return
		var/response = alert(C, "Someone is attempting to reboot a maintenance drone. Would you like to play as one?", "Maintenance drone reboot", "Yes", "No", "Never for this round.")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_PAI

/mob/living/silicon/robot/drone/proc/transfer_personality(var/client/player)

	if(!player) return

	src.ckey = player.ckey

	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(src)

	lawupdate = 0
	src << "<b>Systems rebooted</b>. Loading base pattern maintenance protocol... <b>loaded</b>."
	full_law_reset()
	src << "<br><b>You are a maintenance drone, a tiny-brained robotic repair machine</b>."
	src << "You have no individual will, no personality, and no drives or urges other than your laws."
	src << "Use <b>:b</b> to talk to your fellow synthetics, <b>:d</b> to talk to other drones, and <b>say</b> to speak silently to your nearby fellows."
	src << "Remember,  you are <b>lawed against interference with the crew</b>. Also remember, <b>you DO NOT take orders from the AI.</b>"
	src << "<b>Don't invade their worksites, don't steal their resources, don't tell them about the changeling in the toilets.</b>"
	src << "<b>If a crewmember has noticed you, <i>you are probably breaking your first law</i></b>."

/mob/living/silicon/robot/drone/Bump(atom/movable/AM as mob|obj, yes)
	if (!yes || ( \
	 !istype(AM,/obj/machinery/door) && \
	 !istype(AM,/obj/machinery/recharge_station) && \
	 !istype(AM,/obj/machinery/disposal/deliveryChute) && \
	 !istype(AM,/obj/machinery/teleport/hub) && \
	 !istype(AM,/obj/effect/portal)
	)) return
	..()
	return

/mob/living/silicon/robot/drone/Bumped(AM as mob|obj)
	return

/mob/living/silicon/robot/drone/start_pulling(var/atom/movable/AM)

	if(istype(AM,/obj/item/pipe) || istype(AM,/obj/structure/disposalconstruct))
		..()
	else if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > 2)
			src << "<span class='warning'>You are too small to pull that.</span>"
			return
		else
			..()
	else
		src << "<span class='warning'>You are too small to pull that.</span>"
		return
