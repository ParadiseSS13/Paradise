
#define NITROGEN_RETARDATION_FACTOR 4        //Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 750               //Higher == more heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500                //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 1500        //Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1                //Higher == more overall power

//Controls how much power is produced by each collector in range - this is the main parameter for tweaking SM balance, as it basically controls how the power variable relates to the rest of the game.
#define POWER_FACTOR 0.35              //Obtained from testing. Aiming to make the ideal running output (600 kW) run the SM to ~85% of the safety level.

#define CHARGING_FACTOR 0.55
#define DAMAGE_RATE_LIMIT 5                 //damage rate cap at power = 900, scales linearly with power


//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 30 		//seconds between warnings.

/obj/machinery/power/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal. \red You get headaches just from looking at it."
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 0
	luminosity = 4

	var/gasefficency = 0.25

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystaline hyperstructure returning to safe operating levels."
	var/warning_point = 100
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 700
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 1000

	l_color = "#8A8A00"
	var/warning_color = "#B8B800"
	var/emergency_color = "#D9D900"

	var/grav_pulling = 0
	var/pull_radius = 14

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0                        // Time in 1/10th of seconds since the last sent warning
	var/power = 0

	var/oxygen = 0				  // Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//        var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

	shard //Small subtype, less efficient and more sensitive, but less boom.
		name = "Supermatter Shard"
		desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. \red You get headaches just from looking at it."
		icon_state = "darkmatter_shard"
		base_icon_state = "darkmatter_shard"

		warning_point = 50
		emergency_point = 500
		explosion_point = 900

		gasefficency = 0.125

		pull_radius = 5
		explosion_power = 3 //3,6,9,12? Or is that too small?


/obj/machinery/power/supermatter/New()
	. = ..()
	radio = new (src)


/obj/machinery/power/supermatter/Del()
	del radio
	. = ..()

/obj/machinery/power/supermatter/proc/explode()
	anchored = 1
	grav_pulling = 1
	spawn(100)
		explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1)
		del src
		return

//Changes color and luminosity of the light to these values if they were not already set
/obj/machinery/power/supermatter/proc/shift_light(var/lum, var/clr)
	if(l_color != clr)
		l_color = clr
	if(luminosity != lum)
		SetLuminosity(lum)

/obj/machinery/power/supermatter/process()

	var/turf/L = loc

	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.


	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status

		shift_light(5, warning_color)
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)
				shift_light(7, emergency_color)
				radio.autosay(addtext(emergency_alert, " Instability: ",stability,"%"), "Supermatter Monitor")
				lastwarning = world.timeofday

			else if(damage >= damage_archived) // The damage is still going up
				radio.autosay(addtext(warning_alert," Instability: ",stability,"%"), "Supermatter Monitor")
				lastwarning = world.timeofday - 150

			else                                                 // Phew, we're safe
				radio.autosay(safe_alert, "Supermatter Monitor")
				lastwarning = world.timeofday

		if(damage > explosion_point)
			for(var/mob/living/mob in living_mob_list)
				if(loc.z == mob.loc.z)
					if(istype(mob, /mob/living/carbon/human))
						//Hilariously enough, running into a closet should make you get hit the hardest.
						var/mob/living/carbon/human/H = mob
						H.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
					var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(mob, src) + 1) )
					mob.apply_effect(rads, IRRADIATE)

			explode()
	else
		shift_light(4,initial(l_color))
	if(grav_pulling)
		supermatter_pull()

	//Ok, get the air from the turf
	var/datum/gas_mixture/removed = null
	var/datum/gas_mixture/env = null

	//ensure that damage doesn't increase too quickly due to super high temperatures resulting from no coolant, for example. We dont want the SM exploding before anyone can react.
	//We want the cap to scale linearly with power (and explosion_point). Let's aim for a cap of 5 at power = 900 (based on testing, equals roughly 5% per SM alert announcement).
	var/damage_inc_limit = (power/900)*(explosion_point/1000)*DAMAGE_RATE_LIMIT

	if(!istype(L, /turf/space))
		env = L.return_air()
		removed = env.remove(gasefficency * env.total_moles)	//Remove gas from surrounding area

	if(!env || !removed || !removed.total_moles)
		damage += max(((power-(1600*POWER_FACTOR)))/10, 0)	//exciting the supermatter in a vacuum means the internal energy is mostly locked inside.
	else if (grav_pulling) //If supermatter is detonating, remove all air from the zone
		env.remove(env.total_moles)
	else
		damage_archived = damage

		damage = max( damage + min( ( (removed.temperature - 800) / 150 ), damage_inc_limit ) , 0 )
		//Ok, 100% oxygen atmosphere = best reaction
		//Maxes out at 100% oxygen pressure
		oxygen = max(min((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / MOLES_CELLSTANDARD, 1), 0)

		var/temp_factor = 100

		if(oxygen > 0.8)
			// with a perfect gas mix, make the power less based on heat
			icon_state = "[base_icon_state]_glow"
		else
			// in normal mode, base the produced energy around the heat
			temp_factor = 60
			icon_state = base_icon_state

		power = max( (removed.temperature * temp_factor / T0C) * oxygen + power, 0) //Total laser power plus an overload

		//We've generated power, now let's transfer it to the collectors for storing/usage
		transfer_energy()

		var/device_energy = power * REACTION_POWER_MODIFIER

		//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
		//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
		//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
		//Since the core is effectively "cold"

		//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
		//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.

		var/thermal_power = THERMAL_RELEASE_MODIFIER

		//This shouldn't be necessary. If the number of moles is low, then heat_capacity should be tiny.
		//if(removed.total_moles < 35) thermal_power += 750   //If you don't add coolant, you are going to have a bad time.

		removed.temperature += ((device_energy * thermal_power) / removed.heat_capacity())

		removed.temperature = max(0, min(removed.temperature, 10000))

		//Calculate how much gas to release
		removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

		removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

		removed.update_values()

		env.merge(removed)

	for(var/mob/living/carbon/human/l in view(src, min(7, round(power ** 0.25)))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			l.hallucination = max(0, min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)) ) ) )

	//adjusted range so that a power of 600 (pretty high) results in 8 tiles, roughly the distance from the core to the engine monitoring room.
	//at power of 1210 this becomes 9 tiles --> increases very very slowly.
	for(var/mob/living/l in range(src, round((power / 0.146484375) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)

	power -= (power/500)**3		//energy losses due to radiation

	return 1


/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy	* CHARGING_FACTOR
	else
		damage += Proj.damage * config_bullet_energy
	return 0


/obj/machinery/power/supermatter/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/machinery/power/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"
	return

/obj/machinery/power/supermatter/attack_ai(mob/user as mob)
	user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"

/obj/machinery/power/supermatter/attack_hand(mob/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(power * POWER_FACTOR)
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_effect(150, IRRADIATE)


/obj/machinery/power/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
	else if(!grav_pulling) //To prevent spam, detonating supermatter does not indicate non-mobs being destroyed
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	Consume(AM)


/obj/machinery/power/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user))
		user.dust()
		power += 200
	else
		del user

	power += 200

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/l in range(10))
		if(l in view())
			l.show_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class=\"warning\">The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			l.show_message("<span class=\"warning\">You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)
		var/rads = 500 * sqrt( 1 / (get_dist(l, src) + 1) )
		l.apply_effect(rads, IRRADIATE, 0) // Permit blocking


/obj/machinery/power/supermatter/proc/supermatter_pull()

	//following is adapted from singulo code
	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1
	// Let's just make this one loop.
	for(var/atom/X in orange(pull_radius,src))
		// Movable atoms only
		if(istype(X, /atom/movable))
			if(is_type_in_list(X, uneatable))	continue
			if(((X) && (!istype(X,/mob/living/carbon/human))))
				step_towards(X,src)
				if(istype(X, /obj)) //unanchored objects pulled twice as fast
					var/obj/O = X
					if(!O.anchored)
						step_towards(X,src)
				else
					step_towards(X,src)
				if(istype(X, /obj/structure/window)) //shatter windows
					var/obj/structure/window/W = X
					W.ex_act(2.0)
			else if(istype(X,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						step_towards(H,src) //step just once with magboots
						continue
				step_towards(H,src) //step twice
				step_towards(H,src)

	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0
	return


/obj/machinery/power/supermatter/GotoAirflowDest(n) //Supermatter not pushed around by airflow
	return

/obj/machinery/power/supermatter/RepelAirflowDest(n)
	return
