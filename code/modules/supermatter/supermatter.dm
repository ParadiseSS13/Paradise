
#define NITROGEN_RETARDATION_FACTOR 0.15	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 750		//Higher == more heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500		//Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 1500		//Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1			//Higher == more overall power

/*
	How to tweak the SM

	POWER_FACTOR		directly controls how much power the SM puts out at a given level of excitation (power var). Making this lower means you have to work the SM harder to get the same amount of power.
	CRITICAL_TEMPERATURE	The temperature at which the SM starts taking damage.

	CHARGING_FACTOR		Controls how much emitter shots excite the SM.
	DAMAGE_RATE_LIMIT	Controls the maximum rate at which the SM will take damage due to high temperatures.
*/

//Controls how much power is produced by each collector in range - this is the main parameter for tweaking SM balance, as it basically controls how the power variable relates to the rest of the game.
#define POWER_FACTOR 1.0
#define DECAY_FACTOR 700			//Affects how fast the supermatter power decays
#define CRITICAL_TEMPERATURE 800	//K
#define CHARGING_FACTOR 0.05
#define DAMAGE_RATE_LIMIT 3			//damage rate cap at power = 300, scales linearly with power


//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600

#define TRANSFORM_DISTANCE_MOD 2 // Size/this is maximum distance from SM during burst for transformation to Nucleation

#define WARNING_DELAY 30			//seconds between warnings.

/obj/machinery/power/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal. \red You get headaches just from looking at it."
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 0
	light_range = 4

	var/gasefficency = 0.25

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystaline hyperstructure returning to safe operating levels."
	var/safe_warned = 0
	var/warning_point = 100
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 700
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 1000

	light_color = "#8A8A00"
	var/warning_color = "#B8B800"
	var/emergency_color = "#D9D900"

	var/grav_pulling = 0
	var/pull_radius = 14
	// Time in ticks between delamination ('exploding') and exploding (as in the actual boom)
	var/pull_time = 100
	var/explosion_power = 8

	var/emergency_issued = 0

	// Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0

	// This stops spawning redundand explosions. Also incidentally makes supermatter unexplodable if set to 1.
	var/exploded = 0

	var/power = 0
	var/oxygen = 0

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//        var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

	var/debug = 0

/obj/machinery/power/supermatter/New()
	. = ..()
	radio = new (src)


/obj/machinery/power/supermatter/Del()
	del radio
	. = ..()

/obj/machinery/power/supermatter/proc/explode()
	message_admins("Supermatter exploded at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Supermatter exploded at ([x],[y],[z])")
	anchored = 1
	grav_pulling = 1
	exploded = 1
	spawn(pull_time)
		var/turf/epicenter = get_turf(src)
		explosion(epicenter, explosion_power, explosion_power*2, explosion_power*3, explosion_power*4, 1)
		supermatter_delamination( epicenter, explosion_power*4, 1 )
		del src
		return

//Changes color and light_range of the light to these values if they were not already set
/obj/machinery/power/supermatter/proc/shift_light(var/lum, var/clr)
	if(light_color != clr)
		light_color = clr
	if(light_range != lum)
		set_light(lum)

/obj/machinery/power/supermatter/proc/announce_warning()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	var/alert_msg = " Integrity at [integrity]%"

	if(damage > emergency_point)
		alert_msg = emergency_alert + alert_msg
		lastwarning = world.timeofday - WARNING_DELAY * 4
	else if(damage >= damage_archived) // The damage is still going up
		safe_warned = 0
		alert_msg = warning_alert + alert_msg
		lastwarning = world.timeofday
	else if(!safe_warned)
		safe_warned = 1 // We are safe, warn only once
		alert_msg = safe_alert
		lastwarning = world.timeofday
	else
		alert_msg = null
	if(alert_msg)
		radio.autosay(alert_msg, "Supermatter Monitor")

/obj/machinery/power/supermatter/process()

	var/turf/L = loc

	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(damage > explosion_point)
		if(!exploded)
			if(!istype(L, /turf/space))
				announce_warning()
			explode()
	else if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		shift_light(5, warning_color)
		if(damage > emergency_point)
			shift_light(7, emergency_color)
		if(!istype(L, /turf/space) && (world.timeofday - lastwarning) >= WARNING_DELAY * 10)
			announce_warning()
	else
		shift_light(4,initial(light_color))
	if(grav_pulling)
		supermatter_pull()

	//Ok, get the air from the turf
	var/datum/gas_mixture/removed = null
	var/datum/gas_mixture/env = null

	//ensure that damage doesn't increase too quickly due to super high temperatures resulting from no coolant, for example. We dont want the SM exploding before anyone can react.
	//We want the cap to scale linearly with power (and explosion_point). Let's aim for a cap of 5 at power = 300 (based on testing, equals roughly 5% per SM alert announcement).
	var/damage_inc_limit = (power/300)*(explosion_point/1000)*DAMAGE_RATE_LIMIT

	if(!istype(L, /turf/space))
		env = L.return_air()
		removed = env.remove(gasefficency * env.total_moles())	//Remove gas from surrounding area

	if(!env || !removed || !removed.total_moles())
		damage += max((power - 15*POWER_FACTOR)/10, 0)
	else if (grav_pulling) //If supermatter is detonating, remove all air from the zone
		env.remove(env.total_moles())
	else
		damage_archived = damage

		damage = max( damage + min( ( (removed.temperature - CRITICAL_TEMPERATURE) / 150 ), damage_inc_limit ) , 0 )
		//Ok, 100% oxygen atmosphere = best reaction
		//Maxes out at 100% oxygen pressure
		oxygen = max(min((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / removed.total_moles(), 1), 0)

		//calculate power gain for oxygen reaction
		var/temp_factor
		var/equilibrium_power
		if (oxygen > 0.8)
			//If chain reacting at oxygen == 1, we want the power at 800 K to stabilize at a power level of 400
			equilibrium_power = 400
			icon_state = "[base_icon_state]_glow"
		else
			//If chain reacting at oxygen == 1, we want the power at 800 K to stabilize at a power level of 250
			equilibrium_power = 250
			icon_state = base_icon_state

		temp_factor = ( (equilibrium_power/DECAY_FACTOR)**3 )/800
		power = max( (removed.temperature * temp_factor) * oxygen + power, 0)

		//We've generated power, now let's transfer it to the collectors for storing/usage
		transfer_energy()

		var/device_energy = power * REACTION_POWER_MODIFIER


		//Calculate how much gas to release
		removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

		removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

		env.merge(removed)


	for(var/mob/living/carbon/human/l in view(src, min(7, round(sqrt(power/6))))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			l.hallucination = max(0, min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)) ) ) )

	//adjusted range so that a power of 300 (pretty high) results in 8 tiles, roughly the distance from the core to the engine monitoring room.
	for(var/mob/living/l in range(src, round(sqrt(power / 5))))
		var/rads = (power / 10) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)

	power -= (power/DECAY_FACTOR)**3		//energy losses due to radiation

	return 1


/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(istype(Proj, /obj/item/projectile/beam))
		power += Proj.damage * config_bullet_energy	* CHARGING_FACTOR / POWER_FACTOR
	else
		damage += Proj.damage * config_bullet_energy
	return 0

/obj/machinery/power/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"
	return

/obj/machinery/power/supermatter/attack_ai(mob/user as mob)
	user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"

/obj/machinery/power/supermatter/attack_hand(mob/user as mob)
	if(istype(user,/mob/living/carbon/human/nucleation)) // Nucleation's biology doesn't react to this
		return

	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		var/distance = get_dist(R, src)
		if(distance <= 15)
			//for collectors using standard plasma tanks at 1013 kPa, the actual power generated will be this power*POWER_FACTOR*20*29 = power*POWER_FACTOR*580
			R.receive_pulse(power * POWER_FACTOR * (min(3/distance, 1))**2)
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	user.unEquip(W)
	Consume(W)

	user.apply_effect(150, IRRADIATE)


/obj/machinery/power/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		if(istype(AM,/mob/living/carbon/human/nucleation)) // Nucleation's biology doesn't react to this
			return
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
	else if(!grav_pulling) //To prevent spam, detonating supermatter does not indicate non-mobs being destroyed
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	Consume(AM)


/obj/machinery/power/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user,/mob/living/carbon/human/nucleation)) // Nucleation's biology doesn't react to this
		return

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
		l.apply_effect(rads, IRRADIATE)


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


proc/supermatter_delamination(var/turf/epicenter, var/size, var/transform_mobs = 0, var/adminlog = 1)
	spawn(0)
		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		if(adminlog)
			message_admins("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</a>)")
			log_game("Supermatter delamination with size ([size]) in area [epicenter.loc.name] ")

		playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(size*2,1) )
		playsound(epicenter, "explosion", 100, 1, round(size,1) )

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		var/x = epicenter.x
		var/y = epicenter.y
		var/z = epicenter.z

		epicenter.ChangeTurf( /turf/simulated/floor/plating/smatter )

		for(var/mob/living/mob in orange( epicenter, size*2 )) // Irradiate area twice the size of the main blast
			if(epicenter.z == mob.loc.z)
				if( ishuman(mob) )
					//Hilariously enough, running into a closet should make you get hit the hardest.
					var/mob/living/carbon/human/H = mob
					H.hallucination += max(50, min(size*10, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, epicenter) + 1)) ) )
				var/rads = size*10 * sqrt( 1 / (get_dist(mob, epicenter) + 1) )
				mob.apply_effect(rads, IRRADIATE)

		for(var/i=0, i<size, i++) // An awful way to do this, but i'm tired
			for(var/j=0, j<i, j++)
				var/turf/cur_turf = locate((x-i)+j, y+j, z )
				var/dist = get_dist( cur_turf, epicenter )
				var/percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs )

				cur_turf = locate(x+j, (y+i)-j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs )

				cur_turf = locate((x+i)-j, y-j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs )

				cur_turf = locate(x-j, (y-i)+j, z )
				dist = get_dist( cur_turf, epicenter )
				percent = min( 100, ((( size-dist )/size )*100 ))
				blow_lights( cur_turf )
				if( prob( percent ))
					supermatter_convert( cur_turf, transform_mobs )

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0

		diary << "## Supermatter delamination with size [size]. Took [(world.timeofday-start)/10] seconds."
	return 1


proc/supermatter_convert( var/turf/T, var/transform_mobs = 0 )
	if( transform_mobs )
		for( var/mob/item in T.contents )
			if( ishuman( item ))
				var/mob/living/carbon/human/M = item
				if( istype(M.species, /datum/species/human ))
					if( prob( 33 ))
						M.set_species( "Nucleation", 1 )
			item.ex_act( 3 )

	if( istype( T, /turf/simulated/floor ))
		new /obj/effect/supermatter_crystal(T)

proc/blow_lights( var/turf/T )
	for( var/obj/machinery/power/apc/apc in T )
		apc.overload_lighting()


/obj/machinery/power/supermatter/shard //Small subtype, less efficient and more sensitive, but less boom.
	name = "Supermatter Shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. \red You get headaches just from looking at it."
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"

	warning_point = 50
	emergency_point = 400
	explosion_point = 600

	gasefficency = 0.125

	pull_radius = 5
	pull_time = 45
	explosion_power = 3

/obj/machinery/power/supermatter/shard/announce_warning() //Shards don't get announcements
	return
