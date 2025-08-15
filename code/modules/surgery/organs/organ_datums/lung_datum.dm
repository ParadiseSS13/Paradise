/datum/organ/lungs
	organ_tag = ORGAN_DATUM_LUNGS

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent


	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/tox_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/tox_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/tox_damage_type = TOX

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_types = list(BURN = 1)

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 460
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_types = list(BURN = 1)


/**
 * LUNG ATMOS CODE, VENTURE FURTHER IF YOU DARE!!!
 */

/datum/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	if(H.status_flags & GODMODE)
		return

	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(isspaceturf(H.loc))
			H.adjustOxyLoss(10)
		else
			H.adjustOxyLoss(5)

		if(safe_oxygen_min)
			H.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /atom/movable/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			H.throw_alert("not_enough_nitro", /atom/movable/screen/alert/not_enough_nitro)
		return FALSE


	if(H.health < HEALTH_THRESHOLD_CRIT)
		return FALSE

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath.oxygen())
	var/N2_pp = breath.get_breath_partial_pressure(breath.nitrogen())
	var/Toxins_pp = breath.get_breath_partial_pressure(breath.toxins())
	var/CO2_pp = breath.get_breath_partial_pressure(breath.carbon_dioxide())
	var/SA_pp = breath.get_breath_partial_pressure(breath.sleeping_agent())


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath.oxygen() / safe_oxygen_max / safe_oxygen_max) * 10
			H.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			H.throw_alert("too_much_oxy", /atom/movable/screen/alert/too_much_oxy)
		else
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			handle_too_little_breath(H, O2_pp, safe_oxygen_min, breath.oxygen())
			H.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		else
			H.adjustOxyLoss(-HUMAN_MAX_OXYLOSS)
			H.clear_alert("not_enough_oxy")

		// Exhale
		breath.set_carbon_dioxide(breath.carbon_dioxide() + breath.oxygen())
		breath.set_oxygen(0)

	//-- Nitrogen --//

	//Too much nitrogen!
	if(safe_nitro_max)
		if(N2_pp > safe_nitro_max)
			var/ratio = (breath.nitrogen() / safe_nitro_max) * 10
			H.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			H.throw_alert("too_much_nitro", /atom/movable/screen/alert/too_much_nitro)
		else
			H.clear_alert("too_much_nitro")

	//Too little nitrogen!
	if(safe_nitro_min)
		if(N2_pp < safe_nitro_min)
			handle_too_little_breath(H, N2_pp, safe_nitro_min, breath.nitrogen())
			H.throw_alert("not_enough_nitro", /atom/movable/screen/alert/not_enough_nitro)
		else
			H.adjustOxyLoss(-HUMAN_MAX_OXYLOSS)
			H.clear_alert("not_enough_nitro")

		// Exhale
		breath.set_carbon_dioxide(breath.carbon_dioxide() + breath.nitrogen())
		breath.set_nitrogen(0)

	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Paralyse(6 SECONDS)
				H.apply_damage_type(HUMAN_MAX_OXYLOSS, co2_damage_type) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.apply_damage_type(15, co2_damage_type)
				H.throw_alert("too_much_co2", /atom/movable/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			handle_too_little_breath(H, CO2_pp, safe_co2_min, breath.carbon_dioxide())
			H.throw_alert("not_enough_co2", /atom/movable/screen/alert/not_enough_co2)
		else
			H.adjustOxyLoss(-HUMAN_MAX_OXYLOSS)
			H.clear_alert("not_enough_co2")

		// Exhale
		breath.set_oxygen(breath.oxygen() + breath.carbon_dioxide())
		breath.set_carbon_dioxide(0)


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath.toxins() / safe_toxins_max) * 10
			H.apply_damage_type(clamp(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type)
			H.throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_tox)
		else
			H.clear_alert("too_much_tox")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			handle_too_little_breath(H, Toxins_pp, safe_toxins_min, breath.toxins())
			H.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
		else
			H.adjustOxyLoss(-HUMAN_MAX_OXYLOSS)
			H.clear_alert("not_enough_tox")

		// Exhale
		breath.set_carbon_dioxide(breath.carbon_dioxide() + breath.toxins())
		breath.set_toxins(0)


	//-- TRACES --//

	if(breath.sleeping_agent())	// If there's some other shit in the air lets deal with it here.
		if(SA_pp > SA_para_min)
			H.Paralyse(6 SECONDS) // 6 seconds gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.AdjustSleeping(16 SECONDS, bound_lower = 0, bound_upper = 20 SECONDS)
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))

	handle_breath_temperature(breath, H)

	return TRUE


/datum/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, breath_moles = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	var/available_ratio = clamp(breath_pp / safe_breath_min, 0, 1)
	// Take oxyloss damage scaled to the amount of missing air.
	H.adjustOxyLoss((1 - available_ratio) * HUMAN_MAX_OXYLOSS)


/datum/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature()

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/CM = abs(H.dna.species.coldmod)
		var/TC = 0
		if(breath_temperature < cold_level_3_threshold)
			TC = cold_level_3_damage
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			TC = cold_level_2_damage
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			TC = cold_level_1_damage
		if(TC)
			for(var/D in cold_damage_types)
				if(HAS_TRAIT(H, TRAIT_DRASK_SUPERCOOL))
					TC *= 4
				H.apply_damage_type(TC * CM * cold_damage_types[D], D)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [cold_message] in your [linked_organ.name]!</span>")

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/HM = abs(H.dna.species.heatmod)
		var/TH = 0
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			TH = heat_level_1_damage
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			TH = heat_level_2_damage
		if(breath_temperature > heat_level_3_threshold)
			TH = heat_level_3_damage
		if(TH)
			for(var/D in heat_damage_types)
				H.apply_damage_type(TH * HM * heat_damage_types[D], D)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [hot_message] in your [linked_organ.name]!</span>")


/**
 * Lung atmos code ends here. Thank god...
 */

/datum/organ/lungs/on_successful_emp()
	linked_organ.owner?.LoseBreath(40 SECONDS)

/datum/organ/lungs/on_insert(mob/living/carbon/given_to)
	clear_alerts(given_to)

/datum/organ/lungs/on_replace(mob/living/carbon/human/organ_owner)
	clear_alerts(organ_owner)

/datum/organ/lungs/on_remove(mob/living/carbon/removed_from, special = FALSE)
	clear_alerts(removed_from)

/datum/organ/lungs/proc/clear_alerts(mob/living/carbon/alert_owner)
	for(var/thing in list("oxy", "tox", "co2", "nitro"))
		alert_owner.clear_alert("not_enough_[thing]")
		alert_owner.clear_alert("too_much_[thing]")

/datum/organ/lungs/on_life()
	if(linked_organ.germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			linked_organ.owner.emote("cough")		//respitory tract infection

	if(linked_organ.is_bruised())
		if(prob(2) && !(NO_BLOOD in linked_organ.owner.dna.species.species_traits))
			linked_organ.owner.custom_emote(EMOTE_VISIBLE, "coughs up blood!")
			linked_organ.owner.bleed(1)
		if(prob(4))
			linked_organ.owner.custom_emote(EMOTE_VISIBLE, "gasps for air!")
			linked_organ.owner.AdjustLoseBreath(10 SECONDS)


/datum/organ/lungs/on_prepare_eat(obj/item/food/organ/snorgan)
	snorgan.reagents.add_reagent("salbutamol", 5)


/datum/organ/lungs/vox
	safe_oxygen_min = 0 //We don't breathe this
	safe_oxygen_max = 0.05 //This is toxic to us
	safe_nitro_min = 16 //We breathe THIS!
	oxy_damage_type = TOX //And it poisons us

/datum/organ/lungs/plasmamen
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breathe THIS!
	safe_toxins_max = 0

/datum/organ/lungs/drask
	cold_message = "an invigorating coldness"
	cold_level_3_threshold = 60
	cold_level_1_damage = -COLD_GAS_DAMAGE_LEVEL_1 //They heal when the air is cold
	cold_level_2_damage = -COLD_GAS_DAMAGE_LEVEL_2
	cold_level_3_damage = -COLD_GAS_DAMAGE_LEVEL_3
	cold_damage_types = list(BRUTE = 0.5, BURN = 0.25)

	heat_level_1_threshold = 310
	heat_level_2_threshold = 340
	heat_level_3_threshold = 400

/datum/organ/lungs/tajaran
	cold_level_1_threshold = 240
	cold_level_2_threshold = 180
	cold_level_3_threshold = 100

	heat_level_1_threshold = 340
	heat_level_2_threshold = 380
	heat_level_3_threshold = 440

/datum/organ/lungs/unathi
	cold_level_1_threshold = 280
	cold_level_2_threshold = 220
	cold_level_3_threshold = 140

	heat_level_1_threshold = 505
	heat_level_2_threshold = 540
	heat_level_3_threshold = 600

/datum/organ/lungs/ashwalker
	safe_oxygen_min = 4 // 4x as efficient as regular Unathi, can comfortably breathe on lavaland
	heat_level_1_threshold = 505
	heat_level_2_threshold = 540
	heat_level_3_threshold = 600

	cold_level_1_threshold = 280
	cold_level_2_threshold = 220
	cold_level_3_threshold = 140

/datum/organ/lungs/slime
	cold_level_1_threshold = 280
	cold_level_2_threshold = 240
	cold_level_3_threshold = 200

/datum/organ/lungs/advanced_cyber/New(obj/item/organ/internal/link_em)
	. = ..()
	make_advanced()

/datum/organ/lungs/proc/make_advanced()
	safe_toxins_max = 20
	safe_co2_max = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100
