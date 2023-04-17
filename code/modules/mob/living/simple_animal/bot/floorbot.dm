//Floorbot
/mob/living/simple_animal/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	anchored = FALSE
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

	var/process_type //Determines what to do when process_scan() recieves a target. See process_scan() for details.
	var/targetdirection
	var/amount = 10
	var/replacetiles = 0
	var/eattiles = 0
	var/maketiles = 0
	var/fixfloors = 0
	var/autotile = 0
	var/nag_on_empty = 1
	var/nagged = 0 //Prevents the Floorbot nagging more than once per refill.
	var/max_targets = 50
	var/turf/target
	var/oldloc = null
	var/toolbox_color = ""

	#define HULL_BREACH		1
	#define BRIDGE_MODE		2
	#define FIX_TILE		3
	#define AUTO_TILE		4
	#define REPLACE_TILE	5
	#define TILE_EMAG		6

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
	ignore_list.Cut()
	nagged = 0
	anchored = FALSE
	update_icon()

/mob/living/simple_animal/bot/floorbot/set_custom_texts()
	text_hack = "You corrupt [name]'s construction protocols."
	text_dehack = "You detect errors in [name] and reset [p_their()] programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/floorbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Floor Repairer Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[UID()];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Tiles left: [amount]<BR>"
	dat += "Behvaiour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += "Add tiles to new hull plating: <A href='?src=[UID()];operation=autotile'>[autotile ? "Yes" : "No"]</A><BR>"
		dat += "Replace floor tiles: <A href='?src=[UID()];operation=replace'>[replacetiles ? "Yes" : "No"]</A><BR>"
		dat += "Finds tiles: <A href='?src=[UID()];operation=tiles'>[eattiles ? "Yes" : "No"]</A><BR>"
		dat += "Make pieces of metal into tiles when empty: <A href='?src=[UID()];operation=make'>[maketiles ? "Yes" : "No"]</A><BR>"
		dat += "Transmit notice when empty: <A href='?src=[UID()];operation=emptynag'>[nag_on_empty ? "Yes" : "No"]</A><BR>"
		dat += "Repair damaged tiles and platings: <A href='?src=[UID()];operation=fix'>[fixfloors ? "Yes" : "No"]</A><BR>"
		dat += "Traction Magnets: <A href='?src=[UID()];operation=anchor'>[anchored ? "Engaged" : "Disengaged"]</A><BR>"
		dat += "Patrol Station: <A href='?src=[UID()];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"
		var/bmode
		if(targetdirection)
			bmode = dir2text(targetdirection)
		else
			bmode = "disabled"
		dat += "Bridge Mode : <A href='?src=[UID()];operation=bridgemode'>[bmode]</A><BR>"

	return dat


/mob/living/simple_animal/bot/floorbot/attackby(obj/item/W , mob/user, params)
	if(istype(W, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/T = W
		if(amount >= 50)
			return
		var/loaded = min(50-amount, T.amount)
		T.use(loaded)
		amount += loaded
		if(loaded > 0)
			to_chat(user, "<span class='notice'>You load [loaded] tiles into the floorbot. [p_they(TRUE)] now contains [amount] tiles.</span>")
			nagged = 0
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least one floor tile to put into [src]!</span>")
	else
		..()

/mob/living/simple_animal/bot/floorbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/floorbot/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["operation"])
		if("replace")
			replacetiles = !replacetiles
		if("tiles")
			eattiles = !eattiles
		if("make")
			maketiles = !maketiles
		if("fix")
			fixfloors = !fixfloors
		if("autotile")
			autotile = !autotile
		if("emptynag")
			nag_on_empty = !nag_on_empty
		if("anchor")
			anchored = !anchored

		if("bridgemode")
			var/setdir = input("Select construction direction:") as null|anything in list("north","east","south","west","disable")
			switch(setdir)
				if("north")
					targetdirection = 1
				if("south")
					targetdirection = 2
				if("east")
					targetdirection = 4
				if("west")
					targetdirection = 8
				if("disable")
					targetdirection = null
	update_controls()

/mob/living/simple_animal/bot/floorbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_REPAIRING)
		return

	if(amount <= 0 && !target) //Out of tiles! We must refill!
		if(eattiles) //Configured to find and consume floortiles!
			target = scan(/obj/item/stack/tile/plasteel)
			process_type = null

		if(!target && maketiles) //We did not manage to find any floor tiles! Scan for metal stacks and make our own!
			target = scan(/obj/item/stack/sheet/metal)
			process_type = null
			return
		else
			if(nag_on_empty) //Floorbot is empty and cannot acquire more tiles, nag the engineers for more!
				nag()

	if(prob(5))
		audible_message("[src] makes an excited booping beeping sound!")

	//Normal scanning procedure. We have tiles loaded, are not emagged.
	if(!target && emagged < 2 && amount > 0)
		if(targetdirection != null) //The bot is in bridge mode.
			//Try to find a space tile immediately in our selected direction.
			var/turf/T = get_step(src, targetdirection)
			if(isspaceturf(T))
				target = T

			else //Find a space tile farther way!
				target = scan(/turf/space)
			process_type = BRIDGE_MODE

		if(!target)
			process_type = HULL_BREACH //Ensures the floorbot does not try to "fix" space areas or shuttle docking zones.
			target = scan(/turf/space)

		if(!target && replacetiles) //Finds a floor without a tile and gives it one.
			process_type = REPLACE_TILE //The target must be the floor and not a tile. The floor must not already have a floortile.
			target = scan(/turf/simulated/floor)

		if(!target && fixfloors) //Repairs damaged floors and tiles.
			process_type = FIX_TILE
			target = scan(/turf/simulated/floor)

	if(!target && emagged == 2) //We are emagged! Time to rip up the floors!
		process_type = TILE_EMAG
		target = scan(/turf/simulated/floor)


	if(!target)

		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == target || loc == target.loc)
			if(istype(target, /obj/item/stack/tile/plasteel))
				start_eattile(target)
			else if(istype(target, /obj/item/stack/sheet/metal))
				start_maketile(target)
			else if(isturf(target) && emagged < 2)
				repair(target)
			else if(emagged == 2 && isfloorturf(target))
				var/turf/simulated/floor/F = target
				anchored = TRUE
				mode = BOT_REPAIRING
				if(prob(90))
					F.break_tile_to_plating()
				else
					F.ReplaceWithLattice()
				audible_message("<span class='danger'>[src] makes an excited booping sound.</span>")
				addtimer(CALLBACK(src, PROC_REF(inc_amount_callback)), 5 SECONDS)

			path = list()
			return
		if(!length(path))
			if(!isturf(target))
				var/turf/TL = get_turf(target)
				path = get_path_to(src, TL, 30, id=access_card,simulated_only = 0)
			else
				path = get_path_to(src, target, 30, id=access_card,simulated_only = 0)

			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				mode = BOT_IDLE
				return
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc

/mob/living/simple_animal/bot/floorbot/proc/inc_amount_callback()
	amount ++
	anchored = FALSE
	mode = BOT_IDLE
	target = null

/mob/living/simple_animal/bot/floorbot/proc/nag() //Annoy everyone on the channel to refill us!
	if(!nagged)
		speak("Requesting refill at <b>[get_area(src)]</b>!", radio_channel)
		nagged = TRUE

/mob/living/simple_animal/bot/floorbot/proc/is_hull_breach(turf/t) //Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	var/area/t_area = get_area(t)
	if(t_area && (t_area.name == "Space" || findtext(t_area.name, "huttle")))
		return 0
	else
		return 1

//Floorbots, having several functions, need sort out special conditions here.
/mob/living/simple_animal/bot/floorbot/process_scan(atom/scan_target)
	var/result
	var/turf/simulated/floor/F
	switch(process_type)
		if(HULL_BREACH) //The most common job, patching breaches in the station's hull.
			if(is_hull_breach(scan_target)) //Ensure that the targeted space turf is actually part of the station, and not random space.
				result = scan_target
				anchored = TRUE //Prevent the floorbot being blown off-course while trying to reach a hull breach.
		if(BRIDGE_MODE) //Only space turfs in our chosen direction are considered.
			if(get_dir(src, scan_target) == targetdirection)
				result = scan_target
				anchored = TRUE
		if(REPLACE_TILE)
			F = scan_target
			if(istype(F, /turf/simulated/floor/plating)) //The floor must not already have a tile.
				result = F
		if(FIX_TILE)	//Selects only damaged floors.
			F = scan_target
			if(istype(F) && (F.broken || F.burnt))
				result = F
		if(TILE_EMAG) //Emag mode! Rip up the floor and cause breaches to space!
			F = scan_target
			if(!istype(F, /turf/simulated/floor/plating))
				result = F
		else //If no special processing is needed, simply return the result.
			result = scan_target
	return result

/mob/living/simple_animal/bot/floorbot/proc/repair(turf/target_turf)
	if(isspaceturf(target_turf))
		//Must be a hull breach or in bridge mode to continue.
		if(!is_hull_breach(target_turf) && !targetdirection)
			target = null
			return

	else if(!isfloorturf(target_turf))
		return

	if(amount <= 0)
		mode = BOT_IDLE
		target = null
		return

	anchored = TRUE

	if(isspaceturf(target_turf)) //If we are fixing an area not part of pure space, it is
		visible_message("<span class='notice'>[targetdirection ? "[src] begins installing a bridge plating." : "[src] begins to repair the hole."] </span>")
		mode = BOT_REPAIRING
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), target_turf), 5 SECONDS)

	else
		var/turf/simulated/floor/F = target_turf
		mode = BOT_REPAIRING
		update_icon(UPDATE_ICON_STATE)
		visible_message("<span class='notice'>[src] begins repairing the floor.</span>")
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), F), 5 SECONDS)

/mob/living/simple_animal/bot/floorbot/proc/make_floor(turf/simulated/floor/F)
	if(mode != BOT_REPAIRING)
		return

	F.broken = FALSE
	F.burnt = FALSE
	F.ChangeTurf(/turf/simulated/floor/plasteel)
	mode = BOT_IDLE
	amount--
	update_icon(UPDATE_ICON_STATE)
	anchored = FALSE
	target = null

/mob/living/simple_animal/bot/floorbot/proc/make_bridge_plating(turf/target_turf)
	if(mode != BOT_REPAIRING)
		return

	if(autotile) //Build the floor and include a tile.
		target_turf.ChangeTurf(/turf/simulated/floor/plasteel)
	else //Build a hull plating without a floor tile.
		target_turf.ChangeTurf(/turf/simulated/floor/plating)
	mode = BOT_IDLE
	amount--
	update_icon(UPDATE_ICON_STATE)
	anchored = FALSE
	target = null

/mob/living/simple_animal/bot/floorbot/proc/start_eattile(obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	visible_message("<span class='notice'>[src] begins to collect tiles.</span>")
	mode = BOT_REPAIRING
	addtimer(CALLBACK(src, PROC_REF(do_eattile), T), 2 SECONDS)

/mob/living/simple_animal/bot/floorbot/proc/do_eattile(obj/item/stack/tile/plasteel/T)
	if(isnull(T))
		target = null
		mode = BOT_IDLE
		return
	if(amount + T.amount > 50)
		var/i = 50 - amount
		amount += i
		T.amount -= i
	else
		amount += T.amount
		qdel(T)
	target = null
	mode = BOT_IDLE
	update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/bot/floorbot/proc/start_maketile(obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	visible_message("<span class='notice'>[src] begins to create tiles.</span>")
	mode = BOT_REPAIRING
	addtimer(CALLBACK(src, PROC_REF(do_maketile), M), 2 SECONDS)

/mob/living/simple_animal/bot/floorbot/proc/do_maketile(obj/item/stack/sheet/metal/M)
	if(isnull(M))
		target = null
		mode = BOT_IDLE
		return
	var/obj/item/stack/tile/plasteel/T = new /obj/item/stack/tile/plasteel
	T.amount = 4
	T.forceMove(M.loc)
	if(M.amount > 1)
		M.amount--
	else
		qdel(M)
	target = null
	mode = BOT_IDLE

/mob/living/simple_animal/bot/floorbot/update_icon_state()
	if(mode == BOT_REPAIRING)
		icon_state = "[toolbox_color]floorbot-c"
		return
	if(amount > 0)
		icon_state = "[toolbox_color]floorbot[on]"
	else
		icon_state = "[toolbox_color]floorbot[on]e"

/mob/living/simple_animal/bot/floorbot/explode()
	on = FALSE
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	var/obj/item/storage/toolbox/mechanical/N = new /obj/item/storage/toolbox/mechanical(Tsec)
	N.contents = list()
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)

	while(amount)//Dumps the tiles into the appropriate sized stacks
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
		start_eattile(A)
	else if(istype(A,/obj/item/stack/sheet/metal))
		start_maketile(A)
	else
		..()
