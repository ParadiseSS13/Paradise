//For my sanity :))

#define COOLANT_INPUT_GATE air1
#define MODERATOR_INPUT_GATE air2
#define COOLANT_OUTPUT_GATE air3

#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_CRITICAL 800 //At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_MELTDOWN 900

#define RBMK_NO_COOLANT_TOLERANCE 5 //How many process()ing ticks the reactor can sustain without coolant before slowly taking damage

#define RBMK_PRESSURE_OPERATING 1000 //PSI
#define RBMK_PRESSURE_CRITICAL 1469.59 //PSI

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER 8000 //To turn those KWs into something usable

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

/**

What is this?

Moderators list (try to keep accurate):
Fuel Type:
Oxygen: Power production multiplier. Allows you to run a low plasma, high oxy mix, and still get a lot of power.
Plasma: Power production gas. More plasma -> more power, but it enriches your fuel and makes the reactor much, much harder to control.

Moderation Type:
N2: Helps you regain control of the reaction by increasing control rod effectiveness, will massively boost the rad production of the reactor.
CO2: Super effective shutdown gas for runaway reactions. MASSIVE RADIATION PENALTY!

Permeability Type:
N2O: Increases your reactor's ability to transfer its heat to the coolant, thus letting you cool it down faster (but your output will get hotter)

Depletion type:
Agent B: When you need weapons grade plutonium yesterday. Causes your fuel to deplete much, much faster. Not a huge amount of use outside of sabotage.

Sabotage:

Meltdown:
Flood reactor moderator with plasma, they won't be able to mitigate the reaction with control rods.
Shut off coolant entirely. Raise control rods.
Swap all fuel out with spent fuel, as it's way stronger.

Blowout:
Shut off exit valve for quick overpressure.
Cause a pipefire in the coolant line (LETHAL).
Tack heater onto coolant line (can also cause straight meltdown)

Tips:
Be careful to not exhaust your plasma supply. I recommend you DON'T max out the moderator input when youre running plasma + o2, or you're at a tangible risk of running out of those gasses from atmos.
The reactor CHEWS through moderator. It does not do this slowly. Be very careful with that!

*/

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

//Helper proc to set a new looping ambience, and play it to any mobs already inside of that area.

/area/proc/set_looping_ambience(sound)
	if(ambient_buzz == sound)
		return FALSE
	ambient_buzz = sound
	var/list/affecting = list() //Which mobs are we about to transmit to?
	if(!affecting.len) //OK, we can't get away with the cheaper check.
		for(var/mob/L in src) //This is really really expensive, please use this proc on non-overmap supported areas sparingly!
			if(!istype(L))
				continue
			affecting += L
	for(var/mob/L in affecting)
		if(L.client && L.client?.last_ambience != ambient_buzz)
			SEND_SOUND(L, sound(ambient_buzz, repeat = 1, wait = 0, volume = 100, channel = CHANNEL_BUZZ))
			L.client.last_ambience = ambient_buzz
	return TRUE

/obj/machinery/atmospherics/trinary/nuclear_reactor
	name = "\improper Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'icons/obj/rbmk.dmi'
	icon_state = "reactor_map"
	pixel_x = -32
	pixel_y = -32
	dir = SOUTH
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	//processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = SOUTH //Less headache inducing :))
	var/rbmkid = "rbmk" //Change me mappers
	//Variables essential to operation
	///Lose control of this -> Meltdown
	var/temperature = 0
	///How long can the reactor withstand overpressure / meltdown? This gives you a fair chance to react to even a massive pipe fire
	var/vessel_integrity = 400
	///should be the same as the previous var
	var/starting_vessel_integrity = 400
	///Lose control of this -> Blowout
	var/pressure = 0
	///Rate of reaction.
	var/K = 0
	///desired rate of reaction.
	var/desired_k = 0
	///Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/control_rod_effectiveness = 0.65
	///0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power = 0
	///Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/power_modifier = 1
	///list of loaded fuel rods
	var/list/fuel_rods = list()
	//Secondary variables.
	///rate of moderator input
	var/gas_absorption_effectiveness = 0.5
	///We refer to this one as it's set on init, randomized.
	var/gas_absorption_constant = 0.5
	///moles of gas required for calculation to occur
	var/minimum_coolant_level = 0.1
	///For logging purposes
	var/last_power_produced = 0
	///Light flicker timer
	var/next_flicker = 0
	var/next_slowprocess = 0
	var/base_power_modifier = RBMK_POWER_FLAVOURISER
	///Is this reactor even usable any more?
	var/slagged = FALSE
	//Console statistics.
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	//For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/last_heat_delta = 0
	//How many times in succession did we not have enough coolant? Decays twice as fast as it accumulates.
	var/no_coolant_ticks = 0
	///used to prevent fuel rod duplicaiton
	var/obj/item/fuel_rod/held_fuel_rod

	// below vars contol emergency alert systems
	var/obj/item/radio/radio
	var/rbmk_warning_delay = 60
	var/lastrbmkwarn = 0
	var/rbmk_safe_alert = "Reactor core returning to safe operating parameters"
	var/rbmk_temp_alert = "Reactor core internal temperature rising above critical levels!"
	var/rbmk_pressure_alert = "Reactor core internal pressure rising above critical levels!"
	var/rbmk_meltdown_alert = "REACTOR MELTDOWN IMMINENT"
	var/rbmk_blowout_alert = "REACTOR BLOWOUT IMMINENT"
	var/temp_damage = 0
	var/pressure_damage = 0

	//used to activate parts of the reactor code for testing
	var/testing = FALSE

// procs to start and stop testing

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/test()
	testing = TRUE

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/endtest()
	testing = FALSE


/obj/machinery/atmospherics/trinary/nuclear_reactor/destroyed
	icon_state = "reactor_slagged"
	slagged = TRUE
	vessel_integrity = 0

/obj/machinery/atmospherics/trinary/nuclear_reactor/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, turn(dir, -90))
		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/nuclear_reactor/examine(mob/user)
	. = ..()
	if(Adjacent(src, user))
		var/percent = vessel_integrity / initial(vessel_integrity) * 100
		var/msg = "<span class='warning'>The reactor looks operational.</span>"
		switch(percent)
			if(0 to 10)
				msg = "<span class='boldwarning'>[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel! </span>"
			if(10 to 40)
				msg = "<span class='boldwarning'>[src]'s seals are heavily warped and cracked! </span>"
			if(40 to 60)
				msg = "<span class='warning'>[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.</span>"
			if(60 to 80)
				msg = "<span class='warning'>[src]'s seals are in-tact, but slightly worn. There are no visible cracks in the reactor vessel.</span>"
			if(80 to 90)
				msg = "<span class='notice'>[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.</span>"
			if(95 to 100)
				msg = "<span class='notice'>[src]'s seals look factory new, and the reactor's in excellent shape.</span>"
		. += msg

//issue with fuel rod remaining after insertion
/obj/machinery/atmospherics/trinary/nuclear_reactor/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/fuel_rod))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot insert fuel into [src] when it has been raised above 20% power.</span>")
			return FALSE
		if(fuel_rods.len >= 5)
			to_chat(user, "<span class='warning'>[src] is already at maximum fuel load.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to insert [W] into [src]...</span>")
		radiation_pulse(src, temperature)
		if(do_after(user, 5 SECONDS, target=src))
			if(!length(fuel_rods))
				start_up() //That was the first fuel rod. Let's heat it up.
			fuel_rods += W
			user.drop_item()
			W.forceMove(src)
			held_fuel_rod = W
			RegisterSignal(W, COMSIG_PARENT_QDELETING, PROC_REF(clear_held_fuel_rod))
			radiation_pulse(src, temperature) //Wear protective equipment when even breathing near a reactor!
		return TRUE
	if(!slagged && istype(W, /obj/item/stack/nanopaste))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot repair [src] while it is running at above 20% power.</span>")
			return FALSE
		if(vessel_integrity >= 350)
			to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
			return FALSE
		if(vessel_integrity <= 0.5 * initial(vessel_integrity)) //Heavily damaged.
			to_chat(user, "<span class='notice'>[src]'s reactor vessel is cracked and worn, you need to repair the cracks with a welder before you can repair the seals.</span>")
			return FALSE
		if(do_after(user, 5 SECONDS, target=src))
			if(vessel_integrity >= 350)	//They might've stacked doafters
				to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
				return FALSE
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			user.visible_message("<span class='warning'>[user] applies sealant to some of [src]'s worn out seals.</span>", "<span class='notice'>You apply sealant to some of [src]'s worn out seals.</span>")
			vessel_integrity += 10
			vessel_integrity = clamp(vessel_integrity, 0, initial(vessel_integrity))
		return TRUE
	return ..()

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/clear_held_fuel_rod()
	UnregisterSignal(held_fuel_rod, COMSIG_PARENT_QDELETING)
	held_fuel_rod = null

/obj/machinery/atmospherics/trinary/nuclear_reactor/welder_act(mob/living/user, obj/item/I)
	if(slagged)
		to_chat(user, "<span class='notice'>You can't repair [src], it's completely slagged!</span>")
		return FALSE
	if(power >= 20)
		to_chat(user, "<span class='notice'>You can't repair [src] while it is running at above 20% power.</span>")
		return FALSE
	if(vessel_integrity > 0.5 * initial(vessel_integrity))
		to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with nanopaste sealant.</span>")
		return FALSE
	if(I.use_tool(src, user, 0, volume=40))
		if(vessel_integrity > 0.5 * initial(vessel_integrity))
			to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with nanopaste sealant.</span>")
			return FALSE
		vessel_integrity += 20
		to_chat(user, "<span class='notice'>You weld together some of [src]'s cracks. This'll do for now.</span>")
	return TRUE

//Admin procs to mess with the reaction environment.

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/lazy_startup()
	slagged = FALSE
	for(var/I=0;I<5;I++)
		fuel_rods += new /obj/item/fuel_rod(src)
	start_up()

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/deplete()
	for(var/obj/item/fuel_rod/FR in fuel_rods)
		FR.depletion = 100

/obj/machinery/atmospherics/trinary/nuclear_reactor/Initialize(mapload)
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.
	initialize_directions = NORTH|WEST|SOUTH|EAST
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Engineering" = 0))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/on_entered(datum/source, atom/movable/AM, oldloc)
	SIGNAL_HANDLER

	if(isliving(AM) && temperature > 0)
		var/mob/living/L = AM
		L.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/has_fuel()
	return length(fuel_rods)

/obj/machinery/atmospherics/trinary/nuclear_reactor/process_atmos()
	. = ..()
	if(slagged)
		STOP_PROCESSING(SSmachines, src)
		return

	if(testing == TRUE)
		to_chat(world,"------ Running Process Atmos ------" )

	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE
	handle_alerts() //Let's check if they're about to die, and let them know.

	if(testing == TRUE)
		to_chat(world,"----- START OF PROC -----")
		to_chat(world,"--- Coolant Input ---")
		to_chat(world,"Total Moles: [coolant_input.total_moles()]" )
		to_chat(world,"Temperature: [coolant_input.return_temperature()]" )
		to_chat(world,"--- Coolant Output ---")
		to_chat(world,"Total Moles: [coolant_output.total_moles()]" )
		to_chat(world,"Temperature: [coolant_output.return_temperature()]" )
		to_chat(world,"--- Moderator Total ---")
		to_chat(world,"Total Moles: [moderator_input.total_moles()]" )
		to_chat(world,"Temperature: [moderator_input.return_temperature()]" )

	//Firstly, heat up the reactor based off of K.
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = KELVIN_TO_CELSIUS(coolant_input.return_temperature())
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 100) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta
		temperature += heat_delta
		coolant_output.temperature = temperature
		last_output_temperature = coolant_output.temperature
		pressure = coolant_output.total_moles() * R_IDEAL_GAS_EQUATION * coolant_output.temperature / coolant_output.volume
		//this line is everything I hate about atmos
		coolant_output.merge(air1) //And now, shove the input into the output.
		coolant_input.remove(coolant_input.total_moles()) //Clear out anything left in the input gate.
		color = null
		no_coolant_ticks = max(0, no_coolant_ticks-2)	//Needs half as much time to recover the ticks than to acquire them
	else
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > RBMK_NO_COOLANT_TOLERANCE)
				temperature += temperature / 500 //This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
				vessel_integrity -= temperature / 200 //Think fast loser.
				take_damage(10) //Just for the sound effect, to let you know you've fucked up. NOTE: take_damage is normally set to 10 but is set to 1 for current test.
				to_chat(world, "Reactor is taking damage because of no coolant! Total Damage: [src.vessel_integrity]/400")
				color = "[COLOR_RED]"

	//Now, heat up the output and set our pressure.

	power = max(((temperature / RBMK_TEMPERATURE_CRITICAL) * 100), 0)
	if (!length(fuel_rods))
		power = 0
		return
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	//Next up, handle moderators!
	if(moderator_input.total_moles() >= minimum_coolant_level)
		var/total_fuel_moles = moderator_input.toxins
		var/power_modifier = max((moderator_input.oxygen / (moderator_input.total_moles() * 10)), 1) //You can never have negative IPM. For now.
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/power_produced = max((total_fuel_moles / moderator_input.total_moles() * 10), 1) //used for reactor power output, this power CANNOT be harnessed.
			last_power_produced = max(0,((power_produced*power_modifier)*moderator_input.total_moles()))
			last_power_produced *= (max(0,power)/100) //Aaaand here comes the cap. Hotter reactor => more power.
			last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.
			to_chat(world, "Moderator input total moles [moderator_input.total_moles()]")
			if(power >= 20)
				coolant_output.agent_b = total_fuel_moles/20 //Shove out agent B into the air when it's fuelled. You need to filter this off, or you're gonna have a bad (and green) time.
				return
		var/total_control_moles = moderator_input.nitrogen + (moderator_input.carbon_dioxide*2) //N2 helps you control the reaction at the cost of making it absolutely blast you with rads.
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
			radioactivity_spice_multiplier += moderator_input.nitrogen / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
			radioactivity_spice_multiplier += moderator_input.carbon_dioxide / 12.5
		var/total_permeability_moles = moderator_input.sleeping_agent
		if(total_permeability_moles >= minimum_coolant_level)
			var/permeability_bonus = total_permeability_moles / 500
			gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus
		var/total_degradation_moles = moderator_input.agent_b //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)
			K += total_fuel_moles / 1000
		//From this point onwards, we clear out the remaining gasses.
		moderator_input.remove(moderator_input.remove(10)) //Woosh. And the soul is gone.
	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		K = 0
	else
		for(var/obj/item/fuel_rod/FR in fuel_rods)
			K += FR.fuel_power
			fuel_power += FR.fuel_power
			FR.deplete(depletion_modifier)
	//Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)
	//Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference
	K = clamp(K, 0, RBMK_MAX_CRITICALITY)
	if(has_fuel())
		temperature += K
	else
		temperature = 293 //Nothing to heat us up, so heat is absorbed by the reactor to room temp (hacky method, but neg pressure is bad)
	update_icon()
	radiation_pulse(src, temperature*radioactivity_spice_multiplier)
	if(power >= 90 && world.time >= next_flicker) //You're overloading the reactor. Give a more subtle warning that power is getting out of control.
		next_flicker = world.time + 1.5 MINUTES
		for(var/obj/machinery/light/L in GLOB.machines)
			if(prob(25)) //If youre running the reactor cold though, no need to flicker the lights.
				L.flicker()

	if(temperature <= 150) //That's as cold as I'm letting you get it, engineering.
		color = COLOR_CYAN
		temperature = 150 //You've stalled my reactor!
		if(coolant_input.temperature >= 450 && temperature <= 150) //un-stalling a reactor will carry some risk
			color = null
			temperature = 250
	if(pressure_damage > 0)
		pressure_damage -= min(pressure/100, initial(vessel_integrity)/45)
	if(temp_damage > 0)
		temp_damage -= min(temperature/100, initial(vessel_integrity)/40)

	/*for(var/atom/movable/I in get_turf(src))
		if(isliving(I))
			var/mob/living/L = I
			if(temperature > 0)
				L.adjust_bodytemperature(CLAMP(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!
		if(istype(I, /obj/item/reagent_containers/food) && !istype(I, /obj/item/reagent_containers/food/drinks))
			playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 100, TRUE)
			var/obj/item/reagent_containers/food/grilled_item = I
			if(prob(80))
				to_chat(world, "<span class='userdanger'> !!! Returning Early because of Cooking??? !!! </span>")
				return //To give the illusion that it's actually cooking omegalul.
			switch(power)
				if(20 to 39)
					grilled_item.name = "grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(I.desc)] It's been grilled over a nuclear reactor."
				if(40 to 70)
					grilled_item.name = "heavily grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(I.desc)] It's been heavily grilled through the magic of nuclear fission."
				if(70 to 95)
					grilled_item.name = "Three-Mile Nuclear-Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. It's been put on top of a nuclear reactor running at extreme power by some badass engineer."
				if(95 to INFINITY)
					grilled_item.name = "Ultimate Meltdown Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. A grill this perfect is a rare technique only known by a few engineers who know how to perform a 'controlled' meltdown whilst also having the time to throw food on a reactor. I'll bet it tastes amazing."
*/
	// issue here, stems from nulled pipe, works fine when mapped in
	parent2.update = 1
	parent3.update = 1
	parent1.update = 1

	//each tick remove one from the alert counter
	lastrbmkwarn = (src.lastrbmkwarn - 1)
	to_chat(world, "Last warning timer: [src.lastrbmkwarn]")
	return

//Method to handle sound effects, reactor warnings, all that jazz.
//currently broken. needs total rework.
/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/handle_alerts()
	if(testing == TRUE)
		to_chat(world,"HANDLE ALERTS PROC'D")
	if(K <= 0 && temperature <= 100)
		shut_down()
	//First alert condition: Overheat
	else if(temperature >= RBMK_TEMPERATURE_MELTDOWN)
		var/temp_damage = min(temperature/100, 2)	//40 seconds to meltdown from full integrity, worst-case. Bit less than blowout since it's harder to spike heat that much.
		vessel_integrity -= temp_damage
		if(testing == TRUE)
			to_chat(world, "Reactor is taking damge from heat! Total damage: [vessel_integrity]/400")
		if((vessel_integrity < starting_vessel_integrity) && lastrbmkwarn < 0)
			radio.autosay("[rbmk_temp_alert] Core Integrity: [(vessel_integrity / starting_vessel_integrity)*100]%", name, "Engineering", list(z)) //scream on engi comms meltdown is occuring
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)
			lastrbmkwarn = 15
		if((vessel_integrity < (0.25 * starting_vessel_integrity)) && lastrbmkwarn < 1)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
			radio.autosay("[rbmk_meltdown_alert] Core Integrity: [(vessel_integrity / starting_vessel_integrity)*100]%", name, null, list(z)) //tell everyone meltdown is occuring and to panic
			lastrbmkwarn = 15
		if(vessel_integrity <= 0) //It wouldn't be able to tank another hit.
			meltdown() //Oops! All meltdown
			if(testing == TRUE)
				to_chat(world, "oops, all meltdown")
			return
	//Second alert condition: Overpressurized (the more lethal one)
	else if(pressure >= RBMK_PRESSURE_CRITICAL)
		playsound(loc, 'sound/effects/rbmk/steam_whoosh.ogg', 100, TRUE)
		var/pressure_damage = 2	//You should get about 45 seconds (if you had full integrity), worst-case. But hey, at least it can't be instantly nuked with a pipe-fire.. though it's still very difficult to save.
		vessel_integrity -= pressure_damage
		if(testing == TRUE)
			to_chat(world, "Reactor is taking pressure damage! Total Damage: [vessel_integrity]/400")
		if((vessel_integrity < starting_vessel_integrity) && lastrbmkwarn < 0)
			radio.autosay("[rbmk_pressure_alert] Core Integrity: [(vessel_integrity / starting_vessel_integrity)*100]%", name, "Engineering", list(z)) //scream on engi comms blowout is occuring
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)
			lastrbmkwarn = 15
		if((vessel_integrity < (0.25 * starting_vessel_integrity)) && lastrbmkwarn < 1)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
			radio.autosay("[rbmk_blowout_alert] Core Integrity: [(vessel_integrity / starting_vessel_integrity)*100]%", name, null, list(z)) //tell everyone meltdown is occuring and to panic
			lastrbmkwarn = 15
		if(vessel_integrity < 0) //It wouldn't be able to tank another hit.
			blowout()
			if(testing == TRUE)
				to_chat(world, "oops, chernobyl!")
			return
	else
		color = null

//Failure condition 1: Meltdown. Achieved by having heat go over tolerances. This is less devastating because it's easier to achieve.
//Results: Engineering becomes unusable and your engine irreparable
/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/meltdown()
	set waitfor = FALSE
	SSair.atmos_machinery -= src //Annd we're now just a useless brick.
	slagged = TRUE
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "reactor_slagged"
	AddComponent(/datum/component/radioactive, 15000 , src)
	//var/obj/effect/landmark/nuclear_waste_spawner/NSW = new /obj/effect/landmark/nuclear_waste_spawner/strong(get_turf(src)) //commeted out due to mapping required for use
	//var/obj/structure/overmap/OM = get_overmap()
	playsound(src.loc, 'sound/effects/rbmk/meltdown.ogg', TRUE, channel = CHANNEL_ENGINE)
	visible_message("<span class='userdanger'>You hear a horrible metallic hissing.</span>")
	//NSW.fire() //This will take out engineering for a decent amount of time as they have to clean up the sludge.
	for(var/obj/machinery/power/apc/A in GLOB.apcs)
		if(prob(70))
			A.overload_lighting()
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE
	var/turf/T = get_turf(src)
	coolant_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	moderator_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	T.assume_air(coolant_input)
	T.assume_air(moderator_input)
	T.assume_air(coolant_output)
	explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)
	empulse(get_turf(src), 25, 15)
	SSblackbox.record_feedback("tally", "engine_stats", 1, "failed")
	SSblackbox.record_feedback("tally", "engine_stats", 1, "agcnr")

//Failure condition 2: Blowout. Achieved by reactor going over-pressured. This is a round-ender because it requires more fuckery to achieve. basically a meltdown and big boom
/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/blowout()
	explosion(get_turf(src), 3, 7, 14, 14)
	meltdown() //Double kill.
	playsound('sound/effects/rbmk/explode.ogg', TRUE, channel = CHANNEL_ENGINE)
	/*
	// commented out due to round ending nature, this has been commented out
	if(OM?.role == MAIN_OVERMAP) //Irradiate the shit out of the player ship
		SSweather.run_weather("nuclear fallout")
	*/

	/*
	// commented out due to the need of mapping changes to function properly
	for(var/X in GLOB.landmarks_list)
		if(istype(X, /obj/effect/landmark/nuclear_waste_spawner))
			var/obj/effect/landmark/nuclear_waste_spawner/WS = X
			if(shares_overmap(src, WS)) //Begin the SLUDGING
				WS.fire()
*/

/*
// We do not have crew objectives, commented out
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/fail_meltdown_objective()
	for(var/client/C in GLOB.clients)
		if(CONFIG_GET(flag/allow_crew_objectives))
			var/mob/M = C.mob
			if(M?.mind?.current && LAZYLEN(M.mind.crew_objectives) && (M.job == "Station Engineer" || M.job == "Chief Engineer" || M.job == "Atmospheric Technician"))
				for(var/datum/objective/crew/meltdown/MO in M.mind.crew_objectives)
					MO.meltdown = TRUE
*/

/obj/machinery/atmospherics/trinary/nuclear_reactor/update_icon()
	. = ..()
	icon_state = "reactor_off"
	switch(temperature)
		if(0 to 200)
			icon_state = "reactor_on"
		if(200 to RBMK_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(RBMK_TEMPERATURE_OPERATING to 750)
			icon_state = "reactor_veryhot"
		if(750 to RBMK_TEMPERATURE_CRITICAL) //Point of no return.
			icon_state = "reactor_overheat"
		if(RBMK_TEMPERATURE_CRITICAL to INFINITY)
			icon_state = "reactor_meltdown"
	if(!has_fuel())
		icon_state = "reactor_off"
	if(slagged)
		icon_state = "reactor_slagged"


//Startup, shutdown

/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/start_up()
	if(slagged)
		return // No :)
	START_PROCESSING(SSmachines, src)
	desired_k = 1
	set_light(10)
	var/area/AR = get_area(src)
	AR.set_looping_ambience('sound/effects/rbmk/reactor_hum.ogg')
	var/startup_sound = pick('sound/effects/rbmk/startup.ogg', 'sound/effects/rbmk/startup2.ogg')
	playsound(loc, startup_sound, 100)
	SSblackbox.record_feedback("tally", "engine_stats", 1, "agcnr")
	SSblackbox.record_feedback("tally", "engine_stats", 1, "started")

//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/trinary/nuclear_reactor/proc/shut_down()
	STOP_PROCESSING(SSmachines, src)
	set_light(0)
	K = 0
	desired_k = 0
	temperature = 0
	update_icon()

/obj/item/fuel_rod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactive, 350 , src)

//Preset pumps for mappers. You can also set the id tags yourself. Commeted out until computer is setup and fixed
/*
/obj/machinery/atmospherics/components/binary/pump/rbmk_input
	name = "rbmk_input"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_output
	name = "rbmk_output"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_moderator
	name = "rbmk_moderator"
	frequency = FREQ_RBMK_CONTROL
	*/

/* Not  in use on paracode
/obj/machinery/computer/reactor/pump
	name = "reactor inlet valve computer"
	desc = "A computer which controls valve settings on an advanced gas cooled reactor. Alt click it to remotely set pump pressure."
	icon_screen = "rbmk_input"
	id = "rbmk_input"
	var/datum/radio_frequency/radio_connection
	var/on = FALSE

/obj/machinery/computer/reactor/pump/AltClick(mob/user)
	. = ..()
	var/newPressure = input(user, "Set new output pressure (kPa)", "Remote pump control", null) as num
	if(!newPressure)
		return
	newPressure = clamp(newPressure, 0, MAX_OUTPUT_PRESSURE) //Number sanitization is not handled in the pumps themselves, only during their ui_act which this doesn't use.
	signal(on, newPressure)

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/pump/attack_hand(mob/living/user)
	. = ..()
	if(!(stat & (NOPOWER|BROKEN|MAINT)))
		return FALSE
	playsound(loc, pick('sound/effects/rbmk/switch.ogg','sound/effects/rbmk/switch2.ogg','sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	visible_message("<span class='notice'>[src]'s switch flips [on ? "off" : "on"].</span>")
	on = !on
	signal(on)

/obj/machinery/computer/reactor/pump/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_RBMK_CONTROL,filter=RADIO_ATMOSIA)


/obj/machinery/computer/reactor/pump/proc/signal(power, set_output_pressure=null)
	var/datum/signal/signal
	if(!set_output_pressure) //Yes this is stupid, but technically if you pass through "set_output_pressure" onto the signal, it'll always try and set its output pressure and yeahhh...
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"sigtype" = "command"
		))
	else
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"set_output_pressure" = set_output_pressure,
			"sigtype" = "command"
		))
	radio_connection.post_signal(src, signal, filter=RADIO_ATMOSIA)
	*/

//Preset subtypes for mappers
/*
/obj/machinery/computer/reactor/pump/rbmk_input
	name = "Reactor inlet valve computer"
	icon_screen = "rbmk_input"
	id = "rbmk_input"

/obj/machinery/computer/reactor/pump/rbmk_output
	name = "Reactor output valve computer"
	icon_screen = "rbmk_output"
	id = "rbmk_output"

/obj/machinery/computer/reactor/pump/rbmk_moderator
	name = "Reactor moderator valve computer"
	icon_screen = "rbmk_moderator"
	id = "rbmk_moderator"
*/
//SPENT FUEL POOL
/*
/turf/open/indestructible/sound/pool/spentfuel
	name = "Spent fuel pool"
	desc = "A dumping ground for spent nuclear fuel, can you touch the bottom?"
	icon = 'icons/obj/pool.dmi'
	icon_state = "spentfuelpool"

/turf/open/indestructible/sound/pool/spentfuel/wall
	icon_state = "spentfuelpoolwall"
*/
//Monitoring program. Not used. Keeping commeted as refrence
/*
/datum/computer_file/program/nuclear_monitor
	filename = "rbmkmonitor"
	filedesc = "Nuclear Reactor Monitoring"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CONSTRUCTION
	category = PROGRAM_CATEGORY_ENGI
	network_destination = "rbmk monitoring system"
	size = 2
	tgui_id = "NtosRbmkStats"
	var/active = TRUE //Easy process throttle
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor //Our reactor.


/datum/computer_file/program/nuclear_monitor/process_tick()
	..()
	if(!reactor || !active)
		return FALSE
	var/stage = 0
	//This is dirty but i'm lazy wahoo!
	if(reactor.power > 0)
		stage = 1
	if(reactor.power >= 40)
		stage = 2
	if(reactor.temperature >= RBMK_TEMPERATURE_OPERATING)
		stage = 3
	if(reactor.temperature >= RBMK_TEMPERATURE_CRITICAL)
		stage = 4
	if(reactor.temperature >= RBMK_TEMPERATURE_MELTDOWN)
		stage = 5
		if(reactor.vessel_integrity <= 100) //Bye bye! GET OUT!
			stage = 6
	ui_header = "smmon_[stage].gif"
	program_icon_state = "smmon_[stage]"
	if(istype(computer))
		computer.update_icon()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/datum/computer_file/program/nuclear_monitor/on_start(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!reactor)
		/*for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
			if(shares_overmap+(user, R))
				reactor = R
				break*/
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = get_header_data()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("swap_reactor")
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
				choices += R
			reactor = input(usr, "What reactor do you wish to monitor?", "[src]", null) as null|anything in choices
			powerData = list()
			psiData = list()
			tempInputData = list()
			tempOutputdata = list()
			return TRUE
			*/

#undef COOLANT_INPUT_GATE
#undef MODERATOR_INPUT_GATE
#undef COOLANT_OUTPUT_GATE
