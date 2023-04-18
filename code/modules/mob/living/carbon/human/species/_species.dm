/datum/species
	var/name                     // Species name.
	var/name_plural 			 // Pluralized name (since "[name]s" is not always valid)
	var/a = "a"					 // the "a" or "an" in "a Vulpkanin" or "an Abductor", use with singular version

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/blood_species // Species blood's name

	var/eyes = "eyes_s"                                  // Icon for eyes.
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.
	var/butt_sprite = "human"

	var/datum/species/primitive_form = null          // Lesser form, if any (ie. monkey for humans)
	var/datum/species/greater_form = null             // Greater form, if any, ie. human for monkeys.
	/// Name of tail image in species effects icon file.
	var/tail
	/// like tail but wings
	var/wing
	var/datum/unarmed_attack/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
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
	var/stamina_mod = 1
	var/stun_mod = 1	 // If a species is more/less impacated by stuns/weakens/paralysis
	var/speed_mod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/blood_damage_type = OXY //What type of damage does this species take if it's low on blood?
	var/total_health = 100
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9	 //damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/obj_damage = 0
	var/list/default_genes = list()

	var/ventcrawler = VENTCRAWLER_NONE //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

	///Sounds to override barefeet walking
	var/list/special_step_sounds

	var/list/allowed_consumed_mobs = list() //If a species can consume mobs, put the type of mobs it can consume here.

	var/list/species_traits = list()

	var/breathid = "o2"

	var/clothing_flags = 0 // Underwear and socks.
	var/exotic_blood
	var/skinned_type
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/can_craft = TRUE // Can this mob using crafting or not?

	var/bodyflags = 0

	var/blood_color = COLOR_BLOOD_BASE //Red.
	var/flesh_color = "#d1aa2e" //Gold.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/remains_type = /obj/effect/decal/remains/human //What sort of remains is left behind when the species dusts
	var/base_color      //Used when setting species.
	var/list/inherent_factions

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	var/is_small
	var/show_ssd = 1
	var/forced_heartattack = FALSE //Some species have blood, but we still want them to have heart attacks
	var/dies_at_threshold = FALSE // Do they die or get knocked out at specific thresholds, or do they go through complex crit?
	var/can_revive_by_healing				// Determines whether or not this species can be revived by simply healing them
	var/has_gender = TRUE
	var/blacklisted = FALSE
	var/dangerous_existence = FALSE

	//Death vars.
	var/death_message = "цепенеет и расслабляется, взгляд становится пустым и безжизненным..."
	var/list/suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает свои глазницы большими пальцами!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	// Language/culture vars.
	var/default_language = "Galactic Common" // Default language is used when 'say' is used without modifiers.
	var/language = "Galactic Common"         // Default racial language, if any.
	var/secondary_langs = list()             // The names of secondary languages that are available to this species.
	var/list/speech_sounds                   // A list of sounds to potentially play when speaking.
	var/list/speech_chance                   // The likelihood of a speech sound playing.
	var/scream_verb = "кричит"
	var/female_giggle_sound = list('sound/voice/giggle_female_1.ogg','sound/voice/giggle_female_2.ogg','sound/voice/giggle_female_3.ogg')
	var/male_giggle_sound = list('sound/voice/giggle_male_1.ogg','sound/voice/giggle_male_2.ogg')
	var/male_scream_sound = 'sound/goonstation/voice/male_scream.ogg'
	var/female_scream_sound = 'sound/goonstation/voice/female_scream.ogg'
	var/female_laugh_sound = list('sound/voice/laugh_female_1.ogg','sound/voice/laugh_female_2.ogg','sound/voice/laugh_female_3.ogg')
	var/male_laugh_sound = list('sound/voice/laugh_male_1.ogg','sound/voice/laugh_male_2.ogg','sound/voice/laugh_male_3.ogg')
	var/list/death_sounds = list('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg')
	var/list/male_dying_gasp_sounds = list('sound/goonstation/voice/male_dying_gasp_1.ogg', 'sound/goonstation/voice/male_dying_gasp_2.ogg', 'sound/goonstation/voice/male_dying_gasp_3.ogg', 'sound/goonstation/voice/male_dying_gasp_4.ogg', 'sound/goonstation/voice/male_dying_gasp_5.ogg', 'sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg')
	var/list/female_dying_gasp_sounds = list('sound/goonstation/voice/female_dying_gasp_1.ogg', 'sound/goonstation/voice/female_dying_gasp_2.ogg', 'sound/goonstation/voice/female_dying_gasp_3.ogg', 'sound/goonstation/voice/female_dying_gasp_4.ogg', 'sound/goonstation/voice/female_dying_gasp_5.ogg', 'sound/voice/gasp_female1.ogg','sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg')
	var/gasp_sound = 'sound/goonstation/voice/gasp.ogg'
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
	/// Name of default body accessory if any.
	var/default_bodyacc
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
		"r_foot" = list("path" = /obj/item/organ/external/foot/right))

	// Mutant pieces
	var/obj/item/organ/internal/ears/mutantears = /obj/item/organ/internal/ears

	// Species specific boxes
	var/speciesbox
	/// Whether the presence of a body accessory on this species is optional or not.
	var/optional_body_accessory = TRUE

	var/toolspeedmod = 1

	var/toxic_food = TOXIC
	var/disliked_food = GROSS
	var/liked_food = FRIED | JUNKFOOD | SUGAR

/datum/species/New()
	//If the species has eyes, they are the default vision organ
	if(!vision_organ && has_organ["eyes"])
		vision_organ = /obj/item/organ/internal/eyes

	unarmed = new unarmed_type()

/datum/species/proc/get_random_name(gender)
	var/datum/language/species_language = GLOB.all_languages[language]
	return species_language.get_random_name(gender)

/datum/species/proc/create_organs(mob/living/carbon/human/H) //Handles creation of mob organs.
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

	create_mutant_organs(H)

	for(var/name in H.bodyparts_by_name)
		H.bodyparts |= H.bodyparts_by_name[name]

	H.update_tail()
	H.update_wing()
	for(var/obj/item/organ/external/O in H.bodyparts)
		O.owner = H

/datum/species/proc/create_mutant_organs(mob/living/carbon/human/H)
	var/obj/item/organ/internal/ears/ears = H.get_int_organ(/obj/item/organ/internal/ears)
	if(ears)
		qdel(ears)

	if(mutantears)
		ears = new mutantears(H)

/datum/species/proc/breathe(mob/living/carbon/human/H)
	if((NO_BREATHE in species_traits) || (BREATHLESS in H.mutations))
		return TRUE

////////////////
// MOVE SPEED //
////////////////
#define ADD_SLOWDOWN(__value) if(!ignoreslow || __value < 0) . += __value

/datum/species/proc/movement_delay(mob/living/carbon/human/H)
	. = 0	//We start at 0.

	if(has_gravity(H))
		if(H.status_flags & GOTTAGOFAST)
			. -= 1
		else if(H.status_flags & GOTTAGONOTSOFAST)
			. -= 0.5

		var/ignoreslow = FALSE
		if((H.status_flags & IGNORESLOWDOWN) || (RUN in H.mutations) || (H.status_flags & GODMODE))
			ignoreslow = TRUE

		var/flight = H.flying	//Check for flight and flying items

		ADD_SLOWDOWN(speed_mod)

		if(H.status_flags & IGNORE_SPEED_CHANGES)
			return .

		if(H.wear_suit && !H.wear_suit.is_speedslimepotioned)
			ADD_SLOWDOWN(H.wear_suit.slowdown)
		if(!H.buckled && H.shoes && !H.shoes.is_speedslimepotioned)
			ADD_SLOWDOWN(H.shoes.slowdown)
		if(H.back && !H.back.is_speedslimepotioned)
			ADD_SLOWDOWN(H.back.slowdown)
		if(H.l_hand && (H.l_hand.flags & HANDSLOW) && !H.l_hand.is_speedslimepotioned)
			ADD_SLOWDOWN(H.l_hand.slowdown)
		if(H.r_hand && (H.r_hand.flags & HANDSLOW) && !H.r_hand.is_speedslimepotioned)
			ADD_SLOWDOWN(H.r_hand.slowdown)

		if(ignoreslow)
			return . // Only malusses after here

		var/health_deficiency = max(H.maxHealth - H.health, H.staminaloss)
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
		if(H.dna.species.spec_movement_delay()) //Species overrides for slowdown due to feet/legs
			. += 2 * H.stance_damage //damaged/missing feet or legs is slow

		if((hungry >= 70) && !flight)
			. += hungry/50
		if(FAT in H.mutations)
			. += (1.5 - flight)
		if (coldmod>0)
			if(H.bodytemperature < cold_level_1)
				. += (cold_level_1 - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

	return .

#undef ADD_SLOWDOWN

/datum/species/proc/on_species_gain(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	for(var/slot_id in no_equip)
		var/obj/item/thing = H.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src, thing.species_exception)))
			H.unEquip(thing)
	if(H.hud_used)
		H.hud_used.update_locked_slots()
	H.ventcrawler = ventcrawler

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

/datum/species/proc/on_species_loss(mob/living/carbon/human/H)
	if(H.butcher_results) //clear it out so we don't butcher a actual human.
		H.butcher_results = null
	H.ventcrawler = initial(H.ventcrawler)

	if(inherent_factions)
		for(var/i in inherent_factions)
			H.faction -= i

/datum/species/proc/updatespeciescolor(mob/living/carbon/human/H) //Handles changing icobase for species that have multiple skin colors.
	return

// Do species-specific reagent handling here
// Return 1 if it should do normal processing too
// Return the parent value if processing does not explicitly stop
// Return 0 if it shouldn't deplete and do its normal effect
// Other return values will cause weird badness
/datum/species/proc/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == exotic_blood)
		H.blood_volume = min(H.blood_volume + round(R.volume, 0.1), BLOOD_VOLUME_NORMAL)
		H.reagents.del_reagent(R.id)
		return FALSE
	return TRUE

// For special snowflake species effects
// (Slime People changing color based on the reagents they consume)
/datum/species/proc/handle_life(mob/living/carbon/human/H)
	if((NO_BREATHE in species_traits) || (BREATHLESS in H.mutations))
		var/takes_crit_damage = (!(NOCRITDAMAGE in species_traits))
		if((H.health <= HEALTH_THRESHOLD_CRIT) && takes_crit_damage)
			H.adjustBruteLoss(1)
	return

/datum/species/proc/handle_dna(mob/living/carbon/human/H, remove) //Handles DNA mutations, as that doesn't work at init. Make sure you call genemutcheck on any blocks changed here
	return

/datum/species/proc/handle_death(gibbed, mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return

/datum/species/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, mob/living/carbon/human/H, sharp = 0, obj/used_weapon = null)
	blocked = (100 - blocked) / 100
	if(blocked <= 0)
		return 0

	var/obj/item/organ/external/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		organ = H.get_organ(check_zone(def_zone))
	if(!organ)
		return 0

	damage = damage * blocked

	switch(damagetype)
		if(BRUTE)
			damage = damage * brute_mod
			if(damage)
				H.damageoverlaytemp = 20

			if(organ.receive_damage(damage, 0, sharp, used_weapon))
				H.UpdateDamageIcon()

		if(BURN)
			damage = damage * burn_mod
			if(damage)
				H.damageoverlaytemp = 20

			if(organ.receive_damage(0, damage, sharp, used_weapon))
				H.UpdateDamageIcon()

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	H.updatehealth("apply damage")
	return 1

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	return

/datum/species/proc/spec_electrocute_act(mob/living/carbon/human/H, shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	return

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style && attacker_style.help_act(user, target) == TRUE)//adminfu only...
		return TRUE
	if(target.health >= HEALTH_THRESHOLD_CRIT && !(target.status_flags & FAKEDEATH))
		target.help_shake_act(user)
		return TRUE
	else
		user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] попытку захвата [user.declent_ru(GENITIVE)]!</span>")
		return FALSE
	if(attacker_style && attacker_style.grab_act(user, target) == TRUE)
		return TRUE
	else
		target.grabbedby(user)
		return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, "<span class='warning'>[pluralize_ru(user.gender,"Ты не хочешь","Вы не хотите")] навредить [target.declent_ru(DATIVE)]!</span>")
		return FALSE
	//Vampire code
	if(user.mind && user.mind.vampire && (user.mind in SSticker.mode.vampires) && !user.mind.vampire.draining && user.zone_selected == "head" && target != user)
		if((NO_BLOOD in target.dna.species.species_traits) || target.dna.species.exotic_blood || !target.blood_volume)
			to_chat(user, "<span class='warning'>Отсутствует кровь!</span>")
			return
		if(target.mind && target.mind.vampire && (target.mind in SSticker.mode.vampires))
			to_chat(user, "<span class='warning'>[pluralize_ru(user.gender,"Твои","Ваши")] клыки не могут пронзить холодную плоть [target.declent_ru(GENITIVE)].</span>")
			return
		if(SKELETON in target.mutations)
			to_chat(user, "<span class='warning'>В скелете нет ни капли крови!</span>")
			return
		//we're good to suck the blood, blaah
		user.mind.vampire.handle_bloodsucking(target)
		add_attack_logs(user, target, "vampirebit")
		return
		//end vampire codes
	if(target.check_block())
		target.visible_message("<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] атаку [user.declent_ru(GENITIVE)]!</span>")
		return FALSE
	if(attacker_style && attacker_style.harm_act(user, target) == TRUE)
		return TRUE
	else
		var/datum/unarmed_attack/attack = user.dna.species.unarmed
		var/attack_species = pick(attack.attack_verb)

		//вносим проверку что это не диона, ведь у дионы свои атаки
		//вносим проверку на тип атаки, иначе рвущие атаки будут рвать кулаками, а дионы хлестать кулаками.
		switch (user.dna.species.unarmed_type)
			if (/datum/unarmed_attack/diona) attack_species += ""
			if (/datum/unarmed_attack/claws) attack_species += "[genderize_ru(user.gender,"","а","о","и")] когтями"
			if (/datum/unarmed_attack) attack_species += "[genderize_ru(user.gender,"","а","о","и")] кулаком"

		user.do_attack_animation(target, attack.animation_type)
		if(attack.harmless)
			playsound(target.loc, attack.attack_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)]!</span>")
			return FALSE
		add_attack_logs(user, target, "Melee attacked with fists")

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey

		var/damage_type = BRUTE
		var/damage = rand(user.dna.species.punchdamagelow, user.dna.species.punchdamagehigh)
		damage += attack.damage
		if(!damage)
			playsound(target.loc, attack.miss_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)], но промахива[pluralize_ru(user.gender,"ется","ются")]!</span>")
			return FALSE

		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")

		playsound(target.loc, attack.attack_sound, 25, 1, -1)

		target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] [attack_species] [target.declent_ru(ACCUSATIVE)]!</span>")

		if(target.mind && user?.mind?.objectives)
			for(var/datum/objective/pain_hunter/objective in user.mind.objectives)
				if(target.mind == objective.target)
					objective.take_damage(damage, damage_type)

		target.apply_damage(damage, damage_type, affecting, armor_block, sharp = attack.sharp) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>", \
							"<span class='userdanger'>[user.declent_ru(NOMINATIVE)] ослабля[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
			target.apply_effect(2, WEAKEN, armor_block)
			target.forcesay(GLOB.hit_appends)
		else if(target.lying)
			target.forcesay(GLOB.hit_appends)
		SEND_SIGNAL(target, COMSIG_PARENT_ATTACKBY)

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[target.declent_ru(NOMINATIVE)] блокиру[pluralize_ru(target.gender,"ет","ют")] попытку обезоруживания [user.declent_ru(GENITIVE)]!</span>")
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user, target) == TRUE)
		return TRUE
	else
		add_attack_logs(user, target, "Disarmed", ATKLOG_ALL)
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/randn = rand(1, 100)
		if(randn <= 10)
			target.apply_effect(2, WEAKEN, target.run_armor_check(affecting, "melee"))
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] толка[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
			add_attack_logs(user, target, "Pushed over", ATKLOG_ALL)
			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = user
			return

		var/talked = 0	// BubbleWrap

		if(randn <= 60)
			//BubbleWrap: Disarming breaks a pull
			if(target.pulling)
				target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] разрыва[pluralize_ru(user.gender,"ет","ют")] хватку [target.declent_ru(GENITIVE)] на [target.pulling.declent_ru(PREPOSITIONAL)]!</span>")
				talked = 1
				target.stop_pulling()

			//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
			if(istype(target.l_hand, /obj/item/grab))
				var/obj/item/grab/lgrab = target.l_hand
				if(lgrab.affecting)
					target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] разрыва[pluralize_ru(user.gender,"ет","ют")] хватку [target.declent_ru(GENITIVE)] на [lgrab.affecting.declent_ru(PREPOSITIONAL)]!</span>")
					talked = 1
				spawn(1)
					qdel(lgrab)
			if(istype(target.r_hand, /obj/item/grab))
				var/obj/item/grab/rgrab = target.r_hand
				if(rgrab.affecting)
					target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] разрыва[pluralize_ru(user.gender,"ет","ют")] хватку [target.declent_ru(GENITIVE)] на [rgrab.affecting.declent_ru(PREPOSITIONAL)]!</span>")
					talked = 1
				spawn(1)
					qdel(rgrab)
			//End BubbleWrap

			if(!talked)	//BubbleWrap
				if(target.drop_item())
					target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] обезоружи[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!</span>")
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return


	playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	target.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] пыта[pluralize_ru(user.gender,"ется","ются")] обезоружить [target.declent_ru(ACCUSATIVE)]!</span>")

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style) //Handles any species-specific attackhand events.
	if(!istype(M))
		return

	if(istype(M))
		var/obj/item/organ/external/temp = M.bodyparts_by_name["r_hand"]
		if(M.hand)
			temp = M.bodyparts_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			to_chat(M, "<span class='warning'>[pluralize_ru(M.gender,"Ты не можешь","Вы не можете")] пользоваться своей рукой.</span>")
			return

	if(M.mind)
		attacker_style = M.mind.martial_art

	if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		add_attack_logs(M, H, "Melee attacked with fists (miss/block)")
		H.visible_message("<span class='warning'>[M.declent_ru(NOMINATIVE)] пыта[pluralize_ru(M.gender,"ется","ются")] коснуться [H.declent_ru(ACCUSATIVE)]!</span>")
		return FALSE

	switch(M.a_intent)
		if(INTENT_HELP)
			help(M, H, attacker_style)

		if(INTENT_GRAB)
			grab(M, H, attacker_style)

		if(INTENT_HARM)
			harm(M, H, attacker_style)

		if(INTENT_DISARM)
			disarm(M, H, attacker_style)

/datum/species/proc/say_filter(mob/M, message, datum/language/speaking)
	return message

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/species/proc/can_understand(mob/other)
	return

// Called in life() when the mob has no client.
/datum/species/proc/handle_npc(mob/living/carbon/human/H)
	return

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("ударил", "вмазал", "стукнул", "вдарил", "влепил")	// Empty hand hurt intent verb.
	var/damage = 0						// How much flat bonus damage an attack will do. This is a *bonus* guaranteed damage amount on top of the random damage attacks do.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/animation_type = ATTACK_EFFECT_PUNCH
	var/harmless = FALSE //if set to true, attacks won't be admin logged and punches will "hit" for no damage

/datum/unarmed_attack/diona
	attack_verb = list("охлестал", "тяжело стукнул", "лозой хлестанул", "ветвью щелкнул")

/datum/unarmed_attack/claws
	attack_verb = list("царапнул", "разорвал", "искромсал", "надорвал", "порвал", "полоснул") //, "полоснул когтями", "искромсал когтями", "царапнул когтями", "разорвал когтями", "надорвал когтями", "порвал когтями"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_CLAW
	var/has_been_sharpened = FALSE

/datum/unarmed_attack/bite
	attack_verb = list("грызет", "кусает", "вгрызается", "трепает")
	attack_sound = 'sound/weapons/bite.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_BITE

/datum/unarmed_attack/claws/armalis
	attack_verb = list("хлестает", "хлестанул", "искромсал", "разорвал") //армалисами почти никто не пользуется. Зачем вносить пол вырезаной расе которой никогда не будет в игре?
	damage = 6

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, mob/living/carbon/human/H)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	if(!H.has_organ_for_slot(slot))
		return FALSE

	switch(slot)
		if(slot_l_hand)
			return !H.l_hand && !H.incapacitated()
		if(slot_r_hand)
			return !H.r_hand && !H.incapacitated()
		if(slot_wear_mask)
			return !H.wear_mask && (I.slot_flags & SLOT_MASK)
		if(slot_back)
			return !H.back && (I.slot_flags & SLOT_BACK)
		if(slot_wear_suit)
			return !H.wear_suit && (I.slot_flags & SLOT_OCLOTHING)
		if(slot_gloves)
			return !H.gloves && (I.slot_flags & SLOT_GLOVES)
		if(slot_shoes)
			return !H.shoes && (I.slot_flags & SLOT_FEET)
		if(slot_neck)
			return !H.neck && (I.slot_flags & SLOT_NECK)
		if(slot_belt)
			if(H.belt)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(!(I.slot_flags & SLOT_BELT))
				return
			return TRUE
		if(slot_glasses)
			return !H.glasses && (I.slot_flags & SLOT_EYES)
		if(slot_head)
			return !H.head && (I.slot_flags & SLOT_HEAD)
		if(slot_l_ear)
			return !H.l_ear && (I.slot_flags & SLOT_EARS) && !((I.slot_flags & SLOT_TWOEARS) && H.r_ear)
		if(slot_r_ear)
			return !H.r_ear && (I.slot_flags & SLOT_EARS) && !((I.slot_flags & SLOT_TWOEARS) && H.l_ear)
		if(slot_w_uniform)
			return !H.w_uniform && (I.slot_flags & SLOT_ICLOTHING)
		if(slot_wear_id)
			if(H.wear_id)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(!(I.slot_flags & SLOT_ID))
				return FALSE
			return TRUE
		if(slot_wear_pda)
			if(H.wear_pda)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(!(I.slot_flags & SLOT_PDA))
				return FALSE
			return TRUE
		if(slot_l_store)
			if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(I.slot_flags & SLOT_DENYPOCKET)
				return
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET))
				return TRUE
		if(slot_r_store)
			if(I.flags & NODROP)
				return FALSE
			if(H.r_store)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(I.slot_flags & SLOT_DENYPOCKET)
				return FALSE
			if(I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_POCKET))
				return TRUE
			return FALSE
		if(slot_s_store)
			if(I.flags & NODROP) //Suit storage NODROP items drop if you take a suit off, this is to prevent people exploiting this.
				return FALSE
			if(H.s_store)
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, "<span class='alert'>Вам нужен костюм перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "Вы как-то достали костюм без хранения разрешенных предметов. Прекратите это.")
				return FALSE
			if(!H.wear_suit.can_store_weighted(I))
				if(!disable_warning)
					to_chat(H, "Размер [I] слишком большой, чтобы прикрепить.")
				return FALSE
			if(istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed))
				return TRUE
			return FALSE
		if(slot_handcuffed)
			return !H.handcuffed && istype(I, /obj/item/restraints/handcuffs)
		if(slot_legcuffed)
			return !H.legcuffed && istype(I, /obj/item/restraints/legcuffs)
		if(slot_in_backpack)
			if(H.back && istype(H.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = H.back
				if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
					return TRUE
			return FALSE
		if(slot_tie)
			if(!H.w_uniform)
				if(!disable_warning)
					to_chat(H, "<span class='warning'>Вам нужен комбинезон перед тем как вы сможете прикрепить [I].</span>")
				return FALSE
			var/obj/item/clothing/under/uniform = H.w_uniform
			if(uniform.accessories.len && !uniform.can_attach_accessory(H))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>У вас уже есть аксессуар этого типа на [uniform].</span>")
				return FALSE
			if(!(I.slot_flags & SLOT_TIE))
				return FALSE
			return TRUE

	return FALSE //Unsupported slot

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return FALSE

/*
Returns the path corresponding to the corresponding organ
It'll return null if the organ doesn't correspond, so include null checks when using this!
*/
//Fethas Todo:Do i need to redo this?
/datum/species/proc/return_organ(organ_slot)
	if(!(organ_slot in has_organ))
		return null
	return has_organ[organ_slot]

/datum/species/proc/update_sight(mob/living/carbon/human/H)
	H.sight = initial(H.sight)

	var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		H.sight |= eyes.vision_flags
		H.see_in_dark = eyes.see_in_dark
		H.see_invisible = eyes.see_invisible
		H.lighting_alpha = eyes.lighting_alpha
	else
		H.see_in_dark = initial(H.see_in_dark)
		H.see_invisible = initial(H.see_invisible)
		H.lighting_alpha = initial(H.lighting_alpha)

	if(H.client && H.client.eye != H)
		var/atom/A = H.client.eye
		if(A && A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
			return

	if(H.mind && H.mind.vampire)
		if(H.mind.vampire.get_ability(/datum/vampire_passive/full))
			H.sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			H.see_in_dark = 8
			H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		else if(H.mind.vampire.get_ability(/datum/vampire_passive/vision))
			H.sight |= SEE_MOBS
			H.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	for(var/obj/item/organ/internal/cyberimp/eyes/E in H.internal_organs)
		H.sight |= E.vision_flags
		if(E.see_in_dark)
			H.see_in_dark = max(H.see_in_dark, E.see_in_dark)
		if(E.see_invisible)
			H.see_invisible = min(H.see_invisible, E.see_invisible)
		if(E.lighting_alpha)
			H.lighting_alpha = min(H.lighting_alpha, E.lighting_alpha)

	// my glasses, I can't see without my glasses
	if(H.glasses)
		var/obj/item/clothing/glasses/G = H.glasses
		H.sight |= G.vision_flags
		H.see_in_dark = max(G.see_in_dark, H.see_in_dark)

		if(G.invis_override)
			H.see_invisible = G.invis_override
		else
			H.see_invisible = min(G.invis_view, H.see_invisible)

		if(!isnull(G.lighting_alpha))
			H.lighting_alpha = min(G.lighting_alpha, H.lighting_alpha)

	// better living through hat trading
	if(H.head)
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			H.sight |= hat.vision_flags
			H.see_in_dark = max(hat.see_in_dark, H.see_in_dark)

			if(!isnull(hat.lighting_alpha))
				H.lighting_alpha = min(hat.lighting_alpha, H.lighting_alpha)

	if(H.vision_type)
		H.sight |= H.vision_type.sight_flags
		H.see_in_dark = max(H.see_in_dark, H.vision_type.see_in_dark)

		if(!isnull(H.vision_type.lighting_alpha))
			H.lighting_alpha = min(H.vision_type.lighting_alpha, H.lighting_alpha)

		if(H.vision_type.light_sensitive)
			H.weakeyes = TRUE

	if(XRAY in H.mutations)
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)

	if(H.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		H.see_invisible = SEE_INVISIBLE_OBSERVER

	H.sync_lighting_plane_alpha()

/datum/species/proc/water_act(mob/living/carbon/human/M, volume, temperature, source, method = REAGENT_TOUCH)
	if(abs(temperature - M.bodytemperature) > 10) // If our water and mob temperature varies by more than 10K, cool or/ heat them appropriately.
		M.bodytemperature = (temperature + M.bodytemperature) * 0.5 // Approximation for gradual heating or cooling.

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H) //return TRUE if hit, FALSE if stopped/reflected/etc
	return TRUE

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)

/proc/get_random_species(species_name = FALSE)	// Returns a random non black-listed or hazardous species, either as a string or datum
	var/static/list/random_species = list()
	if(!random_species.len)
		for(var/thing  in subtypesof(/datum/species))
			var/datum/species/S = thing
			if(!initial(S.dangerous_existence) && !initial(S.blacklisted))
				random_species += initial(S.name)
	var/picked_species = pick(random_species)
	var/datum/species/selected_species = GLOB.all_species[picked_species]
	return species_name ? picked_species : selected_species.type

/datum/species/proc/can_hear(mob/living/carbon/human/H)
	. = FALSE
	var/obj/item/organ/internal/ears/ears = H.get_int_organ(/obj/item/organ/internal/ears)
	if(istype(ears) && !ears.deaf)
		. = TRUE

/datum/species/proc/spec_Process_Spacemove(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/spec_thunk(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/spec_movement_delay()
	return TRUE

/datum/species/proc/spec_WakeUp(mob/living/carbon/human/H)
	return FALSE

/**
  * Species-specific runechat colour handler
  *
  * Checks the species datum flags and returns the appropriate colour
  * Can be overridden on subtypes to short-circuit these checks (Example: Grey colour is eye colour)
  * Arguments:
  * * H - The human who this DNA belongs to
  */
/datum/species/proc/get_species_runechat_color(mob/living/carbon/human/H)
	if(bodyflags & HAS_SKIN_COLOR)
		return H.skin_colour
	else
		var/obj/item/organ/external/head/HD = H.get_organ("head")
		return HD.hair_colour
