// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2

/mob/living/simple_animal/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	density = 1
	move_resist = MOVE_FORCE_STRONG
	animate_movement = 1
	health = 50
	maxHealth = 50
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	a_intent = INTENT_HARM //No swapping
	buckle_lying = FALSE
	mob_size = MOB_SIZE_LARGE
	radio_channel = "Supply"

	bot_type = MULE_BOT
	bot_filter = RADIO_MULEBOT
	model = "MULE"
	bot_purpose = "deliver crates and other packages between departments, as requested"
	bot_core_type = /obj/machinery/bot_core/mulebot
	path_image_color = "#7F5200"


	suffix = ""

	var/global/mulebot_count = 0
	var/atom/movable/load = null
	var/mob/living/passenger = null
	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/home_destination = "" 	// tag of home beacon

	var/reached_target = 1 	//true if already reached the target

	var/auto_return = 1		// true if auto return to home beacon after unload
	var/auto_pickup = 1 	// true if auto-pickup at beacon
	var/report_delivery = 1 // true if bot will announce an arrival to a location.

	var/obj/item/stock_parts/cell/cell
	var/datum/wires/mulebot/wires = null
	var/bloodiness = 0
	var/currentBloodColor = "#A10808"
	var/currentDNA = null

/mob/living/simple_animal/bot/mulebot/get_cell()
	return cell

/mob/living/simple_animal/bot/mulebot/New()
	..()
	wires = new /datum/wires/mulebot(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	access_card.access = J.get_access()
	prev_access = access_card.access
	cell = new /obj/item/stock_parts/cell/upgraded(src)

	mulebot_count++
	set_suffix(suffix ? suffix : "#[mulebot_count]")

/mob/living/simple_animal/bot/mulebot/Destroy()
	unload(0)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	return ..()

/mob/living/simple_animal/bot/mulebot/proc/set_suffix(suffix)
	src.suffix = suffix
	if(paicard)
		bot_name = "\improper MULEbot ([suffix])"
	else
		name = "\improper MULEbot ([suffix])"

/mob/living/simple_animal/bot/mulebot/bot_reset()
	..()
	reached_target = 0

/mob/living/simple_animal/bot/mulebot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		..()
		if(open)
			on = FALSE
		update_controls()
	else if(istype(I,/obj/item/stock_parts/cell) && open && !cell)
		if(!user.drop_item())
			return
		var/obj/item/stock_parts/cell/C = I
		C.forceMove(src)
		cell = C
		visible_message("[user] inserts a cell into [src].",
						"<span class='notice'>You insert the new cell into [src].</span>")
		update_controls()
	else if(istype(I, /obj/item/crowbar) && open && cell)
		cell.add_fingerprint(usr)
		cell.forceMove(loc)
		cell = null
		visible_message("[user] crowbars out the power cell from [src].",
						"<span class='notice'>You pry the powercell out of [src].</span>")
		update_controls()
	else if(istype(I, /obj/item/wrench))
		if(health < maxHealth)
			adjustBruteLoss(-25)
			updatehealth()
			user.visible_message(
				"<span class='notice'>[user] repairs [src]!</span>",
				"<span class='notice'>You repair [src]!</span>"
			)
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair!</span>")
	else if((istype(I, /obj/item/multitool) || istype(I, /obj/item/wirecutters)) && open)
		return attack_hand(user)
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1 + I.force * 2))
			unload(0)
			user.visible_message("<span class='danger'>[user] knocks [load] off [src] with \the [I]!</span>",
									"<span class='danger'>You knock [load] off [src] with \the [I]!</span>")
		else
			to_chat(user, "<span class='warning'>You hit [src] with \the [I] but to no effect!</span>")
			..()
	else
		..()
	update_icon()
	return

/mob/living/simple_animal/bot/mulebot/emag_act(mob/user)
	if(emagged < 1)
		emagged = 1
	if(!open)
		locked = !locked
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the [src]'s controls!</span>")
	flick("mulebot-emagged", src)
	playsound(loc, 'sound/effects/sparks1.ogg', 100, 0)

/mob/living/simple_animal/bot/mulebot/update_icon()
	if(open)
		icon_state="mulebot-hatch"
	else
		icon_state = "mulebot[!wires.MobAvoid()]"
	overlays.Cut()
	if(load && !ismob(load))//buckling handles the mob offsets
		load.pixel_y = initial(load.pixel_y) + 9
		if(load.layer < layer)
			load.layer = layer + 0.1
		overlays += load
	return

/mob/living/simple_animal/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			for(var/i = 1; i < 3; i++)
				wires.RandomCut()
		if(3)
			wires.RandomCut()
	return

/mob/living/simple_animal/bot/mulebot/bullet_act(obj/item/projectile/Proj)
	if(..())
		if(prob(50) && !isnull(load))
			unload(0)
		if(prob(25))
			visible_message("<span class='danger'>Something shorts out inside [src]!</span>")
			wires.RandomCut()

/mob/living/simple_animal/bot/mulebot/Topic(href, list/href_list)
	if(..())
		return 1

	switch(href_list["op"])
		if("lock")
			toggle_lock(usr)
		if("power")
			if(on)
				turn_off()
			else if(cell && !open)
				if(!turn_on())
					to_chat(usr, "<span class='warning'>You can't switch on [src]!</span>")
					return
			else
				return
			visible_message("[usr] switches [on ? "on" : "off"] [src].")
		if("cellremove")
			if(open && cell && !usr.get_active_hand())
				cell.update_icon()
				usr.put_in_active_hand(cell)
				cell.add_fingerprint(usr)
				cell = null

				usr.visible_message("<span class='notice'>[usr] removes the power cell from [src].</span>", "<span class='notice'>You remove the power cell from [src].</span>")
		if("cellinsert")
			if(open && !cell)
				var/obj/item/stock_parts/cell/C = usr.get_active_hand()
				if(istype(C))
					usr.drop_item()
					cell = C
					C.forceMove(src)
					C.add_fingerprint(usr)

					usr.visible_message("<span class='notice'>[usr] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		if("stop")
			if(mode >= BOT_DELIVER)
				bot_reset()
		if("go")
			if(mode == BOT_IDLE)
				start()
		if("home")
			if(mode == BOT_IDLE || mode == BOT_DELIVER)
				start_home()
		if("destination")
			var/new_dest = input(usr, "Enter Destination:", name, destination) as null|anything in GLOB.deliverybeacontags
			if(new_dest)
				set_destination(new_dest)
		if("setid")
			var/new_id = stripped_input(usr, "Enter ID:", name, suffix, MAX_NAME_LEN)
			if(new_id)
				set_suffix(new_id)
		if("sethome")
			var/new_home = input(usr, "Enter Home:", name, home_destination) as null|anything in GLOB.deliverybeacontags
			if(new_home)
				home_destination = new_home
		if("unload")
			if(load && mode != BOT_HUNT)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
		if("autoret")
			auto_return = !auto_return
		if("autopick")
			auto_pickup = !auto_pickup
		if("report")
			report_delivery = !report_delivery
	update_controls()

/mob/living/simple_animal/bot/mulebot/proc/toggle_lock(var/mob/user)
	if(bot_core.allowed(user))
		locked = !locked
		update_controls()
		return 1
	else
		to_chat(user, "<span class='danger'>Access denied.</span>")
		return 0

// TODO: remove this; PDAs currently depend on it
/mob/living/simple_animal/bot/mulebot/get_controls(mob/user)
	var/ai = issilicon(user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<h3>Multiple Utility Load Effector Mk. V</h3>"
	dat += "<b>ID:</b> [suffix]<BR>"
	dat += "<b>Power:</b> [on ? "On" : "Off"]<BR>"

	if(!open)
		dat += "<h3>Status</h3>"
		dat += "<div class='statusDisplay'>"
		switch(mode)
			if(BOT_IDLE)
				dat += "<span class='good'>Ready</span>"
			if(BOT_DELIVER)
				dat += "<span class='good'>[mode_name[BOT_DELIVER]]</span>"
			if(BOT_GO_HOME)
				dat += "<span class='good'>[mode_name[BOT_GO_HOME]]</span>"
			if(BOT_BLOCKED)
				dat += "<span class='average'>[mode_name[BOT_BLOCKED]]</span>"
			if(BOT_NAV,BOT_WAIT_FOR_NAV)
				dat += "<span class='average'>[mode_name[BOT_NAV]]</span>"
			if(BOT_NO_ROUTE)
				dat += "<span class='bad'>[mode_name[BOT_NO_ROUTE]]</span>"
		dat += "</div>"

		dat += "<b>Current Load:</b> [load ? load.name : "<i>none</i>"]<BR>"
		dat += "<b>Destination:</b> [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "<b>Power level:</b> [cell ? cell.percent() : 0]%"

		if(locked && !ai && !user.can_admin_interact())
			dat += "&nbsp;<br /><div class='notice'>Controls are locked</div><A href='?src=[UID()];op=unlock'>Unlock Controls</A>"
		else
			dat += "&nbsp;<br /><div class='notice'>Controls are unlocked</div><A href='?src=[UID()];op=lock'>Lock Controls</A><BR><BR>"

			dat += "<A href='?src=[UID()];op=power'>Toggle Power</A><BR>"
			dat += "<A href='?src=[UID()];op=stop'>Stop</A><BR>"
			dat += "<A href='?src=[UID()];op=go'>Proceed</A><BR>"
			dat += "<A href='?src=[UID()];op=home'>Return to Home</A><BR>"
			dat += "<A href='?src=[UID()];op=destination'>Set Destination</A><BR>"
			dat += "<A href='?src=[UID()];op=setid'>Set Bot ID</A><BR>"
			dat += "<A href='?src=[UID()];op=sethome'>Set Home</A><BR>"
			dat += "<A href='?src=[UID()];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<A href='?src=[UID()];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"
			dat += "<A href='?src=[UID()];op=report'>Toggle Delivery Reporting</A> ([report_delivery ? "On" : "Off"])<BR>"
			if(load)
				dat += "<A href='?src=[UID()];op=unload'>Unload Now</A><BR>"
			dat += "<div class='notice'>The maintenance hatch is closed.</div>"
	else
		if(!ai)
			dat += "<div class='notice'>The maintenance hatch is open.</div><BR>"
			dat += "<b>Power cell:</b> "
			if(cell)
				dat += "<A href='?src=[UID()];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='?src=[UID()];op=cellinsert'>Removed</A><BR>"

			wires.Interact(user)
		else
			dat += "<div class='notice'>The bot is in maintenance mode and cannot be controlled.</div><BR>"

	return dat


// returns true if the bot has power
/mob/living/simple_animal/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && wires.HasPower()

/mob/living/simple_animal/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			audible_message("[src] makes a sighing buzz.", "<span class='emote'>You hear an electronic buzzing sound.</span>")
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		if(ANNOYED)
			audible_message("[src] makes an annoyed buzzing sound.", "<span class='emote'>You hear an electronic buzzing sound.</span>")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
		if(DELIGHT)
			audible_message("[src] makes a delighted ping!", "<span class='emote'>You hear a ping.</span>")
			playsound(loc, 'sound/machines/ping.ogg', 50, 0)


// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/simple_animal/bot/mulebot/MouseDrop_T(atom/movable/AM, mob/user)

	if(user.incapacitated() || user.lying || get_dist(user, src) > 1)
		return

	if(!istype(AM))
		return

	load(AM)

// called to load a crate
/mob/living/simple_animal/bot/mulebot/proc/load(atom/movable/AM)
	if(!on || load || AM.anchored || get_dist(src, AM) > 1)
		return


	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!istype(AM, /obj/item) && !istype(AM, /obj/machinery) && !istype(AM, /obj/structure) && !ismob(AM))
		return
	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/CRATE
	if(istype(AM,/obj/structure/closet/crate))
		CRATE = AM
	else
		if(wires.LoadCheck())
			buzz(SIGH)
			return	// if not hacked, only allow crates to be loaded

	if(CRATE) // if it's a crate, close before loading
		CRATE.close()

	if(isobj(AM))
		var/obj/O = AM
		if(O.has_buckled_mobs() || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

	if(isliving(AM))
		if(!load_mob(AM))
			return
	else
		AM.forceMove(src)

	load = AM
	mode = BOT_IDLE
	update_icon()

/mob/living/simple_animal/bot/mulebot/proc/load_mob(mob/living/M)
	can_buckle = TRUE
	if(buckle_mob(M))
		passenger = M
		load = M
		can_buckle = FALSE
		// Not sure why this is done
		reset_perspective(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/mulebot/post_buckle_mob(mob/living/M)
	M.pixel_y = initial(M.pixel_y) + 9
	if(M.layer < layer)
		M.layer = layer + 0.01

/mob/living/simple_animal/bot/mulebot/post_unbuckle_mob(mob/living/M)
	load = null
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/mob/living/simple_animal/bot/mulebot/proc/unload(dirn)
	if(!load)
		return

	mode = BOT_IDLE

	overlays.Cut()

	if(ismob(load))
		var/mob/M = load
		M.reset_perspective(null)
	unbuckle_all_mobs()

	if(load)
		load.forceMove(loc)
		load.pixel_y = initial(load.pixel_y)
		load.layer = initial(load.layer)
		load.plane = initial(load.plane)
		if(dirn)
			var/turf/T = loc
			var/turf/newT = get_step(T,dirn)
			if(load.CanPass(load,newT)) //Can't get off onto anything that wouldn't let you pass normally
				step(load, dirn)
		load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		if(AM == cell || AM == access_card || AM == Radio || AM == bot_core || AM == paicard)
			continue

		AM.forceMove(loc)
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		AM.plane = initial(AM.plane)
		if(ismob(AM))
			var/mob/M = AM
			M.reset_perspective(null)

/mob/living/simple_animal/bot/mulebot/call_bot()
	..()
	var/area/dest_area
	if(path && path.len)
		target = ai_waypoint //Target is the end point of the path, the waypoint set by the AI.
		dest_area = get_area(target)
		destination = format_text(dest_area.name)
		pathset = 1 //Indicates the AI's custom path is initialized.
		start()

/mob/living/simple_animal/bot/mulebot/handle_automated_action()
	diag_hud_set_botmode()

	if(!has_power())
		on = 0
		return
	if(on)
		var/speed = (wires.Motor1() ? 1 : 0) + (wires.Motor2() ? 2 : 0)
//		to_chat(world, "speed: [speed]")
		var/num_steps = 0
		switch(speed)
			if(0)
				// do nothing
			if(1)
				num_steps = 10
			if(2)
				num_steps = 5
			if(3)
				num_steps = 3

		if(num_steps)
			process_bot()
			num_steps--
			if(mode != BOT_IDLE)
				spawn(0)
					for(var/i=num_steps,i>0,i--)
						sleep(2)
						process_bot()

/mob/living/simple_animal/bot/mulebot/proc/process_bot()
	if(!on)
		return
	update_icon()

	switch(mode)
		if(BOT_IDLE) // idle
			return

		if(BOT_DELIVER, BOT_GO_HOME, BOT_BLOCKED) // navigating to deliver,home, or blocked
			if(loc == target) // reached target
				at_target()
				return

			else if(path.len > 0 && target) // valid path
				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					increment_path()
					return
				if(istype(next, /turf/simulated))
//					to_chat(world, "at ([x],[y]) moving to ([next.x],[next.y])")

					var/oldloc = loc
					var/moved = step_towards(src, next)	// attempt to move
					if(cell) cell.use(1)
					if(moved && oldloc!=loc)	// successful move
//						to_chat(world, "Successful move.")
						blockcount = 0
						increment_path()

						if(destination == home_destination)
							mode = BOT_GO_HOME
						else
							mode = BOT_DELIVER

					else		// failed to move

//						to_chat(world, "Unable to move.")
						blockcount++
						mode = BOT_BLOCKED
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 10)	// attempt 10 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)
							mode = BOT_WAIT_FOR_NAV
							blockcount = 0
							spawn(20)
								calc_path(avoid=next)
								if(path.len > 0)
									buzz(DELIGHT)
								mode = BOT_BLOCKED
							return
						return
				else
					buzz(ANNOYED)
//					to_chat(world, "Bad turf.")
					mode = BOT_NAV
					return
			else
//				to_chat(world, "No path.")
				mode = BOT_NAV
				return

		if(BOT_NAV)	// calculate new path
//			to_chat(world, "Calc new path.")
			mode = BOT_WAIT_FOR_NAV
			spawn(0)
				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = BOT_BLOCKED
					buzz(DELIGHT)

				else
					buzz(SIGH)

					mode = BOT_NO_ROUTE

// calculates a path to the current destination
// given an optional turf to avoid
/mob/living/simple_animal/bot/mulebot/calc_path(turf/avoid = null)
	check_bot_access()
	set_path(get_path_to(src, target, /turf/proc/Distance_cardinal, 0, 250, id=access_card, exclude=avoid))

// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/mob/living/simple_animal/bot/mulebot/proc/set_destination(new_dest)
	new_destination = new_dest
	get_nav()

// starts bot moving to current destination
/mob/living/simple_animal/bot/mulebot/proc/start()
	if(!on)
		return
	if(destination == home_destination)
		mode = BOT_GO_HOME
	else
		mode = BOT_DELIVER
	update_icon()
	get_nav()

// starts bot moving to home
// sends a beacon query to find
/mob/living/simple_animal/bot/mulebot/proc/start_home()
	if(!on)
		return
	spawn(0)
		set_destination(home_destination)
		mode = BOT_BLOCKED
	update_icon()

// called when bot reaches current target
/mob/living/simple_animal/bot/mulebot/proc/at_target()
	if(!reached_target)
		radio_channel = "Supply" //Supply channel
		audible_message("[src] makes a chiming sound!", "<span class='emote'>You hear a chime.</span>")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(pathset) //The AI called us here, so notify it of our arrival.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				to_chat(calling_ai, "<span class='notice'>[bicon(src)] [src] wirelessly plays a chiming sound!</span>")
				playsound(calling_ai, 'sound/machines/chime.ogg',40, 0)
				calling_ai = null
				radio_channel = "AI Private" //Report on AI Private instead if the AI is controlling us.

		if(load)		// if loaded, unload at target
			if(report_delivery)
				speak("Destination <b>[destination]</b> reached. Unloading [load].", radio_channel)
			if(istype(load, /obj/structure/closet/crate))
				var/obj/structure/closet/crate/C = load
				C.notifyRecipient(destination)
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup) // find a crate
				var/atom/movable/AM
				if(wires.LoadCheck()) // if hacked, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM && AM.Adjacent(src))
					load(AM)
					if(report_delivery)
						speak("Now loading [load] at <b>[get_area(src)]</b>.", radio_channel)
		// whatever happened, check to see if we return home

		if(auto_return && home_destination && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()	// otherwise go idle

	return

/mob/living/simple_animal/bot/mulebot/Move(turf/simulated/next)
	. = ..()

	if(. && istype(next))
		if(bloodiness)
			var/obj/effect/decal/cleanable/blood/tracks/B = locate() in next
			if(!B)
				B = new /obj/effect/decal/cleanable/blood/tracks(loc)
			if(blood_DNA && blood_DNA.len)
				B.blood_DNA |= blood_DNA.Copy()
			B.basecolor = currentBloodColor
			var/newdir = get_dir(next, loc)
			if(newdir == dir)
				B.setDir(newdir)
			else
				newdir = newdir | dir
				if(newdir == 3)
					newdir = 1
				else if(newdir == 12)
					newdir = 4
				B.setDir(newdir)
			B.update_icon()
			bloodiness--

// called when bot bumps into anything
/mob/living/simple_animal/bot/mulebot/Bump(atom/obs)
	if(!wires.MobAvoid())	// usually just bumps, but if avoidance disabled knock over mobs
		var/mob/M = obs
		if(ismob(M))
			if(istype(M,/mob/living/silicon/robot))
				visible_message("<span class='danger'>[src] bumps into [M]!</span>")
			else
				if(!paicard)
					add_attack_logs(src, M, "Knocked down")
					visible_message("<span class='danger'>[src] knocks over [M]!</span>")
					M.stop_pulling()
					M.Stun(8)
					M.Weaken(5)
	return ..()

/mob/living/simple_animal/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	if(H.player_logged)//No running over SSD people
		return
	add_attack_logs(src, H, "Run over (DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message("<span class='danger'>[src] drives over [H]!</span>", \
					"<span class='userdanger'>[src] drives over you!</span>")
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, "head", run_armor_check("head", "melee"))
	H.apply_damage(2*damage, BRUTE, "chest", run_armor_check("chest", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "l_leg", run_armor_check("l_leg", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "r_leg", run_armor_check("r_leg", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "l_arm", run_armor_check("l_arm", "melee"))
	H.apply_damage(0.5*damage, BRUTE, "r_arm", run_armor_check("r_arm", "melee"))




	if(NO_BLOOD in H.dna.species.species_traits)//Does the run over mob have blood?
		return//If it doesn't it shouldn't bleed (Though a check should be made eventually for things with liquid in them, like slime people, vox armalis, etc.)

	var/turf/T = get_turf(src)//Where are we?
	H.add_mob_blood(H)//Cover the victim in their own blood.
	H.add_splatter_floor(T)//Put the blood where we are.
	bloodiness += 4

	var/list/blood_dna = H.get_blood_dna_list()
	if(blood_dna)
		transfer_blood_dna(blood_dna)
		currentBloodColor = H.dna.species.blood_color
		return

/mob/living/simple_animal/bot/mulebot/bot_control_message(command, mob/user, user_turf)
	switch(command)
		if("start")
			if(load)
				to_chat(src, "<span class='warning big'>DELIVER [load] TO [destination]</span>")
			else
				to_chat(src, "<span class='warning big'>PICK UP DELIVERY AT [destination]</span>")
		if("unload")
			if(load)
				to_chat(src, "<span class='warning big'>UNLOAD</span>")
			else
				to_chat(src, "<span class='warning big'>LOAD</span>")
		if("autoret", "autopick", "target")
		else
			..()

/mob/living/simple_animal/bot/mulebot/receive_signal(datum/signal/signal)
	if(!wires.RemoteRX() || ..())
		return 1

	var/recv = signal.data["command"]

	// process control input
	switch(recv)
		if("start")
			start()

		if("target")
			set_destination(signal.data["destination"])

		if("unload")
			if(client)
				return 1
			if(loc == target)
				unload(loaddir)
			else
				unload(0)

		if("home")
			start_home()

		if("autoret")
			auto_return = text2num(signal.data["value"])

		if("autopick")
			auto_pickup = text2num(signal.data["value"])

		else
			return 0
	return 1

// send a radio signal with multiple data key/values
/mob/living/simple_animal/bot/mulebot/post_signal_multiple(var/freq, var/list/keyval)
	if(!wires.RemoteTX())
		return

	..()

// signals bot status etc. to controller
/mob/living/simple_animal/bot/mulebot/send_status()
	var/list/kv = list(
		"type" = MULE_BOT,
		"name" = suffix,
		"loca" = get_area(src),
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, kv)

// player on mulebot attempted to move
/mob/living/simple_animal/bot/mulebot/relaymove(mob/user)
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)


//Update navigation data. Called when commanded to deliver, return home, or a route update is needed...
/mob/living/simple_animal/bot/mulebot/proc/get_nav()
	if(!on || !wires.BeaconRX())
		return

	for(var/obj/machinery/navbeacon/NB in GLOB.deliverybeacons)
		if(NB.location == new_destination)	// if the beacon location matches the set destination
			destination = new_destination	// the we will navigate there
			target = NB.loc
			var/direction = NB.dir	// this will be the load/unload dir
			loaddir = direction
			update_icon()
			calc_path()
			return

/mob/living/simple_animal/bot/mulebot/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()


/mob/living/simple_animal/bot/mulebot/explode()
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	do_sparks(3, 1, src)

	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()

/mob/living/simple_animal/bot/mulebot/remove_air(amount) //To prevent riders suffocating
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/mob/living/simple_animal/bot/mulebot/resist()
	..()
	if(load)
		unload()

/mob/living/simple_animal/bot/mulebot/UnarmedAttack(atom/A)
	if(isturf(A) && isturf(loc) && loc.Adjacent(A) && load)
		unload(get_dir(loc, A))
	else
		..()

#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot
	req_access = list(access_cargo)
