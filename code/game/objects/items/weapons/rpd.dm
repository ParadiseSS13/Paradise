/*Contains:
	Rapid Pipe Dispenser
*/

#define RPD_COOLDOWN_TIME		4 //How long should we have to wait between dispensing pipes?
#define RPD_WALLBUILD_TIME		40 //How long should drilling into a wall take?

/obj/item/rpd
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
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	origin_tech = "engineering=4;materials=2"
	var/datum/effect_system/spark_spread/spark_system
	var/lastused
	var/iconrotation = 0 //Used to orient icons and pipes
	var/mode = RPD_ATMOS_MODE //Disposals, atmospherics, etc.
	var/pipetype = RPD_ATMOS_PIPING//For nanoUI menus, this is a subtype of pipes e.g. scrubbers pipes, devices
	var/whatpipe = PIPE_SIMPLE_STRAIGHT //What kind of atmos pipe is it?
	var/whatdpipe = PIPE_DISPOSALS_STRAIGHT //What kind of disposals pipe is it?
	var/spawndelay = RPD_COOLDOWN_TIME
	var/walldelay = RPD_WALLBUILD_TIME

/obj/item/rpd/New()
	..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

//Procs

/obj/item/rpd/proc/activate_rpd(delay) //Maybe makes sparks and activates cooldown if there is a delay
	playsound(loc, "sound/machines/click.ogg", 50, 1)
	if(prob(15))
		spark_system.start()
	if(delay)
		lastused = world.time

/obj/item/rpd/proc/create_atmos_pipe(mob/user, turf/T) //Make an atmos pipe, meter, or gas sensor
	var/obj/item/pipe/P
	if(whatpipe == PIPE_GAS_SENSOR)
		P = new /obj/item/pipe_gsensor(T)
	else if(whatpipe == PIPE_METER)
		P = new /obj/item/pipe_meter(T)
	else
		P = new(T, pipe_type = whatpipe, dir = user.dir) //Make the pipe, BUT WAIT! There's more!
		if(!iconrotation && P.is_bent_pipe()) //Automatically rotates dispensed pipes if the user selected auto-rotation
			P.dir = turn(user.dir, 135)
		else if(!iconrotation && P.pipe_type in list(PIPE_CONNECTOR, PIPE_UVENT, PIPE_SCRUBBER, PIPE_HEAT_EXCHANGE, PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP, PIPE_INJECTOR, PIPE_PASV_VENT)) //Some pipes dispense oppositely to what you'd expect, but we don't want to do anything if they selected a direction
			P.flip()
		else if(iconrotation && P.is_bent_pipe()) //If user selected a rotation and the pipe is bent
			P.dir = turn(iconrotation, -45)
		else if(iconrotation) //If user selected a rotation
			P.dir = iconrotation
	to_chat(user, "<span class = 'notice'>[src] rapidly dispenses [P]!</span>")
	activate_rpd(1)

/obj/item/rpd/proc/create_disposals_pipe(mob/user, turf/T) //Make a disposals pipe / construct
	var/obj/structure/disposalconstruct/P = new(T, whatdpipe, iconrotation)
	if(!iconrotation) //Automatic rotation
		P.dir = user.dir
	if(!iconrotation && whatdpipe != PIPE_DISPOSALS_JUNCTION) //Disposals pipes are in the opposite direction to atmos pipes, so we need to flip them. Junctions don't have this quirk though
		P.flip()
	to_chat(user, "<span class = 'notice'>[src] rapidly dispenses [P]!</span>")
	activate_rpd(1)

/obj/item/rpd/proc/rotate_all_pipes(mob/user, turf/T) //Rotate all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.rotate()
	for(var/obj/structure/disposalconstruct/D in T)
		D.rotate()

/obj/item/rpd/proc/flip_all_pipes(mob/user, turf/T) //Flip all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.flip()
	for(var/obj/structure/disposalconstruct/D in T)
		D.flip()

/obj/item/rpd/proc/delete_all_pipes(mob/user, turf/T) //Delete all pipes on a turf
	var/eaten
	for(var/obj/item/pipe/P in T)
		QDEL_NULL(P)
		eaten = TRUE
	for(var/obj/item/pipe_gsensor/G in T)
		QDEL_NULL(G)
		eaten = TRUE
	for(var/obj/item/pipe_meter/M in T)
		QDEL_NULL(M)
		eaten = TRUE
	for(var/obj/structure/disposalconstruct/D in T)
		if(!D.anchored)
			QDEL_NULL(D)
			eaten = TRUE
	if(eaten)
		to_chat(user, "<span class='notice'>[src] sucks up the loose pipes on [T].")
		activate_rpd()
	else
		to_chat(user, "<span class='notice'>There were no loose pipes on [T].</span>")

/obj/item/rpd/proc/delete_single_pipe(mob/user, obj/P) //Delete a single pipe
	to_chat(user, "<span class='notice'>[src] sucks up [P].</span>")
	QDEL_NULL(P)
	activate_rpd()

//Lists of things

var/list/mainmenu = list(
	list("category" = "Atmospherics", "mode" = RPD_ATMOS_MODE, "icon" = "wrench"),
	list("category" = "Disposals", "mode" = RPD_DISPOSALS_MODE, "icon" = "recycle"),
	list("category" = "Rotate", "mode" = RPD_ROTATE_MODE, "icon" = "rotate-right"),
	list("category" = "Flip", "mode" = RPD_FLIP_MODE, "icon" = "exchange"),
	list("category" = "Recycle", "mode" = RPD_DELETE_MODE, "icon" = "trash"))
var/list/pipemenu = list(
	list("pipecategory" = "Normal", "pipemode" = RPD_ATMOS_PIPING),
	list("pipecategory" = "Supply", "pipemode" = RPD_SUPPLY_PIPING),
	list("pipecategory" = "Scrubber", "pipemode" = RPD_SCRUBBERS_PIPING),
	list("pipecategory" = "Devices", "pipemode" = RPD_DEVICES),
	list("pipecategory" = "Heat exchange", "pipemode" = RPD_HEAT_PIPING))

//NanoUI stuff

/obj/item/rpd/attack_self(mob/user)
	ui_interact(user)

/obj/item/rpd/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = inventory_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rpd.tmpl", "[name]", 400, 650, state = state)
		ui.open()
		ui.set_auto_update(1)

/obj/item/rpd/ui_data(mob/user, ui_key = "main", datum/topic_state/state = inventory_state)
	var/data[0]
	data["iconrotation"] = iconrotation
	data["mainmenu"] = mainmenu
	data["mode"] = mode
	data["pipelist"] = construction_pipe_list
	data["pipemenu"] = pipemenu
	data["pipetype"] = pipetype
	data["whatdpipe"] = whatdpipe
	data["whatpipe"] = whatpipe
	return data

/obj/item/rpd/Topic(href, href_list, nowindow, state)
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
	SSnanoui.update_uis(src)

/obj/item/rpd/afterattack(atom/target, mob/user, proximity)
	..()
	if(loc != user || !proximity || world.time < lastused + spawndelay)
		return
	target.rpd_act(user, src) //Handle RPD effects in separate procs

#undef RPD_COOLDOWN_TIME
#undef RPD_WALLBUILD_TIME
