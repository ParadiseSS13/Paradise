/*Contains:
	Rapid Pipe Dispenser
*/

#define SIMPLE_CAP				20
#define SUPPLY_CAP				32
#define SCRUBBERS_CAP			33
#define HE_EXCHANGER			17
#define CONNECTOR				4
#define UNARY_VENT				7
#define PASSIVE_VENT			37
#define GAS_SCRUBBER			10
#define INJECTOR				34
#define GAS_SENSOR				98
#define METER					99
#define DISPOSALS_JUNCTION		2
#define ATMOS_MODE				1
#define DISPOSALS_MODE			2
#define ROTATION_MODE			3
#define FLIP_MODE				4
#define DELETE_MODE				5
#define ATMOS_PIPING			1
#define SUPPLY_PIPING			2
#define SCRUBBERS_PIPING		3
#define DEVICES					4
#define HEAT_PIPING				5

/obj/item/weapon/rpd
	name = "rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	opacity = 0
	density = 0
	anchored = 0
	flags = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 30000, MAT_GLASS = 5000)
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/system/spark_spread/spark_system
	var/lastused
	var/iconrotation = 0 //used to orient icons and pipes
	var/mode = 1 //Disposals, atmospherics, etc.
	var/pipetype = 1//For nanoUI menus
	var/whatpipe = 0 //What kind of pipe is it? See code/game/machinery/pipe/construction.dm for a list of defines
	var/whatdpipe = 0 //What kind of disposals pipe is it? See code/game/machinery/pipe/dispenser.dm for a list of defines
	var/spawndelay = 4 //How long should we have to wait between dispensing pipes?
	var/walldelay = 40 //How long should drilling into a wall take?

/obj/item/weapon/rpd/New()
	..()
	spark_system = new /datum/effect/system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

//Procs

/obj/item/weapon/rpd/proc/Activaterpd(delay)
	playsound(loc, "sound/machines/click.ogg", 50, 1)
	if(prob(15))
		spark_system.start()
	if(delay)
		lastused = world.time

/obj/item/weapon/rpd/proc/Manipulatepipes(subject, atmosverb, disposalsverb)
	if(istype(subject, /obj/item/pipe))
		call(subject, atmosverb)()
	else if(istype(subject, /obj/structure/disposalconstruct/))
		call(subject, disposalsverb)()

//Lists of things

var/list/pipelist = list( //id refers to the pipe_type found in construction.dm, icon refers to the name of the icon state in icons/obj/pipe-item.dmi. Icons are made with the asset-cache
	list("pipename" = "Straight pipe", "id" = 0, "category" = ATMOS_PIPING, "orientations" = 2, "icon" = "simple"),
	list("pipename" = "Bent pipe", "id" = 1, "category" = ATMOS_PIPING, "orientations" = 4, "icon" = "simple", "bendy" = 1),
	list("pipename" = "T-manifold", "id" = 5, "category" = ATMOS_PIPING, "orientations" = 4, "icon" = "manifold"),
	list("pipename" = "4-way manifold", "id" = 19, "category" = ATMOS_PIPING, "orientations" = 1, "icon" = "manifold4w"),
	list("pipename" = "Pipe cap", "id" = 20, "category" = ATMOS_PIPING, "orientations" = 4, "icon" = "cap"),
	list("pipename" = "Manual valve", "id" = 8, "category" = ATMOS_PIPING, "orientations" = 2, "icon" = "mvalve"),
	list("pipename" = "Digital valve", "id" = 35, "category" = ATMOS_PIPING, "orientations" = 2, "icon" = "dvalve"),
	list("pipename" = "Manual T-valve", "id" = 18, "category" = ATMOS_PIPING, "orientations" = 4, "icon" = "tvalve"),
	list("pipename" = "Digital T-valve", "id" = 38, "category" = ATMOS_PIPING, "orientations" = 4, "icon" = "dtvalve"),
	list("pipename" = "Straight supply pipe", "id" = 24, "category" = SUPPLY_PIPING, "orientations" = 2, "icon" = "simple"),
	list("pipename" = "Bent supply pipe", "id" = 25, "category" = SUPPLY_PIPING, "orientations" = 4, "icon" = "simple", "bendy" = 1),
	list("pipename" = "Supply T-manifold", "id" = 28, "category" = SUPPLY_PIPING, "orientations" = 4, "icon" = "manifold"),
	list("pipename" = "4-way supply manifold", "id" = 30, "category" = SUPPLY_PIPING, "orientations" = 1, "icon" = "manifold4w"),
	list("pipename" = "Supply pipe cap", "id" = 32, "category" = SUPPLY_PIPING, "orientations" = 4, "icon" = "cap"),
	list("pipename" = "Straight scrubbers pipe", "id" = 26, "category" = SCRUBBERS_PIPING, "orientations" = 2, "icon" = "simple"),
	list("pipename" = "Bent scrubbers pipe", "id" = 27, "category" = SCRUBBERS_PIPING, "orientations" = 4, "icon" = "simple", "bendy" = 1),
	list("pipename" = "Scrubbers T-manifold", "id" = 29, "category" = SCRUBBERS_PIPING, "orientations" = 4, "icon" = "manifold"),
	list("pipename" = "4-way scrubbers manifold", "id" = 31, "category" = SCRUBBERS_PIPING, "orientations" = 1, "icon" = "manifold4w"),
	list("pipename" = "Scrubbers pipe cap", "id" = 33, "category" = SCRUBBERS_PIPING, "orientations" = 4, "icon" = "cap"),
	list("pipename" = "Universal pipe adapter", "id" = 23, "category" = DEVICES, "orientations" = 2, "icon" = "universal"),
	list("pipename" = "Connector", "id" = 4, "category" = DEVICES, "orientations" = 4, "icon" = "connector"),
	list("pipename" = "Unary vent", "id" = 7, "category" = DEVICES, "orientations" = 4, "icon" = "uvent"),
	list("pipename" = "Scrubber", "id" = 10, "category" = DEVICES, "orientations" = 4, "icon" = "scrubber"),
	list("pipename" = "Gas pump", "id" = 9, "category" = DEVICES, "orientations" = 4, "icon" = "pump"),
	list("pipename" = "Volume pump", "id" = 16, "category" = DEVICES, "orientations" = 4, "icon" = "volumepump"),
	list("pipename" = "Passive gate", "id" = 15, "category" = DEVICES, "orientations" = 4, "icon" = "passivegate"),
	list("pipename" = "Gas filter", "id" = 13, "category" = DEVICES, "orientations" = 4, "icon" = "filter"),
	list("pipename" = "Gas mixer", "id" = 14, "category" = DEVICES, "orientations" = 4, "icon" = "mixer"),
	list("pipename" = "Gas sensor", "id" = 98, "category" = DEVICES, "orientations" = 1, "icon" = "sensor"),
	list("pipename" = "Meter", "id" = 99, "category" = DEVICES, "orientations" = 1, "icon" = "meter"),
	list("pipename" = "Passive vent", "id" = 37, "category" = DEVICES, "orientations" = 4, "icon" = "passive vent"),
	list("pipename" = "Dual-port vent pump", "id" = 36, "category" = DEVICES, "orientations" = 2, "icon" = "dual-port vent"),
	list("pipename" = "Air injector", "id" = 34, "category" = DEVICES, "orientations" = 4, "icon" = "injector"),
	list("pipename" = "Straight HE pipe", "id" = 2, "category" = HEAT_PIPING, "orientations" = 2, "icon" = "he"),
	list("pipename" = "Bent HE pipe", "id" = 3, "category" = HEAT_PIPING, "orientations" = 4, "icon" = "he", "bendy" = 1),
	list("pipename" = "Junction", "id" = 6, "category" = HEAT_PIPING, "orientations" = 4, "icon" = "junction"),
	list("pipename" = "Heat exchanger", "id" = 17, "category" = HEAT_PIPING, "orientations" = 4, "icon" = "heunary"))
var/list/dpipelist = list(
	list("pipename" = "Straight pipe", "id" = 0, "orientations" = 2, "icon" = "conpipe-s"),
	list("pipename" = "Bent pipe", "id" = 1, "orientations" = 4, "icon" = "conpipe-c"),
	list("pipename" = "Junction", "id" = 2, "orientations" = 4, "icon" = "conpipe-j1"),
	list("pipename" = "Y-junction", "id" = 4, "orientations" = 4, "icon" = "conpipe-y"),
	list("pipename" = "Trunk", "id" = 5, "orientations" = 4, "icon" = "conpipe-t"),
	list("pipename" = "Bin", "id" = 6, "orientations" = 1, "icon" = "condisposal"),
	list("pipename" = "Outlet", "id" = 7, "orientations" = 4, "icon" = "outlet"),
	list("pipename" = "Chute", "id" = 8, "orientations" = 4, "icon" = "intake"))
var/list/mainmenu = list(
	list("category" = "Atmospherics", "mode" = 1, "icon" = "wrench"),
	list("category" = "Disposals", "mode" = 2, "icon" = "recycle"),
	list("category" = "Rotate", "mode" = 3, "icon" = "rotate-right"),
	list("category" = "Flip", "mode" = 4, "icon" = "exchange"),
	list("category" = "Recycle", "mode" = 5, "icon" = "trash"))
var/list/pipemenu = list(
	list("pipecategory" = "Normal", "pipemode" = 1),
	list("pipecategory" = "Supply", "pipemode" = 2),
	list("pipecategory" = "Scrubber", "pipemode" = 3),
	list("pipecategory" = "Devices", "pipemode" = 4),
	list("pipecategory" = "Heat exchange", "pipemode" = 5))

//NanoUI stuff

/obj/item/weapon/rpd/attack_self(mob/user)
	ui_interact(user)

/obj/item/weapon/rpd/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = inventory_state)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rpd.tmpl", "[name]", 400, 650, state = state)
		ui.open()
		ui.set_auto_update(1)

/obj/item/weapon/rpd/ui_data(mob/user, ui_key = "main", datum/topic_state/state = inventory_state)
	var/data[0]
	data["dpipelist"] = dpipelist
	data["iconrotation"] = iconrotation
	data["mainmenu"] = mainmenu
	data["mode"] = mode
	data["pipelist"] = pipelist
	data["pipemenu"] = pipemenu
	data["pipetype"] = pipetype
	data["whatdpipe"] = whatdpipe
	data["whatpipe"] = whatpipe
	return data

/obj/item/weapon/rpd/Topic(href, href_list, nowindow, state)
	..()
	if(href_list["iconrotation"])
		iconrotation = text2num(sanitize(href_list["iconrotation"]))
	else if(href_list["whatpipe"])
		whatpipe = text2num(sanitize(href_list["whatpipe"]))
	else if(href_list["whatdpipe"])
		whatdpipe = text2num(sanitize(href_list["whatdpipe"]))
	else if(href_list["pipetype"])
		pipetype = text2num(sanitize(href_list["pipetype"]))
	else if(href_list["mode"])
		mode = text2num(sanitize(href_list["mode"]))
	else
		return
	nanomanager.update_uis(src)

//What the RPD actually does

/obj/item/weapon/rpd/afterattack(atom/target, mob/user, proximity)
	..()
	var/turf/T = get_turf(target)
	if(src.loc != user || ismob(target) || istype(target, /obj/structure/window) || !proximity || world.time < lastused + spawndelay)
		return
	if(mode == ATMOS_MODE && !istype(T, /turf/simulated/shuttle)) //No pipes on shuttles nerds
		if(istype(T, /turf/simulated/wall)) //Drilling into walls takes time
			playsound(loc, "sound/weapons/circsawhit.ogg", 50, 1)
			user.visible_message("<span class = 'notice'>[user] starts drilling a hole in [T]...</span>", "<span class = 'notice'>You start drilling a hole in [T]...</span>", "<span class = 'warning'>You hear a drill.</span>")
			if(!do_after(user, walldelay, target = T))
				return
			user.visible_message("<span class = 'notice'>[user] finishes drilling a hole in [T]!</span>", "<span class = 'notice'>You finish drilling a hole in [T]!</span>", "<span class = 'warning'>You hear clanking.</span>")
		var/obj/item/pipe/P
		if(whatpipe == GAS_SENSOR)
			P = new /obj/item/pipe_gsensor(T)
		else if(whatpipe == METER)
			P = new /obj/item/pipe_meter(T)
		else
			P = new(T, pipe_type = whatpipe, dir = user.dir)
			if(iconrotation == 0 && P.is_bent_pipe()) //Automatic rotation of dispensed pipes
				P.dir = turn(user.dir, 135)
			else if(iconrotation == 0 && P.pipe_type in list(CONNECTOR, UNARY_VENT, GAS_SCRUBBER, HE_EXCHANGER, SIMPLE_CAP, SUPPLY_CAP, SCRUBBERS_CAP, INJECTOR, PASSIVE_VENT)) //Some pipes dispense oppositely to what you'd expect, but we don't want to do anything if they selected a direction
				P.flip()
			else if(iconrotation != 0 && P.is_bent_pipe()) //If they selected a rotation and the pipe is bent
				P.dir = turn(iconrotation, -45)
			else if(iconrotation != 0)
				P.dir = iconrotation
		to_chat(user, "<span class = 'notice'>[src] rapidly dispenses [P]!</span>")
		Activaterpd(1)
	else if(mode == DISPOSALS_MODE && !istype(T, /turf/simulated/shuttle))
		if(istype(T, /turf/simulated/wall)) //No disposals pipes on walls
			to_chat(user, "<span class = 'warning'>That type of pipe won't fit on [T]!</span>")
			return
		var/obj/structure/disposalconstruct/P = new(T) //Now we make the pipe
		P.dir = iconrotation
		P.ptype = whatdpipe
		if(iconrotation == 0) //Automatic rotation
			P.dir = user.dir
		if(iconrotation == 0 && whatdpipe != DISPOSALS_JUNCTION) //Disposals pipes are in the opposite direction to atmos pipes, so we need to flip them. Junctions don't have this quirk though
			P.flip()
		P.update()
		to_chat(user, "<span class = 'notice'>[src] rapidly dispenses [P]!</span>")
		Activaterpd(1)
	else if(mode == ROTATION_MODE)
		for(var/obj/W in T)
			Manipulatepipes(W, /obj/item/pipe/verb/rotate, /obj/structure/disposalconstruct/verb/rotate)
	else if(mode == FLIP_MODE)
		for(var/obj/W in T)
			Manipulatepipes(W, /obj/item/pipe/verb/flip, /obj/structure/disposalconstruct/verb/flip)
	else if(mode == DELETE_MODE)
		var/eaten
		for(var/obj/W in T)
			if(istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter) || istype(W, /obj/item/pipe_gsensor) || istype(W, /obj/structure/disposalconstruct) && !W.anchored)
				QDEL_NULL(W)
				eaten = TRUE
		if(eaten)
			to_chat(user, "<span class='notice'>[src] sucks up the loose pipes on [T].")
			Activaterpd()
		else
			to_chat(user, "<span class='notice'>There were no loose pipes on [T].</span>")

#undef SIMPLE_CAP
#undef SUPPLY_CAP
#undef SCRUBBERS_CAP
#undef HE_EXCHANGER
#undef CONNECTOR
#undef UNARY_VENT
#undef PASSIVE_VENT
#undef GAS_SCRUBBER
#undef INJECTOR
#undef GAS_SENSOR
#undef METER
#undef DISPOSALS_JUNCTION
#undef ATMOS_MODE
#undef DISPOSALS_MODE
#undef ROTATION_MODE
#undef FLIP_MODE
#undef DELETE_MODE
#undef ATMOS_PIPING
#undef SUPPLY_PIPING
#undef SCRUBBERS_PIPING
#undef DEVICES
#undef HEAT_PIPING
