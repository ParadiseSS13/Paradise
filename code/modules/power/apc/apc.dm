// main_status var
#define APC_EXTERNAL_POWER_NOTCONNECTED 0
#define APC_EXTERNAL_POWER_NOENERGY 1
#define APC_EXTERNAL_POWER_GOOD 2

//opened
#define APC_CLOSED 0
#define APC_OPENED 1
#define APC_COVER_OFF 2

#define APC_AUTOFLAG_ALL_OFF 0
#define APC_AUTOFLAG_ENVIRO_ONLY 1
#define APC_AUTOFLAG_EQUIPMENT_OFF 2
#define APC_AUTOFLAG_ALL_ON 3

//electronics_state
#define APC_ELECTRONICS_NONE 0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED 2

/// Power channel is off, anything connected to it is not powered, cannot be set manually by players
#define CHANNEL_SETTING_OFF 0
/// APC power channel Setting Off, if set while apc is "on" set apc to "off" otherwise set to "auto-off"
#define CHANNEL_SETTING_AUTO_OFF 1
/// APC power channel setting on,
#define CHANNEL_SETTING_ON 2   //on
// APC user setting,
#define CHANNEL_SETTING_AUTO_ON  3 //auto

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon_state = "apc0"
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	req_access = list(ACCESS_ENGINE_EQUIP)
	siemens_strength = 1
	damage_deflection = 10
	move_resist = INFINITY

	// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	powernet = 0

	/*** APC Area/Powernet vars ***/
	/// the area that this APC is in
	var/area/apc_area
	/// the set string name of the area, used in naming the APC
	var/areastring = null
	/// The power terminal connected to this APC
	var/obj/machinery/power/terminal/terminal = null
	/// The status of the terminals powernet that this APC is connected to: not connected, no power, or recieving power
	var/main_status = APC_EXTERNAL_POWER_NOTCONNECTED

	/// amount of power used in the last cycle for lighting channel
	var/last_used_lighting = 0
	/// amount of power used in the last cycle for equipment channel
	var/last_used_equipment = 0
	/// amount of power used in the last cycle for environment channel
	var/last_used_environment = 0
	/// amount of power used in the last cycle in total
	var/last_used_total = 0

	/*** APC Cell Vars ***/
	/// the cell type stored in this APC
	var/obj/item/stock_parts/cell/cell
	/// the percentage charge the internal battery will start with
	var/start_charge = 90
	/// Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/cell_type = 2500

	/*** APC Status Vars ***/
	/// The wire panel associated with this APC
	var/datum/wires/apc/wires = null
	/// Can the APC recieve/transmit power? Determined by the condition of the 2 Main Power Wires
	var/shorted = FALSE
	/// Is the APC on and transmitting power to enabled breakers? Think of this var as the master breaker for the APC
	var/operating = TRUE
	/// The current charging mode of the APC: not charging, charging, fully charged
	var/charging = APC_NOT_CHARGING
	/// A counter var used to help determine if the APC has not been charging long enough to justify not performing certain auto setting such as turning all channels back on
	var/longtermpower = 10
	/// State of the APC Cover - Closed, Open, or Off
	var/opened = APC_CLOSED
	/// Can silicons access this APC?
	var/aidisabled = FALSE
	var/electronics_state = APC_ELECTRONICS_NONE

	/*** APC Settings Vars ***/
	/// The current setting for the lighting channel
	var/lighting_channel = CHANNEL_SETTING_AUTO_ON
	/// The current setting for the equipment channel
	var/equipment_channel = CHANNEL_SETTING_AUTO_ON
	/// The current setting for the environment channel
	var/environment_channel = CHANNEL_SETTING_AUTO_ON
	/// Is the APC cover locked? i.e cannot be opened?
	var/coverlocked = TRUE
	/// Is the APC User Interface locked (prevents interaction)? Will not prevent silicons or admin observers from interacting
	var/locked = TRUE
	/// If TRUE, the APC will automatically draw power from connect terminal, if FALSE it will not charge
	var/chargemode = TRUE
	/// Counter var, ticks up when the APC recieves power from terminal and resets to 0 when not charging, used for the `var/charging` var
	var/chargecount = 0
	var/report_power_alarm = TRUE

	var/shock_proof = FALSE //if set to FALSE, this APC will not arc bolts of electricity if it's overloaded.

	// Nightshift
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0

	/// Used to determine if emergency lights should be on or off
	var/emergency_power = TRUE
	var/emergency_power_timer
	var/emergency_lights = FALSE

	/// settings variable for having the APC auto use certain power channel settings
	var/autoflag = APC_AUTOFLAG_ALL_OFF		// 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.

	/// Being hijacked by a pulse demon?
	var/being_hijacked = FALSE

	/*** APC Malf AI Vars ****/
	var/malfhack = FALSE //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/mob/living/silicon/ai/occupier = null
	/// Was this APC built instead of already existing? Used for malfhack to keep borgs from building apcs in space
	var/constructed = FALSE
	var/overload = 1 //used for the Blackout malf module

	/*** APC Overlay Vars ***/
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = FALSE
	var/updating_icon = FALSE
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
	var/keep_preset_name = FALSE

/obj/machinery/power/apc/New(turf/loc, direction, building = 0)
	if(!armor)
		armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 100, BOMB = 30, RAD = 100, FIRE = 90, ACID = 50)
	..()
	GLOB.apcs += src
	GLOB.apcs = sortAtom(GLOB.apcs)

	wires = new(src)

	if(building)
		// Offset 24 pixels in direction of dir. This allows the APC to be embedded in a wall, yet still inside an area
		setDir(direction) // This is only used for pixel offsets, and later terminal placement. APC dir doesn't affect its sprite since it only has one orientation.
		set_pixel_offsets_from_dir(24, -24, 24, -24)

		apc_area = get_area(src)
		apc_area.apc += src
		opened = APC_OPENED
		operating = FALSE
		name = "[apc_area.name] APC"
		stat |= MAINT
		constructed = TRUE
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/Destroy()
	SStgui.close_uis(wires)
	GLOB.apcs -= src

	machine_powernet.set_power_channel(PW_CHANNEL_LIGHTING, FALSE)
	machine_powernet.set_power_channel(PW_CHANNEL_EQUIPMENT, FALSE)
	machine_powernet.set_power_channel(PW_CHANNEL_ENVIRONMENT, FALSE)
	machine_powernet.power_change()
	if(occupier)
		malfvacate(1)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	machine_powernet.powernet_apc = null
	apc_area.apc -= src
	return ..()



/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	electronics_state = APC_ELECTRONICS_SECURED
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new /obj/item/stock_parts/cell/upgraded(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = get_area(src)


	//if area isn't specified use current
	if(keep_preset_name)
		if(isarea(A))
			apc_area = A
		// no-op, keep the name
	else if(isarea(A) && !areastring)
		apc_area = A
		name = "\improper [apc_area.name] APC"
	else
		name = "\improper [get_area_name(apc_area, TRUE)] APC"
	apc_area.apc |= src

	update_icon()

	make_terminal()

	set_light(1, LIGHTING_MINIMUM_POWER)

	addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(stat & BROKEN)
			return
		if(opened)
			if(has_electronics() && terminal)
				. += "The cover is [opened == APC_OPENED ? "removed" : "open"] and the power cell is [ cell ? "installed" : "missing"]."
			else if(!has_electronics() && terminal)
				. += "There are some wires but no electronics."
			else if(has_electronics() && !terminal)
				. += "Electronics installed but not wired."
			else /* if(!has_electronics() && !terminal) */
				. += "There are no electronics nor connected wires."
		else
			if(stat & MAINT)
				. += "The cover is closed. Something wrong with it: it doesn't work."
			else if(malfhack)
				. += "The cover is broken. It may be hard to force it open."
			else
				. += "The cover is closed."
	. += "<span class='notice'>This powerful, yet small, device powers the entire room in which it is located. From lighting, airlocks, and equipment, an APC is able to power it all! You can unlock an APC by using an ID with the required access on it, or by a local synthetic.</span>"
	. += "<span class='notice'>The enviroment setting controls the gas and airlock power.</span>"
	. += "<span class='notice'>The lighting setting controls the power of all the lighting of the room.</span>"
	. += "<span class='notice'>The equipment setting controls the power of all machines and computers in the room.</span>"
	. += "<span class='notice'>You can crowbar an unlocked APC to open the cover of the APC.</span>"
	if(isAntag(user))
		. += "<span class='warning'>An APC can be emagged to unlock it, this will keep it in it's refresh state, making very obvious something is wrong.</span>"

//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src, user) > 1)
		return attack_hand(user)

	else if(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
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

			for(var/mob/living/simple_animal/demon/pulse_demon/demon in cell)
				demon.forceMove(src)
				demon.current_power = src
				if(!being_hijacked) // first come first serve
					demon.try_hijack_apc(src)
			if(being_hijacked)
				cell.rigged = FALSE // don't blow the demon up

			user.visible_message(\
				"[user.name] has inserted the power cell to [name]!",\
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
		else if(!has_electronics())
			to_chat(user, "<span class='warning'>There is nothing to wire!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten lengths of cable for APC!</span>")
			return
		user.visible_message("[user.name] adds cables to the APC frame.", \
							"<span class='notice'>You start adding cables to the APC frame...</span>")
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(do_after(user, 20, target = src))
			if(C.get_amount() < 10 || !C)
				return
			if(C.get_amount() >= 10 && !terminal && opened && has_electronics())
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
		if(has_electronics()) // there are already electronicks inside
			to_chat(user, "<span class='warning'>You cannot put the board inside, there already is one!</span>")
			return
		else if(stat & BROKEN)
			to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged!</span>")
			return

		user.visible_message("[user.name] inserts [W] into [src].", \
							"<span class='notice'>You start to insert [W] into the frame...</span>")
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(do_after(user, 10, target = src))
			if(!has_electronics())
				electronics_state = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				to_chat(user, "<span class='notice'>You place [W] inside the frame.</span>")
				qdel(W)

	else if(istype(W, /obj/item/mounted/frame/apc_frame) && opened)
		if(!(stat & BROKEN || opened == APC_COVER_OFF || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, "<span class='warning'>You found no reason for repairing this APC</span>")
			return
		if(!(stat & BROKEN) && opened == APC_COVER_OFF) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] replaces missing APC's cover.",\
							"<span class='notice'>You begin to replace APC's cover...</span>")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, "<span class='notice'>You replace missing APC's cover.</span>")
				qdel(W)
				opened = APC_OPENED
				update_icon()
			return
		if(has_electronics())
			to_chat(user, "<span class='warning'>You cannot repair this APC until you remove the electronics still inside!</span>")
			return
		user.visible_message("[user.name] replaces the damaged APC frame with a new one.",\
							"<span class='notice'>You begin to replace the damaged APC frame...</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You replace the damaged APC frame with a new one.</span>")
			qdel(W)
			stat &= ~BROKEN
			obj_integrity = max_integrity
			if(opened == APC_COVER_OFF)
				opened = APC_OPENED
			update_icon()
		return
	else
		return ..()

/obj/machinery/power/apc/AltClick(mob/user)
	if(Adjacent(user))
		togglelock(user)

/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/power/apc/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		set_broken()

// attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/user)
	if(!user)
		return
	add_fingerprint(user)

	if(usr == user && opened && !issilicon(user))
		if(cell)
			user.visible_message("<span class='warning'>[user.name] removes [cell] from [src]!", "<span class='notice'>You remove [cell].</span>")
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.update_icon(UPDATE_OVERLAYS)
			cell = null
			charging = APC_NOT_CHARGING
			update_icon()
		return
	if(stat & (BROKEN|MAINT))
		return

	interact(user)

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

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "APC", name, 510, 460, master_ui, state)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = is_locked(user)
	data["normallyLocked"] = locked
	data["isOperating"] = operating
	data["externalPower"] = main_status
	data["powerCellStatus"] = cell ? cell.percent() : null
	data["chargeMode"] = chargemode
	data["chargingStatus"] = charging
	data["totalLoad"] = round(last_used_equipment + last_used_lighting + last_used_environment)
	data["coverLocked"] = coverlocked
	data["siliconUser"] = issilicon(user)
	data["siliconLock"] = locked
	data["malfStatus"] = get_malf_status(user)
	data["nightshiftLights"] = nightshift_lights
	data["emergencyLights"] = !emergency_lights

	var/list/power_channels = list()
	power_channels += list(list(
		"title" = "Equipment",
		"powerLoad" = round(last_used_equipment),
		"status" = equipment_channel,
		"topicParams" = list(
			"auto" = list("eqp" = 3),
			"on"   = list("eqp" = 2),
			"off"  = list("eqp" = 1)
		)
	))
	power_channels += list(list(
		"title" = "Lighting",
		"powerLoad" = round(last_used_lighting),
		"status" = lighting_channel,
		"topicParams" = list(
			"auto" = list("lgt" = 3),
			"on"   = list("lgt" = 2),
			"off"  = list("lgt" = 1)
		)
	))
	power_channels += list(list(
		"title" = "Environment",
		"powerLoad" = round(last_used_environment),
		"status" = environment_channel,
		"topicParams" = list(
			"auto" = list("env" = 3),
			"on"   = list("env" = 2),
			"off"  = list("env" = 1)
		)
	))

	data["powerChannels"] = power_channels

	return data

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		machine_powernet.set_power_channel(PW_CHANNEL_LIGHTING, (lighting_channel > CHANNEL_SETTING_AUTO_OFF))
		machine_powernet.set_power_channel(PW_CHANNEL_EQUIPMENT, (equipment_channel > CHANNEL_SETTING_AUTO_OFF))
		machine_powernet.set_power_channel(PW_CHANNEL_ENVIRONMENT, (environment_channel > CHANNEL_SETTING_AUTO_OFF))
		if(lighting_channel)
			emergency_power = TRUE
			if(emergency_power_timer)
				deltimer(emergency_power_timer)
				emergency_power_timer = null
		else
			emergency_power_timer = addtimer(CALLBACK(src, PROC_REF(turn_emergency_power_off)), 2 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		machine_powernet.set_power_channel(PW_CHANNEL_LIGHTING, FALSE)
		machine_powernet.set_power_channel(PW_CHANNEL_EQUIPMENT, FALSE)
		machine_powernet.set_power_channel(PW_CHANNEL_ENVIRONMENT, FALSE)
		emergency_power_timer = addtimer(CALLBACK(src, PROC_REF(turn_emergency_power_off)), 2 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
	machine_powernet.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(user.can_admin_interact())
		return TRUE

	autoflag = 5 //why the hell is this being set to 5, fucking malf code -sirryan
	if(issilicon(user))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(aidisabled || (malfhack && istype(malfai) && ((istype(AI) && (malfai != AI && malfai != AI.parent))) || (istype(robot) && malfai && !(robot in malfai.connected_robots))))
			if(!loud)
				to_chat(user, "<span class='danger'>\The [src] has AI control disabled!</span>")
			return FALSE
	else
		if((!in_range(src, user) || !isturf(loc)))
			return FALSE

	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(H.getBrainLoss() >= 60)
			for(var/mob/M in viewers(src, null))
				to_chat(M, "<span class='danger'>[H] stares cluelessly at [src] and drools.</span>")
			return FALSE
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='danger'>You momentarily forget how to use [src].</span>")
			return FALSE
	return TRUE

/obj/machinery/power/apc/proc/is_authenticated(mob/user as mob)
	if(user.can_admin_interact())
		return TRUE
	if(isAI(user) || isrobot(user) || user.has_unlimited_silicon_privilege)
		return TRUE
	else
		return !locked

/obj/machinery/power/apc/proc/is_locked(mob/user as mob)
	if(user.can_admin_interact())
		return FALSE
	if(isAI(user) || isrobot(user) || user.has_unlimited_silicon_privilege)
		return FALSE
	else
		return locked

/obj/machinery/power/apc/ui_act(action, params, datum/tgui/ui)
	var/mob/user = ui.user
	if(..() || !can_use(user, TRUE) || (is_locked(user) && (action != "toggle_nightshift")))
		return
	. = TRUE
	switch(action)
		if("lock")
			if(user.has_unlimited_silicon_privilege)
				if(emagged || stat & BROKEN)
					to_chat(user, "<span class='warning'>The APC does not respond to the command!</span>")
					return FALSE
				else
					locked = !locked
					update_icon()
			else
				to_chat(user, "<span class='warning'>Access Denied!</span>")
				return FALSE
		if("cover")
			coverlocked = !coverlocked
		if("breaker")
			toggle_breaker(user)
		if("toggle_nightshift")
			if(last_nightshift_switch > world.time + 100) // don't spam...
				to_chat(user, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
				return FALSE
			last_nightshift_switch = world.time
			set_nightshift(!nightshift_lights)
		if("charge")
			chargemode = !chargemode
		if("channel")
			if(params["eqp"])
				equipment_channel = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting_channel = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environment_channel = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
		if("overload")
			if(user.has_unlimited_silicon_privilege)
				INVOKE_ASYNC(src, PROC_REF(overload_lighting))
		if("hack")
			if(get_malf_status(user))
				malfhack(user)
		if("occupy")
			if(get_malf_status(user))
				malfoccupy(usr)
		if("deoccupy")
			if(get_malf_status(user))
				malfvacate()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/L in apc_area)
				INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
				CHECK_TICK

/obj/machinery/power/apc/proc/update_last_used()
	last_used_lighting = machine_powernet.get_channel_usage(PW_CHANNEL_LIGHTING)
	last_used_equipment = machine_powernet.get_channel_usage(PW_CHANNEL_EQUIPMENT)
	last_used_environment = machine_powernet.get_channel_usage(PW_CHANNEL_ENVIRONMENT)
	last_used_total = machine_powernet.get_total_usage()
	machine_powernet.clear_usage()

/// What the APC will do every process interval, updates power settings and power changes depending on powernet state
/obj/machinery/power/apc/process()
	if(stat & (BROKEN|MAINT)) // if the APC is broken, don't even bother
		return
	if(!apc_area.requires_power) // if the area doesn't use power, don't even bother
		return

	//We store the initial power channel states so we can check if they've changed at the end of the proc so we can update overlays efficiently
	var/last_lighting_state = lighting_channel
	var/last_equipment_state = equipment_channel
	var/last_environment_state = environment_channel
	var/last_charging_state = charging
	update_last_used() // get local powernet usage and clear it for next cycle

	var/excess = get_power_balance()

	if(!get_available_power())
		main_status = APC_EXTERNAL_POWER_NOTCONNECTED
	else if(excess < 0)
		main_status = APC_EXTERNAL_POWER_NOENERGY  // there's more demand than supply on powernet, there's not enough power
	else
		main_status = APC_EXTERNAL_POWER_GOOD // there's some excess power on the powernet!

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cell_used = min(cell.charge, GLOB.CELLRATE * last_used_total)	// clamp deduction to a max, amount left in cell
		cell.use(cell_used)

		if(excess > last_used_total)	// if power excess recharge the cell  by the same amount just used
			cell.give(cell_used)
			consume_direct_power(cell_used / GLOB.CELLRATE)		// add the load used to recharge the cell
		else // no excess, and not enough per-apc
			if((cell.charge / GLOB.CELLRATE + excess) >= last_used_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				consume_direct_power(excess) // so draw what we can from the grid
				charging = APC_NOT_CHARGING
			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
				lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
				environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
				autoflag = APC_AUTOFLAG_ALL_OFF

		// Set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging != APC_NOT_CHARGING && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		handle_autoflag()

		// now trickle-charge the cell
		if(chargemode && charging == APC_IS_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				consume_direct_power(ch / GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(charging == APC_NOT_CHARGING)
				if(excess > cell.maxcharge * GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_IS_CHARGING

		else // chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

		if(!shock_proof)
			handle_shock_chance(excess)

	else // no cell, switch everything off
		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
		lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
		environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
		if(report_power_alarm)
			apc_area.poweralert(FALSE, src)
		autoflag = APC_AUTOFLAG_ALL_OFF

	// update icon & area power if anything changed

	if(last_lighting_state != lighting_channel || last_equipment_state != equipment_channel || last_environment_state != environment_channel)
		queue_icon_update()
		update()
	else if(last_charging_state != charging)
		queue_icon_update()

	machine_powernet.handle_flicker() // try and flicker machines/lights in the area randomly

/obj/machinery/power/apc/proc/handle_autoflag()
	// Put most likely at the top so we don't check it last, effeciency 101 <--- old coders can't spell
	if(cell.charge >= 1250 || longtermpower > 0)
		if(autoflag != APC_AUTOFLAG_ALL_ON)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_AUTO_OFF)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_AUTO_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			autoflag = APC_AUTOFLAG_ALL_ON
			if(report_power_alarm)
				apc_area.poweralert(TRUE, src)
		return
	if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0) // <30%, turn off equipment
		if(autoflag != APC_AUTOFLAG_EQUIPMENT_OFF)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_ON)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_AUTO_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			if(report_power_alarm)
				apc_area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_EQUIPMENT_OFF
	else if(cell.charge < 750 && cell.charge > 10)        // <15%, turn off lighting & equipment
		if(autoflag > APC_AUTOFLAG_ENVIRO_ONLY)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_ON)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_ON)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			if(report_power_alarm)
				apc_area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_ENVIRO_ONLY
	else if(cell.charge <= 0)                                   // zero charge, turn all off
		if(autoflag != APC_AUTOFLAG_ALL_OFF)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
			if(report_power_alarm)
				apc_area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_ALL_OFF

/// Handles APC arc'ing every APC process interval
/obj/machinery/power/apc/proc/handle_shock_chance(excess = 0)
	if(excess < 2500000)
		return
	var/shock_chance = 5 // 5%
	if(excess >= 7500000)
		shock_chance = 15
	else if(excess >= 5000000)
		shock_chance = 10
	if(prob(shock_chance))
		var/list/shock_mobs = list()
		for(var/C in view(get_turf(src), 5)) //We only want to shock a single random mob in range, not every one.
			if(isliving(C))
				shock_mobs += C
		if(length(shock_mobs))
			var/mob/living/L = pick(shock_mobs)
			L.electrocute_act(rand(5, 25), "electrical arc")
			playsound(get_turf(L), 'sound/effects/eleczap.ogg', 75, TRUE)
			Beam(L, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)


///    *************
/// APC Power Procs
///    *************

/obj/machinery/power/apc/get_cell()
	return cell

/// Override because the APC does not directly connect to the network; it goes through a terminal.
/obj/machinery/power/apc/connect_to_network()
	terminal?.connect_to_network() //The terminal is what the power computer looks for

/obj/machinery/power/apc/get_surplus()
	if(terminal)
		return terminal.get_surplus()
	else
		return 0

/obj/machinery/power/apc/get_power_balance()
	if(terminal)
		return terminal.get_power_balance()
	else
		return 0

/obj/machinery/power/apc/consume_direct_power(amount)
	if(terminal?.powernet)
		terminal.consume_direct_power(amount)

/obj/machinery/power/apc/get_available_power()
	return terminal ? terminal.get_available_power() : 0

/obj/machinery/power/apc/proc/power_destroy() // Caused only by explosions and teslas, not for deconstruction
	if(obj_integrity > integrity_failure || opened != APC_COVER_OFF)
		return
	var/drop_loc = drop_location()
	new /obj/item/stack/sheet/metal(drop_loc, 3) // Metal from the frame
	new /obj/item/stack/cable_coil(drop_loc, 10) // wiring from the terminal and the APC, some lost due to explosion
	QDEL_NULL(terminal) // We don't want floating terminals
	qdel(src)

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(get_turf(src))
	terminal.setDir(dir)
	terminal.master = src

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

///    *************
/// APC Settings
///    *************

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
		if(allowed(user) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the APC interface.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	update()
	update_icon()

/**
	* # autoset
	*
	* this proc is rather confusing at first glance, it handles apc power channel settings when trying to
	* auto set values to it, good luck understanding how this works but I sure as hell don't
*/
/obj/machinery/power/apc/proc/autoset(current_setting, new_setting)
	switch(new_setting)
		if(CHANNEL_SETTING_OFF)
			if(current_setting == CHANNEL_SETTING_ON)	// if on, return off
				return CHANNEL_SETTING_OFF
			if(current_setting == CHANNEL_SETTING_AUTO_ON)	// if auto-on, return auto-off
				return CHANNEL_SETTING_AUTO_OFF
		if(CHANNEL_SETTING_AUTO_OFF)
			if(current_setting == CHANNEL_SETTING_AUTO_OFF)	// if auto-off, return auto-on
				return CHANNEL_SETTING_AUTO_ON
		if(CHANNEL_SETTING_ON)
			if(current_setting == CHANNEL_SETTING_AUTO_ON)	// if auto-on, return auto-off
				return CHANNEL_SETTING_AUTO_OFF
	return current_setting //if setting is not changed, just keep current setting

/obj/machinery/power/apc/proc/setsubsystem(new_setting)
	if(cell?.charge > 1) //if there's a charge
		if(new_setting == CHANNEL_SETTING_AUTO_OFF)  //and apc now set to off, return off
			return CHANNEL_SETTING_OFF
		return new_setting //else return the new setting
	if(new_setting == CHANNEL_SETTING_AUTO_ON) //if no charge and set to auto, set to auto off
		return CHANNEL_SETTING_AUTO_OFF
	return CHANNEL_SETTING_OFF //if set to on and no charge, set to off

///    ************* ---
/// APC Helper Procs --- Antag Abilities/Fun Stuff
///    ************* ---

/// set APC stat as broken and set it to be non operational, kick out an AI if there's a malf one in it
/obj/machinery/power/apc/proc/set_broken()
	stat |= BROKEN
	operating = FALSE
	if(occupier)
		malfvacate(1)
	update_icon()
	update()

/// overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting(chance = 100)
	if(!operating || shorted)
		return
	if(cell && cell.charge >= 20)
		cell.use(20)
		for(var/obj/machinery/light/L in apc_area)
			if(prob(chance))
				L.break_light_tube(0, 1)
				stoplag()

/// turns off emergency power and sets each light to update
/obj/machinery/power/apc/proc/turn_emergency_power_off()
	emergency_power = FALSE
	for(var/obj/machinery/light/L in apc_area)
		INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)

/// sets nightshift mode on for the APC
/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in apc_area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE, play_sound = FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/relock_callback()
	locked = TRUE
	updateDialog()

/// Updates APC to not be shorted if both main power wires are mended
/obj/machinery/power/apc/proc/check_main_power_callback()
	if(!wires.is_cut(WIRE_MAIN_POWER1) && !wires.is_cut(WIRE_MAIN_POWER2))
		shorted = FALSE
		updateDialog()

/// Updates APC to AI accesible if AI Wire is mended
/obj/machinery/power/apc/proc/check_ai_control_callback()
	if(!wires.is_cut(WIRE_AI_CONTROL))
		aidisabled = FALSE
		updateDialog()

/// Repairs all wires, enables all breakers, and unshorts the APC
/obj/machinery/power/apc/proc/repair_apc()
	if(wires)
		wires.repair()
	if(!operating)
		toggle_breaker()
	if(shorted)
		shorted = FALSE

/// If the APC has a cell, recharge it
/obj/machinery/power/apc/proc/recharge_apc()
	var/obj/item/stock_parts/cell/C = get_cell()
	if(C)
		C.charge = C.maxcharge

/obj/machinery/power/apc/proc/emp_callback()
	equipment_channel = 3
	environment_channel = 3
	update_icon()
	update()

///    *************
/// External Acts on the APCS
///    *************

/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(occupier)
		occupier.emp_act(severity)
	lighting_channel = 0
	equipment_channel = 0
	environment_channel = 0
	update_icon()
	update()
	addtimer(CALLBACK(src, PROC_REF(emp_callback)), 60 SECONDS)
	..()

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/ex_act(severity)
	..()
	if(severity < EXPLODE_LIGHT)
		power_destroy()

/obj/machinery/power/apc/zap_act(power, zap_flags)
	. = ..()
	power_destroy()

/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!malfhack && is_station_level(z))
		if(prob(3))
			locked = TRUE
			if(cell.charge > 0)
				cell.charge = 0
				cell.corrupt()
				malfhack = TRUE
				update_icon()
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(3, FALSE, loc)
				smoke.attach(src)
				smoke.start()
				do_sparks(3, 1, src)
				for(var/mob/M in viewers(src))
					M.show_message("<span class='danger'>[src] suddenly lets out a blast of smoke and some sparks!", 3, "<span class='danger'>You hear sizzling electronics.</span>", 2)

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
			emagged = TRUE
			locked = FALSE
			to_chat(user, "You emag the APC interface.")
			update_icon()

/obj/machinery/power/apc/proc/apc_short()
	// if it has internal wires, cut the power wires
	if(wires)
		if(!wires.is_cut(WIRE_MAIN_POWER1))
			wires.cut(WIRE_MAIN_POWER1)
		if(!wires.is_cut(WIRE_MAIN_POWER2))
			wires.cut(WIRE_MAIN_POWER2)
	// if it was operating, toggle off the breaker
	if(operating)
		toggle_breaker()
	// no matter what, ensure the area knows something happened to the power
	apc_area.powernet.power_change()

///    *************
/// APC subtypes
///    *************

/obj/machinery/power/apc/worn_out
	name = "\improper Worn out APC"
	keep_preset_name = TRUE
	locked = FALSE
	environment_channel = 0
	equipment_channel = 0
	lighting_channel = 0
	operating = FALSE
	emergency_power = FALSE

/// APC type used for when you don't want the power alarm on the APC to show up on AI reports
/obj/machinery/power/apc/off_station
	report_power_alarm = FALSE

/// APCs used for ruins, this version also starts devoid of a charge
/obj/machinery/power/apc/off_station/empty_charge
	start_charge = 0

/obj/machinery/power/apc/syndicate //general syndicate access
	name = "Main branch, do not use"
	req_access = list(ACCESS_SYNDICATE)
	report_power_alarm = FALSE

/obj/machinery/power/apc/syndicate/north
	name = "north bump"
	pixel_y = 24

/obj/machinery/power/apc/syndicate/south
	name = "south bump"
	pixel_y = -24

/obj/machinery/power/apc/syndicate/east
	name = "east bump"
	pixel_x = 24

/obj/machinery/power/apc/syndicate/west
	name = "west bump"
	pixel_x = -24

/obj/machinery/power/apc/syndicate/off
	name = "APC off"
	environment_channel = 0
	equipment_channel = 0
	lighting_channel = 0
	operating = FALSE

/obj/machinery/power/apc/syndicate/off/Initialize(mapload)
	. = ..()
	cell.charge = 0

/obj/item/apc_electronics
	name = "APC electronics"
	desc = "Heavy-duty switching circuits for power control."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
	item_state = "electronic"
	flags = CONDUCT
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1


#undef APC_EXTERNAL_POWER_NOTCONNECTED
#undef APC_EXTERNAL_POWER_NOENERGY
#undef APC_EXTERNAL_POWER_GOOD
