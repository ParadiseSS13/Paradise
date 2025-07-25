GLOBAL_LIST_EMPTY(monkey_recyclers)

/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1
	var/cycle_through = 0
	var/obj/item/food/monkeycube/cube_type = /obj/item/food/monkeycube
	var/list/connected = list()

/obj/machinery/monkey_recycler/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	GLOB.monkey_recyclers += src
	RefreshParts()
	locate_camera_console()

/obj/machinery/monkey_recycler/Destroy()
	GLOB.monkey_recyclers -= src
	for(var/thing in connected)
		var/obj/machinery/computer/camera_advanced/xenobio/console = thing
		console.connected_recycler = null
	connected.Cut()
	return ..()

/obj/machinery/monkey_recycler/proc/locate_camera_console()
	if(length(connected))
		return // we're already connected!
	for(var/obj/machinery/computer/camera_advanced/xenobio/xeno_camera in SSmachines.get_by_type(/obj/machinery/computer/camera_advanced/xenobio))
		if(get_area(xeno_camera) == get_area(loc))
			xeno_camera.connected_recycler = src
			connected |= xeno_camera
			break

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind

/obj/machinery/monkey_recycler/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(default_unfasten_wrench(user, used, time = 4 SECONDS))
		power_change()
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/multitool))
		if(!panel_open)
			cycle_through++
			switch(cycle_through)
				if(1)
					cube_type = /obj/item/food/monkeycube/nian_wormecube
				if(2)
					cube_type = /obj/item/food/monkeycube/farwacube
				if(3)
					cube_type = /obj/item/food/monkeycube/wolpincube
				if(4)
					cube_type = /obj/item/food/monkeycube/stokcube
				if(5)
					cube_type = /obj/item/food/monkeycube/neaeracube
				if(6)
					cube_type = /obj/item/food/monkeycube
					cycle_through = 0
			to_chat(user, "<span class='notice'>You change the monkeycube type to [initial(cube_type.name)].</span>")
		else
			var/obj/item/multitool/M = used
			M.buffer = src
			to_chat(user, "<span class='notice'>You log [src] in [M]'s buffer.</span>")
		return ITEM_INTERACT_COMPLETE
	if(stat != 0) //NOPOWER etc
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		var/grabbed = G.affecting
		if(ishuman(grabbed))
			var/mob/living/carbon/human/target = grabbed
			if(issmall(target))
				if(target.stat == CONSCIOUS)
					to_chat(user, "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>")
				else
					user.drop_item()
					qdel(target)
					target = null //we sleep in this proc, clear reference NOW
					to_chat(user, "<span class='notice'>You stuff the monkey in the machine.</span>")
					playsound(loc, 'sound/machines/juicer.ogg', 50, 1)
					var/offset = prob(50) ? -2 : 2
					animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
					use_power(500)
					grinded++
					to_chat(user, "<span class='notice'>The machine now has [grinded] monkey\s worth of material stored.</span>")
					addtimer(VARSET_CALLBACK(src, pixel_x, initial(pixel_x)), 5 SECONDS)
			else
				to_chat(user, "<span class='warning'>The machine only accepts monkeys!</span>")
		else
			to_chat(user, "<span class='warning'>The machine only accepts monkeys!</span>")
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/monkey_recycler/attack_hand(mob/user)
	if(stat != 0) //NOPOWER etc
		return
	if(grinded >= required_grind)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>")
		playsound(loc, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++) // Forgot to fix this bit the first time through
			new cube_type(loc)
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded] monkey\s worth of material left.</span>")
	else // I'm not sure if the \s macro works with a word in between; I'll play it safe
		to_chat(user, "<span class='warning'>The machine needs at least [required_grind] monkey\s worth of material to compress [cube_production] monkey\s. It only has [grinded].</span>")
	return
