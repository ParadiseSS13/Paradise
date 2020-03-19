/datum/species
	var/name                     // Species name.
	var/name_plural 			// Pluralized name (since "[name]s" is not always valid)
	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	var/damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	var/damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	var/eyes = "eyes_s"                                  // Icon for eyes.
	var/blurb = "A completely nondescript species."      // A brief lore summary for use in the chargen screen.
	var/butt_sprite = "human"

	var/datum/species/primitive_form = null          // Lesser form, if any (ie. monkey for humans)
	var/datum/species/greater_form = null             // Greater form, if any, ie. human for monkeys.
	var/tail                     // Name of tail image in species effects icon file.
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
	var/obj/item/mutanthands
	var/total_health = 100
	var/punchdamagelow = 0       //lowest possible punch damage
	var/punchdamagehigh = 9      //highest possible punch damage
	var/punchstunthreshold = 9	 //damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/list/default_genes = list()

	var/ventcrawler = VENTCRAWLER_NONE //Determines if the mob can go through the vents.
	var/has_fine_manipulation = 1 // Can use small items.

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
	var/dietflags  = 0	// Make sure you set this, otherwise it won't be able to digest a lot of foods

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#d1aa2e" //Gold.
	var/single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	var/remains_type = /obj/effect/decal/remains/human //What sort of remains is left behind when the species dusts
	var/base_color      //Used when setting species.

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
	var/list/death_sounds = list('sound/goonstation/voice/deathgasp_1.ogg', 'sound/goonstation/voice/deathgasp_2.ogg')
	var/list/male_dying_gasp_sounds = list('sound/goonstation/voice/male_dying_gasp_1.ogg', 'sound/goonstation/voice/male_dying_gasp_2.ogg', 'sound/goonstation/voice/male_dying_gasp_3.ogg', 'sound/goonstation/voice/male_dying_gasp_4.ogg', 'sound/goonstation/voice/male_dying_gasp_5.ogg')
	var/list/female_dying_gasp_sounds = list('sound/goonstation/voice/female_dying_gasp_1.ogg', 'sound/goonstation/voice/female_dying_gasp_2.ogg', 'sound/goonstation/voice/female_dying_gasp_3.ogg', 'sound/goonstation/voice/female_dying_gasp_4.ogg', 'sound/goonstation/voice/female_dying_gasp_5.ogg')
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
		if(speed_mod)
			. = speed_mod

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
		. += 2 * H.stance_damage //damaged/missing feet or legs is slow

		if((hungry >= 70) && !flight)
			. += hungry/50
		if(FAT in H.mutations)
			. += (1.5 - flight)
		if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			. += (BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR

		if(H.status_flags & GOTTAGOFAST)
			. -= 1
		if(H.status_flags & GOTTAGOFAST_METH)
			. -= 1
	return .

/datum/species/proc/on_species_gain(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	for(var/slot_id in no_equip)
		var/obj/item/thing = H.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src, thing.species_exception)))
			H.unEquip(thing)
	if(H.hud_used)
		H.hud_used.update_locked_slots()
	H.ventcrawler = ventcrawler

/datum/species/proc/on_species_loss(mob/living/carbon/human/H)
	if(H.butcher_results) //clear it out so we don't butcher a actual human.
		H.butcher_results = null
	H.ventcrawler = initial(H.ventcrawler)

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
			H.damageoverlaytemp = 20
			damage = damage * brute_mod

			if(organ.receive_damage(damage, 0, sharp, used_weapon))
				H.UpdateDamageIcon()

			if(H.LAssailant && ishuman(H.LAssailant)) //superheros still get the comical hit markers
				var/mob/living/carbon/human/A = H.LAssailant
				if(A.mind && A.mind in (SSticker.mode.superheroes || SSticker.mode.supervillains || SSticker.mode.greyshirts))
					var/list/attack_bubble_recipients = list()
					var/mob/living/user
					for(var/mob/O in viewers(user, src))
						if(O.client && O.has_vision(information_only=TRUE))
							attack_bubble_recipients.Add(O.client)
					spawn(0)
						var/image/dmgIcon = image('icons/effects/hit_blips.dmi', src, "dmg[rand(1,2)]",MOB_LAYER+1)
						dmgIcon.pixel_x = (!H.lying) ? rand(-3,3) : rand(-11,12)
						dmgIcon.pixel_y = (!H.lying) ? rand(-11,9) : rand(-10,1)
						flick_overlay(dmgIcon, attack_bubble_recipients, 9)


		if(BURN)
			H.damageoverlaytemp = 20
			damage = damage * burn_mod

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
	if(attacker_style && attacker_style.help_act(user, target))//adminfu only...
		return TRUE
	if(target.health >= HEALTH_THRESHOLD_CRIT && !(target.status_flags & FAKEDEATH))
		target.help_shake_act(user)
		return TRUE
	else
		user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s grab attempt!</span>")
		return FALSE
	if(attacker_style && attacker_style.grab_act(user, target))
		return TRUE
	else
		target.grabbedby(user)
		return TRUE

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return FALSE
	//Vampire code
	if(user.mind && user.mind.vampire && (user.mind in SSticker.mode.vampires) && !user.mind.vampire.draining && user.zone_selected == "head" && target != user)
		if((NO_BLOOD in target.dna.species.species_traits) || target.dna.species.exotic_blood || !target.blood_volume)
			to_chat(user, "<span class='warning'>They have no blood!</span>")
			return
		if(target.mind && target.mind.vampire && (target.mind in SSticker.mode.vampires))
			to_chat(user, "<span class='warning'>Your fangs fail to pierce [target.name]'s cold flesh</span>")
			return
		if(SKELETON in target.mutations)
			to_chat(user, "<span class='warning'>There is no blood in a skeleton!</span>")
			return
		//we're good to suck the blood, blaah
		user.mind.vampire.handle_bloodsucking(target)
		add_attack_logs(user, target, "vampirebit")
		return
		//end vampire codes
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s attack!</span>")
		return FALSE
	if(attacker_style && attacker_style.harm_act(user, target))
		return TRUE
	else
		var/datum/unarmed_attack/attack = user.dna.species.unarmed

		user.do_attack_animation(target, attack.animation_type)
		if(attack.harmless)
			playsound(target.loc, attack.attack_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user] [pick(attack.attack_verb)]ed [target]!</span>")
			return FALSE
		add_attack_logs(user, target, "Melee attacked with fists", target.ckey ? null : ATKLOG_ALL)

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

		var/damage = rand(user.dna.species.punchdamagelow, user.dna.species.punchdamagehigh)
		damage += attack.damage
		if(!damage)
			playsound(target.loc, attack.miss_sound, 25, 1, -1)
			target.visible_message("<span class='danger'>[user] tried to [pick(attack.attack_verb)] [target]!</span>")
			return FALSE


		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/armor_block = target.run_armor_check(affecting, "melee")

		playsound(target.loc, attack.attack_sound, 25, 1, -1)

		target.visible_message("<span class='danger'>[user] [pick(attack.attack_verb)]ed [target]!</span>")
		target.apply_damage(damage, BRUTE, affecting, armor_block, sharp = attack.sharp) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			target.visible_message("<span class='danger'>[user] has weakened [target]!</span>", \
							"<span class='userdanger'>[user] has weakened [target]!</span>")
			target.apply_effect(4, WEAKEN, armor_block)
			target.forcesay(GLOB.hit_appends)
		else if(target.lying)
			target.forcesay(GLOB.hit_appends)
		SEND_SIGNAL(target, COMSIG_PARENT_ATTACKBY)

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s disarm attempt!</span>")
		return FALSE
	if(attacker_style && attacker_style.disarm_act(user, target))
		return TRUE
	else
		add_attack_logs(user, target, "Disarmed", ATKLOG_ALL)
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		var/obj/item/organ/external/affecting = target.get_organ(ran_zone(user.zone_selected))
		var/randn = rand(1, 100)
		if(randn <= 25)
			target.apply_effect(2, WEAKEN, target.run_armor_check(affecting, "melee"))
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			target.visible_message("<span class='danger'>[user] has pushed [target]!</span>")
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
				target.visible_message("<span class='danger'>[user] has broken [target]'s grip on [target.pulling]!</span>")
				talked = 1
				target.stop_pulling()

			//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
			if(istype(target.l_hand, /obj/item/grab))
				var/obj/item/grab/lgrab = target.l_hand
				if(lgrab.affecting)
					target.visible_message("<span class='danger'>[user] has broken [target]'s grip on [lgrab.affecting]!</span>")
					talked = 1
				spawn(1)
					qdel(lgrab)
			if(istype(target.r_hand, /obj/item/grab))
				var/obj/item/grab/rgrab = target.r_hand
				if(rgrab.affecting)
					target.visible_message("<span class='danger'>[user] has broken [target]'s grip on [rgrab.affecting]!</span>")
					talked = 1
				spawn(1)
					qdel(rgrab)
			//End BubbleWrap

			if(!talked)	//BubbleWrap
				if(target.drop_item())
					target.visible_message("<span class='danger'>[user] has disarmed [target]!</span>")
			playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return


	playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	target.visible_message("<span class='danger'>[user] attempted to disarm [target]!</span>")

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style = M.martial_art) //Handles any species-specific attackhand events.
	if(!istype(M))
		return
	if(H.frozen)
		to_chat(M, "<span class='warning'>Do not touch Admin-Frozen people.</span>")
		return

	if(istype(M))
		var/obj/item/organ/external/temp = M.bodyparts_by_name["r_hand"]
		if(M.hand)
			temp = M.bodyparts_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			to_chat(M, "<span class='warning'>You can't use your hand.</span>")
			return

	if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		add_attack_logs(M, H, "Melee attacked with fists (miss/block)")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
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
	var/attack_verb = list("punch")	// Empty hand hurt intent verb.
	var/damage = 0						// How much flat bonus damage an attack will do. This is a *bonus* guaranteed damage amount on top of the random damage attacks do.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = FALSE
	var/animation_type = ATTACK_EFFECT_PUNCH
	var/harmless = FALSE //if set to true, attacks won't be admin logged and punches will "hit" for no damage

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_CLAW
	var/has_been_sharpened = FALSE

/datum/unarmed_attack/bite
	attack_verb = list("chomp")
	attack_sound = 'sound/weapons/bite.ogg'
	sharp = TRUE
	animation_type = ATTACK_EFFECT_BITE

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 6

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, mob/living/carbon/human/H)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	if(!H.has_organ_for_slot(slot))
		return FALSE

	if(istype(I, /obj/item/clothing/under) || istype(I, /obj/item/clothing/suit))
		if(FAT in H.mutations)
			if(!(I.flags_size & ONESIZEFITSALL))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You're too fat to wear the [I].</span>")
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
		if(slot_belt)
			if(H.belt)
				return FALSE
			var/obj/item/organ/external/O = H.get_organ(BODY_ZONE_CHEST)

			if(!H.w_uniform && !nojumpsuit && (!O || !(O.status & ORGAN_ROBOT)))
				if(!disable_warning)
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
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
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
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
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
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
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
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
					to_chat(H, "<span class='alert'>You need a jumpsuit before you can attach this [name].</span>")
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
					to_chat(H, "<span class='alert'>You need a suit before you can attach this [name].</span>")
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, "The [name] is too big to attach.")
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
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return FALSE
			var/obj/item/clothing/under/uniform = H.w_uniform
			if(uniform.accessories.len && !uniform.can_attach_accessory(H))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You already have an accessory of this type attached to your [uniform].</span>")
				return FALSE
			if(!(I.slot_flags & SLOT_TIE))
				return FALSE
			return TRUE

	return FALSE //Unsupported slot

/datum/species/proc/get_perceived_trauma(mob/living/carbon/human/H)
	return min(H.health, H.maxHealth - H.getStaminaLoss())

/datum/species/proc/handle_hud_icons(mob/living/carbon/human/H)
	if(!H.client)
		return
	handle_hud_icons_health(H)
	H.handle_hud_icons_health_overlay()
	handle_hud_icons_nutrition(H)

/datum/species/proc/handle_hud_icons_health(mob/living/carbon/H)
	if(!H.client)
		return
	handle_hud_icons_health_side(H)
	handle_hud_icons_health_doll(H)

/datum/species/proc/handle_hud_icons_health_side(mob/living/carbon/human/H)
	if(H.healths)
		if(H.stat == DEAD || (H.status_flags & FAKEDEATH))
			H.healths.icon_state = "health7"
		else
			switch(H.hal_screwyhud)
				if(SCREWYHUD_CRIT)	H.healths.icon_state = "health6"
				if(SCREWYHUD_DEAD)	H.healths.icon_state = "health7"
				if(SCREWYHUD_HEALTHY)	H.healths.icon_state = "health0"
				else
					switch(get_perceived_trauma(H))
						if(100 to INFINITY)		H.healths.icon_state = "health0"
						if(80 to 100)			H.healths.icon_state = "health1"
						if(60 to 80)			H.healths.icon_state = "health2"
						if(40 to 60)			H.healths.icon_state = "health3"
						if(20 to 40)			H.healths.icon_state = "health4"
						if(0 to 20)				H.healths.icon_state = "health5"
						else					H.healths.icon_state = "health6"

/datum/species/proc/handle_hud_icons_health_doll(mob/living/carbon/human/H)
	if(H.healthdoll)
		if(H.stat == DEAD || (H.status_flags & FAKEDEATH))
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

/datum/species/proc/handle_hud_icons_nutrition(mob/living/carbon/human/H)
	if(NO_HUNGER in species_traits)
		return FALSE
	if(H.mind && H.mind.vampire && (H.mind in SSticker.mode.vampires)) //Vampires
		switch(H.nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				H.throw_alert("nutrition", /obj/screen/alert/fat/vampire)
			if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
				H.throw_alert("nutrition", /obj/screen/alert/full/vampire)
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				H.throw_alert("nutrition", /obj/screen/alert/well_fed/vampire)
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				H.throw_alert("nutrition", /obj/screen/alert/fed/vampire)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				H.throw_alert("nutrition", /obj/screen/alert/hungry/vampire)
			else
				H.throw_alert("nutrition", /obj/screen/alert/starving/vampire)
		return 1

	else ///Any other non-vampires
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
		if(A.update_remote_sight(H)) //returns 1 if we override all other sight updates.
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

	if(istype(H.back, /obj/item/rig)) ///aghhh so snowflakey
		var/obj/item/rig/rig = H.back
		if(rig.visor)
			if(!rig.helmet || (H.head && rig.helmet == H.head))
				if(rig.visor && rig.visor.vision && rig.visor.active && rig.visor.vision.glasses)
					var/obj/item/clothing/glasses/G = rig.visor.vision.glasses
					if(istype(G))
						H.sight |= G.vision_flags
						H.see_in_dark = max(G.see_in_dark, H.see_in_dark)
						H.see_invisible = min(G.invis_view, H.see_invisible)

						if(!isnull(G.lighting_alpha))
							H.lighting_alpha = min(G.lighting_alpha, H.lighting_alpha)

	if(H.vision_type)
		H.sight |= H.vision_type.sight_flags
		H.see_in_dark = max(H.see_in_dark, H.vision_type.see_in_dark)

		if(!isnull(H.vision_type.lighting_alpha))
			H.lighting_alpha = min(H.vision_type.lighting_alpha, H.lighting_alpha)

		if(H.vision_type.light_sensitive)
			H.weakeyes = TRUE

	if(XRAY in H.mutations)
		H.sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)

	H.sync_lighting_plane_alpha()

/datum/species/proc/water_act(mob/living/carbon/human/M, volume, temperature, source, method = REAGENT_TOUCH)
	if(abs(temperature - M.bodytemperature) > 10) // If our water and mob temperature varies by more than 10K, cool or/ heat them appropriately.
		M.bodytemperature = (temperature + M.bodytemperature) * 0.5 // Approximation for gradual heating or cooling.

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H) //return TRUE if hit, FALSE if stopped/reflected/etc
	return TRUE

/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)

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
