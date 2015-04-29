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
			list("name" = "\[N2\]", "icon" = "red-c"),
			list("name" = "\[O2\]", "icon" = "blue-c"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c"),
			list("name" = "\[CO2\]", "icon" = "black-c"),
			list("name" = "\[Air\]", "icon" = "grey-c"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c")
			)
		possibletertcolor = list(
			list("name" = "\[N2\]", "icon" = "red-c-1"),
			list("name" = "\[O2\]", "icon" = "blue-c-1"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-1"),
			list("name" = "\[CO2\]", "icon" = "black-c-1"),
			list("name" = "\[Air\]", "icon" = "grey-c-1"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-1")
			)
		possiblequartcolor = list(
			list("name" = "\[N2\]", "icon" = "red-c-2"),
			list("name" = "\[O2\]", "icon" = "blue-c-2"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-2"),
			list("name" = "\[CO2\]", "icon" = "black-c-2"),
			list("name" = "\[Air\]", "icon" = "grey-c-2"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-2")
			)

		possibledecals = list( //var that stores all possible decals, used by ui
			list("name" = "Low temperature canister", "icon" = "cold"),
			list("name" = "High temperature canister", "icon" = "hot"),
			list("name" = "Plasma containing canister", "icon" = "plasma")
		)

var/datum/canister_icons/canister_icon_container = new()

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags = CONDUCT

	var/menu = 0
	//used by nanoui: 0 = main menu, 1 = relabel

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/list/_color //variable that stores colours
	var/list/decals //list that stores the decals

	//lists for check_change()
	var/list/oldcolor
	var/list/olddecals

	//passed to the ui to render the color lists
	var/list/colorcontainer
	var/list/possibledecals

	var/can_label = 1
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""
	var/busy = 0
	var/update_flag = 0

	New()
		..()
		_color = list(
		"prim" = "yellow",
		"sec" = "none",
		"ter" = "none",
		"quart" = "none")
		oldcolor = new /list()
		decals = list("cold" = 0, "hot" = 0, "plasma" = 0)
		colorcontainer = new /list(4)
		possibledecals = new /list(3)
		update_icon()

/obj/machinery/portable_atmospherics/canister/proc/init_data_vars()
	//passed to the ui to render the color lists
	colorcontainer = list(
		"prim" = list(
			"options" = canister_icon_container.possiblemaincolor,
			"name" = "Primary color",
		),
		"sec" = list(
			"options" = canister_icon_container.possibleseccolor,
			"name" = "Secondary color",
		),
		"ter" = list(
			"options" = canister_icon_container.possibletertcolor,
			"name" = "Tertiary color",
		),
		"quart" = list(
			"options" = canister_icon_container.possiblequartcolor,
			"name" = "Quaternary color",
		)
	)

	//var/anycolor used by the nanoUI, 0: no color applied. 1: color applied
	for(var/C in colorcontainer)
		if(C == "prim") continue
		var/list/L = colorcontainer[C]
		if(!(_color[C]) || (_color[C] == "none"))
			L.Add(list("anycolor" = 0))
		else
			L.Add(list("anycolor" = 1))
		colorcontainer[C] = L

	possibledecals = new /list(3)

	var/i
	var/list/L = canister_icon_container.possibledecals
	for(i=1;i<=L.len;i++)
		var/list/LL = L[i]
		LL = LL.Copy() //make sure we don't edit the datum list
		LL.Add(list("active" = decals[LL["icon"]])) //"active" used by nanoUI
		possibledecals[i] = LL

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

	if(list2params(oldcolor) != list2params(_color))
		update_flag |= 64
		oldcolor = _color.Copy()

	if(list2params(olddecals) != list2params(decals))
		update_flag |= 128
		olddecals = decals.Copy()

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
128 = decals
(note: colors and decals has to be applied every icon update)
*/

	if (src.destroyed)
		src.overlays = 0
		src.icon_state = text("[]-1", src._color["prim"])//yes, I KNOW the colours don't reflect when the can's borked, whatever.

	if(icon_state != src._color["prim"])
		icon_state = src._color["prim"]

	if(check_change()) //Returns 1 if no change needed to icons.
		return

	overlays.Cut()

	for(var/C in _color)
		if(C == "prim") continue
		if(_color[C] == "none") continue
		overlays.Add(_color[C])

	for(var/D in decals)
		if(decals[D])
			overlays.Add("decal-" + D)

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

	update_flag &= ~196 //the flags 128 and 64 represent change, not states. As such, we have to reset them to be able to detect a change on the next go.
	return

//template modification exploit prevention, used in Topic()
/obj/machinery/portable_atmospherics/canister/proc/is_a_color(var/inputVar, var/checkColor = "all")
	if (checkColor == "prim" || checkColor == "all")
		for(var/list/L in canister_icon_container.possiblemaincolor)
			if (L["icon"] == inputVar)
				return 1
	if (checkColor == "sec" || checkColor == "all")
		for(var/list/L in canister_icon_container.possibleseccolor)
			if (L["icon"] == inputVar)
				return 1
	if (checkColor == "ter" || checkColor == "all")
		for(var/list/L in canister_icon_container.possibletertcolor)
			if (L["icon"] == inputVar)
				return 1
	if (checkColor == "quart" || checkColor == "all")
		for(var/list/L in canister_icon_container.possiblequartcolor)
			if (L["icon"] == inputVar)
				return 1
	return 0

/obj/machinery/portable_atmospherics/canister/proc/is_a_decal(var/inputVar)
	for(var/list/L in canister_icon_container.possibledecals)
		if (L["icon"] == inputVar)
			return 1
	return 0

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
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
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
				air_update_turf()
			src.update_icon()


	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 200
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(Proj.damage)
			src.health -= round(Proj.damage / 2)
			healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(iswelder(W) && src.destroyed)
		if(weld(W, user))
			user << "\blue You salvage whats left of \the [src]"
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src.loc)
			M.amount = 3
			del src
		return

	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("\red [user] hits the [src] with a [W]!")
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			user << "You pulse-pressurize your jetpack from the tank."
		return

	..()

	nanomanager.update_uis(src) // Update all NanoUIs attached to src



/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_alien(mob/living/carbon/alien/humanoid/user)
	return

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if (src.destroyed)
		return

	init_data_vars() //set up var/colorcontainer and var/possibledecals

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["menu"] = menu ? 1 : 0
	data["canLabel"] = can_label ? 1 : 0
	data["_color"] = _color
	data["colorContainer"] = colorcontainer
	data["possibleDecals"] = possibledecals
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["minReleasePressure"] = round(ONE_ATMOSPHERE/10)
	data["maxReleasePressure"] = round(10*ONE_ATMOSPHERE)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "canister.tmpl", "Canister", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

	//Disregard these, avoid cluttering up the VV window
	colorcontainer = new /list(4)
	possibledecals = new /list(3)

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict. // yeah but without SOME sort of Topic check any dick can mess with them via exploits as he pleases -walter0o
	if (!istype(src.loc, /turf))
		return 0

	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr)) // exploit protection -walter0o
		usr << browse(null, "window=canister")
		onclose(usr, "canister")
		return

	if (href_list["choice"] == "menu")
		menu = text2num(href_list["mode_target"])

	if(href_list["toggle"])
		if (valve_open)
			if (holding)
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
			else
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the <font color='red'><b>air</b></font><br>"
		else
			if (holding)
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the [holding]<br>"
			else
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the <font color='red'><b>air</b></font><br>"
		valve_open = !valve_open

	if (href_list["remove_tank"])
		if(holding)
			if (valve_open)
				valve_open = 0
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
			holding.loc = loc
			holding = null

	if (href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		if(diff > 0)
			release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
		else
			release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

	if (href_list["rename"])
		if (can_label)
			var/T = sanitize(copytext(input("Choose canister label", "Name", name) as text|null,1,MAX_NAME_LEN))
			if (can_label) //Exploit prevention
				if (T)
					name = T
				else
					name = "canister"
			else
				usr << "\red As you attempted to rename it the pressure rose!"

	if (href_list["choice"] == "Primary color")
		if (is_a_color(href_list["icon"],"prim"))
			_color["prim"] = href_list["icon"]
	if (href_list["choice"] == "Secondary color")
		if (href_list["icon"] == "none")
			_color["sec"] = "none"
		else if (is_a_color(href_list["icon"],"sec"))
			_color["sec"] = href_list["icon"]
	if (href_list["choice"] == "Tertiary color")
		if (href_list["icon"] == "none")
			_color["ter"] = "none"
		else if (is_a_color(href_list["icon"],"ter"))
			_color["ter"] = href_list["icon"]
	if (href_list["choice"] == "Quaternary color")
		if (href_list["icon"] == "none")
			_color["quart"] = "none"
		else if (is_a_color(href_list["icon"],"quart"))
			_color["quart"] = href_list["icon"]

	if (href_list["choice"] == "decals")
		if (is_a_decal(href_list["icon"]))
			decals[href_list["icon"]] = (decals[href_list["icon"]] == 0)

	src.add_fingerprint(usr)
	update_icon()

	return 1


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

	_color["prim"] = "orange"
	decals["plasma"] = 1
	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()
	..()

	_color["prim"] = "blue"
	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()
	..()

	_color["prim"] = "redws"
	var/datum/gas/sleeping_agent/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


//Dirty way to fill room with gas. However it is a bit easier to do than creating some floor/engine/n2o -rastaf0
/obj/machinery/portable_atmospherics/canister/sleeping_agent/roomfiller/New()
	..()
	var/datum/gas/sleeping_agent/trace_gas = air_contents.trace_gases[1]
	trace_gas.moles = 9*4000
	spawn(100)
		var/turf/simulated/location = src.loc
		if (istype(src.loc))
			while (!location.air)
				sleep(1000)
			location.assume_air(air_contents)
			air_contents = new
	return 1


/obj/machinery/portable_atmospherics/canister/nitrogen/New()
	..()

	_color["prim"] = "red"
	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()
	..()

	_color["prim"] = "black"
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()
	..()

	_color["prim"] = "grey"
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/custom_mix/New()
	..()

	_color["prim"] = "whiters"
	src.update_icon() // Otherwise new canisters do not have their icon updated with the pressure light, likely want to add this to the canister class constructor, avoiding at current time to refrain from screwing up code for other canisters. --DZD
	return 1

/obj/machinery/portable_atmospherics/canister/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)

	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	user << "<span class='notice'>You start to slice away at \the [src]...</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 50))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0
