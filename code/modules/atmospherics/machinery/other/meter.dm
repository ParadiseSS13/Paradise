GLOBAL_LIST_EMPTY(gas_meters)

/obj/machinery/atmospherics/meter
	name = "gas flow meter"
	desc = "A meter used by experienced atmospheric technicians to determine pressure and temperature in a pipe."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PUMP_OFFSET
	layer_offset = GAS_PUMP_OFFSET
	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 40, ACID = 0)
	power_state = IDLE_POWER_USE
	idle_power_consumption = 2
	active_power_consumption = 5
	var/obj/machinery/atmospherics/pipe/target = null

/obj/machinery/atmospherics/meter/Initialize(mapload)
	. = ..()
	GLOB.gas_meters += src
	target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/atmospherics/meter/Destroy()
	target = null
	GLOB.gas_meters -= src
	return ..()

/obj/machinery/atmospherics/meter/process_atmos()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/meter/update_icon_state()
	if(!target)
		icon_state = "meterX"
		return

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return

	var/datum/gas_mixture/environment = target.return_obj_air()
	if(!environment)
		icon_state = "meterX"
		return

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

/obj/machinery/atmospherics/meter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Measures the volume and temperature of the pipe under the meter.</span>"
	if(get_dist(user, src) > 3 && !(is_ai(user) || istype(user, /mob/dead)))
		. += "<span class='boldnotice'>You are too far away to read it.</span>"

	else if(stat & (NOPOWER|BROKEN))
		. += "<span class='danger'>The display is off.</span>"

	else if(target)
		var/datum/gas_mixture/environment = target.return_obj_air()
		if(environment)
			. += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature(), 0.01)]K ([round(environment.temperature() - T0C, 0.01)]&deg;C)"
		else
			. += "The sensor error light is blinking."
	else
		. += "The connect error light is blinking."

/obj/machinery/atmospherics/meter/Click()
	if(is_ai(usr)) // ghosts can call ..() for examine
		usr.examinate(src)
		return TRUE

	return ..()

/obj/machinery/atmospherics/meter/wrench_act(mob/living/user, obj/item/wrench/W)
	// don't call parent here, we're kind of different
	to_chat(user, "<span class='notice'>You begin to unfasten [src]...</span>")
	if(!W.use_tool(src, user, volume = W.tool_volume))
		return

	user.visible_message(
		"[user] unfastens [src].",
		"<span class='notice'>You have unfastened [src].</span>",
		"You hear ratchet."
	)
	deconstruct(TRUE)
	return TRUE

/obj/machinery/atmospherics/meter/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	qdel(src)

/obj/machinery/atmospherics/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()


/obj/machinery/atmospherics/meter/multitool_act(mob/living/user, obj/item/I)
	if(!ismultitool(I))
		return

	var/obj/item/multitool/M = I
	M.buffer_uid = UID()
	to_chat(user, "<span class='notice'>You save [src] into [M]'s buffer</span>")
