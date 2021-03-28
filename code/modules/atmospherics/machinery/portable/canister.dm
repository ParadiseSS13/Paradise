/datum/canister_icons
	var
		possiblemaincolor = list( //these lists contain the possible colors of a canister
			list("name" = "\[N2O\]", "icon" = "redws"),
			list("name" = "\[N2\]", "icon" = "red"),
			list("name" = "\[O2\]", "icon" = "blue"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange"),
			list("name" = "\[CO2\]", "icon" = "black"),
			list("name" = "\[Air\]", "icon" = "grey"),
			list("name" = "\[CAUTION\]", "icon" = "yellow"),
			list("name" = "\[SPECIAL\]", "icon" = "whiters")
			)
		possibleseccolor = list( // no point in having the N2O and "whiters" ones in these lists
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c"),
			list("name" = "\[O2\]", "icon" = "blue-c"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c"),
			list("name" = "\[CO2\]", "icon" = "black-c"),
			list("name" = "\[Air\]", "icon" = "grey-c"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c")
			)
		possibletertcolor = list(
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c-1"),
			list("name" = "\[O2\]", "icon" = "blue-c-1"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-1"),
			list("name" = "\[CO2\]", "icon" = "black-c-1"),
			list("name" = "\[Air\]", "icon" = "grey-c-1"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-1")
			)
		possiblequartcolor = list(
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c-2"),
			list("name" = "\[O2\]", "icon" = "blue-c-2"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-2"),
			list("name" = "\[CO2\]", "icon" = "black-c-2"),
			list("name" = "\[Air\]", "icon" = "grey-c-2"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-2")
			)
GLOBAL_DATUM_INIT(canister_icon_container, /datum/canister_icons, new())

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	flags = CONDUCT
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 50)
	max_integrity = 250
	integrity_failure = 100

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/list/canister_color //variable that stores colours
	var/list/color_index // list which stores tgui color indexes for the recoloring options, to enable previously-set colors to show up right

	//lists for check_change()
	var/list/oldcolor

	//passed to the ui to render the color lists
	var/list/colorcontainer

	var/can_label = 1
	var/filled = 0.5
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = NO_POWER_USE
	interact_offline = 1
	var/release_log = ""
	var/update_flag = 0

/obj/machinery/portable_atmospherics/canister/New()
	..()
	canister_color = list(
		"prim" = "yellow",
		"sec" = "none",
		"ter" = "none",
		"quart" = "none"
	)
	oldcolor = new /list()
	colorcontainer = list(
		"prim" = list(
			"options" = GLOB.canister_icon_container.possiblemaincolor,
			"name" = "Primary color",
		),
		"sec" = list(
			"options" = GLOB.canister_icon_container.possibleseccolor,
			"name" = "Secondary color",
		),
		"ter" = list(
			"options" = GLOB.canister_icon_container.possibletertcolor,
			"name" = "Tertiary color",
		),
		"quart" = list(
			"options" = GLOB.canister_icon_container.possiblequartcolor,
			"name" = "Quaternary color",
		)
	)
	color_index = list()
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/check_change()
	var/old_flag = update_flag
	update_flag = 0
	if(holding)
		update_flag |= 1
	if(connected_port)
		update_flag |= 2

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < 10)
		update_flag |= 4
	else if(tank_pressure < ONE_ATMOSPHERE)
		update_flag |= 8
	else if(tank_pressure < 15*ONE_ATMOSPHERE)
		update_flag |= 16
	else
		update_flag |= 32

	if(list2params(oldcolor) != list2params(canister_color))
		update_flag |= 64
		oldcolor = canister_color.Copy()

	if(update_flag == old_flag)
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/canister/update_icon()
/*
update_flag
1 = holding
2 = connected_port
4 = tank_pressure < 10
8 = tank_pressure < ONE_ATMOS
16 = tank_pressure < 15*ONE_ATMOS
32 = tank_pressure go boom.
64 = colors
(note: colors has to be applied every icon update)
*/

	if(destroyed)
		overlays = 0
		icon_state = text("[]-1", canister_color["prim"])//yes, I KNOW the colours don't reflect when the can's borked, whatever.
		return

	if(icon_state != canister_color["prim"])
		icon_state = canister_color["prim"]

	if(check_change()) //Returns 1 if no change needed to icons.
		return

	overlays.Cut()

	for(var/C in canister_color)
		if(C == "prim")
			continue
		if(canister_color[C] == "none")
			continue
		overlays.Add(canister_color[C])

	if(update_flag & 1)
		overlays += "can-open"
	if(update_flag & 2)
		overlays += "can-connector"
	if(update_flag & 4)
		overlays += "can-o0"
	if(update_flag & 8)
		overlays += "can-o1"
	else if(update_flag & 16)
		overlays += "can-o2"
	else if(update_flag & 32)
		overlays += "can-o3"

	update_flag &= ~68 //the flag 64 represents change, not states. As such, we have to reset them to be able to detect a change on the next go.
	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	if((stat & BROKEN) || (flags & NODECONSTRUCT))
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)
	air_update_turf()

	stat |= BROKEN
	density = FALSE
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	update_icon()

	if(holding)
		holding.forceMove(T)
		holding = null

/obj/machinery/portable_atmospherics/canister/process_atmos()
	if(destroyed)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta * environment.volume / (air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
				air_update_turf()
			update_icon()


	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	updateDialog()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			valve_open = FALSE
			update_icon()
			investigate_log("Valve was <b>closed</b> by [key_name(user)].<br>", "atmos")
		else if(valve_open && holding)
			investigate_log("[key_name(user)] started a transfer into [holding].<br>", "atmos")

/obj/machinery/portable_atmospherics/canister/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(mob/user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Canister", name, 600, 350, master_ui, state)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = ONE_ATMOSPHERE
	data["minReleasePressure"] = round(ONE_ATMOSPHERE / 10)
	data["maxReleasePressure"] = round(ONE_ATMOSPHERE * 10)
	data["valveOpen"] = valve_open ? 1 : 0
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["colorContainer"] = colorcontainer.Copy()
	data["color_index"] = color_index
	data["hasHoldingTank"] = holding ? 1 : 0
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	var/can_min_release_pressure = round(ONE_ATMOSPHERE / 10)
	var/can_max_release_pressure = round(ONE_ATMOSPHERE * 10)
	. = TRUE
	switch(action)
		if("relabel")
			if(can_label)
				var/T = sanitize(copytext(input("Choose canister label", "Name", name) as text|null, 1, MAX_NAME_LEN))
				if(can_label) //Exploit prevention
					if(T)
						name = T
					else
						name = "canister"
				else
					to_chat(usr, "<span class='warning'>As you attempted to rename it the pressure rose!</span>")
					. = FALSE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = ONE_ATMOSPHERE
			else if(pressure == "min")
				pressure = can_min_release_pressure
			else if(pressure == "max")
				pressure = can_max_release_pressure
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(isnull(pressure))
					. = FALSE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", "atmos")
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into the [holding || "air"].<br>"
				if(!holding)
					logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into the air.<br>"
					if(air_contents.toxins > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains plasma in [get_area(src)]! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						log_admin("[key_name(usr)] opened a canister that contains plasma at [get_area(src)]: [x], [y], [z]")
					if(air_contents.sleeping_agent > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains N2O in [get_area(src)]! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
						log_admin("[key_name(usr)] opened a canister that contains N2O at [get_area(src)]: [x], [y], [z]")
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the [holding || "air"].<br>"
			investigate_log(logmsg, "atmos")
			release_log += logmsg
		if("eject")
			if(holding)
				if(valve_open)
					valve_open = FALSE
					release_log += "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the [holding]<br>"
				replace_tank(usr, FALSE)
		if("recolor")
			if(can_label)
				var/ctype = params["ctype"]
				var/cnum = text2num(params["nc"])
				if(isnull(colorcontainer[ctype]))
					message_admins("[key_name_admin(usr)] passed an invalid ctype var to a canister.")
					return
				var/newcolor = sanitize_integer(cnum, 0, length(colorcontainer[ctype]["options"]))
				color_index[ctype] = newcolor
				newcolor++ // javascript starts arrays at 0, byond (for some reason) starts them at 1, this converts JS values to byond values
				canister_color[ctype] = colorcontainer[ctype]["options"][newcolor]["icon"]
	add_fingerprint(usr)
	update_icon()


/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Plasma)\]"
	icon_state = "orange" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey" //See New()
	can_label = 0
/obj/machinery/portable_atmospherics/canister/custom_mix
	name = "Canister \[Custom\]"
	icon_state = "whiters" //See New()
	can_label = 0


/obj/machinery/portable_atmospherics/canister/toxins/New()
	..()

	canister_color["prim"] = "orange"
	air_contents.toxins = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()
	..()

	canister_color["prim"] = "blue"
	air_contents.oxygen = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()
	..()

	canister_color["prim"] = "redws"
	air_contents.sleeping_agent = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()
	..()

	canister_color["prim"] = "red"
	air_contents.nitrogen = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()
	..()

	canister_color["prim"] = "black"
	air_contents.carbon_dioxide = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()
	..()

	canister_color["prim"] = "grey"
	air_contents.oxygen = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.nitrogen = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

	update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/custom_mix/New()
	..()

	canister_color["prim"] = "whiters"
	update_icon() // Otherwise new canisters do not have their icon updated with the pressure light, likely want to add this to the canister class constructor, avoiding at current time to refrain from screwing up code for other canisters. --DZD
	return 1

/obj/machinery/portable_atmospherics/canister/welder_act(mob/user, obj/item/I)
	if(!(stat & BROKEN))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You salvage whats left of [src]!</span>")
		new /obj/item/stack/sheet/metal(drop_location(), 3)
		qdel(src)
