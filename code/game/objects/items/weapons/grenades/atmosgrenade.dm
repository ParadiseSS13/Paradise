


/obj/item/weapon/grenade/gas
	name = "Plasma Fire Grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	origin_tech = "materials=3;magnets=4;syndicate=4"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	var/gas_type = "fire"
	var/max_spread_turfs = 20
	var/gas_debug = 0

/obj/item/weapon/grenade/gas/overpressure
	name = "Overpressure Grenade"
	desc = "A compressed gas grenade, used to create crushing pressure in an area."
	gas_type = "overpressure"

/obj/item/weapon/grenade/gas/suffocation
	name = "Suffocation Grenade"
	desc = "An oxygen depletion grenade, used to ensure anyone entering the target area quickly suffocates."
	gas_type = "suffocation"

/obj/item/weapon/grenade/gas/vacuum
	name = "Vacuum Grenade"
	desc = "A grenade that completely removes all air and heat from its detonation area."
	gas_type = "vacuum"

/obj/item/weapon/grenade/gas/knockout
	name = "Knockout Grenade"
	desc = "A grenade that completely removes all air and heat from its detonation area."
	gas_type = "knockout"

/obj/item/weapon/grenade/gas/prime()
	var/turf/simulated/origin = get_turf(src)
	var/list/spread_turfs = list()
	var/list/scan_turfs = list()

	if(!istype(origin))
		// Error, unsimulated turf.
		qdel(src)
		return

	scan_turfs += origin

	while(spread_turfs.len < max_spread_turfs && scan_turfs.len)
		if(gas_debug)
			visible_message("[src] loops: [spread_turfs.len] turfs, [scan_turfs.len] to scan!")
		var/turf/scan_from = pick(scan_turfs)
		var/list/adj = 	scan_from.GetAtmosAdjacentTurfs(1)
		for(var/turf/simulated/C in adj)
			if(!(C in scan_turfs) && C.CanAtmosPass(C))
				scan_turfs += C
		spread_turfs += scan_from
		scan_turfs -= scan_from

	if(!spread_turfs.len)
		visible_message("<span class='notice'>[src] detonates harmlessly in the airless space.</span>")
		qdel(src)
	else
		if(gas_debug)
			visible_message("[src] affects [spread_turfs.len] turfs, with [scan_turfs.len] left to scan!")
		for(var/turf/simulated/target_turf in spread_turfs)
			switch(gas_type)
				if("fire")
					target_turf.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 200) // works well
				if("overpressure")
					target_turf.atmos_spawn_air(SPAWN_20C | SPAWN_NITROGEN, 2000) // kills slowly, but hard to deal with
				if("suffocation")
					target_turf.atmos_spawn_air(SPAWN_20C | SPAWN_CO2, target_turf.air.oxygen) // knocks out slowly, kills
					target_turf.atmos_spawn_air(SPAWN_20C | SPAWN_OXYGEN, target_turf.air.oxygen * -1)
				if("knockout")
					target_turf.atmos_spawn_air(SPAWN_20C | SPAWN_N2O, 100) // knocks out quickly
				if("vacuum")
					target_turf.air.nitrogen = 0
					target_turf.air.oxygen = 0
					target_turf.air.nitrogen = 0
					air_master.add_to_active(target_turf, 0)
			var/obj/machinery/alarm/air_alarm = locate(/obj/machinery/alarm/) in target_turf
			if(istype(air_alarm))
				// break the alarm off the wall
				air_alarm.visible_message("[air_alarm] breaks from the rapid change in pressure!")
				playsound(air_alarm.loc, 'sound/effects/sparks4.ogg', 50, 1)
				new /obj/item/mounted/frame/alarm_frame(air_alarm.loc)
				qdel(air_alarm)
			var/obj/machinery/atmospherics/unary/vent_pump/v = locate(/obj/machinery/atmospherics/unary/vent_pump) in target_turf
			if(istype(v))
				v.welded = 1
				v.update_icon()
				v.visible_message("<span class='danger'>[v] is broken by the rapid pressure change!</span>")
			var/obj/machinery/atmospherics/unary/vent_scrubber/s = locate(/obj/machinery/atmospherics/unary/vent_scrubber) in target_turf
			if(istype(s))
				s.welded = 1
				s.update_icon()
				s.visible_message("<span class='danger'>[s] is broken by the rapid pressure change!</span>")
			target_turf.air_update_turf()
		visible_message("<span class='userdanger'>[src] detonates!</span>")
		qdel(src)