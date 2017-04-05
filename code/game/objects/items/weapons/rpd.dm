/*Contains:
	Rapid Pipe Dispenser
*/

/obj/item/weapon/rpd
	name = "rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to."
	icon = 'icons/obj/tools.dmi' //Apparently we can't use double quotes here
	icon_state = "rpd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 5
	w_class = 3
	materials = list(MAT_METAL = 30000, MAT_GLASS = 5000)
	origin_tech = "engineering=4;materials=2"
	var/iconrotation = 0 //used to orient icons and pipes
	var/initialised = 0 //This stops us unnecessarily checking the cache for icons
	var/mode = 1 //Disposals, atmospherics
	var/pipemenu = 1 //For nanoUI menus
	var/pipetype = 1//For nanoUI menus
	var/whatpipe = 0 //What kind of pipe is it? See code/game/machinery/pipe/construction.dm for a list of defines
	var/whatdpipe = 0 //What kind of disposals pipe is it? See code/game/machinery/pipe/pipe_dispenser.dm for a list of defines
	var/cooldown = 0 //Waiting for something to complete?
	var/spawndelay = 4 //Adding a *slight* delay to the RPD, shouldn't be very noticeable
	var/walldelay = 40 //How long should drilling into a wall take?
	var/datum/effect/system/spark_spread/spark_system

/obj/item/weapon/rpd/New()
	spark_system = new /datum/effect/system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

//List of things follow here

//Pipename, pipe type (see construction.dm), pipe category, number of orientations this pipe has, name of pipe in the icon file, is this pipe bendy?
var/list/pipelist = list(
	list("key1" = "Straight pipe", "key2" = "0", "key3" = "1", "key4" = "2", "key5" = "simple", "key6" = "0"),
	list("key1" = "Bent pipe", "key2" = "1", "key3" = "1", "key4" = "4", "key5" = "simple", "key6" = "1"),
	list("key1" = "T-manifold", "key2" = "5", "key3" = "1", "key4" = "4", "key5" = "manifold", "key6" = "0"),
	list("key1" = "4-way manifold", "key2" = "19", "key3" = "1", "key4" = "1", "key5" = "manifold4w", "key6" = "0"),
	list("key1" = "Pipe cap", "key2" = "20", "key3" = "1", "key4" = "4", "key5" = "cap", "key6" = "0"),
	list("key1" = "Manual valve", "key2" = "8", "key3" = "1", "key4" = "2", "key5" = "mvalve", "key6" = "0"),
	list("key1" = "Digital valve", "key2" = "35", "key3" = "1", "key4" = "2", "key5" = "dvalve", "key6" = "0"),
	list("key1" = "Manual T-valve", "key2" = "18", "key3" = "1", "key4" = "4", "key5" = "tvalve", "key6" = "0"),
	list("key1" = "Digital T-valve", "key2" = "38", "key3" = "1", "key4" = "4", "key5" = "dtvalve", "key6" = "0"),
	list("key1" = "Straight supply pipe", "key2" = "24", "key3" = "2", "key4" = "2", "key5" = "simple", "key6" = "0"),
	list("key1" = "Bent supply pipe", "key2" = "25", "key3" = "2", "key4" = "4", "key5" = "simple", "key6" = "1"),
	list("key1" = "Supply T-manifold", "key2" = "28", "key3" = "2", "key4" = "4", "key5" = "manifold", "key6" = "0"),
	list("key1" = "4-way supply manifold", "key2" = "30", "key3" = "2", "key4" = "1", "key5" = "manifold4w", "key6" = "0"),
	list("key1" = "Supply pipe cap", "key2" = "32", "key3" = "2", "key4" = "4", "key5" = "cap", "key6" = "0"),
	list("key1" = "Straight scrubbers pipe", "key2" = "26", "key3" = "3", "key4" = "2", "key5" = "simple", "key6" = "0"),
	list("key1" = "Bent scrubbers pipe", "key2" = "27", "key3" = "3", "key4" = "4", "key5" = "simple", "key6" = "1"),
	list("key1" = "Scrubbers T-manifold", "key2" = "29", "key3" = "3", "key4" = "4", "key5" = "manifold", "key6" = "0"),
	list("key1" = "4-way scrubbers manifold", "key2" = "31", "key3" = "3", "key4" = "1", "key5" = "manifold4w", "key6" = "0"),
	list("key1" = "Scrubbers pipe cap", "key2" = "33", "key3" = "3", "key4" = "4", "key5" = "cap", "key6" = "0"),
	list("key1" = "Universal pipe adapter", "key2" = "23", "key3" = "4", "key4" = "2", "key5" = "universal", "key6" = "0"),
	list("key1" = "Unary vent", "key2" = "7", "key3" = "4", "key4" = "4", "key5" = "uvent", "key6" = "0"),
	list("key1" = "Scrubber", "key2" = "10", "key3" = "4", "key4" = "4", "key5" = "scrubber", "key6" = "0"),
	list("key1" = "Air injector", "key2" = "34", "key3" = "4", "key4" = "4", "key5" = "injector", "key6" = "0"),
	list("key1" = "Gas pump", "key2" = "9", "key3" = "4", "key4" = "4", "key5" = "pump", "key6" = "0"),
	list("key1" = "Volume pump", "key2" = "16", "key3" = "4", "key4" = "4", "key5" = "volumepump", "key6" = "0"),
	list("key1" = "Passive gate", "key2" = "15", "key3" = "4", "key4" = "4", "key5" = "passivegate", "key6" = "0"),
	list("key1" = "Connector", "key2" = "4", "key3" = "4", "key4" = "4", "key5" = "connector", "key6" = "0"),
	list("key1" = "Gas sensor", "key2" = "98", "key3" = "4", "key4" = "1", "key5" = "sensor", "key6" = "0"),
	list("key1" = "Meter", "key2" = "99", "key3" = "4", "key4" = "1", "key5" = "meter", "key6" = "0"),
	list("key1" = "Gas filter", "key2" = "13", "key3" = "4", "key4" = "4", "key5" = "filter", "key6" = "0"),
	list("key1" = "Gas mixer", "key2" = "14", "key3" = "4", "key4" = "4", "key5" = "mixer", "key6" = "0"),
	list("key1" = "Dual-port vent pump", "key2" = "36", "key3" = "4", "key4" = "2", "key5" = "dual-port vent", "key6" = "0"),
	list("key1" = "Passive vent", "key2" = "37", "key3" = "4", "key4" = "4", "key5" = "passive vent", "key6" = "0"),
	list("key1" = "Straight HE pipe", "key2" = "2", "key3" = "5", "key4" = "2", "key5" = "he", "key6" = "0"),
	list("key1" = "Bent HE pipe", "key2" = "3", "key3" = "5", "key4" = "4", "key5" = "he", "key6" = "1"),
	list("key1" = "Junction", "key2" = "6", "key3" = "5", "key4" = "4", "key5" = "junction", "key6" = "0"),
	list("key1" = "Heat exchanger", "key2" = "17", "key3" = "5", "key4" = "4", "key5" = "heunary", "key6" = "0"))

//Pipename, pipe type, no. of unique orientations, name of pipe icon
var/list/dpipelist = list(
	list("key1" = "Straight pipe", "key2" = "0", "key3" = "2", "key4" = "conpipe-s"),
	list("key1" = "Bent pipe", "key2" = "1", "key3" = "4", "key4" = "conpipe-c"),
	list("key1" = "Junction", "key2" = "2", "key3" = "4", "key4" = "conpipe-j1"),
	list("key1" = "Y-junction", "key2" = "4", "key3" = "4", "key4" = "conpipe-y"),
	list("key1" = "Trunk", "key2" = "5", "key3" = "4", "key4" = "conpipe-t"),
	list("key1" = "Bin", "key2" = "6", "key3" = "1", "key4" = "condisposal"),
	list("key1" = "Outlet", "key2" = "7", "key3" = "4", "key4" = "outlet"),
	list("key1" = "Chute", "key2" = "8", "key3" = "4", "key4" = "intake"))

//Procs

/obj/item/weapon/rpd/proc/Activaterpd(soundfile, delay)
	playsound(loc, soundfile, 50, 1)
	if(prob(15))
		spark_system.start()
	if(delay == 1)
		cooldown = 1
		spawn(spawndelay)
		cooldown = 0
	return

/obj/item/weapon/rpd/proc/Checkifbent(x)
	if(x in list(1,3,25,27))
		return 1
	else
		return 0

//This proc puts each necessary icon into the initial user's cache for later use. It then sets initialised = 1 to avoid calling itself unnecessarily.
/obj/item/weapon/rpd/proc/Initialiseicons()
	if(initialised == 1)
		return
	var/F
	var/I
	var/disposalsfile = "icons/obj/pipes/disposal.dmi"
	var/pipefile = "icons/obj/pipe-item.dmi"
	var/list/filenames
	for(I in pipelist)
		if(I["key6"] == "1")//Bendy pipe icons
			filenames = list(
			list(I["key5"] + "-southeast.png", SOUTHEAST),
			list(I["key5"] + "-southwest.png", SOUTHWEST),
			list(I["key5"] + "-northwest.png", NORTHWEST),
			list(I["key5"] + "-northeast.png", NORTHEAST))
		else if(I["key4"] == "2") //Dual state icons
			filenames = list(
			list(I["key5"] + "-north.png", NORTH),
			list(I["key5"] + "-east.png", EAST))
		else if(I["key4"] == "4")//All other pipes that need icons
			filenames = list(
			list(I["key5"] + "-north.png", NORTH),
			list(I["key5"] + "-east.png", EAST),
			list(I["key5"] + "-south.png", SOUTH),
			list(I["key5"] + "-west.png", WEST))
		else
			filenames = .
		for(F in filenames)
			var/icon/iconfile = icon(pipefile, icon_state = I["key5"], dir = F[2])
			usr << browse_rsc(iconfile, F[1])
	for(I in dpipelist) //All disposals pipes have four states so we don't need to bother checking direction
		filenames = list(
		list(I["key4"] + "-north.png", NORTH),
		list(I["key4"] + "-east.png", EAST),
		list(I["key4"] + "-south.png", SOUTH),
		list(I["key4"] + "-west.png", WEST))
		for(F in filenames)
			var/icon/iconfile = icon(disposalsfile, icon_state = I["key4"], dir = F[2])
			usr << browse_rsc(iconfile, F[1])
	initialised = 1
	return

/obj/item/weapon/rpd/proc/Manipulatepipes(subject, targetturf, atmosverb, disposalsverb)
	if(istype(subject, /obj/item/pipe))
		call(subject, atmosverb)()
	else if(istype(subject, /obj/structure/disposalconstruct/))
		call(subject, disposalsverb)()
	else
		return

//NanoUI stuff

/obj/item/weapon/rpd/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/weapon/rpd/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = inventory_state)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rpd.tmpl", "[name]", 600, 650, state = state)
		ui.open()
		Initialiseicons()
		ui.set_auto_update(1)

/obj/item/weapon/rpd/ui_data(mob/user, ui_key = "main", datum/topic_state/state = inventory_state)
	var/data[0]
	data["dpipelist"] = dpipelist
	data["iconrotation"] = iconrotation
	data["mode"] = mode
	data["pipelist"] = pipelist
	data["pipemenu"] = pipemenu
	data["pipetype"] = pipetype
	data["whatdpipe"] = whatdpipe
	data["whatpipe"] = whatpipe
	data["mainmenu"] = list(
	list("key1" = "Atmospherics piping", "key2" = "1", "key3" = "wrench"),
	list("key1" = "Disposals piping", "key2" = "2", "key3" = "recycle"),
	list("key1" = "Rotate mode", "key2" = "3", "key3" = "rotate-right"),
	list("key1" = "Flip mode", "key2" = "4", "key3" = "exchange"),
	list("key1" = "Recycle mode", "key2" = "5", "key3" = "trash"))
	data["mainmenu"] = list(
	list("key1" = "Atmospherics piping", "key2" = "1", "key3" = "wrench"),
	list("key1" = "Disposals piping", "key2" = "2", "key3" = "recycle"),
	list("key1" = "Rotate mode", "key2" = "3", "key3" = "rotate-right"),
	list("key1" = "Flip mode", "key2" = "4", "key3" = "exchange"),
	list("key1" = "Recycle mode", "key2" = "5", "key3" = "trash"))
	data["pipemenu"] = list(
	list("key1" = "Normal pipes", "key2" = "1"),
	list("key1" = "Supply pipes", "key2" = "2"),
	list("key1" = "Scrubber pipes", "key2" = "3"),
	list("key1" = "Devices", "key2" = "4"),
	list("key1" = "HE pipes", "key2" = "5"))
	return data

/obj/item/weapon/rpd/Topic(href, href_list, nowindow, state)
	if(href_list["iconrotation"])
		iconrotation = text2num(href_list["iconrotation"])
	else if(href_list["whatpipe"])
		whatpipe = text2num(href_list["whatpipe"])
	else if(href_list["whatdpipe"])
		whatdpipe = text2num(href_list["whatdpipe"])
	else if(href_list["pipetype"])
		pipetype = text2num(href_list["pipetype"])
	else if(href_list["mode"])
		mode = text2num(href_list["mode"])
	else if(href_list["refresh"])
		to_chat(usr, "<span class='notice'>You press the reset button, refreshing all settings on the [src].</span>")
		iconrotation = 0
		initialised = 0
		mode = 1
		pipemenu = 1
		pipetype = 1
		whatpipe = 0
		whatdpipe = 0
		cooldown = 0
		Initialiseicons()
	else
		return
	nanomanager.update_uis(src)
	return

//What the RPD actually does

/obj/item/weapon/rpd/afterattack(atom/target, mob/user as mob, proximity)
	var/turf/T = get_turf(target)
	if(!proximity)
		return
	else if(cooldown == 1)
		return
	else if(!isturf(target) && !istype(target, /obj/item/pipe) && !istype(target, /obj/item/pipe_meter) && !istype(target, /obj/item/pipe_gsensor) && !istype(target, /obj/structure/disposalconstruct))
		return
	else if(istype(target, /turf/simulated/shuttle))
		return
	else if(mode == 1) //Atmos mode
		if(istype(T, /turf/simulated/wall)) //Drilling into walls takes time and we don't want to do anything else while drilling
			cooldown = 1
			playsound(get_turf(src), "sound/weapons/circsawhit.ogg", 50, 1)
			usr.visible_message("<span class='notice'>[usr] starts drilling a hole in [T]...</span>", "<span class='notice'>You start drilling a hole in [T]...</span>", "<span class='warning'>You hear a drill.</span>")
			if(do_after(usr, walldelay, target = T))
				usr.visible_message("<span class='notice'>[usr] finishes drilling a hole in [T]!</span>", "<span class = 'notice'>You finish drilling a hole in [T]!</span>", "<span class='warning'>You hear clanking.</span>")
			else
				cooldown = 0
				return
		if(whatpipe == 98)//need to check if it's a meter or a gas sensor separately ayylmao
			new /obj/item/pipe_gsensor(T)
			to_chat(usr, "<span class='notice'>[src] dispenses a sensor!</span>")
			Activaterpd("sound/machines/click.ogg", 1)
			return
		if(whatpipe == 99)
			new /obj/item/pipe_meter(T)
			to_chat(usr, "<span class='notice'>[src] dispenses a meter!</span>")
			Activaterpd("sound/machines/click.ogg", 1)
			return
		var/obj/item/pipe/P = new(T, pipe_type=whatpipe, dir = usr.dir) //Now we make the pipes
		if(iconrotation == 0 && Checkifbent(P.pipe_type) == 1) //Automatic rotation of dispensed pipes
			P.dir = turn(usr.dir, 135)
		else if(iconrotation == 0 && P.pipe_type in list(4, 7, 10, 17, 20, 32, 33, 34, 37)) //Some pipes dispense oppositely to what you'd expect, but we don't want to do anything if they selected a direction
			call(P, /obj/item/pipe/verb/flip)()
		else if(iconrotation != 0 && Checkifbent(P.pipe_type) == 1) //If they selected a rotation and the pipe is bent
			P.dir = turn(iconrotation, -45)
		else if(iconrotation != 0)
			P.dir = iconrotation
		P.update()
		to_chat(usr, "<span class='notice'>[src] rapidly dispenses [P]!</span>")
		Activaterpd("sound/machines/click.ogg", 1)
	else if(mode == 2) //Disposals mode
		if(istype(T, /turf/simulated/wall))
			to_chat(usr, "<span class='warning'>That type of pipe won't fit on [T]!</span>")
			return
		if(is_blocked_turf(T) == 1 && whatdpipe in list(6, 7, 8))//We need to check if the targetted turf is already dense, in case some goofball sticks 100 bins in front of security or something
			to_chat(usr, "<span class='warning'>You can't dispense that on [T] because something is in the way!</span>")
			return
		var/obj/structure/disposalconstruct/P = new(T) //Now we make the pipe
		P.dir = iconrotation
		P.ptype = whatdpipe
		if(whatdpipe in list(6, 7, 8)) //To properly set density of our bins/chutes/outlets
			P.density = 1
		if(iconrotation == 0) //Automatic rotation
			P.dir = usr.dir
		if(iconrotation == 0 && whatdpipe != 2) //Disposals pipes are in the opposite direction to atmos pipes, so we need to flip them. Junctions don't have this quirk though
			call(P, /obj/structure/disposalconstruct/verb/flip)()
		P.update()
		to_chat(usr, "<span class='notice'>[src] rapidly dispenses [P]!</span>")
		Activaterpd("sound/machines/click.ogg", 1)
		return
	else if(mode == 3) //Rotate mode
		for(var/obj/W in T)
			Manipulatepipes(W, T, /obj/item/pipe/verb/rotate, /obj/structure/disposalconstruct/verb/rotate)
		return
	else if(mode == 4) //Flip mode
		for(var/obj/W in T)
			Manipulatepipes(W, T, /obj/item/pipe/verb/flip, /obj/structure/disposalconstruct/verb/flip)
		return
	else if(mode == 5) //Delete mode
		var/eaten
		for(var/obj/W in T)
			if(istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter) || istype(W, /obj/item/pipe_gsensor) || istype(W, /obj/structure/disposalconstruct) && W.anchored == 0)
				qdel(W)
				eaten = 1
		if(eaten == 1)
			to_chat(usr, "<span class='notice'>[src] sucks up the loose pipes on [T]!</span>")
			Activaterpd("sound/items/Deconstruct.ogg", 1)
		else
			to_chat(usr, "<span class='notice'>There were no loose pipes on [T].</span>")
		return
	else //Finished.
		return
