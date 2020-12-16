#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BACK
	hitsound = 'sound/weapons/smash.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	actions_types = list(/datum/action/item_action/set_internals)
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	var/integrity = 3
	var/volume = 70

/obj/item/tank/New()
	..()

	air_contents = new /datum/gas_mixture()
	air_contents.volume = volume //liters
	air_contents.temperature = T20C
	START_PROCESSING(SSobj, src)
	return

/obj/item/tank/Destroy()
	QDEL_NULL(air_contents)

	STOP_PROCESSING(SSobj, src)

	return ..()


/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/proc/toggle_internals(mob/user, silent = FALSE)
	var/mob/living/carbon/C = user
	if(!istype(C))
		return FALSE

	if(C.internal == src)
		to_chat(C, "<span class='notice'>You close \the [src] valve.</span>")
		C.internal = null
	else
		if(!C.get_organ_slot("breathing_tube")) // Breathing tubes can always use internals, if they have one, skip ahead and turn internals on/off
			if(!C.wear_mask) // Do we have a mask equipped?
				return FALSE

			var/obj/item/clothing/mask/M = C.wear_mask
			// If the "mask" isn't actually a mask OR That mask isn't internals compatible AND Their headgear isn't internals compatible
			if(!istype(M) || (!(initial(M.flags) & AIRTIGHT) && !(C.head && C.head.flags & AIRTIGHT)))
				if(!silent)
					to_chat(C, "<span class='warning'>You are not wearing a suitable mask or helmet.</span>")
				return FALSE
			if(M.mask_adjusted) // If the mask is equipped but pushed down
				M.adjustmask(C) // Adjust it back

		if(!silent)
			if(C.internal)
				to_chat(C, "<span class='notice'>You switch your internals to [src].</span>")
			else
				to_chat(C, "<span class='notice'>You open \the [src] valve.</span>")
		C.internal = src
	C.update_action_buttons_icon()


/obj/item/tank/examine(mob/user)
	. = ..()

	var/obj/icon = src
	if(istype(loc, /obj/item/assembly))
		icon = loc

	if(!in_range(src, user))
		if(icon == src)
			. += "<span class='notice'>It's \a [bicon(icon)][src]! If you want any more information you'll need to get closer.</span>"
		return

	var/celsius_temperature = air_contents.temperature-T0C
	var/descriptive

	if(celsius_temperature < 20)
		descriptive = "cold"
	else if(celsius_temperature < 40)
		descriptive = "room temperature"
	else if(celsius_temperature < 80)
		descriptive = "lukewarm"
	else if(celsius_temperature < 100)
		descriptive = "warm"
	else if(celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	. += "<span class='notice'>\The [bicon(icon)][src] feels [descriptive]</span>"

/obj/item/tank/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		var/turf/location = get_turf(src)
		if(!location)
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(air_contents)
			air_update_turf()
		playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	qdel(src)

/obj/item/tank/attackby(obj/item/W as obj, mob/user as mob, params)
	..()

	add_fingerprint(user)
	if(istype(loc, /obj/item/assembly))
		icon = loc

	if((istype(W, /obj/item/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)

	if(istype(W, /obj/item/assembly_holder))
		bomb_assemble(W,user)

/obj/item/tank/attack_self(mob/user as mob)
	if(!(air_contents))
		return

	ui_interact(user)

/obj/item/tank/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Tank",  name, 300, 150, master_ui, state)
		ui.open()

/obj/item/tank/ui_data(mob/user)
	var/list/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(!istype(C))
		return data
	data["has_mask"] = C.wear_mask ? TRUE : FALSE
	data["connected"] = (C.internal && C.internal == src) ? TRUE : FALSE
	return data

/obj/item/tank/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
			else if(pressure == "min")
				pressure = TANK_DEFAULT_RELEASE_PRESSURE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
			else
				. = FALSE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_DEFAULT_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)
		if("internals")
			toggle_internals(usr)
		else
			. = FALSE
	if(.)
		add_fingerprint(usr)

/obj/item/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/tank/return_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()


/obj/item/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(loc,/obj/item/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [fingerprintslast] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
			log_game("Explosive tank rupture! last key to touch the tank was [fingerprintslast] at [x], [y], [z]")
//		to_chat(world, "<span class='notice'>[x],[y] tank is exploding: [pressure] kPa</span>")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)

//		to_chat(world, "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>")

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(loc,/obj/item/transfer_valve))
			qdel(loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE)
//		to_chat(world, "<span class='notice'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
//		to_chat(world, "<span class='notice'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
