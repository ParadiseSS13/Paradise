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

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 460 // Heat damage level 3 above this point; used for body temperature
	var/heat_level_3_breathe = 1000 // Heat damage level 3 above this point; used for breathed air temperature

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/passive_temp_gain = 0			//IS_SYNTHETIC species will gain this much temperature every second
	var/reagent_tag                 //Used for metabolizing reagents.

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.

	var/light_dam //Light level above which species takes damage, and below which it heals.
	var/light_effect_amp //If 0, takes/heals 1 burn and brute per tick. Otherwise, both healing and damage effects are amplified.

	var/total_health = 100
	var/max_hurt_damage = 9 // Max melee damage dealt + 5 if hulk
	var/list/default_genes = list()

	var/ventcrawler = 0 //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

	var/flags = 0       // Various specific features.
	var/clothing_flags = 0 // Underwear and socks.
	var/exotic_blood
	var/bodyflags = 0
	var/dietflags  = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human

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

	// Language/culture vars.
	var/default_language = "Galactic Common" // Default language is used when 'say' is used without modifiers.
	var/language = "Galactic Common"         // Default racial language, if any.
	var/secondary_langs = list()             // The names of secondary languages that are available to this species.
	var/list/speech_sounds                   // A list of sounds to potentially play when speaking.
	var/list/speech_chance                   // The likelihood of a speech sound playing.

                              // Determines the organs that the species spawns with and
	var/list/has_organ = list(    // which required-organ checks are conducted.
		"heart" =    /obj/item/organ/heart,
		"lungs" =    /obj/item/organ/lungs,
		"liver" =    /obj/item/organ/liver,
		"kidneys" =  /obj/item/organ/kidneys,
		"brain" =    /obj/item/organ/brain,
		"appendix" = /obj/item/organ/appendix,
		"eyes" =     /obj/item/organ/eyes
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

/datum/species/New()
	//If the species has eyes, they are the default vision organ
	if(!vision_organ && has_organ["eyes"])
		vision_organ = "eyes"

	unarmed = new unarmed_type()

/datum/species/proc/get_random_name(var/gender)
	var/datum/language/species_language = all_languages[language]
	return species_language.get_random_name(gender)

/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.

	for(var/obj/item/organ/organ in H.contents)
		if((organ in H.organs) || (organ in H.internal_organs))
			qdel(organ)

	if(H.organs)                  H.organs.Cut()
	if(H.internal_organs)         H.internal_organs.Cut()
	if(H.organs_by_name)          H.organs_by_name.Cut()
	if(H.internal_organs_by_name) H.internal_organs_by_name.Cut()

	H.organs = list()
	H.internal_organs = list()
	H.organs_by_name = list()
	H.internal_organs_by_name = list()

	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/O = new limb_path(H)
		organ_data["descriptor"] = O.name

	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		H.internal_organs_by_name[organ] = new organ_type(H,1)

	for(var/name in H.organs_by_name)
		H.organs |= H.organs_by_name[name]

	for(var/obj/item/organ/external/O in H.organs)
		O.owner = H

/datum/species/proc/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/nitrogen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME
	var/vox_oxygen_max = 1 // For vox.

	//Partial pressure of the O2 in our breath
	var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
	// Same, but for the toxins
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
	// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
	var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure // Tweaking to fit the hacky bullshit I've done with atmo -- TLE
	// Nitrogen, for Vox.
	var/Nitrogen_pp = (breath.nitrogen/breath.total_moles())*breath_pressure

	// TODO: Split up into Voxs' own proc.
	if(O2_pp < safe_oxygen_min && name != "Vox") 	// Too little oxygen
		if(prob(20))
			spawn(0)
				H.emote("gasp")
		if(O2_pp > 0)
			var/ratio = safe_oxygen_min/O2_pp
			H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
			H.failed_last_breath = 1
			oxygen_used = breath.oxygen*ratio/6
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			H.failed_last_breath = 1
		H.oxygen_alert = max(H.oxygen_alert, 1)
	else if(Nitrogen_pp < safe_oxygen_min && name == "Vox")  //Vox breathe nitrogen, not oxygen.

		if(prob(20))
			spawn(0) H.emote("gasp")
		if(Nitrogen_pp > 0)
			var/ratio = safe_oxygen_min/Nitrogen_pp
			H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS))
			H.failed_last_breath = 1
			nitrogen_used = breath.nitrogen*ratio/6
		else
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			H.failed_last_breath = 1
		H.oxygen_alert = max(H.oxygen_alert, 1)

	else								// We're in safe limits
		H.failed_last_breath = 0
		H.adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		H.oxygen_alert = 0

	breath.oxygen -= oxygen_used
	breath.nitrogen -= nitrogen_used
	breath.carbon_dioxide += oxygen_used

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(CO2_pp > safe_co2_max)
		if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			H.co2overloadtime = world.time
		else if(world.time - H.co2overloadtime > 120)
			H.Paralyse(3)
			H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				H.adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			spawn(0) H.emote("cough")

	else
		H.co2overloadtime = 0

	if(Toxins_pp > safe_toxins_max) // Too much toxins
		var/ratio = (breath.toxins/safe_toxins_max) * 10
		//adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(H.reagents)
			H.reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.toxins_alert = max(H.toxins_alert, 1)

	else if(O2_pp > vox_oxygen_max && name == "Vox") //Oxygen is toxic to vox.
		var/ratio = (breath.oxygen/vox_oxygen_max) * 1000
		H.adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		H.toxins_alert = max(H.toxins_alert, 1)
	else
		H.toxins_alert = 0

	if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
				H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
				if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
					H.sleeping = max(H.sleeping+2, 10)
			else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					spawn(0) H.emote(pick("giggle", "laugh"))

	handle_temperature(breath, H)

	return 1

/datum/species/proc/handle_temperature(datum/gas_mixture/breath, var/mob/living/carbon/human/H) // called by human/life, handles temperatures
	if( (abs(310.15 - breath.temperature) > 50) && !(RESIST_HEAT in H.mutations)) // Hot air hurts :(
		if(H.status_flags & GODMODE)	return 1	//godmode
		if(breath.temperature < cold_level_1)
			if(prob(20))
				H << "\red You feel your face freezing and an icicle forming in your lungs!"
		else if(breath.temperature > heat_level_1)
			if(prob(20))
				H << "\red You feel your face burning and a searing heat in your lungs!"



		switch(breath.temperature)
			if(-INFINITY to cold_level_3)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			if(cold_level_3 to cold_level_2)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			if(cold_level_2 to cold_level_1)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			if(heat_level_1 to heat_level_2)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			if(heat_level_2 to heat_level_3_breathe)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			if(heat_level_3_breathe to INFINITY)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)
	return

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/C) //Handles anything not already covered by basic species assignment.
	handle_dna(C)
	return

/datum/species/proc/handle_dna(var/mob/living/carbon/C, var/remove) //Handles DNA mutations, as that doesn't work at init.
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
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/punch/weak
	attack_verb = list("flail")
	damage = 1

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
	damage = 6	//they're huge! they should do a little more damage, i'd even go for 15-20 maybe...

/datum/species/proc/handle_can_equip(obj/item/I, slot, disable_warning = 0, mob/living/carbon/human/user)
	return 0

/datum/species/proc/handle_vision(mob/living/carbon/human/H)
	if( H.stat == DEAD )
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		H.see_in_dark = 8
		if(!H.druggy)		H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		H.sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)

		H.see_in_dark = darksight //set their variables to default, modify them later
		H.see_invisible = SEE_INVISIBLE_LIVING

		if(H.mind && H.mind.vampire)
			if(VAMP_VISION in H.mind.vampire.powers && !(VAMP_FULL in H.mind.vampire.powers))
				H.sight |= SEE_MOBS

			else if(VAMP_FULL in H.mind.vampire.powers)
				H.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
				H.see_in_dark = 8
				H.see_invisible = SEE_INVISIBLE_MINIMUM


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
				if(H.tinttotal >= TINT_BLIND)
					H.eye_blind = max(H.eye_blind, 1)
				if(H.client)
					H.client.screen += global_hud.darkMask

		if(H.glasses)
			if(istype(H.glasses, /obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = H.glasses
				H.sight |= G.vision_flags

				if(G.darkness_view)
					H.see_in_dark = G.darkness_view

				if(!G.see_darkness)
					H.see_invisible = SEE_INVISIBLE_MINIMUM

				//switch(G.HUDType)
				//	if(SECHUD)
				//		process_sec_hud(H,1)
				//	if(MEDHUD)
				//		process_med_hud(H,1)
				//	if(ANTAGHUD)
				//		process_antag_hud(H)

		if(H.head)
			if(istype(H.head, /obj/item/clothing/head))
				var/obj/item/clothing/head/hat = H.head
				H.sight |= hat.vision_flags

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

		if(H.blind)
			if(H.blinded)		H.blind.layer = 18
			else				H.blind.layer = 0

		if(H.disabilities & NEARSIGHTED)	//this looks meh but saves a lot of memory by not requiring to add var/prescription
			if(H.glasses)					//to every /obj/item
				var/obj/item/clothing/glasses/G = H.glasses
				if(!G.prescription)
					H.client.screen += global_hud.vimpaired
			else
				H.client.screen += global_hud.vimpaired

		if(H.eye_blurry)			H.client.screen += global_hud.blurry
		if(H.druggy)				H.client.screen += global_hud.druggy

/datum/species/proc/handle_hud_icons(mob/living/carbon/human/H)
	if(H.healths)
		if(H.analgesic)
			H.healths.icon_state = "health_health_numb"
		else
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
		H.healthdoll.overlays.Cut()
		if(H.stat == DEAD)
			H.healthdoll.icon_state = "healthdoll_DEAD"
		else
			H.healthdoll.icon_state = "healthdoll_OVERLAY"
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
				if(icon_num)
					H.healthdoll.overlays += image('icons/mob/screen_gen.dmi',"[O.limb_name][icon_num]")

	if(H.nutrition_icon)
		switch(H.nutrition)
			if(450 to INFINITY)				H.nutrition_icon.icon_state = "nutrition0"
			if(350 to 450)					H.nutrition_icon.icon_state = "nutrition1"
			if(250 to 350)					H.nutrition_icon.icon_state = "nutrition2"
			if(150 to 250)					H.nutrition_icon.icon_state = "nutrition3"
			else							H.nutrition_icon.icon_state = "nutrition4"


	// BAY SHIT
	if(H.pressure)
		H.pressure.icon_state = "pressure[H.pressure_alert]"

	if(H.toxin)
		if(H.hal_screwyhud == 4 || H.toxins_alert)	H.toxin.icon_state = "tox1"
		else										H.toxin.icon_state = "tox0"
	if(H.oxygen)
		if(H.hal_screwyhud == 3 || H.oxygen_alert)	H.oxygen.icon_state = "oxy1"
		else										H.oxygen.icon_state = "oxy0"
	if(H.fire)
		if(H.fire_alert)							H.fire.icon_state = "fire[H.fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
		else										H.fire.icon_state = "fire0"

	if(H.bodytemp)
		var/temp_step
		if(H.bodytemperature >= body_temperature)
			temp_step = (heat_level_1 - body_temperature)/4

			if(H.bodytemperature >= heat_level_1)
				H.bodytemp.icon_state = "temp4"
			else if(H.bodytemperature >= body_temperature + temp_step*3)
				H.bodytemp.icon_state = "temp3"
			else if(H.bodytemperature >= body_temperature + temp_step*2)
				H.bodytemp.icon_state = "temp2"
			else if(H.bodytemperature >= body_temperature + temp_step*1)
				H.bodytemp.icon_state = "temp1"
			else
				H.bodytemp.icon_state = "temp0"

		else if(H.bodytemperature < body_temperature)
			temp_step = (body_temperature - cold_level_1)/4

			if(H.bodytemperature <= cold_level_1)
				H.bodytemp.icon_state = "temp-4"
			else if(H.bodytemperature <= body_temperature - temp_step*3)
				H.bodytemp.icon_state = "temp-3"
			else if(H.bodytemperature <= body_temperature - temp_step*2)
				H.bodytemp.icon_state = "temp-2"
			else if(H.bodytemperature <= body_temperature - temp_step*1)
				H.bodytemp.icon_state = "temp-1"
			else
				H.bodytemp.icon_state = "temp0"

	return 1

/*
Returns the path corresponding to the corresponding organ
It'll return null if the organ doesn't correspond, so include null checks when using this!
*/
/datum/species/proc/return_organ(var/organ_slot)
	if(!(organ_slot in has_organ))
		return null
	return has_organ[organ_slot]