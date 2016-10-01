/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.
	var/name_plural 			// Pluralized name (since "[name]s" is not always valid)
	var/path 					// Species path
	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/eyes = "eyes_s"                                  // Icon for eyes.
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.
	var/butt_sprite = "human"

	var/primitive_form            // Lesser form, if any (ie. monkey for humans)
	var/greater_form              // Greater form, if any, ie. human for monkeys.
	var/tail                     // Name of tail image in species effects icon file.
	var/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/slowdown = 0              // Passive movement speed malus (or boost, if negative)
	var/silent_steps = 0          // Stops step noises

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/poison_type = "plasma"   // Poisonous air.
	var/exhale_type = "carbon_dioxide"      // Exhaled gas type.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.
	var/cold_env_multiplier = 1 // Damage multiplier for being in a cold environment

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 460 // Heat damage level 3 above this point; used for body temperature
	var/hot_env_multiplier = 1 // Damage multiplier for being in a hot environment
	var/heat_level_3_breathe = 1000 // Heat damage level 3 above this point; used for breathed air temperature

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.

	var/siemens_coeff = 1 //base electrocution coefficient

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/list/atmos_requirements = list(
		"min_oxy" = 16,
		"max_oxy" = 0,
		"min_nitro" = 0,
		"max_nitro" = 0,
		"min_tox" = 0,
		"max_tox" = 0.005,
		"min_co2" = 0,
		"max_co2" = 10,
		"sa_para" = 1,
		"sa_sleep" = 5
		)

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.

	var/total_health = 100
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9	 //damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/list/default_genes = list()

	var/ventcrawler = 0 //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

	var/list/allowed_consumed_mobs = list() //If a species can consume mobs, put the type of mobs it can consume here.

	var/flags = 0       // Various specific features.
	var/clothing_flags = 0 // Underwear and socks.
	var/exotic_blood
	var/bodyflags = 0
	var/dietflags  = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/remains_type = /obj/effect/decal/remains/human //What sort of remains is left behind when the species dusts
	var/base_color      //Used when setting species.

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template
	var/is_small
	var/show_ssd = 1
	var/virus_immune
	var/can_revive_by_healing				// Determines whether or not this species can be revived by simply healing them

	//Death vars.
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	var/list/suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their thumbs into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

	// Language/culture vars.
	var/default_language = "Galactic Common" // Default language is used when 'say' is used without modifiers.
	var/language = "Galactic Common"         // Default racial language, if any.
	var/secondary_langs = list()             // The names of secondary languages that are available to this species.
	var/list/speech_sounds                   // A list of sounds to potentially play when speaking.
	var/list/speech_chance                   // The likelihood of a speech sound playing.
	var/scream_verb = "screams"
	var/male_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	var/female_scream_sound = 'sound/goonstation/voice/female_scream.ogg'

	//Default hair/headacc style vars.
	var/default_hair = "Bald" 		//Default hair style for newly created humans unless otherwise set.
	var/default_hair_colour
	var/default_fhair = "Shaved"	//Default facial hair style for newly created humans unless otherwise set.
	var/default_fhair_colour
	var/default_headacc = "None"	//Default head accessory style for newly created humans unless otherwise set.
	var/default_headacc_colour

	//Defining lists of icon skin tones for species that have them.
	var/list/icon_skin_tones = list()

                              // Determines the organs that the species spawns with and
	var/list/has_organ = list(    // which required-organ checks are conducted.
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes
		)
	var/vision_organ              // If set, this organ is required for vision. Defaults to "eyes" if the species has them.
	var/list/has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest),
		"groin" =  list("path" = /obj/item/organ/external/groin),
		"head" =   list("path" = /obj/item/organ/external/head),
		"l_arm" =  list("path" = /obj/item/organ/external/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/hand),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/foot),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right)
		)
	var/cyborg_type = "Cyborg"
	var/list/proc/species_abilities = list()

/datum/species/New()
	//If the species has eyes, they are the default vision organ
	if(!vision_organ && has_organ["eyes"])
		vision_organ = /obj/item/organ/internal/eyes

	unarmed = new unarmed_type()

/datum/species/proc/get_random_name(var/gender)
	var/datum/language/species_language = all_languages[language]
	return species_language.get_random_name(gender)

/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.

	for(var/obj/item/organ/internal/iorgan in H.internal_organs)
		if(iorgan in H.internal_organs)
			qdel(iorgan)

	for(var/obj/item/organ/organ in H.contents)
		if(organ in H.organs)
			qdel(organ)

	if(H.organs)                  H.organs.Cut()
	if(H.organs_by_name)          H.organs_by_name.Cut()

	H.organs = list()
	H.internal_organs = list()
	H.organs_by_name = list()

	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/O = new limb_path(H)
		organ_data["descriptor"] = O.name

	for(var/index in has_organ)
		var/organ = has_organ[index]
		// organ new code calls `insert` on its own
		new organ(H)

	for(var/name in H.organs_by_name)
		H.organs |= H.organs_by_name[name]

	for(var/obj/item/organ/external/O in H.organs)
		O.owner = H

/datum/species/proc/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/O2_used = 0
	var/N2_used = 0
	var/Tox_used = 0
	var/CO2_used = 0

	//Partial pressure of the O2 in our breath
	var/O2_pp = (breath.oxygen/breath.total_moles()) * breath_pressure
	// Partial pressure of Nitrogen
	var/N2_pp = (breath.nitrogen/breath.total_moles()) * breath_pressure
	// Partial pressure of plasma
	var/Tox_pp = (breath.toxins/breath.total_moles()) * breath_pressure
	// Partial pressure of CO2
	var/CO2_pp = (breath.carbon_dioxide/breath.total_moles()) * breath_pressure

	if(O2_pp < atmos_requirements["min_oxy"])
		if(prob(20))
			spawn(0)
				H.emote("gasp")

		H.failed_last_breath = 1
		if(O2_pp > 0)
			var/ratio = atmos_requirements["min_oxy"] / O2_pp
			H.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.throw_alert("oxy", /obj/screen/alert/oxy)
	else if(atmos_requirements["max_oxy"] && O2_pp > atmos_requirements["max_oxy"])
		var/ratio = (breath.oxygen / atmos_requirements["max_oxy"]) * 1000
		H.adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.throw_alert("oxy", /obj/screen/alert/too_much_oxy)
	else
		H.clear_alert("oxy")
		if(atmos_requirements["min_oxy"]) //species breathes this gas, so, they got their air
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			O2_used = breath.oxygen / 6

	if(N2_pp < atmos_requirements["min_nitro"])
		if(prob(20))
			spawn(0)
				H.emote("gasp")

		H.failed_last_breath = 1
		if(N2_pp > 0)
			var/ratio = atmos_requirements["min_nitro"] / N2_pp
			H.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.throw_alert("nitro", /obj/screen/alert/nitro)
	else if(atmos_requirements["max_nitro"] && N2_pp > atmos_requirements["max_nitro"])
		var/ratio = (breath.nitrogen / atmos_requirements["max_nitro"]) * 1000
		H.adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.throw_alert("nitro", /obj/screen/alert/too_much_nitro)
	else
		H.clear_alert("nitro")
		if(atmos_requirements["min_nitro"]) //species breathes this gas, so they got their air
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			N2_used = breath.nitrogen / 6

	if(Tox_pp < atmos_requirements["min_tox"])
		if(prob(20))
			spawn(0)
				H.emote("gasp")

		H.failed_last_breath = 1
		if(Tox_pp > 0)
			var/ratio = atmos_requirements["min_tox"] / Tox_pp
			H.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.throw_alert("tox_in_air", /obj/screen/alert/not_enough_tox)
	else if(atmos_requirements["max_tox"] && Tox_pp > atmos_requirements["max_tox"])
		var/ratio = (breath.toxins / atmos_requirements["max_tox"]) * 10
		if(H.reagents)
			H.reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
	else
		H.clear_alert("tox_in_air")
		if(atmos_requirements["min_tox"]) //species breathes this gas, so, they got their air
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			Tox_used = breath.toxins / 6

	if(CO2_pp < atmos_requirements["min_co2"])
		if(prob(20))
			spawn(0)
				H.emote("gasp")

		H.failed_last_breath = 1
		if(CO2_pp)
			var/ratio = atmos_requirements["min_co2"] / CO2_pp
			H.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.throw_alert("co2", /obj/screen/alert/not_enough_co2)
	else if(atmos_requirements["max_co2"] && CO2_pp > atmos_requirements["max_co2"])
		if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			H.co2overloadtime = world.time
		else if(world.time - H.co2overloadtime > 120)
			H.Paralyse(3)
			H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				H.adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			spawn(0)
				H.emote("cough")
	else
		H.clear_alert("co2")
		if(atmos_requirements["min_co2"]) //species breathes this gas, so they got their air
			H.failed_last_breath = 0
			H.adjustOxyLoss(-5)
			CO2_used = breath.carbon_dioxide / 6

	breath.oxygen   		-= O2_used
	breath.nitrogen 		-= N2_used
	breath.toxins   		-= Tox_used
	breath.carbon_dioxide 	-= CO2_used
	breath.carbon_dioxide 	+= O2_used


	if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles / breath.total_moles()) * breath_pressure
			if(SA_pp > atmos_requirements["sa_para"]) // Enough to make us paralysed for a bit
				H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > atmos_requirements["sa_sleep"]) // Enough to make us sleep as well
					H.sleeping = max(H.sleeping + 2, 10)
			else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					spawn(0)
						H.emote(pick("giggle", "laugh"))

	handle_temperature(breath, H)
	return 1

/datum/species/proc/handle_temperature(datum/gas_mixture/breath, var/mob/living/carbon/human/H) // called by human/life, handles temperatures
	if(abs(310.15 - breath.temperature) > 50) // Hot air hurts :(
		if(H.status_flags & GODMODE)	return 1	//godmode
		if(breath.temperature < cold_level_1)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel your face freezing and an icicle forming in your lungs!</span>")
		else if(breath.temperature > heat_level_1)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel your face burning and a searing heat in your lungs!</span>")



		switch(breath.temperature)
			if(-INFINITY to cold_level_3)
				H.apply_damage(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")

			if(cold_level_3 to cold_level_2)
				H.apply_damage(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")

			if(cold_level_2 to cold_level_1)
				H.apply_damage(cold_env_multiplier*COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")

			if(heat_level_1 to heat_level_2)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")

			if(heat_level_2 to heat_level_3_breathe)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")

			if(heat_level_3_breathe to INFINITY)
				H.apply_damage(hot_env_multiplier*HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/C) //Handles anything not already covered by basic species assignment.
	grant_abilities(C)
	return

/datum/species/proc/updatespeciescolor(var/mob/living/carbon/human/H) //Handles changing icobase for species that have multiple skin colors.
	return

/datum/species/proc/grant_abilities(var/mob/living/carbon/human/H)
	for(var/proc/ability in species_abilities)
		H.verbs += ability
	return

/datum/species/proc/handle_pre_change(var/mob/living/carbon/human/H)
	if(H.butcher_results)//clear it out so we don't butcher a actual human.
		H.butcher_results = null
	remove_abilities(H)
	return

/datum/species/proc/remove_abilities(var/mob/living/carbon/human/H)
	for(var/proc/ability in species_abilities)
		H.verbs -= ability
	return

// Do species-specific reagent handling here
// Return 1 if it should do normal processing too
// Return 0 if it shouldn't deplete and do its normal effect
// Other return values will cause weird badness
/datum/species/proc/handle_reagents(var/mob/living/carbon/human/H, var/datum/reagent/R)
	return 1

// For special snowflake species effects
// (Slime People changing color based on the reagents they consume)
/datum/species/proc/handle_life(var/mob/living/carbon/human/H)
	return 1

/datum/species/proc/handle_dna(var/mob/living/carbon/C, var/remove) //Handles DNA mutations, as that doesn't work at init. Make sure you call genemutcheck on any blocks changed here
	return

// Used for species-specific names (Vox, etc)
/datum/species/proc/makeName(var/gender,var/mob/living/carbon/human/H=null)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/datum/species/proc/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/handle_attack_hand(var/mob/living/carbon/human/H, var/mob/living/carbon/human/M) //Handles any species-specific attackhand events.
	return

/datum/species/proc/say_filter(mob/M, message, datum/language/speaking)
	return message

/datum/species/proc/equip(var/mob/living/carbon/human/H)
	return

/datum/species/proc/can_understand(var/mob/other)
	return

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(var/mob/living/carbon/human/H)
	return

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// How much flat bonus damage an attack will do. This is a *bonus* guaranteed damage amount on top of the random damage attacks do.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/punch/weak
	attack_verb = list("flail")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 6

/datum/species/proc/handle_can_equip(obj/item/I, slot, disable_warning = 0, mob/living/carbon/human/user)
	return 0

/datum/species/proc/handle_vision(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		H.see_in_dark = 8
		if(!H.druggy)
			H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		return

	H.sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)

	H.see_in_dark = darksight //set their variables to default, modify them later
	H.see_invisible = SEE_INVISIBLE_LIVING

	if(H.mind && H.mind.vampire)
		if(H.mind.vampire.get_ability(/datum/vampire_passive/full))
			H.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			H.see_in_dark = 8
			H.see_invisible = SEE_INVISIBLE_MINIMUM
		else if(H.mind.vampire.get_ability(/datum/vampire_passive/vision))
			H.sight |= SEE_MOBS


	if(XRAY in H.mutations)
		H.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
		H.see_in_dark = 8

		H.see_invisible = SEE_INVISIBLE_MINIMUM


	if(H.seer == 1)
		var/obj/effect/rune/R = locate() in H.loc
		if(R && R.word1 == cultwords["see"] && R.word2 == cultwords["hell"] && R.word3 == cultwords["join"])
			H.see_invisible = SEE_INVISIBLE_OBSERVER
		else
			H.see_invisible = SEE_INVISIBLE_LIVING
			H.seer = 0

	//This checks how much the mob's eyewear impairs their vision
	if(H.tinttotal >= TINT_IMPAIR)
		if(tinted_weldhelh)
			H.overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
		if(H.tinttotal >= TINT_BLIND)
			H.eye_blind = max(H.eye_blind, 1)
	else
		H.clear_fullscreen("tint")

	var/minimum_darkness_view = INFINITY
	if(H.glasses)
		if(istype(H.glasses, /obj/item/clothing/glasses))
			var/obj/item/clothing/glasses/G = H.glasses
			H.sight |= G.vision_flags

			if(G.darkness_view)
				H.see_in_dark = G.darkness_view
				minimum_darkness_view = G.darkness_view

			if(!G.see_darkness)
				H.see_invisible = SEE_INVISIBLE_MINIMUM

	if(H.head)
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			H.sight |= hat.vision_flags

			if(hat.darkness_view && hat.darkness_view < minimum_darkness_view) // Pick the lowest of the two darkness_views between the glasses and helmet.
				H.see_in_dark = hat.darkness_view

			if(!hat.see_darkness)
				H.see_invisible = SEE_INVISIBLE_MINIMUM

			//switch(hat.HUDType)
			//	if(SECHUD)
			//		process_sec_hud(H,1)
			//	if(MEDHUD)
			//		process_med_hud(H,1)
			//	if(ANTAGHUD)
			//		process_antag_hud(H)

	if(istype(H.back, /obj/item/weapon/rig)) ///ahhhg so snowflakey
		var/obj/item/weapon/rig/rig = H.back
		if(rig.visor)
			if(!rig.helmet || (H.head && rig.helmet == H.head))
				if(rig.visor && rig.visor.vision && rig.visor.active && rig.visor.vision.glasses)
					var/obj/item/clothing/glasses/G = rig.visor.vision.glasses
					if(istype(G))
						H.see_in_dark = (G.darkness_view ? G.darkness_view : darksight) // Otherwise we keep our darkness view with togglable nightvision.
						if(G.vision_flags)		// MESONS
							H.sight |= G.vision_flags

						if(!G.see_darkness)
							H.see_invisible = SEE_INVISIBLE_MINIMUM

						//switch(G.HUDType)
						//	if(SECHUD)
						//		process_sec_hud(H,1)
						//	if(MEDHUD)
						//		process_med_hud(H,1)
						//	if(ANTAGHUD)
						//		process_antag_hud(H)

	if(H.vision_type)
		H.see_in_dark = max(H.see_in_dark, H.vision_type.see_in_dark, darksight)
		H.see_invisible = H.vision_type.see_invisible
		if(H.vision_type.light_sensitive)
			H.weakeyes = 1
		H.sight |= H.vision_type.sight_flags

	if(H.see_override)	//Override all
		H.see_invisible = H.see_override

	if(!H.client)
		return 1

	if(H.blinded || H.eye_blind)
		H.overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		H.throw_alert("blind", /obj/screen/alert/blind)
	else
		H.clear_fullscreen("blind")
		H.clear_alert("blind")


	if(H.disabilities & NEARSIGHTED)	//this looks meh but saves a lot of memory by not requiring to add var/prescription
		if(H.glasses)					//to every /obj/item
			var/obj/item/clothing/glasses/G = H.glasses
			if(G.prescription)
				H.clear_fullscreen("nearsighted")
			else
				H.overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		else
			H.overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	else
		H.clear_fullscreen("nearsighted")

	if(H.eye_blurry)
		H.overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else
		H.clear_fullscreen("blurry")

	if(H.druggy)
		H.overlay_fullscreen("high", /obj/screen/fullscreen/high)
		H.throw_alert("high", /obj/screen/alert/high)
	else
		H.clear_fullscreen("high")
		H.clear_alert("high")

/datum/species/proc/handle_hud_icons(mob/living/carbon/human/H)
	if(!H.client)
		return
	if(H.healths)
		if(H.stat == DEAD)
			H.healths.icon_state = "health7"
		else
			switch(H.hal_screwyhud)
				if(1)	H.healths.icon_state = "health6"
				if(2)	H.healths.icon_state = "health7"
				if(5)	H.healths.icon_state = "health0"
				else
					switch(100 - ((flags & NO_PAIN) ? 0 : H.traumatic_shock) - H.staminaloss)
						if(100 to INFINITY)		H.healths.icon_state = "health0"
						if(80 to 100)			H.healths.icon_state = "health1"
						if(60 to 80)			H.healths.icon_state = "health2"
						if(40 to 60)			H.healths.icon_state = "health3"
						if(20 to 40)			H.healths.icon_state = "health4"
						if(0 to 20)				H.healths.icon_state = "health5"
						else					H.healths.icon_state = "health6"

	if(H.healthdoll)
		if(H.stat == DEAD)
			H.healthdoll.icon_state = "healthdoll_DEAD"
			if(H.healthdoll.overlays.len)
				H.healthdoll.overlays.Cut()
		else
			var/list/new_overlays = list()
			var/list/cached_overlays = H.healthdoll.cached_healthdoll_overlays
			// Use the dead health doll as the base, since we have proper "healthy" overlays now
			H.healthdoll.icon_state = "healthdoll_DEAD"
			for(var/obj/item/organ/external/O in H.organs)
				var/damage = O.burn_dam + O.brute_dam
				var/comparison = (O.max_damage/5)
				var/icon_num = 0
				if(damage)
					icon_num = 1
				if(damage > (comparison))
					icon_num = 2
				if(damage > (comparison*2))
					icon_num = 3
				if(damage > (comparison*3))
					icon_num = 4
				if(damage > (comparison*4))
					icon_num = 5
				new_overlays += "[O.limb_name][icon_num]"
			H.healthdoll.overlays += (new_overlays - cached_overlays)
			H.healthdoll.overlays -= (cached_overlays - new_overlays)
			H.healthdoll.cached_healthdoll_overlays = new_overlays

	switch(H.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			H.throw_alert("nutrition", /obj/screen/alert/fat)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			H.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			H.throw_alert("nutrition", /obj/screen/alert/hungry)
		else
			H.throw_alert("nutrition", /obj/screen/alert/starving)
	return 1

/*
Returns the path corresponding to the corresponding organ
It'll return null if the organ doesn't correspond, so include null checks when using this!
*/
//Fethas Todo:Do i need to redo this?
/datum/species/proc/return_organ(var/organ_slot)
	if(!(organ_slot in has_organ))
		return null
	return has_organ[organ_slot]
