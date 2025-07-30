// Floorbot
/mob/living/simple_animal/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon_state = "floorbot"
	density = FALSE
	health = 25
	maxHealth = 25

	radio_channel = "Engineering"
	bot_type = FLOOR_BOT
	bot_filter = RADIO_FLOORBOT
	model = "Floorbot"
	bot_purpose = "seek out damaged or missing floor tiles, and repair or replace them as necessary"
	req_access = list(ACCESS_CONSTRUCTION, ACCESS_ROBOTICS)
	window_id = "autofloor"
	window_name = "Automatic Station Floor Repairer v1.1"
	/// Determines what to do when process_scan() receives a target. See process_scan() for details.
	var/process_type
	/// Tiles in inventory
	var/amount = 10
	/// Add tiles to existing floor
	var/replace_tiles = FALSE
	/// Add floor tiles to inventory
	var/eat_tiles = FALSE
	/// Convert metal into floor tiles (drops on floor)
	var/make_tiles = FALSE
	var/fix_floor = FALSE
	/// Fix the floor and include a tile.
	var/autotile = FALSE
	var/nag_on_empty = TRUE
	/// Prevents the Floorbot nagging more than once per refill.
	var/nagged = FALSE
	var/max_targets = 50
	var/turf/target
	var/oldloc
	var/toolbox_color = ""

	#define HULL_BREACH		1
	#define FIX_TILE		3
	#define AUTO_TILE		4
	#define REPLACE_TILE	5
	#define TILE_EMAG		6
	#define MAX_AMOUNT		50  // Maximum tiles bot can have in storage

/mob/living/simple_animal/bot/floorbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	toolbox_color = new_toolbox_color
	update_icon()
	var/datum/job/engineer/J = new/datum/job/engineer
	access_card.access += J.get_access()
	prev_access = access_card.access
	if(toolbox_color == "s")
		health = 50
		maxHealth = 50

/mob/living/simple_animal/bot/floorbot/bot_reset()
	..()
	target = null
	oldloc = null
	clear_ignore_list()
	nagged = 0
	anchored = FALSE
	update_icon()

/mob/living/simple_animal/bot/floorbot/set_custom_texts()
	text_hack = "You corrupt [name]'s construction protocols."
	text_dehack = "You detect errors in [name] and reset [p_their()] programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/floorbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/floorbot/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/floorbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotFloor", name)
		ui.open()

/mob/living/simple_animal/bot/floorbot/ui_data(mob/user)
	var/list/data = ..()
	data["hullplating"] = autotile
	data["replace"] = replace_tiles
	data["eat"] = eat_tiles
	data["make"] = make_tiles
	data["fixfloor"] = fix_floor
	data["nag_empty"] = nag_on_empty
	data["magnet"] = anchored
	data["tiles_amount"] = amount
	return data

/mob/living/simple_animal/bot/floorbot/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/mob/user = ui.user
	if(topic_denied(user))
		to_chat(user, "<span class='warning'>[src]'s interface is not responding!</span>")
		return
	add_fingerprint(user)
	. = TRUE
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
		if("autopatrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("hack")
			handle_hacking(usr)
		if("disableremote")
			remote_disabled = !remote_disabled
		if("autotile")
			autotile = !autotile
		if("replacetiles")
			replace_tiles = !replace_tiles
		if("eattiles")
			eat_tiles = !eat_tiles
		if("maketiles")
			make_tiles = !make_tiles
		if("fixfloors")
			fix_floor = !fix_floor
		if("nagonempty")
			nag_on_empty = !nag_on_empty
		if("anchored")
			anchored = !anchored
		if("ejectpai")
			ejectpai()

/mob/living/simple_animal/bot/floorbot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(amount >= MAX_AMOUNT)
			return ITEM_INTERACT_COMPLETE
		var/loaded = min(MAX_AMOUNT - amount, T.amount)
		T.use(loaded)
		amount += loaded
		if(loaded > 0)
			to_chat(user, "<span class='notice'>You load [loaded] tiles into the floorbot. [p_they(TRUE)] now contains [amount] tiles.</span>")
			nagged = 0
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least one floor tile to put into [src]!</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/simple_animal/bot/floorbot/emag_act(mob/user)
	..()
	if(emagged)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/floorbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(mode == BOT_REPAIRING || mode == BOT_EAT_TILE || mode == BOT_MAKE_TILE)
		return

	if(prob(5))
		audible_message("[src] makes an excited booping beeping sound!")

	// Normal scanning procedure. We have tiles loaded, are not emagged.
	if(!target && !emagged && amount)
		if(!target)
			process_type = HULL_BREACH // Ensures the floorbot does not try to "fix" space areas or shuttle docking zones.
			target = scan(/turf/space, avoid_bot = TRUE)

		if(!target && fix_floor) // Repairs damaged floors and tiles.
			process_type = FIX_TILE
			target = scan(/turf/simulated/floor, avoid_bot = TRUE)

		if(!target && replace_tiles) // Finds a floor without a tile and gives it one.
			process_type = REPLACE_TILE // The target must be the floor and not a tile. The floor must not already have a floortile.
			target = scan(/turf/simulated/floor/plating, avoid_bot = TRUE)

	if(!target && emagged) // We are emagged! Time to rip up the floors!
		process_type = TILE_EMAG
		target = scan(/turf/simulated/floor, avoid_bot = TRUE)

	if(amount < MAX_AMOUNT && !target) // Out of tiles! We must refill!

		if(!target && eat_tiles) // Configured to find and consume floortiles!
			process_type = null
			target = scan(/obj/item/stack/tile/plasteel)

		if(!target && make_tiles) // We did not manage to find any floor tiles! Scan for metal stacks and make our own!
			process_type = null
			target = scan(/obj/item/stack/sheet/metal)

		if(!target && nag_on_empty) // Floorbot is empty and cannot acquire more tiles, nag the engineers for more!
			nag()

	if(!target)

		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == target || loc == target.loc)

			if(istype(target, /obj/item/stack/tile/plasteel))
				start_eat_tile(target)

			if(istype(target, /obj/item/stack/sheet/metal))
				start_make_tile(target)

			if(isturf(target) && !emagged)
				repair(target)

			if(emagged && isfloorturf(target))
				var/turf/simulated/floor/F = target
				anchored = TRUE
				set_mode(BOT_REPAIRING)
				if(prob(90))
					F.break_tile_to_plating()
				else
					F.ReplaceWithLattice()
				audible_message("<span class='danger'>[src] makes an excited booping sound.</span>")
				addtimer(CALLBACK(src, PROC_REF(inc_amount_callback)), 5 SECONDS)

			path = list()
			return
		
		var/target_uid = target.UID() // target can become null while path is calculated, so we need to store UID
		if(!length(path)) // No path, need a new one
			if(!isturf(target))
				var/turf/TL = get_turf(target)
				path = get_path_to(src, TL, 30, access = access_card.access, simulated_only = 0)
			else
				path = get_path_to(src, target, 30, access = access_card.access, simulated_only = 0)

			if(!bot_move(target))
				add_to_ignore(target)
				ignore_job -= target_uid
				target = null
				set_mode(BOT_IDLE)
				return
		else if(!bot_move(target))
			ignore_job -= target_uid
			target = null
			set_mode(BOT_IDLE)
			return

	oldloc = loc

/mob/living/simple_animal/bot/floorbot/proc/inc_amount_callback()
	amount ++
	anchored = FALSE
	set_mode(BOT_IDLE)
	ignore_job -= target.UID()
	target = null

/mob/living/simple_animal/bot/floorbot/proc/nag() // Annoy everyone on the channel to refill us!
	if(!nagged)
		speak("Requesting refill [MAX_AMOUNT - amount] at <b>[get_area(src)]</b>!", radio_channel)
		nagged = TRUE

/mob/living/simple_animal/bot/floorbot/proc/is_hull_breach(turf/t) // Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	return !isspacearea(get_area(t))

// Floorbots, having several functions, need sort out special conditions here.
/mob/living/simple_animal/bot/floorbot/process_scan(atom/scan_target)
	var/result
	var/turf/simulated/floor/F
	switch(process_type)
		if(HULL_BREACH) // The most common job, patching breaches in the station's hull.
			if(is_hull_breach(scan_target)) // Ensure that the targeted space turf is actually part of the station, and not random space.
				result = scan_target
				anchored = TRUE // Prevent the floorbot being blown off-course while trying to reach a hull breach.
		if(REPLACE_TILE)
			F = scan_target
			if(istype(F, /turf/simulated/floor/plating)) // The floor must not already have a tile.
				if(locate(/obj/structure/window) in get_turf(F)) // Targeting plating under window
					add_to_ignore(scan_target)
					return FALSE
				result = F
		if(FIX_TILE)	// Selects only damaged floors.
			F = scan_target
			if(istype(F) && (F.broken || F.burnt))
				result = F
		if(TILE_EMAG) // Emag mode! Rip up the floor and cause breaches to space!
			F = scan_target
			if(!istype(F, /turf/simulated/floor/plating))
				result = F
		else // If no special processing is needed, simply return the result.
			result = scan_target
	return result

/mob/living/simple_animal/bot/floorbot/proc/repair(turf/target_turf)
	if(isspaceturf(target_turf))
		// Must be a hull breach to continue.
		if(!is_hull_breach(target_turf))
			ignore_job -= target.UID()
			target = null
			return

	else if(!isfloorturf(target_turf))
		return

	if(amount <= 0)
		set_mode(BOT_IDLE)
		ignore_job -= target.UID()
		target = null
		return

	anchored = TRUE

	if(isspaceturf(target_turf)) // If we are fixing an area not part of pure space, it is
		visible_message("<span class='notice'>[src] begins to repair the hole.</span>")
		set_mode(BOT_REPAIRING)
		update_icon(UPDATE_OVERLAYS)
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), target_turf), 5 SECONDS)

	else
		var/turf/simulated/floor/F = target_turf
		set_mode(BOT_REPAIRING)
		update_icon(UPDATE_OVERLAYS)
		visible_message("<span class='notice'>[src] begins repairing the floor.</span>")
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), F), 5 SECONDS)


/mob/living/simple_animal/bot/floorbot/proc/make_bridge_plating(turf/target_turf)
	var/turf/simulated/floor/F = target
	if(mode != BOT_REPAIRING)
		return

	ignore_job -= target_turf.UID() // If called after the tile fix, turf changes and the UID with it

	if(autotile || replace_tiles)
		if(process_type != HULL_BREACH)
			F.break_tile_to_plating()
		target_turf.ChangeTurf(/turf/simulated/floor/plasteel)
	else
		target_turf.ChangeTurf(/turf/simulated/floor/plating)

	set_mode(BOT_IDLE)
	amount--
	update_icon(UPDATE_OVERLAYS)
	anchored = FALSE
	target = null

/mob/living/simple_animal/bot/floorbot/proc/start_eat_tile(obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	anchored = TRUE
	visible_message("<span class='notice'>[src] begins to collect tiles.</span>")
	set_mode(BOT_EAT_TILE)
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(do_eat_tile), T), 2 SECONDS)

/mob/living/simple_animal/bot/floorbot/proc/do_eat_tile(obj/item/stack/tile/plasteel/T)
	if(isnull(T))
		target = null
		set_mode(BOT_IDLE)
		return
	if((amount + T.amount) > MAX_AMOUNT)
		var/i = MAX_AMOUNT - amount
		amount += i
		T.amount -= i
	else
		amount += T.amount
		qdel(T)
	anchored = FALSE
	target = null
	set_mode(BOT_IDLE)
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/bot/floorbot/proc/start_make_tile(obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	anchored = TRUE
	visible_message("<span class='notice'>[src] begins to create tiles.</span>")
	set_mode(BOT_MAKE_TILE)
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(do_make_tile), M), 2 SECONDS)

/mob/living/simple_animal/bot/floorbot/proc/do_make_tile(obj/item/stack/sheet/metal/M)
	if(isnull(M))
		target = null
		set_mode(BOT_IDLE)
		return

	if((amount + 4) > MAX_AMOUNT) // 1 metal = 4 tiles, hence + 4
		var/missing_amount = MAX_AMOUNT - amount
		var/extra = amount + 4 - MAX_AMOUNT
		amount += missing_amount
		new /obj/item/stack/tile/plasteel(get_turf(src), extra)
	else
		amount += 4

	if(M.amount > 1)
		M.amount --
	else
		qdel(M)
	anchored = FALSE
	target = null
	set_mode(BOT_IDLE)
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/bot/floorbot/update_icon_state()
	return

/mob/living/simple_animal/bot/floorbot/update_overlays()
	. = ..()
	if(toolbox_color)
		. += "[toolbox_color]floorbot"
	if(mode == BOT_REPAIRING || mode == BOT_EAT_TILE || mode == BOT_MAKE_TILE)
		. += "floorbot_work"
	else
		. += "floorbot_[on ? "on" : "off"]"
		. += "floorbot_[amount > 0 ? "metal" : ""]"

/mob/living/simple_animal/bot/floorbot/explode()
	on = FALSE
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	var/obj/item/storage/toolbox/mechanical/N = new /obj/item/storage/toolbox/mechanical(Tsec)
	N.contents = list()
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)

	while(amount)// Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = 16
			amount -= 16
		else
			var/obj/item/stack/tile/plasteel/T = new (Tsec)
			T.amount = amount
			amount = 0

	do_sparks(3, 1, src)
	..()

/mob/living/simple_animal/bot/floorbot/UnarmedAttack(atom/A)
	if(isturf(A))
		repair(A)
	else if(istype(A,/obj/item/stack/tile/plasteel))
		start_eat_tile(A)
	else if(istype(A,/obj/item/stack/sheet/metal))
		start_make_tile(A)
	else
		..()


#undef HULL_BREACH
#undef FIX_TILE
#undef AUTO_TILE
#undef REPLACE_TILE
#undef TILE_EMAG
#undef MAX_AMOUNT
