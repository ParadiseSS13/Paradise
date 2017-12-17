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

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.
	var/coldmod = 1 // Damage multiplier for being in a cold environment

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 460 // Heat damage level 3 above this point; used for body temperature
	var/heatmod = 1 // Damage multiplier for being in a hot environment

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.
	var/hunger_drain = HUNGER_FACTOR
	var/digestion_ratio = 1 //How quickly the species digests/absorbs reagents.
	var/taste_sensitivity = TASTE_SENSITIVITY_NORMAL //the most widely used factor; humans use a different one

	var/siemens_coeff = 1 //base electrocution coefficient

	var/invis_sight = SEE_INVISIBLE_LIVING

	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = 1    // Physical damage reduction/amplification
	var/burn_mod = 1     // Burn damage reduction/amplification
	var/tox_mod = 1      // Toxin damage reduction/amplification
	var/oxy_mod = 1		 // Oxy damage reduction/amplification
	var/clone_mod = 1	 // Clone damage reduction/amplification
	var/brain_mod = 1    // Brain damage damage reduction/amplification
	var/stun_mod = 1	 // If a species is more/less impacated by stuns/weakens/paralysis

	var/blood_damage_type = OXY //What type of damage does this species take if it's low on blood?

	var/total_health = 100
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9	 //damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/list/default_genes = list()

	var/ventcrawler = 0 //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

	var/mob/living/list/ignored_by = list() // list of mobs that will ignore this species

	var/list/allowed_consumed_mobs = list() //If a species can consume mobs, put the type of mobs it can consume here.

	var/list/species_traits = list()

	var/breathid = "o2"

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
	var/can_revive_by_healing				// Determines whether or not this species can be revived by simply healing them
	var/has_gender = TRUE

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
	var/male_laugh_sound = list('honk/sound/emotes/laugh_m1.ogg','honk/sound/emotes/laugh_m2.ogg')
	var/female_laugh_sound = list('honk/sound/emotes/laugh_f1.ogg','honk/sound/emotes/laugh_f2.ogg')
	var/male_groan_sound = list('honk/sound/emotes/yawn_m1.ogg','honk/sound/emotes/yawn_m2.ogg')
	var/female_groan_sound = list('honk/sound/emotes/whimper_f1.ogg','honk/sound/emotes/whimper_f2.ogg')
	var/male_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	var/female_scream_sound = 'sound/goonstation/voice/female_scream.ogg'
	var/male_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	var/female_cough_sounds = list('sound/effects/mob_effects/f_cougha.ogg','sound/effects/mob_effects/f_coughb.ogg')
	var/male_sneeze_sound = 'sound/effects/mob_effects/sneeze.ogg'
	var/female_sneeze_sound = 'sound/effects/mob_effects/f_sneeze.ogg'

	//Default hair/headacc style vars.
	var/default_hair				//Default hair style for newly created humans unless otherwise set.
	var/default_hair_colour
	var/default_fhair				//Default facial hair style for newly created humans unless otherwise set.
	var/default_fhair_colour
	var/default_headacc				//Default head accessory style for newly created humans unless otherwise set.
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
	var/list/proc/species_abilities = list()
	var/genitals = 0
	var/anus = 0
/datum/species/New()
	//If the species has eyes, they are the default vision organ
	if(!vision_organ && has_organ["eyes"])
		vision_organ = /obj/item/organ/internal/eyes

	unarmed = new unarmed_type()

/datum/species/proc/get_random_name(var/gender)
	var/datum/language/species_language = all_languages[language]
	return species_language.get_random_name(gender)

/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.

	QDEL_LIST(H.internal_organs)
	QDEL_LIST(H.bodyparts)

	LAZYREINITLIST(H.bodyparts)
	LAZYREINITLIST(H.bodyparts_by_name)
	LAZYREINITLIST(H.internal_organs)

	for(var/limb_type in has_limbs)
		var/list/organ_data = has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/O = new limb_path(H)
		organ_data["descriptor"] = O.name

	for(var/index in has_organ)
		var/organ = has_organ[index]
		// organ new code calls `insert` on its own
		new organ(H)

	for(var/name in H.bodyparts_by_name)
		H.bodyparts |= H.bodyparts_by_name[name]

	for(var/obj/item/organ/external/O in H.bodyparts)
		O.owner = H

/datum/species/proc/breathe(mob/living/carbon/human/H)
	if((NO_BREATHE in species_traits) || (BREATHLESS in H.mutations))
		return TRUE

////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/movement_delay(mob/living/carbon/human/H)
	. = 0	//We start at 0.
	var/flight = 0	//Check for flight and flying items
	var/ignoreslow = 0
	var/gravity = 0

	if(H.flying)
		flight = 1

	if((H.status_flags & IGNORESLOWDOWN) || (RUN in H.mutations))
		ignoreslow = 1

	if(has_gravity(H))
		gravity = 1

	if(!ignoreslow && gravity)
		if(slowdown)
			. = slowdown

		if(H.wear_suit)
			. += H.wear_suit.slowdown
		if(!H.buckled)
			if(H.shoes)
				. += H.shoes.slowdown
		if(H.back)
			. += H.back.slowdown
		if(H.l_hand && (H.l_hand.flags & HANDSLOW))
			. += H.l_hand.slowdown
		if(H.r_hand && (H.r_hand.flags & HANDSLOW))
			. += H.r_hand.slowdown

		var/health_deficiency = (H.maxHealth - H.health + H.staminaloss)
		var/hungry = (500 - H.nutrition)/5 // So overeat would be 100 and default level would be 80
		if(H.reagents)
			for(var/datum/reagent/R in H.reagents.reagent_list)
				if(R.shock_reduction)
					health_deficiency -= R.shock_reduction
		if(health_deficiency >= 40)
			if(flight)
				. += (health_deficiency / 75)
			else
				. += (health_deficiency / 25)
		if(H.shock_stage >= 10)
			. += 3
		. += 2 * H.stance_damage //damaged/missing feet or legs is slow

		if((hungry >= 70) && !flight)
			. += hungry/50
		if(FAT in H.mutations)
			. += (1.5 - flight)
		if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			. += (BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

		if(H.status_flags & GOTTAGOFAST)
			. -= 1
		if(H.status_flags & GOTTAGOREALLYFAST)
			. -= 2
	return .

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
/datum/species/proc/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == exotic_blood)
		H.blood_volume = min(H.blood_volume + round(R.volume, 0.1), BLOOD_VOLUME_NORMAL)
		H.reagents.del_reagent(R.id)
		return 0
	return 1

// For special snowflake species effects
// (Slime People changing color based on the reagents they consume)
/datum/species/proc/handle_life(var/mob/living/carbon/human/H)
	if((NO_BREATHE in species_traits) || (BREATHLESS in H.mutations))
		H.setOxyLoss(0)
		H.SetLoseBreath(0)

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

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
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

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 6

/datum/species/proc/handle_can_equip(obj/item/I, slot, disable_warning = 0, mob/living/carbon/human/user)
	return 0

/datum/species/proc/handle_vision(mob/living/carbon/human/H)
	// Right now this just handles blind, blurry, and similar states
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
				if(SCREWYHUD_CRIT)	H.healths.icon_state = "health6"
				if(SCREWYHUD_DEAD)	H.healths.icon_state = "health7"
				if(SCREWYHUD_HEALTHY)	H.healths.icon_state = "health0"
				else
					switch(100 - ((NO_PAIN in species_traits) ? 0 : H.traumatic_shock) - H.staminaloss)
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
			for(var/obj/item/organ/external/O in H.bodyparts)
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
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			H.throw_alert("nutrition", /obj/screen/alert/full)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			H.throw_alert("nutrition", /obj/screen/alert/well_fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			H.throw_alert("nutrition", /obj/screen/alert/fed)
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

/datum/species/proc/get_resultant_darksight(mob/living/carbon/human/H) //Returns default value of 2 if the mob doesn't have eyes, otherwise it grabs the eyes darksight.
	var/resultant_darksight = 2
	var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		resultant_darksight = eyes.get_dark_view()
	return resultant_darksight

/datum/species/proc/update_sight(mob/living/carbon/human/H)
	H.sight = initial(H.sight)
	H.see_in_dark = get_resultant_darksight(H)
	H.see_invisible = invis_sight

	if(H.see_in_dark > 2) //Preliminary see_invisible handling as per set_species() in code\modules\mob\living\carbon\human\human.dm.
		H.see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		H.see_invisible = SEE_INVISIBLE_LIVING

	if(H.client.eye != H)
		var/atom/A = H.client.eye
		if(A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
			return

	if(H.mind && H.mind.vampire)
		if(H.mind.vampire.get_ability(/datum/vampire_passive/full))
			H.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			H.see_in_dark = 8
			H.see_invisible = SEE_INVISIBLE_MINIMUM
		else if(H.mind.vampire.get_ability(/datum/vampire_passive/vision))
			H.sight |= SEE_MOBS

	for(var/obj/item/organ/internal/cyberimp/eyes/E in H.internal_organs)
		H.sight |= E.vision_flags
		if(E.dark_view)
			H.see_in_dark = E.dark_view
		if(E.see_invisible)
			H.see_invisible = min(H.see_invisible, E.see_invisible)

	var/lesser_darkview_bonus = INFINITY
	// my glasses, I can't see without my glasses
	if(H.glasses)
		var/obj/item/clothing/glasses/G = H.glasses
		H.sight |= G.vision_flags
		lesser_darkview_bonus = G.darkness_view
		if(G.invis_override)
			H.see_invisible = G.invis_override
		else
			H.see_invisible = min(G.invis_view, H.see_invisible)

	// better living through hat trading
	if(H.head)
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			H.sight |= hat.vision_flags

			if(hat.darkness_view) // Pick the lowest of the two darkness_views between the glasses and helmet.
				lesser_darkview_bonus = min(hat.darkness_view,lesser_darkview_bonus)

			if(hat.helmet_goggles_invis_view)
				H.see_invisible = min(hat.helmet_goggles_invis_view, H.see_invisible)

	if(istype(H.back, /obj/item/weapon/rig)) ///aghhh so snowflakey
		var/obj/item/weapon/rig/rig = H.back
		if(rig.visor)
			if(!rig.helmet || (H.head && rig.helmet == H.head))
				if(rig.visor && rig.visor.vision && rig.visor.active && rig.visor.vision.glasses)
					var/obj/item/clothing/glasses/G = rig.visor.vision.glasses
					if(istype(G))
						H.see_in_dark = (G.darkness_view ? G.darkness_view : get_resultant_darksight(H)) // Otherwise we keep our darkness view with togglable nightvision.
						if(G.vision_flags)		// MESONS
							H.sight |= G.vision_flags

						H.see_invisible = min(G.invis_view, H.see_invisible)

	if(lesser_darkview_bonus != INFINITY)
		H.see_in_dark = max(lesser_darkview_bonus, H.see_in_dark)

	if(H.vision_type)
		H.see_in_dark = max(H.see_in_dark, H.vision_type.see_in_dark, get_resultant_darksight(H))
		H.see_invisible = H.vision_type.see_invisible
		if(H.vision_type.light_sensitive)
			H.weakeyes = 1
		H.sight |= H.vision_type.sight_flags

	if(XRAY in H.mutations)
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		H.see_in_dark = max(H.see_in_dark, 8)
		H.see_invisible = SEE_INVISIBLE_MINIMUM

	if(H.see_override)	//Override all
		H.see_invisible = H.see_override

/datum/species/proc/water_act(mob/living/carbon/human/M, volume, temperature, source)
	if(temperature >= 330)
		M.bodytemperature = M.bodytemperature + (temperature - M.bodytemperature)
	if(temperature <= 280)
		M.bodytemperature = M.bodytemperature - (M.bodytemperature - temperature)