/obj/machinery/chem_heater
	name = "chemical heater"
	desc = "A simple machine that uses a heat exchanger to adjust the temperature of a mixture. Despite the name, it's also capable of cooling. This feature is unpopular with hipsters, as they preferred the chemicals before they were cool."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	idle_power_consumption = 40
	resistance_flags = FIRE_PROOF|ACID_PROOF

	var/obj/item/reagent_containers/beaker = null
	var/desired_temp = T0C
	var/on = FALSE
	/// Whether this should auto-eject the beaker once done heating/cooling.
	var/auto_eject = FALSE
	/// The higher this number, the faster reagents will heat/cool.
	var/speed_increase = 40

/obj/machinery/chem_heater/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_heater(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/chem_heater/RefreshParts()
	speed_increase = initial(speed_increase)
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		speed_increase += 20 * (M.rating - 1)

/obj/machinery/chem_heater/process()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(on)
		if(beaker)
			if(!beaker.reagents.total_volume)
				on = FALSE
				return
			var/sign = SIGN(desired_temp - beaker.reagents.chem_temp)
			beaker.reagents.adjust_reagent_temp(speed_increase * sign, desired_temp)
			if(round(beaker.reagents.chem_temp) == round(desired_temp))
				playsound(loc, 'sound/machines/ding.ogg', 50, 1)
				on = FALSE
				if(auto_eject)
					eject_beaker()

/obj/machinery/chem_heater/proc/eject_beaker(mob/user)
	if(beaker)
		beaker.forceMove(get_turf(src))
		if(user && Adjacent(user) && !issilicon(user))
			user.put_in_hands(beaker)
		beaker = null
		icon_state = "mixer0b"
		on = FALSE
		SStgui.update_uis(src)

/obj/machinery/chem_heater/power_change()
	if(has_power())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/chem_heater/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/glass) && user.a_intent != INTENT_HARM)
		if(beaker)
			to_chat(user, "<span class='notice'>A beaker is already loaded into the machine.</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[used] is stuck to you!</span>")
			return ITEM_INTERACT_COMPLETE

		beaker = used
		used.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		icon_state = "mixer1b"
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/chem_heater/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/chem_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "mixer0b", "mixer[beaker ? "1" : "0"]b", I)

/obj/machinery/chem_heater/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	eject_beaker()
	default_deconstruction_crowbar(user, I)

/obj/machinery/chem_heater/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/chem_heater/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/chem_heater/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(action)
		if("toggle_on")
			on = !on
		if("adjust_temperature")
			desired_temp = clamp(text2num(params["target"]), 0, 1000)
		if("eject_beaker")
			eject_beaker(usr)
			. = FALSE
		if("toggle_autoeject")
			auto_eject = !auto_eject
		else
			return FALSE
	add_fingerprint(usr)

/obj/machinery/chem_heater/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui = null)
	if(user.stat || user.restrained())
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", "Chemical Heater")
		ui.open()

/obj/machinery/chem_heater/ui_data(mob/user)
	var/data[0]
	var/cur_temp = beaker ? beaker.reagents.chem_temp : null

	data["targetTemp"] = desired_temp
	data["targetTempReached"] = FALSE
	data["autoEject"] = auto_eject
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? TRUE : FALSE

	data["currentTemp"] = cur_temp
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	if(cur_temp)
		data["targetTempReached"] = round(cur_temp) == round(desired_temp)

	//copy-pasted from chem dispenser
	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	return data
