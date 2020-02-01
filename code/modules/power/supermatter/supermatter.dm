#define NITROGEN_RETARDATION_FACTOR 0.15	//Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 10000		//Higher == more heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500		//Higher == less phor.. plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 15000		//Higher == less oxygen released at high temperature/power
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
#define CRITICAL_TEMPERATURE 10000	//K
#define CHARGING_FACTOR 0.05
#define DAMAGE_RATE_LIMIT 4.5		//damage rate cap at power = 300, scales linearly with power


// Base variants are applied to everyone on the same Z level
// Range variants are applied on per-range basis: numbers here are on point blank, it scales with the map size (assumes square shaped Z levels)
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600



#define WARNING_DELAY 20			//seconds between warnings.
/obj/machinery/power/supermatter_shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='danger'>You get headaches just from looking at it.</span>"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter_shard"
	density = 1
	anchored = 0
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF


	var/gasefficency = 0.125

	var/base_icon_state = "darkmatter_shard"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystalline hyperstructure returning to safe operating levels."
	var/warning_point = 50
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 400
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 600

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0				// Time in 1/10th of seconds since the last sent warning
	var/last_zap = 0				// Time in 1/10th of seconds since the last tesla zap
	var/power = 0

	var/oxygen = 0					// Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/debug = 0

	var/disable_adminwarn = FALSE

	var/aw_normal = FALSE
	var/aw_notify = FALSE
	var/aw_warning = FALSE
	var/aw_danger = FALSE
	var/aw_emerg = FALSE
	var/aw_delam = FALSE

	var/obj/item/radio/radio

	//for logging
	var/has_been_powered = 0
	var/has_reached_emergency = 0

/obj/machinery/power/supermatter_shard/crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"
	anchored = TRUE
	warning_point = 200
	emergency_point = 2000
	explosion_point = 3600
	gasefficency = 0.25
	explosion_power = 24


/obj/machinery/power/supermatter_shard/New()
	. = ..()
	GLOB.poi_list |= src
	//Added to the atmos_machine process as the SM is highly coupled with the atmospherics system.
	//Having the SM run at a different rate then atmospherics causes odd behavior.
	SSair.atmos_machinery += src
	radio = new(src)
	radio.listening = 0
	investigate_log("has been created.", "supermatter")


/obj/machinery/power/supermatter_shard/proc/handle_admin_warnings()
	if(disable_adminwarn)
		return

	// Generic checks, similar to checks done by supermatter monitor program.
	aw_normal = status_adminwarn_check(SUPERMATTER_NORMAL, aw_normal, "INFO: Supermatter crystal has been energised.<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_notify = status_adminwarn_check(SUPERMATTER_NOTIFY, aw_notify, "INFO: Supermatter crystal is approaching unsafe operating temperature.<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_warning = status_adminwarn_check(SUPERMATTER_WARNING, aw_warning, "WARN: Supermatter crystal is taking integrity damage!<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_danger = status_adminwarn_check(SUPERMATTER_DANGER, aw_danger, "WARN: Supermatter integrity is below 75%!<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", TRUE)
	aw_emerg = status_adminwarn_check(SUPERMATTER_EMERGENCY, aw_emerg, "CRIT: Supermatter integrity is below 50%!<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", FALSE)
	aw_delam = status_adminwarn_check(SUPERMATTER_DELAMINATING, aw_delam, "CRIT: Supermatter is delaminating!<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.", TRUE)

/obj/machinery/power/supermatter_shard/proc/status_adminwarn_check(var/min_status, var/current_state, var/message, var/send_to_irc = FALSE)
	var/status = get_status()
	if(status >= min_status)
		if(!current_state)
			log_and_message_admins(message)
			if(send_to_irc)
				send2adminirc(message)
		return TRUE
	else
		return FALSE


/obj/machinery/power/supermatter_shard/Destroy()
	investigate_log("has been destroyed.", "supermatter")
	if(damage > emergency_point)
		emergency_lighting(0)
	QDEL_NULL(radio)
	GLOB.poi_list.Remove(src)
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/power/supermatter_shard/proc/explode()
	investigate_log("has exploded.", "supermatter")
	explosion(get_turf(src), explosion_power, explosion_power * 1.2, explosion_power * 1.5, explosion_power * 2, 1, 1)
	qdel(src)
	return

/obj/machinery/power/supermatter_shard/process_atmos()
	var/turf/L = loc

	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			alarm()
			emergency_lighting(1)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)
				radio.autosay("[emergency_alert] Instability: [stability]%", src.name)
				lastwarning = world.timeofday
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", "supermatter")
					message_admins("[src] has reached the emergency point <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
					has_reached_emergency = 1

			else if(damage >= damage_archived) // The damage is still going up
				radio.autosay("[warning_alert] Instability: [stability]%", src.name)
				lastwarning = world.timeofday - 150

			else                                                 // Phew, we're safe
				radio.autosay("[safe_alert]", src.name)
				emergency_lighting(0)
				lastwarning = world.timeofday

		if(damage > explosion_point)
			if(get_turf(src))
				var/turf/position = get_turf(src)
				for(var/mob/living/mob in GLOB.living_mob_list)
					var/turf/mob_pos = get_turf(mob)
					if(mob_pos && mob_pos.z == position.z)
						if(ishuman(mob))
							//Hilariously enough, running into a closet should make you get hit the hardest.
							var/mob/living/carbon/human/H = mob
							H.AdjustHallucinate(max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)))))
						var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(mob, src) + 1) )
						mob.apply_effect(rads, IRRADIATE)

			explode()
			emergency_lighting(0)

	if(damage > warning_point && world.timeofday > last_zap)
		last_zap = world.timeofday + rand(80,200)
		supermatter_zap()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/datum/gas_mixture/removed = env.remove(gasefficency * env.total_moles())

	//ensure that damage doesn't increase too quickly due to super high temperatures resulting from no coolant, for example. We dont want the SM exploding before anyone can react.
	//We want the cap to scale linearly with power (and explosion_point). Let's aim for a cap of 5 at power = 300 (based on testing, equals roughly 5% per SM alert announcement).
	var/damage_inc_limit = (power/300)*(explosion_point/1000)*DAMAGE_RATE_LIMIT

	if(!env || !removed || !removed.total_moles())
		damage += max((power - 15*POWER_FACTOR)/10, 0)
	else
		damage_archived = damage

	damage = max(0, damage + between(-DAMAGE_RATE_LIMIT, (removed.temperature - CRITICAL_TEMPERATURE) / 150, damage_inc_limit))

	//Maxes out at 100% oxygen pressure
	oxygen = Clamp((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / removed.total_moles(), 0, 1)

	var/temp_factor
	var/equilibrium_power
	if(oxygen > 0.8)
		//If chain reacting at oxygen > 0.8, we want the power at 800 K to stabilize at a power level of 400
		equilibrium_power = 400
		icon_state = "[base_icon_state]_glow"
	else
		//Otherwise, we want the power at 800 K to stabilize at a power level of 250
		equilibrium_power = 250
		icon_state = base_icon_state

	temp_factor = ((equilibrium_power / DECAY_FACTOR) ** 3) / 800
	power = max((removed.temperature * temp_factor) * oxygen + power, 0)

	var/device_energy = power * REACTION_POWER_MODIFIER

	var/heat_capacity = removed.heat_capacity()

	removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

	removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	var/thermal_power = THERMAL_RELEASE_MODIFIER * device_energy
	if(debug)
		var/heat_capacity_new = removed.heat_capacity()
		visible_message("[src]: Releasing [round(thermal_power)] W.")
		visible_message("[src]: Releasing additional [round((heat_capacity_new - heat_capacity)*removed.temperature)] W with exhaust gasses.")

	removed.temperature += (device_energy)

	removed.temperature = max(0, min(removed.temperature, 10000))

	env.merge(removed)

	air_update_turf()
	transfer_energy()

	for(var/mob/living/carbon/human/l in view(src, min(7, round(sqrt(power/6)))))
		// If they can see it without mesons on.  Bad on them.
		if(l.glasses && istype(l.glasses, /obj/item/clothing/glasses/meson))
			continue
		// Where we're going, we don't need eyes.
		// Prosthetic eyes will also protect against this business.
		var/obj/item/organ/internal/eyes/eyes = l.get_int_organ(/obj/item/organ/internal/eyes)
		if(!istype(eyes))
			continue
		l.Hallucinate(min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)))))

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / max(get_dist(l, src),1) )
		l.apply_effect(rads, IRRADIATE)

	power -= (power/DECAY_FACTOR)**3
	handle_admin_warnings()

	return 1

/obj/machinery/power/supermatter_shard

/obj/machinery/power/supermatter_shard/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
		if(!has_been_powered)
			investigate_log("has been powered for the first time.", "supermatter")
			message_admins("[src] has been powered for the first time <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
			has_been_powered = 1
	else
		damage += Proj.damage * config_bullet_energy
	supermatter_zap()
	return 0

/obj/machinery/power/supermatter_shard/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.","singulo")
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	for(var/mob/M in GLOB.mob_list)
		M << 'sound/effects/supermatter.ogg' //everyone gunna know bout this
		to_chat(M, "<span class='boldannounce'>A horrible screeching fills your ears, and a wave of dread washes over you...</span>")
	qdel(src)
	return(gain)

/obj/machinery/power/supermatter_shard/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		ui_interact(user)
	return

/obj/machinery/power/supermatter_shard/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/power/supermatter_shard/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/power/supermatter_shard/attack_hand(mob/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... [user.p_their(TRUE)] body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/obj/machinery/power/supermatter_shard/proc/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

// This is purely informational UI that may be accessed by AIs or robots
/obj/machinery/power/supermatter_shard/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "supermatter_crystal.tmpl", "Supermatter Crystal", 500, 300)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/power/supermatter_shard/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["integrity_percentage"] = round(get_integrity())
	var/datum/gas_mixture/env = null
	if(!istype(src.loc, /turf/space))
		env = src.loc.return_air()

	if(!env)
		data["ambient_temp"] = 0
		data["ambient_pressure"] = 0
	else
		data["ambient_temp"] = round(env.temperature)
		data["ambient_pressure"] = round(env.return_pressure())
	if(damage > explosion_point)
		data["detonating"] = 1
	else
		data["detonating"] = 0

	return data

/obj/machinery/power/supermatter_shard/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(power/10)
	return

/obj/machinery/power/supermatter_shard/attackby(obj/item/W as obj, mob/living/user as mob, params)
	if(!istype(W) || (W.flags & ABSTRACT) || !istype(user))
		return
	if(user.drop_item(W))
		Consume(W)
		user.visible_message("<span class='danger'>As [user] touches \the [src] with \a [W], silence fills the room...</span>",\
			"<span class='userdanger'>You touch \the [src] with \the [W], and everything suddenly goes silent.\"</span>\n<span class='notice'>\The [W] flashes into dust as you flinch away from \the [src].</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")

		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

		user.apply_effect(150, IRRADIATE)

/obj/machinery/power/supermatter_shard/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class='danger'>\The [AM] slams into \the [src] inducing a resonance... [AM.p_their(TRUE)] body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !istype(AM, /obj/effect))
		AM.visible_message("<span class='danger'>\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)


/obj/machinery/power/supermatter_shard/proc/Consume(atom/movable/AM)
	if(istype(AM, /mob/living))
		var/mob/living/user = AM
		user.dust()
		power += 200
		message_admins("[src] has consumed [key_name_admin(user)] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
		investigate_log("has consumed [key_name(user)].", "supermatter")
	else if(isobj(AM) && !istype(AM, /obj/effect))
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)

	power += 200
	supermatter_zap()


	//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/L in range(10))
		var/rads = 500 * sqrt( 1 / (get_dist(L, src) + 1) )
		L.apply_effect(rads, IRRADIATE)
		investigate_log("has irradiated [L] after consuming [AM].", "supermatter")
		if(L in view())
			L.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			L.show_message("<span class='italics'>You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)

/obj/machinery/power/supermatter_shard/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	if(get_integrity() < 25)
		return SUPERMATTER_DELAMINATING

	if(get_integrity() < 50)
		return SUPERMATTER_EMERGENCY

	if(get_integrity() < 75)
		return SUPERMATTER_DANGER

	if((get_integrity() < 100) || (air.temperature > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_shard/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/power/supermatter_shard/proc/emergency_lighting(active)
    if(active)
        post_status("alert", "radiation")
    else
        post_status("shuttle")

/obj/machinery/power/supermatter_shard/proc/supermatter_zap()
	playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
	tesla_zap(src, 10, max(1000,power * damage / explosion_point))
