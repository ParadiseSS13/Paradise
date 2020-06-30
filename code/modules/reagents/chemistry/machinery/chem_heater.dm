/obj/machinery/chem_heater
	name = "chemical heater"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/obj/item/reagent_containers/beaker = null
	var/desired_temp = T0C
	var/on = FALSE

/obj/machinery/chem_heater/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_heater(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	if(on)
		if(beaker)
			if(!beaker.reagents.total_volume)
				on = FALSE
				return
			beaker.reagents.temperature_reagents(desired_temp)
			beaker.reagents.temperature_reagents(desired_temp)
			if(abs(beaker.reagents.chem_temp - desired_temp) <= 3)
				on = FALSE

/obj/machinery/chem_heater/proc/eject_beaker(mob/user)
	if(beaker)
		beaker.forceMove(get_turf(src))
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(beaker)
		beaker = null
		icon_state = "mixer0b"
		on = FALSE

/obj/machinery/chem_heater/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user)
	if(isrobot(user))
		return

	if(istype(I, /obj/item/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='notice'>A beaker is already loaded into the machine.</span>")
			return

		if(user.drop_item())
			beaker = I
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
			icon_state = "mixer1b"
			return

	if(exchange_parts(user, I))
		return

	return ..()

/obj/machinery/chem_heater/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/chem_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I)

/obj/machinery/chem_heater/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	eject_beaker()
	default_deconstruction_crowbar(user, I)

/obj/machinery/chem_heater/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/chem_heater/attack_ghost(mob/user)
	if(user.can_admin_interact())
		return attack_hand(user)

/obj/machinery/chem_heater/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/chem_heater/tgui_act(action, params)
	if(..())
		return

	switch(action)
		if("toggle_on")
			on = !on
			return TRUE
		if("adjust_temperature")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				desired_temp = clamp(target, 0, 1000)
		if("eject_beaker")
			eject_beaker(usr)
			return TRUE

/obj/machinery/chem_heater/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	if(user.stat || user.restrained())
		return

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemHeater", name, 350, 270, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/chem_heater/tgui_data(mob/user)
	var/data[0]

	data["hasPower"] = !(stat & NOPOWER)

	data["targetTemp"] = desired_temp
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	//copy-pasted from chem dispenser
	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	return data
