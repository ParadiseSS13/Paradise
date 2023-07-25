//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

//Zap constants, speeds up targeting

#define COIL (ROD + 1)
#define ROD (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (OBJECT + 1)
#define OBJECT (LOWEST + 1)
#define LOWEST (1)

#define PLASMA_HEAT_PENALTY 15     // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 0.1
#define NITROGEN_HEAT_PENALTY -1.5

#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4

#define N2O_HEAT_RESISTANCE 6          //Higher == Gas makes the crystal more resistant against heat damage.

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_PENALTY_THRESHOLD 1800           //Above this value we can get lord singulo and independent mol damage, below it we can heal damage
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
//Along with damage_penalty_point, makes flux anomalies.
/// The cutoff for the minimum amount of power required to trigger the crystal invasion delamination event.
#define EVENT_POWER_PENALTY_THRESHOLD 4500
#define POWER_PENALTY_THRESHOLD 5000          //The cutoff on power properly doing damage, pulling shit around, and delamming into a tesla. Low chance of cryo anomalies, +2 bolts of electricity
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //+1 bolt of electricity, allows for gravitational anomalies, and higher chances of cryo anomalies
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //+1 bolt of electricity.
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25


#define THERMAL_RELEASE_MODIFIER 5         //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750        //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power

#define REACTION_POWER_MODIFIER 0.55       //Higher == more overall power

#define MATTER_POWER_CONVERSION 10         //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))


#define GRAVITATIONAL_ANOMALY "gravitational_anomaly"
#define FLUX_ANOMALY "flux_anomaly"
#define CRYO_ANOMALY "cryo_anomaly"

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100
#define CRITICAL_TEMPERATURE 10000

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS

///to prevent accent sounds from layering
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS

#define DEFAULT_ZAP_ICON_STATE "sm_arc"
#define SLIGHTLY_CHARGED_ZAP_ICON_STATE "sm_arc_supercharged"
#define OVER_9000_ZAP_ICON_STATE "sm_arc_dbz_referance" //Witty I know

#define MAX_SPACE_EXPOSURE_DAMAGE 2

/// Colours used for effects.
#define SUPERMATTER_COLOUR "#ffd04f"
#define SUPERMATTER_RED "#aa2c16"
#define SUPERMATTER_TESLA_COLOUR "#00ffff"
#define SUPERMATTER_SINGULARITY_RAYS_COLOUR "#750000"
#define SUPERMATTER_SINGULARITY_LIGHT_COLOUR "#400060"


/obj/machinery/atmospherics/supermatter_crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER + 0.01
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2 | IMMUNE_TO_SHUTTLECRUSH_2 | NO_MALF_EFFECT_2 | CRITICAL_ATOM_2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	base_icon_state = "darkmatter"

	///The id of our supermatter
	var/supermatter_id = 1
	///The amount of supermatters that have been created this round
	var/static/global_supermatter_id = 1
	///Tracks the bolt color we are using
	var/zap_icon = DEFAULT_ZAP_ICON_STATE
	///The portion of the gasmix we're on that we should remove
	var/gasefficency = 0.15

	///Are we exploding?
	var/final_countdown = FALSE

	///The amount of damage we have currently
	var/damage = 0
	///The damage we had before this cycle. Used to limit the damage we can take each cycle, and for safe_alert
	var/damage_archived = 0
	///Our "Shit is no longer fucked" message. We send it when damage is less then damage_archived
	var/safe_alert = "Crystalline hyperstructure returning to safe operating parameters."
	///The point at which we should start sending messeges about the damage to the engi channels.
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Danger! Crystal hyperstructure integrity faltering!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	///The point at which we delam
	var/explosion_point = 900
	///When we pass this amount of damage we start shooting bolts
	var/damage_penalty_point = 550

	///A scaling value that affects the severity of explosions.
	var/explosion_power = 35
	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0
	///Refered to as eer on the moniter. This value effects gas output, heat, damage, and radiation.
	var/power = 0
	///Determines the rate of positve change in gas comp values
	var/gas_change_rate = 0.05

	var/n2comp = 0					// raw composition of each gas in the chamber, ranges from 0 to 1
	var/plasmacomp = 0
	var/o2comp = 0
	var/co2comp = 0
	var/n2ocomp = 0

	///The last air sample's total molar count, will always be above or equal to 0
	var/combined_gas = 0
	///Affects the power gain the sm experiances from heat
	var/gasmix_power_ratio = 0
	///Affects the amount of o2 and plasma the sm outputs, along with the heat it makes.
	var/dynamic_heat_modifier = 1
	///Affects the amount of damage and minimum point at which the sm takes heat damage
	var/dynamic_heat_resistance = 1
	///Uses powerloss_dynamic_scaling and combined_gas to lessen the effects of our powerloss functions
	var/powerloss_inhibitor = 1
	///value plus T0C = temp at which the SM starts to take damage. Variable for event usage
	var/heat_penalty_threshold = HEAT_PENALTY_THRESHOLD
	///Based on co2 percentage, slowly moves between 0 and 1. We use it to calc the powerloss_inhibitor
	var/powerloss_dynamic_scaling= 0
	///Affects the amount of radiation the sm makes. We multiply this with power to find the rads.
	var/power_transmission_bonus = 0
	///Used to increase or lessen the amount of damage the sm takes from heat based on molar counts.
	var/mole_heat_penalty = 0
	///Takes the energy throwing things into the sm generates and slowly turns it into actual power
	var/matter_power = 0
	///The cutoff for a bolt jumping, grows with heat, lowers with higher mol count,
	var/zap_cutoff = 1500
	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/bullet_energy = 2
	///How much hallucination should we produce per unit of power?
	var/hallucination_power = 1
	///Our internal radio
	var/obj/item/radio/radio
	///Reference to the warp effect
	var/obj/effect/warp_effect/supermatter/warp
	///A variable to have the warp effect for singulo SM work properly
	var/pulse_stage = 0
	///This list will hold 4 supermatter darkness effects when the supermatter is delaminating to a singulo delam. This lets me darken the area to look better, as it turns out, walls make the effect look ugly as shit.
	var/list/darkness_effects = list()

	///Boolean used for logging if we've been powered
	var/has_been_powered = FALSE
	///Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE

	///An effect we show to admins and ghosts the percentage of delam we're at
	var/obj/effect/countdown/supermatter/countdown

	///Used to track if we can give out the sm sliver stealing objective
	var/is_main_engine = FALSE
	///Our soundloop
	var/datum/looping_sound/supermatter/soundloop
	///Can it be moved?
	var/moveable = FALSE

	///cooldown tracker for accent sounds
	var/last_accent_sound = 0

	//For making hugbox supermatters
	///Disables all methods of taking damage
	var/takes_damage = TRUE
	///Disables the production of gas, and pretty much any handling of it we do.
	var/produces_gas = TRUE
	///Disables power changes
	var/power_changes = TRUE
	///Disables the sm's proccessing totally.
	var/processes = TRUE

	//vars used for supermatter events (Anomalous crystal activityw)
	/// Do we have an active event?
	var/datum/supermatter_event/event_active
	///flat multiplies the amount of gas released by the SM.
	var/gas_multiplier = 1
	///flat multiplies the heat released by the SM
	var/heat_multiplier = 1
	///amount of EER to ADD
	var/power_additive = 0
	/// Time of next event
	var/next_event_time
	/// Run S-Class event? So we can only run one S-class event per round per crystal
	var/has_run_sclass = FALSE


/obj/machinery/atmospherics/supermatter_crystal/Initialize(mapload)
	. = ..()
	supermatter_id = global_supermatter_id++
	countdown = new(src)
	countdown.start()
	GLOB.poi_list |= src
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Engineering" = 0))
	investigate_log("has been created.", "supermatter")
	if(is_main_engine)
		GLOB.main_supermatter_engine = src
	soundloop = new(list(src), TRUE)

/obj/machinery/atmospherics/supermatter_crystal/Destroy()
	if(warp)
		vis_contents -= warp
		QDEL_NULL(warp)
	investigate_log("has been destroyed.", "supermatter")
	SSair.atmos_machinery -= src
	QDEL_NULL(radio)
	GLOB.poi_list -= src
	if(!processes)
		GLOB.frozen_atom_list -= src
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	QDEL_NULL(soundloop)
	QDEL_NULL(darkness_effects)
	return ..()

/obj/machinery/atmospherics/supermatter_crystal/examine(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(!HAS_TRAIT(H, TRAIT_MESON_VISION) && !HAS_TRAIT(H, SM_HALLUCINATION_IMMUNE) && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
			. += "<span class='danger'>You get headaches just from looking at it.</span>"
	. += "<span class='notice'>When actived by an item hitting this awe-inspiring feat of engineering, it emits radiation and heat. This is the basis of the use of the pseudo-perpetual energy source, the supermatter crystal.</span>"
	. +="<span class='notice'>Any object that touches [src] instantly turns to dust, be it complex as a human or as simple as a metal rod. These bursts of energy can cause hallucinations if meson scanners are not worn near the crystal.</span>"
	if(isAntag(user))
		. += "<span class='warning'>Although a T.E.G. is more costly, there's a damn good reason the syndicate doesn't use this. If the integrity of [src] dips to 0%, perhaps from overheating, the supermatter will violently explode destroying nearly everything even somewhat close to it and releasing massive amounts of radiation.</span>"
	if(moveable)
		. += "<span class='notice'>It can be [anchored ? "unfastened from" : "fastened to"] the floor with a wrench.</span>"

/obj/machinery/atmospherics/supermatter_crystal/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	var/integrity = get_integrity()
	if(integrity < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	if(integrity < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(integrity < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((integrity < SUPERMATTER_WARNING_PERCENT) || (air.temperature > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.temperature > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/atmospherics/supermatter_crystal/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
			GLOB.major_announcement.Announce("WARNING, REACTOR CORE IS IN CRITICAL CHARGE!", "SUPERMATTER: STATUS CRITICAL", 'modular_ss220/aesthetics_sounds/sound/supermatter/meltdown.ogg') //SS220 EDIT - ADDITION
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
			GLOB.major_announcement.Announce("WARNING, CORE OVERHEATTING. NUCLEAR KNOCKDOWN IMMINENT!", "SUPERMATTER: STATUS CRITICAL", 'modular_ss220/aesthetics_sounds/sound/supermatter/core_overheating.ogg') //SS220 EDIT - ADDITION
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/atmospherics/supermatter_crystal/proc/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/atmospherics/supermatter_crystal/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE

	var/image/causality_field = image(icon, null, "causality_field")
	add_overlay(causality_field)

	var/speaking = "[emergency_alert] The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated."
	for(var/mob/M in GLOB.player_list) // for all players
		var/turf/T = get_turf(M)
		if(istype(T) && atoms_share_level(T, src)) // if the player is on the same zlevel as the SM shared
			SEND_SOUND(M, sound('sound/machines/engine_alert2.ogg')) // then send them the sound file
	radio.autosay(speaking, name, null, list(z))
	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(!processes) // Stop exploding if you're frozen by an admin, damn you
			cut_overlay(causality_field, TRUE)
			final_countdown = FALSE
			damage = explosion_point - 1 // One point below exploding, so it will re-start the countdown once unfrozen
			return
		if(damage < explosion_point) // Cutting it a bit close there engineers
			radio.autosay("[safe_alert] Failsafe has been disengaged.", name, null, list(z))
			cut_overlay(causality_field, TRUE)
			final_countdown = FALSE
			remove_filter(list("outline", "icon"))
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(10)
			continue
		else if(i > 50)
			speaking = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
		else
			speaking = "[i*0.1]..."
		radio.autosay(speaking, name, null, list(z))
		sleep(10)

	explode()

/obj/machinery/atmospherics/supermatter_crystal/proc/explode()
	SSblackbox.record_feedback("amount", "supermatter_delaminations", 1)
	for(var/mob in GLOB.alive_mob_list)
		var/mob/living/L = mob
		if(istype(L) && atoms_share_level(L, src))
			if(ishuman(mob))
				//Hilariously enough, running into a closet should make you get hit the hardest.
				var/mob/living/carbon/human/H = mob
				var/hallucination_amount = (max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1))))) SECONDS
				H.AdjustHallucinate(hallucination_amount)
			var/rads = DETONATION_RADS * sqrt(1 / (get_dist(L, src) + 1))
			L.rad_act(rads)

	var/turf/T = get_turf(src)
	var/super_matter_charge_sound = sound('sound/magic/charge.ogg')
	for(var/player in GLOB.player_list)
		var/mob/M = player
		var/turf/mob_turf = get_turf(M)
		if(atoms_share_level(T, mob_turf))
			SEND_SOUND(M, super_matter_charge_sound)

			if(atoms_share_level(M, src))
				to_chat(M, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			else
				to_chat(M, "<span class='boldannounce'>You hold onto \the [M.loc] as hard as you can, as reality distorts around you. You feel safe.</span>")

	if(combined_gas > MOLE_PENALTY_THRESHOLD)
		investigate_log("has collapsed into a singularity.", "supermatter")
		if(T)
			var/obj/singularity/S = new(T)
			S.energy = 800
			S.consume(src)
			return //No boom for me sir
	else if(power > POWER_PENALTY_THRESHOLD)
		investigate_log("has spawned additional energy balls.", "supermatter")
		if(T)
			var/obj/singularity/energy_ball/E = new(T)
			E.energy = 200 //Gets us about 9 balls
//	else if(power > EVENT_POWER_PENALTY_THRESHOLD && prob(power/50) && !istype(src, /obj/machinery/atmospherics/supermatter_crystal/shard))
//		var/datum/round_event_control/crystal_invasion/crystals = new/datum/round_event_control/crystal_invasion
//		crystals.runEvent()
//		return //No boom for me sir
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	playsound(src, 'modular_ss220/aesthetics_sounds/sound/supermatter/explode.ogg', 100, FALSE, 40, 30, falloff_distance = 10) //SS220 EDIT - ADDITION
	explosion(get_turf(T), explosion_power * max(gasmix_power_ratio, 0.205) * 0.5 , explosion_power * max(gasmix_power_ratio, 0.205) + 2, explosion_power * max(gasmix_power_ratio, 0.205) + 4 , explosion_power * max(gasmix_power_ratio, 0.205) + 6, 1, 1)
	qdel(src)

/obj/machinery/atmospherics/supermatter_crystal/process_atmos()
	if(!processes) //Just fuck me up bro
		return
	var/turf/T = loc

	if(isnull(T))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(T)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(T.density)
		var/turf/did_it_melt = T.ChangeTurf(T.baseturf)
		if(!did_it_melt.density) //In case some joker finds way to place these on indestructible walls
			visible_message("<span class='warning'>[src] melts through [T]!</span>")
		return

	try_events()
	if(power > 100)
		if(!has_been_powered)
			enable_for_the_first_time()
	//We vary volume by power, and handle OH FUCK FUSION IN COOLING LOOP noises.
	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
		if(damage >= 300)
			playsound(src, "smdelam", max(50, aggression), FALSE, 40, 30, falloff_distance = 10, channel = CHANNEL_ENGINE)
		else
			playsound(src, "smcalm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10, channel = CHANNEL_ENGINE)
		var/next_sound = round((100 - aggression) * 5)
		last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = T.return_air()

	var/datum/gas_mixture/removed
	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed = new()
	damage_archived = damage
	if(!removed || !removed.total_moles() || isspaceturf(T)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power / 1000) * DAMAGE_INCREASE_MULTIPLIER, 0.1) // always does at least some damage
	else
		if(takes_damage)
			//causing damage
			//Due to DAMAGE_INCREASE_MULTIPLIER, we only deal one 4th of the damage the statements otherwise would cause

			//((((some value between 0.5 and 1 * temp - ((273.15 + 40) * some values between 1 and 10)) * some number between 0.25 and knock your socks off / 150) * 0.25
			//Heat and mols account for each other, a lot of hot mols are more damaging then a few
			//Mols start to have a positive effect on damage after 350
			damage = max(damage + (max(clamp(removed.total_moles() / 200, 0.5, 1) * removed.temperature - ((T0C + heat_penalty_threshold)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Power only starts affecting damage when it is above 5000
			damage = max(damage + (max(power - POWER_PENALTY_THRESHOLD, 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Molar count only starts affecting damage when it is above 1800
			damage = max(damage + (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

			//There might be a way to integrate healing and hurting via heat
			//healing damage
			if(combined_gas < MOLE_PENALTY_THRESHOLD)
				//Only has a net positive effect when the temp is below 313.15, heals up to 2 damage. Psycologists increase this temp min by up to 45
				damage = max(damage + (min(removed.temperature - (T0C + heat_penalty_threshold), 0) / 150 ), 0)

			//Check for holes in the SM inner chamber
			for(var/t in RANGE_TURFS(1, loc))
				if(!isspaceturf(t))
					continue
				var/turf/turf_to_check = t
				if(length(turf_to_check.atmos_adjacent_turfs))
					var/integrity = get_integrity()
					if(integrity < 10)
						damage += clamp((power * 0.0005) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 25)
						damage += clamp((power * 0.0009) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 45)
						damage += clamp((power * 0.005) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					else if(integrity < 75)
						damage += clamp((power * 0.002) * DAMAGE_INCREASE_MULTIPLIER, 0, MAX_SPACE_EXPOSURE_DAMAGE)
					break
			//caps damage rate

			//Takes the lower number between archived damage + (1.8) and damage
			//This means we can only deal 1.8 damage per function call
			damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point),damage)

		//calculating gas related values
		combined_gas = max(removed.total_moles(), 0)

		plasmacomp = max(removed.toxins / combined_gas, 0)
		o2comp = max(removed.oxygen / combined_gas, 0)
		co2comp = max(removed.carbon_dioxide / combined_gas, 0)
		n2ocomp = max(removed.sleeping_agent / combined_gas, 0)
		n2comp = max(removed.nitrogen / combined_gas, 0)

		gasmix_power_ratio = min(max(plasmacomp + o2comp + co2comp - n2comp, 0), 1)

		dynamic_heat_modifier = max((plasmacomp * PLASMA_HEAT_PENALTY) + (o2comp * OXYGEN_HEAT_PENALTY) + (co2comp * CO2_HEAT_PENALTY) + (n2comp * NITROGEN_HEAT_PENALTY), 0.5)
		dynamic_heat_resistance = max(n2ocomp * N2O_HEAT_RESISTANCE, 1)

		power_transmission_bonus = max((plasmacomp * PLASMA_TRANSMIT_MODIFIER) + (o2comp * OXYGEN_TRANSMIT_MODIFIER), 0)

		//more moles of gases are harder to heat than fewer, so let's scale heat damage around them
		mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 0.25)

		if(combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && co2comp > POWERLOSS_INHIBITION_GAS_THRESHOLD)
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling + clamp(co2comp - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
		else
			powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling - 0.05, 0, 1)
		//Ranges from 0 to 1(1-(value between 0 and 1 * ranges from 1 to 1.5(mol / 500)))
		//We take the mol count, and scale it to be our inhibitor
		powerloss_inhibitor = clamp(1 - (powerloss_dynamic_scaling * clamp(combined_gas / POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD, 1 , 1.5)), 0 , 1)

		//Releases stored power into the general pool
		//We get this by consuming shit or being scalpeled
		if(matter_power && power_changes)
			//We base our removed power off one 10th of the matter_power.
			var/removed_matter = max(matter_power / MATTER_POWER_CONVERSION, 40)
			//Adds at least 40 power
			power = max(power + removed_matter, 0)
			//Removes at least 40 matter power
			matter_power = max(matter_power - removed_matter, 0)

		var/temp_factor = 50
		if(gasmix_power_ratio > 0.8)
			//with a perfect gas mix, make the power less based on heat
			icon_state = "[base_icon_state]_glow"
		else
			//in normal mode, base the produced energy around the heat
			temp_factor = 30
			icon_state = base_icon_state


		if(power_changes)
			power = max((removed.temperature * temp_factor / T0C) * gasmix_power_ratio + power, 0)

		if(prob(50))

			radiation_pulse(src, power * max(0, (1 + (power_transmission_bonus / 10))))

		//Power * 0.55 * a value between 1 and 0.8
		var/device_energy = power * REACTION_POWER_MODIFIER

		//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
		//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
		//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
		//Since the core is effectively "cold"

		//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
		//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
		//Power * 0.55 * (some value between 1.5 and 23) / 5
		removed.temperature += (((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER) * heat_multiplier)
		//We can only emit so much heat, that being 57500
		removed.temperature = max(0, min(removed.temperature, 2500 * dynamic_heat_modifier))

		//Calculate how much gas to release
		//Varies based on power and gas content
		removed.toxins += max(((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER) * gas_multiplier, 0)
		//Varies based on power, gas content, and heat
		removed.oxygen += max((((device_energy + removed.temperature * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER) * gas_multiplier, 0)

		if(produces_gas)
			env.merge(removed)
			air_update_turf()

	//Makes em go mad and accumulate rads.
	for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(power))) // If they can see it without mesons on.  Bad on them.
		if(!HAS_TRAIT(l, TRAIT_MESON_VISION) && !HAS_TRAIT(l, SM_HALLUCINATION_IMMUNE))
			var/D = sqrt(1 / max(1, get_dist(l, src)))
			var/hallucination_amount = power * hallucination_power * D
			l.AdjustHallucinate(hallucination_amount, 0, 200 SECONDS)
	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / max(get_dist(l, src), 1) )
		l.rad_act(rads)

	//Transitions between one function and another, one we use for the fast inital startup, the other is used to prevent errors with fusion temperatures.
	//Use of the second function improves the power gain imparted by using co2
	if(power_changes)
		power = max((power - min(((power / 500) ** 3) * powerloss_inhibitor, power * 0.83 * powerloss_inhibitor) + power_additive), 0)
	//After this point power is lowered
	//This wraps around to the begining of the function
	//Handle high power zaps/anomaly generation
	if(power > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point) //If the power is above 5000 or if the damage is above 550
		var/range = 4
		zap_cutoff = 1500
		if(removed && removed.return_pressure() > 0 && removed.return_temperature() > 0)
			//You may be able to freeze the zapstate of the engine with good planning, we'll see
			zap_cutoff = clamp(3000 - (power * (removed.total_moles()) / 10) / removed.return_temperature(), 350, 3000)//If the core is cold, it's easier to jump, ditto if there are a lot of mols
			//We should always be able to zap our way out of the default enclosure
			//See supermatter_zap() for more details
			range = clamp(power / removed.return_pressure() * 10, 2, 7)
		var/flags = ZAP_SUPERMATTER_FLAGS
		var/zap_count = 0
		//Deal with power zaps
		switch(power)
			if(POWER_PENALTY_THRESHOLD to SEVERE_POWER_PENALTY_THRESHOLD)
				zap_icon = DEFAULT_ZAP_ICON_STATE
				zap_count = 2
			if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
				zap_icon = SLIGHTLY_CHARGED_ZAP_ICON_STATE
				//Uncaps the zap damage, it's maxed by the input power
				//Objects take damage now
				flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
				zap_count = 3
			if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
				zap_icon = OVER_9000_ZAP_ICON_STATE
				//It'll stun more now, and damage will hit harder, gloves are no garentee.
				//Machines go boom
				flags |= (ZAP_MOB_STUN | ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
				zap_count = 4
		//Now we deal with damage shit
		if(damage > damage_penalty_point && prob(20))
			zap_count += 1

		if(zap_count >= 1)
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10, channel = CHANNEL_ENGINE)
			for(var/i in 1 to zap_count)
				supermatter_zap(src, range, clamp(power*2, 4000, 20000), flags)

		if(prob(5))
			supermatter_anomaly_gen(src, FLUX_ANOMALY, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
			supermatter_anomaly_gen(src, GRAVITATIONAL_ANOMALY, rand(5, 10))
		if((power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && power > POWER_PENALTY_THRESHOLD))
			supermatter_anomaly_gen(src, CRYO_ANOMALY, rand(5, 10))

	if(prob(15))
		supermatter_pull(loc, min(power / 850, 3)) //850, 1700, 2550
	lights()
	sm_filters()

	//Tells the engi team to get their butt in gear
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_DELAY)
			alarm()

			//Oh shit it's bad, time to freak out
			if(damage > emergency_point)
				radio.autosay("[emergency_alert] Integrity: [get_integrity()]%", name, null, list(z))
				lastwarning = REALTIMEOFDAY
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", "supermatter")
					message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
					has_reached_emergency = TRUE
			else if(damage >= damage_archived) // The damage is still going up
				radio.autosay("[warning_alert] Integrity: [get_integrity()]%", name, "Engineering", list(z))
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY * 5)

			else                                                 // Phew, we're safe
				radio.autosay("[safe_alert] Integrity: [get_integrity()]%", name, "Engineering", list(z))
				lastwarning = REALTIMEOFDAY

			if(power > POWER_PENALTY_THRESHOLD)
				radio.autosay("Warning: Hyperstructure has reached dangerous power level.", name, "Engineering", list(z))
				if(powerloss_inhibitor < 0.5)
					radio.autosay("DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", name, "Engineering", list(z))

			if(combined_gas > MOLE_PENALTY_THRESHOLD)
				radio.autosay("Warning: Critical coolant mass reached.", name, "Engineering", list(z))
		//Boom (Mind blown)
		if(damage > explosion_point)
			countdown()
	return 1

/obj/machinery/atmospherics/supermatter_crystal/bullet_act(obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))
		return FALSE
	if(!istype(Proj.firer, /obj/machinery/power/emitter) && power_changes)
		investigate_log("has been hit by [Proj] fired by [key_name(Proj.firer)]", "supermatter")
	if(Proj.flag != BULLET)
		if(power_changes) //This needs to be here I swear
			power += Proj.damage * bullet_energy
			if(!has_been_powered)
				enable_for_the_first_time()
	else if(takes_damage)
		damage += Proj.damage * bullet_energy
	return FALSE

/obj/machinery/atmospherics/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.", "singulo")
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	var/supermatter_sound = sound('sound/effects/supermatter.ogg')
	for(var/M in GLOB.player_list)
		if(atoms_share_level(M, src))
			SEND_SOUND(M, supermatter_sound) //everyone goan know bout this
			to_chat(M, "<span class='boldannounce'>A horrible screeching fills your ears, and a wave of dread washes over you...</span>")
	qdel(src)
	return gain

/obj/machinery/atmospherics/supermatter_crystal/blob_act(obj/structure/blob/B)
	if(B && !isspaceturf(loc)) //does nothing in space
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
		damage += B.obj_integrity * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
		if(B.obj_integrity > 100)
			B.visible_message("<span class='danger'>[B] strikes at [src] and flinches away!</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			B.take_damage(100, BURN)
		else
			B.visible_message("<span class='danger'>[B] strikes at [src] and rapidly flashes to ash.</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			Consume(B)

/obj/machinery/atmospherics/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	investigate_log("has consumed the brain of [key_name(C)] after being touched with telekinesis", "supermatter")
	C.visible_message("<span class='danger'>[C] suddenly slumps over.</span>", \
		"<span class='userdanger'>As you mentally focus on the supermatter you feel the contents of your skull start melting away. That was a really dense idea.</span>")
	var/obj/item/organ/internal/brain/B = C.get_int_organ(/obj/item/organ/internal/brain)
	C.ghostize(0)
	if(B)
		B.remove(C)
		qdel(B)

/obj/machinery/atmospherics/supermatter_crystal/attack_alien(mob/user)
	dust_mob(user, cause = "alien attack")

/obj/machinery/atmospherics/supermatter_crystal/attack_animal(mob/living/simple_animal/S)
	var/murder
	if(!S.melee_damage_upper && !S.melee_damage_lower)
		murder = S.friendly
	else
		murder = S.attacktext
	dust_mob(S, \
	"<span class='danger'>[S] unwisely [murder] [src], and [S.p_their()] body burns brilliantly before flashing into ash!</span>", \
	"<span class='userdanger'>You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops.</span>", \
	"simple animal attack")

/obj/machinery/atmospherics/supermatter_crystal/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/obj/machinery/atmospherics/supermatter_crystal/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/supermatter_crystal/attack_hand(mob/living/user)
	..()
	if(HAS_TRAIT(user, TRAIT_SUPERMATTER_IMMUNE))
		user.visible_message("<span class='notice'>[user] reaches out and pokes [src] harmlessly...somehow.</span>", "<span class='notice'>You poke [src].</span>")
		return
	dust_mob(user, cause = "hand")

/obj/machinery/atmospherics/supermatter_crystal/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE)
		return
	if(!vis_msg)
		vis_msg = "<span class='danger'>[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!</span>"
	if(!mob_msg)
		mob_msg = "<span class='userdanger'>You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>"
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, "<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", "supermatter")
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/obj/machinery/atmospherics/supermatter_crystal/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I) || (I.flags & ABSTRACT) || !istype(user))
		return
	if(moveable && default_unfasten_wrench(user, I, time = 20))
		return

	if(istype(I, /obj/item/scalpel/supermatter))
		if(!ishuman(user))
			return

		var/mob/living/carbon/human/H = user
		var/obj/item/scalpel/supermatter/scalpel = I

		if(!scalpel.uses_left)
			to_chat(H, "<span class='warning'>[scalpel] isn't sharp enough to carve a sliver off of [src]!</span>")
			return

		var/obj/item/nuke_core/supermatter_sliver/sliver = carve_sliver(H)
		if(sliver)
			scalpel.uses_left--
			if(!scalpel.uses_left)
				to_chat(H, "<span class='boldwarning'>A tiny piece falls off of [scalpel]'s blade, rendering it useless!</span>")

			var/obj/item/retractor/supermatter/tongs = H.is_in_hands(/obj/item/retractor/supermatter)

			if(tongs && !tongs.sliver)
				tongs.sliver = sliver
				sliver.forceMove(tongs)
				tongs.icon_state = "supermatter_tongs_loaded"
				tongs.item_state = "supermatter_tongs_loaded"
				to_chat(H, "<span class='notice'>You pick up [sliver] with [tongs]!</span>")

		return

	if(istype(I, /obj/item/supermatter_halberd))
		carve_sliver(user)
		return

	if(istype(I, /obj/item/retractor/supermatter))
		to_chat(user, "<span class='notice'>[I] bounces off [src], you need to cut a sliver off first!</span>")
	else if(user.drop_item())
		user.visible_message("<span class='danger'>As [user] touches [src] with \a [I], silence fills the room...</span>",\
			"<span class='userdanger'>You touch [src] with [I], and everything suddenly goes silent.</span>\n<span class='notice'>[I] flashes into dust as you flinch away from [src].</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
		investigate_log("has been attacked ([I]) by [key_name(user)]", "supermatter")
		Consume(I)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(src, 150, 4)

/obj/machinery/atmospherics/supermatter_crystal/Bumped(atom/movable/AM)

	if(HAS_TRAIT(AM, TRAIT_SUPERMATTER_IMMUNE))
		return

	if(isliving(AM))
		AM.visible_message("<span class='danger'>[AM] slams into [src] inducing a resonance... [AM.p_their()] body starts to glow and burst into flames before flashing into dust!</span>",\
		"<span class='userdanger'>You slam into [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !iseffect(AM))
		AM.visible_message("<span class='danger'>[AM] smacks into [src] and rapidly flashes to ash.</span>", null,\
		"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(AM)

/obj/machinery/atmospherics/supermatter_crystal/Bump(atom/A, yes)
	..()
	if(!istype(A, /obj/machinery/atmospherics/supermatter_crystal))
		Bumped(A)

/obj/machinery/atmospherics/supermatter_crystal/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		if(user.status_flags & GODMODE)
			return
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", "supermatter")
		user.dust()
		if(power_changes)
			matter_power += 200
	else if(istype(AM, /obj/singularity))
		return
	else if(isobj(AM))
		if(!iseffect(AM))
			var/suspicion = ""
			if(AM.fingerprintslast)
				suspicion = "last touched by [AM.fingerprintslast]"
			message_admins("[src] has consumed [AM], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [AM] - [suspicion].", "supermatter")
			if(istype(AM, /obj/machinery/atmospherics/supermatter_crystal))
				power += 5000//releases A LOT of power
				matter_power += 500000
				damage += 180//drops the integrety by 20%
				AM.visible_message("<span class='danger'>[AM] smacks into [src], rapidly flashing blasts of pure energy. The energy inside [src] undergoes superradiance scattering!</span>", null,\
				"<span class='italics'>You hear a loud crack as a wave of heat washes over you.</span>")
		qdel(AM)
	if(!iseffect(AM) && power_changes)
		matter_power += 200

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, 3000, 2, TRUE)
	for(var/mob/living/L in range(10))
		investigate_log("has irradiated [key_name(L)] after consuming [AM].", "supermatter")
		if(L in view())
			L.show_message("<span class='danger'>As [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			L.show_message("<span class='italics'>You hear an unearthly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)

/obj/machinery/atmospherics/supermatter_crystal/proc/sm_filters()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 125) : 1, (gasmix_power_ratio> 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR), clamp(damage/600, 1, 10), clamp(damage/10, 12, 100))
	// Filter animation persists even if the filter itself is changed externally.
	// Probably prone to breaking. Treat with suspicion.
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

	if(power > POWER_PENALTY_THRESHOLD)
		ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 175) : 1, SUPERMATTER_TESLA_COLOUR, clamp(damage/300, 1, 20), clamp(damage/5, 12, 200))
		if(prob(25))
			new /obj/effect/warp_effect/bsg(get_turf(src)) //Some extra visual effect to the shocking sm which is a bit less interesting.
		if(final_countdown)
			add_filter(name = "icon", priority = 2, params = list(
				type = "layer",
				icon = new/icon('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball", frame = rand(1,12)),
				flags = FILTER_UNDERLAY
			))
		else
			remove_filter("icon")

	if(combined_gas > MOLE_PENALTY_THRESHOLD)
		ray_filter_helper(1, power ? clamp((damage/100) * power, 50, 125) : 1, SUPERMATTER_SINGULARITY_RAYS_COLOUR, clamp(damage / 300, 1, 30), clamp(damage / 5, 12, 300))

		add_filter(name = "outline", priority = 2, params = list(
			type = "outline",
			size = 1,
			color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR
		))
		if(!warp)
			warp = new(src)
			vis_contents += warp
		if(pulse_stage == 4)
			animate(warp, time = 6, transform = matrix().Scale(0.5,0.5))
			animate(time = 14, transform = matrix())
			pulse_stage = 0
		else
			pulse_stage++
		if(final_countdown)
			add_filter(name = "icon", priority = 3, params = list(
				type = "layer",
				icon = new/icon('icons/effects/96x96.dmi', "singularity_s3", frame = rand(1,8)),
				flags = FILTER_OVERLAY
			))
		else
			remove_filter("icon")
	else
		vis_contents -= warp
		remove_filter("outline")
		QDEL_NULL(warp)

/obj/machinery/atmospherics/supermatter_crystal/proc/carve_sliver(mob/living/user)
	to_chat(user, "<span class='notice'>You begin carving a sliver off of [src]...</span>")
	if(do_after_once(user, 4 SECONDS, FALSE, src))
		to_chat(user, "<span class='danger'>You carve a sliver off of [src], and it begins to react violently!</span>")
		matter_power += 800

		var/obj/item/nuke_core/supermatter_sliver/S = new /obj/item/nuke_core/supermatter_sliver(drop_location())
		return S

// Change how bright the rock is
/obj/machinery/atmospherics/supermatter_crystal/proc/lights()
	set_light(
		l_range = 4 + power / 200,
		l_power = 1 + power / 1000,
		l_color = gasmix_power_ratio > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR,
	)

	if(power > POWER_PENALTY_THRESHOLD)
		set_light(
			l_range = 4 + clamp(damage * power, 50, 500),
			l_power = 3,
			l_color = SUPERMATTER_TESLA_COLOUR,
		)
	if(combined_gas > MOLE_PENALTY_THRESHOLD && get_integrity() > SUPERMATTER_DANGER_PERCENT)
		set_light(
			l_range = 4 + clamp((450 - damage) / 10, 1, 50),
			l_power = 3,
			l_color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR,
		)
	if(!combined_gas > MOLE_PENALTY_THRESHOLD || !get_integrity() < SUPERMATTER_DANGER_PERCENT)
		for(var/obj/D in darkness_effects)
			qdel(D)
		return

	var/darkness_strength = clamp((damage - 450) / 75, 1, 8) / 2
	var/darkness_aoe = clamp((damage - 450) / 25, 1, 25)
	set_light(
		l_range = 4 + darkness_aoe,
		l_power = -1 - darkness_strength,
		l_color = "#ddd6cf")
	if(!length(darkness_effects) && moveable) //Don't do this on movable sms oh god. Ideally don't do this at all, but hey, that's lightning for you
		darkness_effects += new /obj/effect/abstract(locate(x-3,y+3,z))
		darkness_effects += new /obj/effect/abstract(locate(x+3,y+3,z))
		darkness_effects += new /obj/effect/abstract(locate(x-3,y-3,z))
		darkness_effects += new /obj/effect/abstract(locate(x+3,y-3,z))
	else
		for(var/obj/O in darkness_effects)
			O.set_light(
				l_range = 0 + darkness_aoe,
				l_power = -1 - darkness_strength / 1.25,
				l_color = "#ddd6cf")

/obj/effect/warp_effect/supermatter
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/light_352.dmi'
	icon_state = "light"
	pixel_x = -176
	pixel_y = -176

/obj/machinery/atmospherics/supermatter_crystal/engine
	is_main_engine = TRUE

/obj/machinery/atmospherics/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	base_icon_state = "darkmatter_shard"
	icon_state = "darkmatter_shard"
	anchored = FALSE
	gasefficency = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE

/obj/machinery/atmospherics/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	takes_damage = FALSE
	produces_gas = FALSE
	power_changes = FALSE
	processes = FALSE //SHUT IT DOWN
	moveable = FALSE
	anchored = TRUE

/obj/machinery/atmospherics/supermatter_crystal/shard/hugbox/fakecrystal //Hugbox shard with crystal visuals, used in the Supermatter/Hyperfractal shuttle
	name = "supermatter crystal"
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"

/obj/machinery/atmospherics/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(center, 'sound/weapons/marauder.ogg', 100, TRUE, extrarange = pull_range - world.view, channel = CHANNEL_ENGINE)
	for(var/atom/movable/P in orange(pull_range,center))
		if((P.anchored || P.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //move resist memes.
			if(istype(P, /obj/structure/closet))
				var/obj/structure/closet/toggle = P
				toggle.open()
			continue
		if(ismob(P))
			var/mob/M = P
			if(M.mob_negates_gravity())
				continue //You can't pull someone nailed to the deck
			if(HAS_TRAIT(M, TRAIT_SUPERMATTER_IMMUNE))
				continue
			else if(M.buckled)
				var/atom/movable/buckler = M.buckled
				if(buckler.unbuckle_mob(M, TRUE))
					visible_message("<span class='danger'>[src]'s sheer force rips [M] away from [buckler]!</span>")
		step_towards(P,center)

/obj/machinery/atmospherics/supermatter_crystal/proc/supermatter_anomaly_gen(turf/anomalycenter, type = FLUX_ANOMALY, anomalyrange = 5)
	var/turf/L = pick(orange(anomalyrange, anomalycenter))
	if(L)
		switch(type)
			if(FLUX_ANOMALY)
				var/obj/effect/anomaly/flux/A = new(L, 300, FALSE)
				A.explosive = FALSE
			if(GRAVITATIONAL_ANOMALY)
				new /obj/effect/anomaly/grav(L, 250, FALSE, FALSE)
			if(CRYO_ANOMALY)
				new /obj/effect/anomaly/cryo(L, 200, FALSE)

/obj/machinery/atmospherics/supermatter_crystal/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 4000, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list())
	if(QDELETED(zapstart))
		return
	. = zapstart.dir
	//If the strength of the zap decays past the cutoff, we stop
	if(zap_str < zap_cutoff)
		return
	var/atom/target
	var/target_type = LOWEST
	var/list/arctargets = list()
	//Making a new copy so additons further down the recursion do not mess with other arcs
	//Lets put this ourself into the do not hit list, so we don't curve back to hit the same thing twice with one arc
	for(var/test in oview(zapstart, range))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(targets_hit, test))
			continue

		if(target_type > COIL)
			continue

		if(istype(test, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/coil = test
			if(coil.anchored && !coil.being_shocked && !coil.panel_open && prob(70)) //Diversity of death
				if(target_type != COIL)
					arctargets = list()
				arctargets += test
				target_type = COIL

		if(target_type > ROD)
			continue

		if(istype(test, /obj/machinery/power/grounding_rod))
			var/obj/machinery/power/grounding_rod/rod = test
			//We're adding machine damaging effects, rods need to be surefire
			if(rod.anchored && !rod.panel_open)
				if(target_type != ROD)
					arctargets = list()
				arctargets += test
				target_type = ROD

		if(target_type > LIVING)
			continue

		if(isliving(test))
			var/mob/living/alive = test
			if(!(HAS_TRAIT(alive, TRAIT_TESLA_SHOCKIMMUNE)) && !(alive.flags_2 & SHOCKED_2) && alive.stat != DEAD && prob(20)) //let's not hit all the engineers with every beam and/or segment of the arc
				if(target_type != LIVING)
					arctargets = list()
				arctargets += test
				target_type = LIVING

		if(target_type > MACHINERY)
			continue

		if(ismachinery(test))
			var/obj/machinery/machine = test
			if(!machine.being_shocked && prob(40))
				if(target_type != MACHINERY)
					arctargets = list()
				arctargets += test
				target_type = MACHINERY

		if(target_type > OBJECT)
			continue

		if(isobj(test))
			var/obj/object = test
			if(!object.being_shocked)
				if(target_type != OBJECT)
					arctargets = list()
				arctargets += test
				target_type = OBJECT

	if(length(arctargets)) //Pick from our pool
		target = pick(arctargets)

	if(!QDELETED(target)) //If we found something
		//Do the animation to zap to it from here
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
			LAZYSET(targets_hit, target, TRUE)
		zapstart.Beam(target, icon_state = zap_icon, time = 5)
		var/zapdir = get_dir(zapstart, target)
		if(zapdir)
			. = zapdir

		//Going boom should be rareish
		if(prob(80))
			zap_flags &= ~ZAP_MACHINE_EXPLOSIVE
		if(target_type == COIL)
			//In the best situation we can expect this to grow up to 2120kw before a delam/IT'S GONE TOO FAR FRED SHUT IT DOWN
			//The formula for power gen is zap_str * zap_mod / 2 * capacitor rating, between 1 and 4
			var/multi = 10
			switch(power)//Between 7k and 9k it's 20, above that it's 40
				if(SEVERE_POWER_PENALTY_THRESHOLD to CRITICAL_POWER_PENALTY_THRESHOLD)
					multi = 20
				if(CRITICAL_POWER_PENALTY_THRESHOLD to INFINITY)
					multi = 40
			target.zap_act(zap_str * multi, zap_flags)
			zap_str /= 3 //Coils should take a lot out of the power of the zap

		else if(isliving(target))//If we got a fleshbag on our hands
			var/mob/living/creature = target
			creature.set_shocked()
			addtimer(CALLBACK(creature, TYPE_PROC_REF(/mob/living, reset_shocked)), 10)
			//3 shots a human with no resistance. 2 to crit, one to death. This is at at least 10000 power.
			//There's no increase after that because the input power is effectivly capped at 10k
			//Does 1.5 damage at the least
			var/shock_damage = ((zap_flags & ZAP_MOB_DAMAGE) ? (power / 200) - 10 : rand(5, 10))
			creature.electrocute_act(shock_damage, "Supermatter Discharge Bolt", 1, ((zap_flags & ZAP_MOB_STUN) ? SHOCK_TESLA : SHOCK_NOSTUN))
			zap_str /= 1.5 //Meatsacks are conductive, makes working in pairs more destructive

		else
			zap_str = target.zap_act(zap_str, zap_flags)
		//This gotdamn variable is a boomer and keeps giving me problems
		var/turf/T = get_turf(target)
		var/pressure = 1
		if(T?.return_air())
			var/datum/gas_mixture/G = T.return_air()
			pressure = max(1, G.return_pressure())
		//We get our range with the strength of the zap and the pressure, the higher the former and the lower the latter the better
		var/new_range = clamp(zap_str / pressure * 10, 2, 7)
		var/zap_count = 1
		if(prob(5))
			zap_str -= (zap_str / 10)
			zap_count += 1
		for(var/j in 1 to zap_count)
			if(zap_count > 1)
				targets_hit = targets_hit.Copy() //Pass by ref begone
			supermatter_zap(target, new_range, zap_str, zap_flags, targets_hit)

/obj/machinery/atmospherics/supermatter_crystal/proc/manual_start(amount)
	has_been_powered = TRUE
	power += amount
	message_admins("[src] has been activated and given an increase EER of [amount] at [ADMIN_JMP(src)]")

/obj/machinery/atmospherics/supermatter_crystal/proc/make_next_event_time()
	// Some completely random bullshit to make a "bell curve"
	var/fake_time = rand(5 MINUTES, 25 MINUTES)
	if(fake_time < 15 MINUTES && prob(30))
		fake_time += rand(2 MINUTES, 10 MINUTES)
	else if(fake_time > 15 MINUTES && prob(30))
		fake_time -= rand(2 MINUTES, 10 MINUTES)
	next_event_time = fake_time + world.time

/obj/machinery/atmospherics/supermatter_crystal/proc/try_events()
	if(has_been_powered == FALSE)
		return
	if(!next_event_time) // for when the SM starts
		make_next_event_time()
		return
	if(world.time < next_event_time)
		return
	if(event_active)
		return
	var/static/list/events = list(/datum/supermatter_event/delta_tier = 40,
								/datum/supermatter_event/charlie_tier = 40,
								/datum/supermatter_event/bravo_tier = 15,
								/datum/supermatter_event/alpha_tier = 5,
								/datum/supermatter_event/sierra_tier = 1)

	var/datum/supermatter_event/event = pick(subtypesof(pickweight(events)))
	if(istype(event, /datum/supermatter_event/sierra_tier) && has_run_sclass)
		make_next_event_time()
		return // We're only gonna have one s-class per round, take a break engineers
	run_event(event)
	make_next_event_time()

/obj/machinery/atmospherics/supermatter_crystal/proc/run_event(datum/supermatter_event/event) // mostly admin testing and stuff
	if(ispath(event))
		event = new event(src)
	if(!istype(event))
		log_debug("Attempted supermatter event aborted due to incorrect path. Incorrect path type: [event.type].")
		return
	event.start_event()

/obj/machinery/atmospherics/supermatter_crystal/proc/enable_for_the_first_time()
	investigate_log("has been powered for the first time.", "supermatter")
	message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
	has_been_powered = TRUE
	make_next_event_time()

#undef HALLUCINATION_RANGE
#undef GRAVITATIONAL_ANOMALY
#undef FLUX_ANOMALY
#undef CRYO_ANOMALY
#undef COIL
#undef ROD
#undef LIVING
#undef MACHINERY
#undef OBJECT
#undef LOWEST
