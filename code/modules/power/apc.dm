#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096

#define APC_UPDATE_ICON_COOLDOWN 200 // 20 seconds

// APC malf status
#define APC_MALF_NOT_HACKED 1
#define APC_MALF_HACKED 2 // APC hacked by user, and user is in its core.
#define APC_MALF_SHUNTED_HERE 3 // User is shunted in this APC
#define APC_MALF_SHUNTED_OTHER 4 // User is shunted in another APC

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon_state = "apc0"
	use_power = NO_POWER_USE
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	req_access = list(access_engine_equip)
	siemens_strength = 1
	damage_deflection = 10
	var/area/area
	var/areastring = null
	var/obj/item/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500	//Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/debug= 0
	var/autoflag= 0		// 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/longtermpower = 10
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = 0
	var/updating_icon = 0
	var/datum/wires/apc/wires = null
	//var/debug = 0
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
	var/indestructible = 0 // If set, prevents aliens from destroying it
	var/keep_preset_name = 0

	var/report_power_alarm = TRUE

	var/shock_proof = 0 //if set to 1, this APC will not arc bolts of electricity if it's overloaded.

	// Nightshift
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0

/obj/machinery/power/apc/worn_out
	name = "\improper Worn out APC"
	keep_preset_name = 1
	locked = 0
	environ = 0
	equipment = 0
	lighting = 0
	operating = 0

/obj/machinery/power/apc/noalarm
	report_power_alarm = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(access_syndicate)
	report_power_alarm = FALSE

/obj/item/apc_electronics
	name = "power control module"
	desc = "Heavy-duty switching circuits for power control."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
	item_state = "electronic"
	flags = CONDUCT
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, ndir, building = 0)
	if(!armor)
		armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 100, "bomb" = 30, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	..()
	GLOB.apcs += src
	GLOB.apcs = sortAtom(GLOB.apcs)

	wires = new(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if(building)
		setDir(ndir)
	tdir = dir		// to fix Vars bug
	setDir(SOUTH)

	pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
	pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
	if(building)
		area = get_area(src)
		area.apc |= src
		opened = 1
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs -= src
	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	if(occupier)
		malfvacate(1)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	area.apc -= src
	return ..()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.setDir(tdir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new/obj/item/stock_parts/cell/upgraded(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = get_area(src)


	//if area isn't specified use current
	if(keep_preset_name)
		if(isarea(A))
			area = A
		// no-op, keep the name
	else if(isarea(A) && src.areastring == null)
		area = A
		name = "\improper [area.name] APC"
	else
		area = get_area_name(areastring)
		name = "\improper [area.name] APC"
	area.apc |= src

	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(stat & BROKEN)
			. += "Looks broken."
		else if(opened)
			if(has_electronics && terminal)
				. += "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
			else if(!has_electronics && terminal)
				. += "There are some wires but no electronics."
			else if(has_electronics && !terminal)
				. += "Electronics installed but not wired."
			else /* if(!has_electronics && !terminal) */
				. += "There is no electronics nor connected wires."
		else
			if(stat & MAINT)
				. += "The cover is closed. Something wrong with it: it doesn't work."
			else if(malfhack)
				. += "The cover is broken. It may be hard to force it open."
			else
				. += "The cover is closed."

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon(force_update = FALSE)

	if(!status_overlays || force_update)
		status_overlays = 1
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")



	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update && !force_update)
		return

	if(force_update || update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
				icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"



	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			overlays = 0
			return



	if(force_update || update & 2)

		if(overlays.len)
			overlays.len = 0

		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			overlays += status_overlays_lock[locked+1]
			overlays += status_overlays_charging[charging+1]
			if(operating)
				overlays += status_overlays_equipment[equipment+1]
				overlays += status_overlays_lighting[lighting+1]
				overlays += status_overlays_environ[environ+1]


/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==1)
			update_state |= UPSTATE_OPENED1
		if(opened==2)
			update_state |= UPSTATE_OPENED2
	else if(emagged || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == 1)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == 2)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if(!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()

	if(!updating_icon)
		updating_icon = 1
		// Start the update
		spawn(APC_UPDATE_ICON_COOLDOWN)
			update_icon()
			updating_icon = 0

/obj/machinery/power/apc/get_spooked(second_pass = FALSE)
	if(opened || panel_open)
		return
	if(stat & (NOPOWER | BROKEN))
		return
	if(!second_pass) //The first time, we just cut overlays
		addtimer(CALLBACK(src, .get_spooked, TRUE), 1)
		cut_overlays()
	else
		flick("apcemag", src) //Second time we cause the APC to update its icon, then add a timer to update icon later
		addtimer(CALLBACK(src, .proc/update_icon, TRUE), 10)

//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return src.attack_hand(user)

	else if	(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed!</span>")
			return
		else
			if(stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell!</span>")
				return
			if(!user.drop_item())
				return
			W.forceMove(src)
			cell = W
			user.visible_message(\
				"[user.name] has inserted the power cell to [src.name]!",\
				"<span class='notice'>You insert the power cell.</span>")
			chargecount = 0
			update_icon()

	else if(W.GetID())			// trying to unlock the interface with an ID card
		togglelock(user)

	else if(istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			throw EXCEPTION("attackby on APC when it's not on a turf")
			return
		if(host_turf.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first!</span>")
			return
		else if(terminal) // it already have terminal
			to_chat(user, "<span class='warning'>This APC is already wired!</span>")
			return
		else if(has_electronics == 0)
			to_chat(user, "<span class='warning'>There is nothing to wire!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten lengths of cable for APC!</span>")
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							"<span class='notice'>You start adding cables to the APC frame...</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			if(C.get_amount() < 10 || !C)
				return
			if(C.get_amount() >= 10 && !terminal && opened && has_electronics > 0)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if(prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, "<span class='notice'>You add cables to the APC frame.</span>")
				make_terminal()
				terminal.connect_to_network()

	else if(istype(W, /obj/item/apc_electronics) && opened)
		if(has_electronics!=0) // there are already electronicks inside
			to_chat(user, "<span class='warning'>You cannot put the board inside, there already is one!</span>")
			return
		else if(stat & BROKEN)
			to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged!</span>")
			return

		user.visible_message("[user.name] inserts the power control board into [src].", \
							"<span class='notice'>You start to insert the power control board into the frame...</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(has_electronics==0)
				has_electronics = 1
				locked = FALSE
				to_chat(user, "<span class='notice'>You place the power control board inside the frame.</span>")
				qdel(W)

	else if(istype(W, /obj/item/mounted/frame/apc_frame) && opened)
		if(!(stat & BROKEN || opened==2 || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, "<span class='warning'>You found no reason for repairing this APC</span>")
			return
		if(!(stat & BROKEN) && opened==2) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							"<span class='notice'>You begin to replace APC's cover...</span>")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, "<span class='notice'>You replace missing APC's cover.</span>")
				qdel(W)
				opened = 1
				update_icon()
			return
		if(has_electronics)
			to_chat(user, "<span class='warning'>You cannot repair this APC until you remove the electronics still inside!</span>")
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							"<span class='notice'>You begin to replace the damaged APC frame...</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You replace the damaged APC frame with a new one.</span>")
			qdel(W)
			stat &= ~BROKEN
			obj_integrity = max_integrity
			if(opened==2)
				opened = 1
			update_icon()
		return
	else
		return ..()


/obj/machinery/power/apc/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(user, 0))
		return
	if(opened) // a) on open apc
		if(has_electronics==1)
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect the wires first!</span>")
				return
			to_chat(user, "<span class='notice'>You are trying to remove the power control board...</span>" )
			if(I.use_tool(src, user, 50, volume = I.tool_volume))
				if(has_electronics==1)
					has_electronics = 0
					if(stat & BROKEN)
						user.visible_message(\
							"[user.name] has broken the power control board inside [src.name]!",
							"<span class='notice'>You break the charred power control board and remove the remains.</span>",
							"<span class='italics'>You hear a crack.</span>")
						return
						//SSticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
					else if(emagged) // We emag board, not APC's frame
						emagged = FALSE
						user.visible_message(
							"[user.name] has discarded emaged power control board from [src.name]!",
							"<span class='notice'>You discarded shorten board.</span>")
						return
					else if(malfhack) // AI hacks board, not APC's frame
						user.visible_message(\
							"[user.name] has discarded strangely programmed power control board from [src.name]!",
							"<span class='notice'>You discarded strangely programmed board.</span>")
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [src.name]!",
							"<span class='notice'>You remove the power control board.</span>")
						new /obj/item/apc_electronics(loc)
						return
		else if(opened!=2) //cover isn't removed
			opened = 0
			coverlocked = TRUE //closing cover relocks it
			update_icon()
			return
	else if(!(stat & BROKEN)) // b) on closed and not broken APC
		if(coverlocked && !(stat & MAINT)) // locked...
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			return
		else if(panel_open) // wires are exposed
			to_chat(user, "<span class='warning'>Exposed wires prevents you from opening it!</span>")
			return
		else
			opened = 1
			update_icon()

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	else if(opened)
		if(cell && !(stat & MAINT))
			to_chat(user, "<span class='warning'>Close the APC first!</span>") //Less hints more mystery!
			return
		else
			if(has_electronics==1)
				has_electronics = 2
				stat &= ~MAINT
				to_chat(user, "<span class='notice'>You screw the circuit electronics into place.</span>")
			else if(has_electronics==2)
				has_electronics = 1
				stat |= MAINT
				to_chat(user, "<span class='notice'>You unfasten the electronics.</span>")
			else
				to_chat(user, "<span class='warning'>There is nothing to secure!</span>")
				return
			update_icon()
	else if(emagged)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else
		panel_open = !panel_open
		to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"]")
		update_icon()


/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open && !opened)
		wires.Interact(user)
	else if(terminal && opened)
		terminal.dismantle(user, I)

/obj/machinery/power/apc/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open && !opened)
		wires.Interact(user)

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(emagged)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else if(opened)
		to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
	else if(panel_open)
		to_chat(user, "<span class='warning'>You must close the panel!</span>")
	else if(stat & (BROKEN|MAINT))
		to_chat(user, "<span class='warning'>Nothing happens!</span>")
	else
		if(allowed(usr) && !isWireCut(APC_WIRE_IDSCAN) && !malfhack)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the APC interface.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/power/apc/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		set_broken()

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != 2)
			opened = 2
			coverlocked = FALSE
			visible_message("<span class='warning'>The APC cover is knocked down!</span>")
			update_icon()

/obj/machinery/power/apc/welder_act(mob/user, obj/item/I)
	if(!opened || has_electronics || terminal)
		return
	. = TRUE
	if(!I.tool_use_check(user, 3))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, amount = 3, volume = I.tool_volume))
		if((stat & BROKEN) || opened==2)
			new /obj/item/stack/sheet/metal(loc)
			user.visible_message(\
				"[user.name] has cut [src] apart with [I].",\
				"<span class='notice'>You disassembled the broken APC frame.</span>")
		else
			new /obj/item/mounted/frame/apc_frame(loc)
			user.visible_message(\
				"[user.name] has cut [src] from the wall with [I].",\
				"<span class='notice'>You cut the APC frame from the wall.</span>")
		qdel(src)

/obj/machinery/power/apc/emag_act(user as mob)
	if(!(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(panel_open)
			to_chat(user, "You must close the panel first.")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			flick("apc-spark", src)
			emagged = 1
			locked = 0
			to_chat(user, "You emag the APC interface.")
			update_icon()

// attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/user)
//	if(!can_use(user)) This already gets called in interact() and in topic()
//		return
	if(!user)
		return
	src.add_fingerprint(user)

	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			if(issilicon(user))
				cell.loc=src.loc // Drop it, whoops.
			else
				user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.update_icon()

			src.cell = null
			user.visible_message("<span class='warning'>[user.name] removes the power cell from [src.name]!", "You remove the power cell.</span>")
//			to_chat(user, "You remove the power cell.")
			charging = 0
			src.update_icon()
		return
	if(stat & (BROKEN|MAINT))
		return

	src.interact(user)

/obj/machinery/power/apc/attack_ghost(mob/user)
	if(panel_open)
		wires.Interact(user)
	return ui_interact(user)

/obj/machinery/power/apc/interact(mob/user)
	if(!user)
		return

	if(panel_open)
		wires.Interact(user)

	return ui_interact(user)


/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return FALSE
	
	// Only if they're a traitor OR they have the malf picker from the combat module
	if(!malf.mind.has_antag_datum(/datum/antagonist/traitor) && !malf.malf_picker)
		return FALSE
	
	if(malfai == (malf.parent || malf))
		if(occupier == malf)
			return APC_MALF_SHUNTED_HERE
		else if(istype(malf.loc, /obj/machinery/power/apc))
			return APC_MALF_SHUNTED_OTHER
		else
			return APC_MALF_HACKED
	else
		return APC_MALF_NOT_HACKED

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!user)
		return

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "apc.tmpl", "[area.name] - APC", 510, issilicon(user) ? 535 : 460)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["locked"] = is_locked(user)
	data["isOperating"] = operating
	data["externalPower"] = main_status
	data["powerCellStatus"] = cell ? cell.percent() : null
	data["chargeMode"] = chargemode
	data["chargingStatus"] = charging
	data["totalLoad"] = round(lastused_equip + lastused_light + lastused_environ)
	data["coverLocked"] = coverlocked
	data["siliconUser"] = istype(user, /mob/living/silicon)
	data["siliconLock"] = locked
	data["malfStatus"] = get_malf_status(user)
	data["nightshiftLights"] = nightshift_lights

	var/powerChannels[0]
	powerChannels[++powerChannels.len] = list(
		"title" = "Equipment",
		"powerLoad" = round(lastused_equip),
		"status" = equipment,
		"topicParams" = list(
			"auto" = list("eqp" = 3),
			"on"   = list("eqp" = 2),
			"off"  = list("eqp" = 1)
		)
	)
	powerChannels[++powerChannels.len] = list(
		"title" = "Lighting",
		"powerLoad" = round(lastused_light),
		"status" = lighting,
		"topicParams" = list(
			"auto" = list("lgt" = 3),
			"on"   = list("lgt" = 2),
			"off"  = list("lgt" = 1)
		)
	)
	powerChannels[++powerChannels.len] = list(
		"title" = "Environment",
		"powerLoad" = round(lastused_environ),
		"status" = environ,
		"topicParams" = list(
			"auto" = list("env" = 3),
			"on"   = list("env" = 2),
			"off"  = list("env" = 1)
		)
	)

	data["powerChannels"] = powerChannels

	return data

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
//		if(area.name == "AI Chamber")
//			spawn(10)
//				to_chat(world, " [area.name] [area.power_equip]")
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
//		if(area.name == "AI Chamber")
//			to_chat(world, "[area.power_equip]")
	area.power_change()

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	return wires.IsIndexCut(wireIndex)


/obj/machinery/power/apc/proc/can_use(var/mob/user, var/loud = 0) //used by attack_hand() and Topic()
	if(user.can_admin_interact())
		return 1

	autoflag = 5
	if(istype(user, /mob/living/silicon))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, "<span class='danger'>\The [src] has AI control disabled!</span>")
				user << browse(null, "window=apc")
				user.unset_machine()
			return 0
	else
		if((!in_range(src, user) || !istype(src.loc, /turf)))
			return 0

	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(H.getBrainLoss() >= 60)
			for(var/mob/M in viewers(src, null))
				to_chat(M, "<span class='danger'>[H] stares cluelessly at [src] and drools.</span>")
			return 0
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='danger'>You momentarily forget how to use [src].</span>")
			return 0
	return 1

/obj/machinery/power/apc/proc/is_authenticated(mob/user as mob)
	if(user.can_admin_interact())
		return 1
	if(isAI(user) || isrobot(user))
		return 1
	else
		return !locked

/obj/machinery/power/apc/proc/is_locked(mob/user as mob)
	if(user.can_admin_interact())
		return 0
	if(isAI(user) || isrobot(user))
		return 0
	else
		return locked

/obj/machinery/power/apc/Topic(href, href_list, var/usingUI = 1)
	if(..())
		return 1

	if(!can_use(usr, 1))
		return 1

	if(href_list["lock"])
		if(!is_authenticated(usr))
			return

		coverlocked = !coverlocked

	else if(href_list["breaker"])
		if(!is_authenticated(usr))
			return

		toggle_breaker()

	else if(href_list["toggle_nightshift"])
		if(!is_authenticated(usr))
			return

		if(last_nightshift_switch > world.time + 100) // don't spam...
			to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
			return
		last_nightshift_switch = world.time
		set_nightshift(!nightshift_lights)

	else if(href_list["cmode"])
		if(!is_authenticated(usr))
			return

		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			update_icon()

	else if(href_list["eqp"])
		if(!is_authenticated(usr))
			return

		var/val = text2num(href_list["eqp"])
		equipment = setsubsystem(val)
		update_icon()
		update()

	else if(href_list["lgt"])
		if(!is_authenticated(usr))
			return

		var/val = text2num(href_list["lgt"])
		lighting = setsubsystem(val)
		update_icon()
		update()

	else if(href_list["env"])
		if(!is_authenticated(usr))
			return

		var/val = text2num(href_list["env"])
		environ = setsubsystem(val)
		update_icon()
		update()
	else if( href_list["close"] )
		SSnanoui.close_user_uis(usr, src)

		return 0
	else if(href_list["close2"])
		usr << browse(null, "window=apcwires")

		return 0

	else if(href_list["overload"])
		if(issilicon(usr) && !aidisabled)
			overload_lighting()

	else if(href_list["malfhack"])
		if(get_malf_status(usr))
			malfhack(usr)

	else if(href_list["occupyapc"])
		if(get_malf_status(usr))
			malfoccupy(usr)

	else if(href_list["deoccupyapc"])
		if(get_malf_status(usr))
			malfvacate()

	else if(href_list["toggleaccess"])
		if(istype(usr, /mob/living/silicon))
			if(emagged || aidisabled || (stat & (BROKEN|MAINT)))
				to_chat(usr, "The APC does not respond to the command.")
			else
				locked = !locked
				update_icon()

	return 0

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	update()
	update_icon()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != APC_MALF_NOT_HACKED)
		return
	if(malf.malfhacking)
		to_chat(malf, "You are already hacking an APC.")
		return
	to_chat(malf, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, /mob/living/silicon/ai/.proc/malfhacked, src), 600, TIMER_STOPPABLE)
	var/obj/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /obj/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current APC first!</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt!</span>")
		return
	if(!is_station_level(src.z))
		return
	occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = 1
	malf.mind.transfer_to(occupier)
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	occupier.verbs += /mob/living/silicon/ai/proc/corereturn
	occupier.cancel_camera()
	if((seclevel2num(get_security_level()) == SEC_LEVEL_DELTA) && malf.nuking)
		for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
			point.the_disk = src //the pinpointer will detect the shunted AI

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = 0
		occupier.parent.adjustOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		qdel(occupier)
		if(seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				for(var/mob/living/silicon/ai/A in ai_list)
					if((A.stat != DEAD) && A.nuking)
						point.the_disk = A //The pinpointer tracks the AI back into its core.
	else
		to_chat(occupier, "<span class='danger'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			occupier.loc = loc
			occupier.death()
			occupier.gib()
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				point.the_disk = null //Pinpointers go back to tracking the nuke disk

/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!src.malfhack && is_station_level(src.z))
		if(prob(3))
			src.locked = 1
			if(src.cell.charge > 0)
				src.cell.charge = 0
				cell.corrupt()
				src.malfhack = 1
				update_icon()
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				do_sparks(3, 1, src)
				for(var/mob/M in viewers(src))
					M.show_message("<span class='danger'>The [src.name] suddenly lets out a blast of smoke and some sparks!", 3, "<span class='danger'>You hear sizzling electronics.</span>", 2)


/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return

	lastused_light = area.usage(STATIC_LIGHT)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	if(debug)
		log_debug("Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light] - Longterm: [longtermpower]")

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = 0

			else	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				autoflag = 0


		// Set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge >= 1250 || longtermpower > 0)              // Put most likely at the top so we don't check it last, effeciency 101
			if(autoflag != 3)
				equipment = autoset(equipment, 1)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				autoflag = 3
				if(report_power_alarm && is_station_contact(z))
					SSalarms.power_alarm.clearAlarm(loc, src)
		else if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0)                       // <30%, turn off equipment
			if(autoflag != 2)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				if(report_power_alarm && is_station_contact(z))
					SSalarms.power_alarm.triggerAlarm(loc, src)
				autoflag = 2
		else if(cell.charge < 750 && cell.charge > 10)        // <15%, turn off lighting & equipment
			if((autoflag > 1 && longtermpower < 0) || (autoflag > 1 && longtermpower >= 0))
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 2)
				environ = autoset(environ, 1)
				if(report_power_alarm && is_station_contact(z))
					SSalarms.power_alarm.triggerAlarm(loc, src)
				autoflag = 1
		else if(cell.charge <= 0)                                   // zero charge, turn all off
			if(autoflag != 0)
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				if(report_power_alarm && is_station_contact(z))
					SSalarms.power_alarm.triggerAlarm(loc, src)
				autoflag = 0

		// now trickle-charge the cell
		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

		if(excess >= 5000000 && !shock_proof) //If there's more than 5,000,000 watts in the grid, start arcing and shocking people.
			if(prob(5))
				var/list/shock_mobs = list()
				for(var/C in view(get_turf(src), 5)) //We only want to shock a single random mob in range, not every one.
					if(isliving(C))
						shock_mobs += C
				if(shock_mobs.len)
					var/mob/living/L = pick(shock_mobs)
					L.electrocute_act(rand(5, 25), "electrical arc")
					playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, 1)
					Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if(report_power_alarm && is_station_contact(z))
			SSalarms.power_alarm.triggerAlarm(loc, src)
		autoflag = 0

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

/obj/machinery/power/apc/proc/autoset(var/val, var/on)
	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(occupier)
		occupier.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update_icon()
	update()
	spawn(600)
		equipment = 3
		environ = 3
		update_icon()
		update()
	..()

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = Clamp(malfai.malf_picker.processing_time - 10,0,1000)
	stat |= BROKEN
	operating = 0
	if(occupier)
		malfvacate(1)
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting(chance = 100)
	if(!operating || shorted)
		return
	if(cell && cell.charge >= 20)
		cell.use(20)
		spawn(0)
			for(var/obj/machinery/light/L in area)
				if(prob(chance))
					L.break_light_tube(0, 1)
					stoplag()

/obj/machinery/power/apc/proc/null_charge()
	for(var/obj/machinery/light/L in area)
		L.break_light_tube(0, 1)
		stoplag()

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

#undef APC_UPDATE_ICON_COOLDOWN
