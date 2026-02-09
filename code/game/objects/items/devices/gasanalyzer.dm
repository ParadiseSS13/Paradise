/obj/item/analyzer
	name = "analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	inhand_icon_state = "analyzer"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throw_speed = 3
	materials = list(MAT_METAL = 210, MAT_GLASS = 140)
	origin_tech = "magnets=1;engineering=1"
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.
	/// FALSE: Sum gas mixes then present. TRUE: Present each mix individually
	var/show_detailed = FALSE

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("Alt-click [src] to activate the barometer function.")
	. += SPAN_NOTICE("Alt-Shift-click [src] to toggle detailed reporting on or off.")

/obj/item/analyzer/attack_self__legacy__attackchain(mob/user as mob)

	if(user.stat)
		return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	atmos_scan(user = user, target = location, detailed = show_detailed)
	add_fingerprint(user)

/obj/item/analyzer/AltShiftClick(mob/user)
	show_detailed = !show_detailed
	to_chat(user, SPAN_NOTICE("You toggle detailed reporting [show_detailed ? "on" : "off"]"))

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	..()

	if(!user.incapacitated() && Adjacent(user))

		if(cooldown)
			to_chat(user, SPAN_WARNING("[src]'s barometer function is preparing itself."))
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, SPAN_WARNING("[src]'s barometer function won't work indoors!"))
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && is_type_in_list(user_area, W.area_types) && !(W.stage == WEATHER_END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == WEATHER_MAIN_STAGE) || (ongoing_weather.stage == WEATHER_WIND_DOWN_STAGE))
				to_chat(user, SPAN_WARNING("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == WEATHER_MAIN_STAGE ? "already here!" : "winding down."]"))
				return

			to_chat(user, SPAN_NOTICE("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
			if(ongoing_weather.aesthetic)
				to_chat(user, SPAN_WARNING("[src]'s barometer function says that the next storm will breeze on by."))
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, SPAN_WARNING("[src]'s barometer function was unable to trace any weather patterns."))
			else
				to_chat(user, SPAN_WARNING("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(ping)), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, SPAN_NOTICE("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy * (1 / 3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1, amount))

/obj/item/analyzer/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	. = ..()
	if(!can_see(user, target, 1))
		return
	if(target.return_analyzable_air())
		atmos_scan(user, target, detailed = show_detailed)
	else
		atmos_scan(user, get_turf(target), detailed = show_detailed)

/**
 * Outputs a message to the user describing the target's gasmixes.
 * Used in chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent = FALSE, print = TRUE, milla_turf_details = FALSE, detailed = FALSE)
	var/list/airs
	var/list/milla = null
	if(milla_turf_details && istype(target, /turf))
		// This is one of the few times when it's OK to call MILLA directly, as we need more information than we normally keep, aren't trying to modify it, and don't need it to be synchronized with anything.
		milla = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(target, milla)

		var/datum/gas_mixture/air = new()
		air.copy_from_milla(milla)
		airs = list(air)
	else
		airs = target.return_analyzable_air()
		if(!airs)
			return FALSE
		if(!islist(airs))
			airs = list(airs)

	var/list/message = list()
	if(!silent && isliving(user))
		user.visible_message(SPAN_NOTICE("[user] uses the analyzer on [target]."), SPAN_NOTICE("You use the analyzer on [target]."))
	message += SPAN_BOLDNOTICE("Results of analysis of [bicon(target)] [target].")

	if(!print)
		return TRUE
	var/total_moles = 0
	var/pressure = 0
	var/volume = 0
	var/heat_capacity = 0
	var/thermal_energy = 0
	var/oxygen = 0
	var/nitrogen = 0
	var/toxins
	var/carbon_dioxide = 0
	var/sleeping_agent = 0
	var/agent_b = 0
	var/hydrogen = 0
	var/water_vapor = 0

	if(detailed)// Present all mixtures one by one
		for(var/datum/gas_mixture/air as anything in airs)
			total_moles = air.total_moles()
			pressure = air.return_pressure()
			volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
			heat_capacity = air.heat_capacity()
			thermal_energy = air.thermal_energy()
			if(total_moles)
				message += SPAN_NOTICE("Total: [round(total_moles, 0.01)] moles")
				if(air.oxygen() && (milla_turf_details || air.oxygen() / total_moles > 0.01))
					message += "  [SPAN_OXYGEN("Oxygen: [round(air.oxygen(), 0.01)] moles ([round(air.oxygen() / total_moles * 100, 0.01)] %)")]"
				if(air.nitrogen() && (milla_turf_details || air.nitrogen() / total_moles > 0.01))
					message += "  [SPAN_NITROGEN("Nitrogen: [round(air.nitrogen(), 0.01)] moles ([round(air.nitrogen() / total_moles * 100, 0.01)] %)")]"
				if(air.carbon_dioxide() && (milla_turf_details || air.carbon_dioxide() / total_moles > 0.01))
					message += "  [SPAN_CARBON_DIOXIDE("Carbon Dioxide: [round(air.carbon_dioxide(), 0.01)] moles ([round(air.carbon_dioxide() / total_moles * 100, 0.01)] %)")]"
				if(air.toxins() && (milla_turf_details || air.toxins() / total_moles > 0.01))
					message += "  [SPAN_PLASMA("Plasma: [round(air.toxins(), 0.01)] moles ([round(air.toxins() / total_moles * 100, 0.01)] %)")]"
				if(air.sleeping_agent() && (milla_turf_details || air.sleeping_agent() / total_moles > 0.01))
					message += "  [SPAN_SLEEPING_AGENT("Nitrous Oxide: [round(air.sleeping_agent(), 0.01)] moles ([round(air.sleeping_agent() / total_moles * 100, 0.01)] %)")]"
				if(air.agent_b() && (milla_turf_details || air.agent_b() / total_moles > 0.01))
					message += "  [SPAN_AGENT_B("Agent B: [round(air.agent_b(), 0.01)] moles ([round(air.agent_b() / total_moles * 100, 0.01)] %)")]"
				if(air.hydrogen() && (milla_turf_details || air.hydrogen() / total_moles > 0.01))
					message += "  [SPAN_HYDROGEN("Hydrogen: [round(air.hydrogen(), 0.01)] moles ([round(air.hydrogen() / total_moles * 100, 0.01)] %)")]"
				if(air.water_vapor() && (milla_turf_details || air.water_vapor() / total_moles > 0.01))
					message += "  [SPAN_WATER_VAPOR("Water Vapor: [round(air.water_vapor(), 0.01)] moles ([round(air.water_vapor() / total_moles * 100, 0.01)] %)")]"
				message += SPAN_NOTICE("Temperature: [round(air.temperature()-T0C)] &deg;C ([round(air.temperature())] K)")
				message += SPAN_NOTICE("Volume: [round(volume)] Liters")
				message += SPAN_NOTICE("Pressure: [round(pressure, 0.1)] kPa")
				message += SPAN_NOTICE("Heat Capacity: [DisplayJoules(heat_capacity)] / K")
				message += SPAN_NOTICE("Thermal Energy: [DisplayJoules(thermal_energy)]")
			else
				message += SPAN_NOTICE("[target] is empty!")
				message += SPAN_NOTICE("Volume: [round(volume)] Liters") // don't want to change the order volume appears in, suck it

	else// Sum mixtures then present
		for(var/datum/gas_mixture/air as anything in airs)
			if(isnull(air))
				continue
			total_moles += air.total_moles()
			volume += air.return_volume()
			heat_capacity += air.heat_capacity()
			thermal_energy += air.thermal_energy()
			oxygen += air.oxygen()
			nitrogen += air.nitrogen()
			toxins += air.toxins()
			carbon_dioxide += air.carbon_dioxide()
			sleeping_agent += air.sleeping_agent()
			agent_b += air.agent_b()
			hydrogen += air.hydrogen()
			water_vapor += air.water_vapor()

		var/temperature = heat_capacity ? thermal_energy / heat_capacity : 0
		pressure = volume ? total_moles * R_IDEAL_GAS_EQUATION * temperature / volume : 0

		if(total_moles)
			message += SPAN_NOTICE("Total: [round(total_moles, 0.01)] moles")
			if(oxygen && (milla_turf_details || oxygen / total_moles > 0.01))
				message += "  [SPAN_OXYGEN("Oxygen: [round(oxygen, 0.01)] moles ([round(oxygen / total_moles * 100, 0.01)] %)")]"
			if(nitrogen && (milla_turf_details || nitrogen / total_moles > 0.01))
				message += "  [SPAN_NITROGEN("Nitrogen: [round(nitrogen, 0.01)] moles ([round(nitrogen / total_moles * 100, 0.01)] %)")]"
			if(carbon_dioxide && (milla_turf_details || carbon_dioxide / total_moles > 0.01))
				message += "  [SPAN_CARBON_DIOXIDE("Carbon Dioxide: [round(carbon_dioxide, 0.01)] moles ([round(carbon_dioxide / total_moles * 100, 0.01)] %)")]"
			if(toxins && (milla_turf_details || toxins / total_moles > 0.01))
				message += "  [SPAN_PLASMA("Plasma: [round(toxins, 0.01)] moles ([round(toxins / total_moles * 100, 0.01)] %)")]"
			if(sleeping_agent && (milla_turf_details || sleeping_agent / total_moles > 0.01))
				message += "  [SPAN_SLEEPING_AGENT("Nitrous Oxide: [round(sleeping_agent, 0.01)] moles ([round(sleeping_agent / total_moles * 100, 0.01)] %)")]"
			if(agent_b && (milla_turf_details || agent_b / total_moles > 0.01))
				message += "  [SPAN_AGENT_B("Agent B: [round(agent_b, 0.01)] moles ([round(agent_b / total_moles * 100, 0.01)] %)")]"
			if(hydrogen && (milla_turf_details || hydrogen / total_moles > 0.01))
				message += "  [SPAN_HYDROGEN("Hydrogen: [round(hydrogen, 0.01)] moles ([round(hydrogen / total_moles * 100, 0.01)] %)")]"
			if(water_vapor && (milla_turf_details || (water_vapor / total_moles > 0.01)))
				message += "  [SPAN_WATER_VAPOR("Water Vapor: [round(water_vapor, 0.01)] moles ([round(water_vapor / total_moles * 100, 0.01)] %)")]"
			message += SPAN_NOTICE("Temperature: [round(temperature-T0C)] &deg;C ([round(temperature)] K)")
			message += SPAN_NOTICE("Volume: [round(volume)] Liters")
			message += SPAN_NOTICE("Pressure: [round(pressure, 0.1)] kPa")
			message += SPAN_NOTICE("Heat Capacity: [DisplayJoules(heat_capacity)] / K")
			message += SPAN_NOTICE("Thermal Energy: [DisplayJoules(thermal_energy)]")
		else
			message += SPAN_NOTICE("[target] is empty!")
			message += SPAN_NOTICE("Volume: [round(volume)] Liters") // don't want to change the order volume appears in, suck it

	if(milla)
		// Values from milla/src/lib.rs, +1 due to array indexing difference.
		message += SPAN_NOTICE("Airtight N/E/S/W: [(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_NORTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_EAST) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_SOUTH) ? "yes" : "no"]/[(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & MILLA_WEST) ? "yes" : "no"]")
		switch(milla[MILLA_INDEX_ATMOS_MODE])
			// These are enum values, so they don't get increased.
			if(0)
				message += SPAN_NOTICE("Atmos Mode: Space")
			if(1)
				message += SPAN_NOTICE("Atmos Mode: Sealed")
			if(2)
				message += SPAN_NOTICE("Atmos Mode: Exposed to Environment (ID: [milla[MILLA_INDEX_ENVIRONMENT_ID]])")
			else
				message += SPAN_NOTICE("Atmos Mode: Unknown ([milla[MILLA_INDEX_ATMOS_MODE]]), contact a coder.")
		message += SPAN_NOTICE("Superconductivity N/E/S/W: [milla[MILLA_INDEX_SUPERCONDUCTIVITY_NORTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_EAST]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH]]/[milla[MILLA_INDEX_SUPERCONDUCTIVITY_WEST]]")
		message += SPAN_NOTICE("Turf's Innate Heat Capacity: [milla[MILLA_INDEX_INNATE_HEAT_CAPACITY]]")
		message += SPAN_NOTICE("Hotspot: [floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE]-T0C)] &deg;C ([floor(milla[MILLA_INDEX_HOTSPOT_TEMPERATURE])] K), [round(milla[MILLA_INDEX_HOTSPOT_VOLUME] * CELL_VOLUME, 1)] Liters ([milla[MILLA_INDEX_HOTSPOT_VOLUME]]x)")
		message += SPAN_NOTICE("Wind: ([round(milla[MILLA_INDEX_WIND_X], 0.001)], [round(milla[MILLA_INDEX_WIND_Y], 0.001)])")
		message += SPAN_NOTICE("Fuel burnt last tick: [milla[MILLA_INDEX_FUEL_BURNT]] moles")

	to_chat(user, chat_box_examine(message.Join("<br>")))
	return TRUE
