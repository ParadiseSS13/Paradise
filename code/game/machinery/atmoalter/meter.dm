/obj/machinery/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"

	layer = GAS_PUMP_LAYER

	var/obj/machinery/atmospherics/pipe/target = null
	anchored = TRUE
	max_integrity = 150
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 0)
	power_channel = ENVIRON
	frequency = ATMOS_DISTRO_FREQ
	var/id
	var/id_tag
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 5
	req_one_access_txt = "24;10"

/obj/machinery/meter/New()
	..()
	SSair.atmos_machinery += src
	target = locate(/obj/machinery/atmospherics/pipe) in loc
	if(id && !id_tag)//i'm not dealing with further merge conflicts, fuck it
		id_tag = id
	return 1

/obj/machinery/meter/Destroy()
	SSair.atmos_machinery -= src
	target = null
	return ..()

/obj/machinery/meter/Initialize()
	..()
	if(!target)
		target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/process_atmos()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/datum/radio_frequency/radio_connection = SSradio.return_frequency(frequency)

		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id_tag,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/proc/status()
	var/t = ""
	if(target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]&deg;K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."
	return t

/obj/machinery/meter/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead)))
		. += "<span class='boldnotice'>You are too far away to read it.</span>"

	else if(stat & (NOPOWER|BROKEN))
		. += "<span class='danger'>The display is off.</span>"

	else if(target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			. += "<span class='notice'>The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C).</span>"
		else
			. += "<span class='warning'>The sensor error light is blinking.</span>"
	else
		. += "<span class='warning'>The connect error light is blinking.</span>"

/obj/machinery/meter/Click()
	if(istype(usr, /mob/living/silicon/ai)) // ghosts can call ..() for examine
		usr.examinate(src)
		return 1

	return ..()

/obj/machinery/meter/wrench_act(mob/user, obj/item/I)
	. = TRUE
	playsound(loc, I.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten [src]...</span>")
	if(do_after(user, 40 * I.toolspeed * gettoolspeedmod(user), target = src))
		user.visible_message( \
			"[user] unfastens [src].", \
			"<span class='notice'>You have unfastened [src].</span>", \
			"You hear ratchet.")
		deconstruct(TRUE)

/obj/machinery/meter/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	qdel(src)

/obj/machinery/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/New()
	..()
	target = loc
	return 1


/obj/machinery/meter/turf/Initialize()
	if(!target)
		target = loc
	..()

/obj/machinery/meter/turf/attackby(var/obj/item/W as obj, var/mob/user as mob, params)
	return
