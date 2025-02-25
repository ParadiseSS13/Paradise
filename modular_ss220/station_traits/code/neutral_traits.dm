/datum/station_trait/darkness
	name = "Electricity Saving"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Предыдущая смена позаботилась об экономии энергии перед уходом."
	blacklist = list(/datum/station_trait/rave)

/datum/station_trait/darkness/on_round_start()
	. = ..()
	for(var/obj/machinery/light_switch/light_switch in GLOB.machines)
		var/turf/our_turf = get_turf(light_switch)
		if(!is_station_level(our_turf.z))
			continue

		var/area/switch_area = get_area(light_switch)
		switch_area.lightswitch = FALSE
		light_switch.update_icon(UPDATE_ICON)

		for(var/obj/machinery/light/light in switch_area)
			light.power_change()

		for(var/obj/item/flashlight/lamp/lamp in switch_area)
			lamp.on = FALSE
			lamp.update_brightness()

		for(var/turf/simulated/floor/light/floor_light in switch_area)
			floor_light.toggle_light(FALSE)
