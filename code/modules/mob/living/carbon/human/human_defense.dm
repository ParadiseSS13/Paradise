/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
meteor_act
emp_act

*/


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(!dna.species.bullet_act(P, src, def_zone))
		add_attack_logs(P.firer, src, "hit by [P.type] but got deflected by species '[dna.species]'")
		P.reflect_back(src) //It has to be here, not on species. Why? Who knows. Testing showed me no reason why it doesn't work on species, and neither did tracing. It has to be here, or it gets qdel'd by bump.
		return -1
	if(P.is_reflectable(REFLECTABILITY_ENERGY))
		var/can_reflect = check_reflect(def_zone)
		var/reflected = FALSE

		switch(can_reflect)
			if(1) // proper reflection
				reflected = TRUE
			if(2) //If target is holding a toy sword
				var/static/list/safe_list = list(/obj/item/projectile/beam/lasertag, /obj/item/projectile/beam/practice)
				reflected = is_type_in_list(P, safe_list) //And it's safe

		if(reflected)
			visible_message("<span class='danger'>[P] gets reflected by [src]!</span>", \
				"<span class='userdanger'>[P] gets reflected by [src]!</span>")
			add_attack_logs(P.firer, src, "hit by [P.type] but got reflected")
			P.reflect_back(src)
			return -1

	//Shields
	var/shield_check_result = check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK)
	if(shield_check_result == 1)
		return 2
	else if(shield_check_result == -1)
		P.reflect_back(src)
		return -1

	if(mind?.martial_art?.deflection_chance) //Some martial arts users can deflect projectiles!
		if(!HAS_TRAIT(src, TRAIT_HULK) && mind.martial_art.try_deflect(src)) //But only if they're not hulked
			add_attack_logs(P.firer, src, "hit by [P.type] but got deflected by martial arts '[mind.martial_art]'")
			playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
			if(HAS_TRAIT(src, TRAIT_PACIFISM) || !P.is_reflectable(REFLECTABILITY_PHYSICAL)) //if it cannot be reflected, it hits the floor. This is the exception to the rule
				// Pacifists can deflect projectiles, but not reflect them.
				// Instead, they deflect them into the ground below them.
				var/turf/T = get_turf(src)
				P.firer = src
				T.bullet_act(P)
				visible_message("<span class='danger'>[src] deflects the projectile into the ground!</span>", "<span class='userdanger'>You deflect the projectile towards the ground beneath your feet!</span>")
				return FALSE

			visible_message("<span class='danger'>[src] deflects the projectile!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
			if(mind.martial_art.reroute_deflection)
				var/refl_angle = get_angle(loc, get_step(src, dir))
				P.firer = src
				P.set_angle(rand(refl_angle - 30, refl_angle + 30))
				return -1
			else
				return FALSE

	if(HAS_TRAIT(src, TRAIT_DEFLECTS_PROJECTILES))
		add_attack_logs(P.firer, src, "Hit by [P.type], but deflected by something other than martial arts")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)

		if(HAS_TRAIT(src, TRAIT_PACIFISM) || !P.is_reflectable(REFLECTABILITY_PHYSICAL))
			// Pacifism and unreflectables hitting the ground logic. Copied from above
			var/turf/T = get_turf(src)
			P.firer = src
			T.bullet_act(P)
			visible_message("<span class='danger'>[src] deflects the projectile into the ground!</span>", "<span class='userdanger'>You deflect the projectile towards the ground beneath your feet!</span>")
			return FALSE

		visible_message("<span class='danger'>[src] deflects the projectile!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		P.firer = src
		P.set_angle(rand(0, 360))
		return -1

	var/obj/item/organ/external/organ = get_organ(check_zone(def_zone))
	if(isnull(organ))
		return bullet_act(P, "chest") //act on chest instead

	organ.add_autopsy_data(P.name, P.damage) // Add the bullet's name to the autopsy data

	return (..(P , def_zone))

/mob/living/carbon/human/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(!I.tool_use_check(user, 1))
		return TRUE
	var/obj/item/organ/external/S = bodyparts_by_name[user.zone_selected]
	if(!S)
		if(ismachineperson(src))
			to_chat(user, "<span class='notice'>[p_they(TRUE)] [p_are()] missing that limb!</span>")
			return TRUE
		return
	if(!S.is_robotic() || S.open == ORGAN_SYNTHETIC_OPEN)
		return
	. = TRUE
	if(S.brute_dam > ROBOLIMB_SELF_REPAIR_CAP)
		to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
		return

	if(!S.brute_dam)
		to_chat(user, "<span class='notice'>Nothing to fix!</span>")
		return

	var/surgery_time = 0
	if(user == src)
		surgery_time = 10
	if(!I.use_tool(src, user, surgery_time, amount = 1, volume = I.tool_volume))
		return
	var/rembrute = HEALPERWELD
	var/nrembrute = 0
	var/childlist
	if(!isnull(S.children))
		childlist = S.children.Copy()
	var/parenthealed = FALSE
	while(rembrute > 0)
		var/obj/item/organ/external/E
		if(S.brute_dam)
			E = S
		else if(LAZYLEN(childlist))
			E = pick_n_take(childlist)
			if(!E.brute_dam || E.brute_dam >= ROBOLIMB_SELF_REPAIR_CAP || !E.is_robotic())
				continue
		else if(S.parent && !parenthealed)
			E = S.parent
			parenthealed = TRUE
			if(!E.brute_dam  || E.brute_dam >= ROBOLIMB_SELF_REPAIR_CAP || !E.is_robotic())
				break
		else
			break
		nrembrute = max(rembrute - E.brute_dam, 0)
		E.heal_damage(rembrute,0,0,1)
		UpdateDamageIcon()
		rembrute = nrembrute
		user.visible_message("<span class='alert'>[user] patches some dents on [src]'s [E.name] with [I].</span>")
	if(bleed_rate && ismachineperson(src))
		bleed_rate = 0
		user.visible_message("<span class='alert'>[user] patches some leaks on [src] with [I].</span>")
	if(IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(src)] on fire with [I]")
		log_game("[key_name(user)] set [key_name(src)] on fire with [I]")


/mob/living/carbon/human/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	var/obj/item/organ/external/affecting = get_organ(check_zone(def_zone))
	if(affecting && !(affecting.limb_flags & CANNOT_DISMEMBER) && affecting.get_damage() >= (affecting.max_damage - P.dismemberment))
		var/damtype = DROPLIMB_SHARP
		if(!P.sharp)
			switch(P.damage_type)
				if(BRUTE)
					damtype = DROPLIMB_BLUNT
				if(BURN)
					damtype = DROPLIMB_BURN

		affecting.droplimb(FALSE, damtype)

/// This proc calculates armor value for humans.
/// If null is passed for def_zone, then this will return something appropriate for all zones (e.g. area effect damage)
/mob/living/carbon/human/getarmor(def_zone, armor_type)
	// If a specific bodypart is targetted, check if it exists, how that bodypart is protected and return the value
	if(def_zone)
		if(is_external_organ(def_zone))
			return __getarmor_bodypart(def_zone, armor_type)
		var/affecting = get_organ(def_zone)
		if(affecting)
			return __getarmor_bodypart(affecting, armor_type)

	// If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	var/armor
	var/mob_bodyparts
	for(var/obj/item/organ/external/part as anything in bodyparts)
		armor += __getarmor_bodypart(part, armor_type)
		mob_bodyparts++

	return armor / mob_bodyparts

/// This is an internal proc, returns the armor value for a particular bodypart [/obj/item/organ/external].
/// Use `getarmor()` instead
/mob/living/carbon/human/proc/__getarmor_bodypart(obj/item/organ/external/def_zone, armor_type)
	// Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	var/list/obj/item/worn_items = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, l_ear, r_ear, wear_id, neck)

	for(var/obj/item/thing in worn_items)
		if(thing?.body_parts_covered & def_zone.body_part)
			. += thing.armor.getRating(armor_type)

	. += physiology.armor.getRating(armor_type)

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	if(!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

/mob/living/carbon/human/proc/check_reflect(def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance var of the object
	if(wear_suit && isitem(wear_suit))
		var/obj/item/I = wear_suit
		if(I.IsReflect(def_zone) == 1)
			return 1
	if(l_hand && isitem(l_hand))
		var/obj/item/I = l_hand
		if(I.IsReflect(def_zone) == 1)
			return 1
		if(I.IsReflect(def_zone) == 2) //Toy swords
			return 2
	if(r_hand && isitem(r_hand))
		var/obj/item/I = r_hand
		if(I.IsReflect(def_zone) == 1)
			return 1
		if(I.IsReflect(def_zone) == 2) //Toy swords
			return 2
	return 0


//End Here


/mob/living/carbon/human/proc/check_shields(atom/AM, damage, attack_text = "the attack", attack_type = MELEE_ATTACK)
	var/obj/item/shield = get_best_shield()
	var/shield_result = shield?.hit_reaction(src, AM, attack_text, 0, damage, attack_type)
	if(shield_result >= 1)
		return TRUE
	if(shield_result == -1)
		return -1

	if(wear_suit && wear_suit.hit_reaction(src, AM, attack_text, 0, damage, attack_type))
		return TRUE

	if(w_uniform && w_uniform.hit_reaction(src, AM, attack_text, 0, damage, attack_type))
		return TRUE

	if(head && head.hit_reaction(src, AM, attack_text, 0, damage, attack_type))
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_HUMAN_CHECK_SHIELDS, AM, attack_text, 0, damage, attack_type) & SHIELD_BLOCK)
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/get_best_shield()
	var/datum/component/parry/left_hand_parry = l_hand?.GetComponent(/datum/component/parry)
	var/datum/component/parry/right_hand_parry = r_hand?.GetComponent(/datum/component/parry)
	if(!right_hand_parry && !left_hand_parry)
		if(l_hand?.flags_2 & RANDOM_BLOCKER_2)
			return l_hand
		if(r_hand?.flags_2 & RANDOM_BLOCKER_2)
			return r_hand
		return null // no parry component

	if(right_hand_parry && left_hand_parry)
		if(right_hand_parry.stamina_coefficient > left_hand_parry.stamina_coefficient) // try and parry with your best item
			return left_hand_parry.parent
		else
			return right_hand_parry.parent
	return right_hand_parry?.parent || left_hand_parry?.parent // parry with whichever hand has an item that can parry

/mob/living/carbon/human/emp_act(severity)
	..()
	if(HAS_TRAIT(src, TRAIT_EMP_IMMUNE))
		return
	if(HAS_TRAIT(src, TRAIT_EMP_RESIST))
		severity = clamp(severity, EMP_LIGHT, EMP_WEAKENED)
	for(var/X in bodyparts)
		var/obj/item/organ/external/L = X
		L.emp_act(severity)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume * 0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == "head") //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_head()
			else
				to_chat(src, "<span class='notice'>Your [head_clothes.name] protects your head and face from the acid!</span>")
		else
			. = get_organ("head")
			if(.)
				damaged += .
			if(l_ear)
				inventory_items_to_kill += l_ear
			if(r_ear)
				inventory_items_to_kill += r_ear

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == "chest")
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [chest_clothes.name] protects your body from the acid!</span>")
		else
			. = get_organ("chest")
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(wear_pda)
				inventory_items_to_kill += wear_pda
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == "l_arm" || bodyzone_hit == "r_arm")
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [arm_clothes.name] protects your arms and hands from the acid!</span>")
		else
			. = get_organ("r_arm")
			if(.)
				damaged += .
			. = get_organ("l_arm")
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == "l_leg" || bodyzone_hit =="r_leg" || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [leg_clothes.name] protects your legs and feet from the acid!</span>")
		else
			. = get_organ("r_leg")
			if(.)
				damaged += .
			. = get_organ("l_leg")
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/organ/external/affecting in damaged)
		affecting.receive_damage(acidity, 2 * acidity)
		to_chat(src, "<span class='userdanger'>The acid burns you!</span>")
		playsound(src, 'sound/weapons/sear.ogg', 50, TRUE)

		if(istype(affecting, /obj/item/organ/external/head))
			var/obj/item/organ/external/head/head_organ = affecting
			if(prob(min(acidpwr * acid_volume / 10, 90))) //Applies disfigurement
				head_organ.receive_damage(acidity, 2 * acidity)
				emote("scream")
				head_organ.disfigure()
				if(!(NO_HAIR in dna.species.species_traits))
					head_organ.h_style = "Bald"
					head_organ.f_style = "Shaved"
					update_hair()
					update_fhair()

		UpdateDamageIcon()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt
		if(l_hand)
			inventory_items_to_kill += l_hand
		if(r_hand)
			inventory_items_to_kill += r_hand

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

/mob/living/carbon/human/emag_act(mob/user)
	var/obj/item/organ/external/affecting
	if(!user.zone_selected) // pulse demons really.
		affecting = get_organ(pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG))
	else
		affecting = get_organ(user.zone_selected)
	if(!istype(affecting))
		return
	if(!affecting.is_robotic())
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
	else
		to_chat(user, "<span class='warning'>You sneakily hack into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
		affecting.sabotaged = TRUE
	return TRUE

/mob/living/carbon/human/grabbedby(mob/living/user)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	return ..()

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!I || !user || QDELETED(src))
		return

	var/obj/item/organ/external/affecting = get_organ(ran_zone(user.zone_selected))

	// if the targeted limb doesn't exist, pick a new one at random so you don't have to swap target zone
	if(!affecting)
		affecting = pick(bodyparts)

	var/hit_area = parse_zone(affecting.limb_name)

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I, I.force, "the [I.name]", MELEE_ATTACK))
			return

	send_item_attack_message(I, user, hit_area)

	if(!I.force)
		return //item force is zero

	var/armor = run_armor_check(
		def_zone = affecting,
		armor_type = MELEE,
		absorb_text = "Your armor has protected your [hit_area].",
		soften_text = "Your armor has softened hit to your [hit_area].",
		armor_penetration_flat = I.armor_penetration_flat,
		armor_penetration_percentage = I.armor_penetration_percentage,
	)
	if(armor == INFINITY)
		return

	var/weapon_sharp = I.sharp
	// do not roll for random blunt if the target mob is dead for the ease of decaps
	if(stat != DEAD)
		if(weapon_sharp && prob(getarmor(user.zone_selected, MELEE)))
			weapon_sharp = FALSE

	var/bonus_damage = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		bonus_damage = H.physiology.melee_bonus

	apply_damage(I.force + bonus_damage , I.damtype, affecting, armor, sharp = weapon_sharp, used_weapon = I)

	var/bloody = FALSE
	if(I.damtype == BRUTE && I.force && prob(25 + I.force * 2))
		I.add_mob_blood(src)	//Make the weapon bloody, not the person.
		if(prob(I.force * 2)) //blood spatter!
			bloody = TRUE
			var/turf/location = loc
			if(issimulatedturf(location))
				add_splatter_floor(location, emittor_intertia = last_movement_dir)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.add_mob_blood(src)

		if(stat == CONSCIOUS)
			switch(hit_area)
				if("head")//Harder to score a stun but if you do it lasts a bit longer
					if(stat == CONSCIOUS && armor < 50)
						if(prob(I.force))
							visible_message("<span class='combat danger'>[src] has been knocked down!</span>", \
											"<span class='combat userdanger'>[src] has been knocked down!</span>")
							KnockDown(10 SECONDS)
							AdjustConfused(30 SECONDS)
						if(mind && prob(I.force + ((100 - health) / 2)) && src != user && I.damtype == BRUTE)
							SSticker.mode.remove_revolutionary(mind, activate_protection = TRUE)

					if(bloody)//Apply blood
						if(wear_mask)
							wear_mask.add_mob_blood(src)
							update_inv_wear_mask()
						if(head)
							head.add_mob_blood(src)
							update_inv_head()
						if(glasses && prob(33))
							glasses.add_mob_blood(src)
							update_inv_glasses()


				if("chest")//Easier to score a stun but lasts less time
					if(stat == CONSCIOUS && I.force && prob(I.force + 10))
						visible_message("<span class='combat danger'>[src] has been knocked down!</span>", \
										"<span class='combat userdanger'>[src] has been knocked down!</span>")
						KnockDown(8 SECONDS)

					if(bloody)
						if(wear_suit)
							wear_suit.add_mob_blood(src)
							update_inv_wear_suit()
						if(w_uniform)
							w_uniform.add_mob_blood(src)
							update_inv_w_uniform()

	dna.species.spec_attacked_by(I, user, affecting, user.a_intent, src)

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	var/spec_return = dna.species.spec_hitby(AM, src)
	if(spec_return)
		return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(isitem(AM))
		I = AM
		throwpower = I.throwforce
		if(locateUID(I.thrownby) == src) //No throwing stuff at yourself to trigger reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE

	else if(mind?.martial_art?.try_deflect(src))
		var/obj/item/TT = AM
		var/direction = pick(GLOB.alldirs)
		var/turf/target = get_turf(src)
		for(var/i in 1 to rand(6, 10))
			target = get_step(target, direction)
		addtimer(CALLBACK(TT, TYPE_PROC_REF(/atom/movable, throw_at), target, 10, 4, src), 0.2 SECONDS) //Timer set to 0.2 seconds to ensure item finishes the throwing to prevent double embeds
		return TRUE

	else if(I)
		if(((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedded_ignore_throwspeed_threshold)
			if(try_embed_object(I))
				hitpush = FALSE
				skipcatch = TRUE //can't catch the now embedded item
	return ..()

/mob/living/carbon/human/proc/try_embed_object(obj/item/I)
	if(!can_embed(I))
		return FALSE
	if(!prob(I.embed_chance) || HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
		return FALSE
	var/obj/item/organ/external/L = pick(bodyparts)
	L.add_embedded_object(I)
	I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
	L.receive_damage(I.w_class * I.embedded_impact_pain_multiplier)
	visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='userdanger'>[I] embeds itself in your [L.name]!</span>")
	return TRUE

/*
	* This proc makes human hands bloody, if you touch something, you will leave a blood trace

	* blood_dna: list of blood DNAs stored in each atom in blood_DNA variable or in get_blood_dna_list() on carbons
	* b_color: blood color, simple. If there will be null, the blood will be red, otherwise the color you pass
	* amount: amount of "blood charges" you want to give, that will be used to make items/walls bloody.
		You can make something bloody this amount - 1 times.
		If this variable will be null, amount will be set randomly from 2 to max_amount
	* max_amount: if amount is not set, amount will be random from 2 to this value, default 4
*/
/mob/living/carbon/human/proc/make_bloody_hands(list/blood_dna, b_color, amount, max_amount = 4)
	if(isnull(b_color))
		b_color = "#A10808"
	if(gloves)
		gloves.add_blood(blood_dna, blood_color, amount, max_amount)
	else
		hand_blood_color = b_color
		if(isnull(amount))
			bloody_hands = rand(2, max_amount)
		else
			bloody_hands = max(1, amount)
		transfer_blood_dna(blood_dna)
		add_verb(src, /mob/living/carbon/human/proc/bloody_doodle)
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(mob/living/source)
	if(wear_suit)
		wear_suit.add_mob_blood(source)
		update_inv_wear_suit()
		return
	if(w_uniform)
		w_uniform.add_mob_blood(source)
		update_inv_w_uniform()

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to hurt [src]!</span>")
			return FALSE
		var/hulk_verb = pick("smash", "pummel")
		if(check_shields(user, 15, "the [hulk_verb]ing"))
			return
		..(user, TRUE)
		var/datum/unarmed_attack/unarmed = user.get_unarmed_attack()
		playsound(loc, unarmed.attack_sound, 25, TRUE, -1)
		var/message = "[user] has [hulk_verb]ed [src]!"
		visible_message("<span class='danger'>[message]</span>", "<span class='userdanger'>[message]</span>")
		adjustBruteLoss(15)
		return TRUE

/mob/living/carbon/human/attack_hand(mob/user)
	if(..())	//to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

	if(bleed_rate && ishuman(user))
		var/mob/living/carbon/human/attacker = user
		attacker.make_bloody_hands(get_blood_dna_list(), get_blood_color())

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_selected))
			apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, MELEE))
			updatehealth("larva attack")

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == INTENT_HARM)
			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, MELEE, armor_penetration_flat = 10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(M.alien_slash_damage, BRUTE, affecting, armor_block)
			add_attack_logs(M, src, "Alien attacked")
			updatehealth("alien attack")

		if(M.a_intent == INTENT_DISARM) //If not absorbed, you get disarmed, knocked down, and hit with stamina damage.
			if(absorb_stun(0))
				visible_message("<span class='warning'>[src] is not affected by [M]'s disarm attempt!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
				return FALSE
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			apply_effect(10 SECONDS, KNOCKDOWN, run_armor_check(affecting, MELEE))
			M.changeNext_move(1.6 SECONDS)
			apply_damage(M.alien_disarm_damage, STAMINA)
			add_attack_logs(M, src, "Alien tackled")
			visible_message("<span class='danger'>[M] has tackled down [src]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>")

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK))
			return FALSE
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ("chest")
		affecting.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		var/armor = run_armor_check(affecting, MELEE, armor_penetration_flat = M.armor_penetration_flat, armor_penetration_percentage = M.armor_penetration_percentage)
		apply_damage(damage, M.melee_damage_type, affecting, armor)
		updatehealth("animal attack")

/mob/living/carbon/human/handle_basic_attack(mob/living/basic/attacker, modifiers)
	. = ..()
	if(.)
		var/damage = rand(attacker.melee_damage_lower, attacker.melee_damage_upper)
		if(check_shields(attacker, damage, "[attacker.name]", MELEE_ATTACK))
			return FALSE
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ("chest")
		affecting.add_autopsy_data(attacker.name, damage) // Add the mob's name to the autopsy data
		var/armor = run_armor_check(affecting, MELEE, armor_penetration_flat = attacker.armor_penetration_flat, armor_penetration_percentage = attacker.armor_penetration_percentage)
		apply_damage(damage, attacker.melee_damage_type, affecting, armor)
		updatehealth("basicmob attack")

/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 25)
		if(M.is_adult)
			damage = rand(10, 35)

		if(check_shields(M, damage, "the [M.name]"))
			return FALSE

		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")

		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ("chest")
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/organ/external/affecting = get_organ(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(affecting)
			var/update = 0
			var/dmg = rand(M.force/2, M.force)
			switch(M.damtype)
				if("brute")
					apply_damage(dmg, STAMINA)
					if(M.force > 35) // durand and other heavy mechas
						KnockDown(6 SECONDS)
					else if(M.force > 20 && !IsKnockedDown()) // lightweight mechas like gygax
						KnockDown(4 SECONDS)
					update |= affecting.receive_damage(dmg, 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
				if("fire")
					update |= affecting.receive_damage(0, dmg)
					playsound(src, 'sound/items/welder.ogg', 50, TRUE)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			if(update)
				UpdateDamageIcon()
			updatehealth("mech melee attack")

		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='userdanger'>[M.name] hits you!</span>")

		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		..()

/mob/living/carbon/human/experience_pressure_difference(flow_x, flow_y)
	playsound(src, 'sound/effects/space_wind.ogg', 50, TRUE)
	if(HAS_TRAIT(src, TRAIT_NOSLIP))
		return // Immune to gas flow.
	return ..()

/mob/living/carbon/human/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	dna.species.water_act(src, volume, temperature, source, method)
	if(method != REAGENT_TOUCH)
		return

	for(var/obj/O in list(head, wear_suit, back, l_hand, r_hand))
		O.water_act(volume, temperature, source, method)
	if((head?.flags & THICKMATERIAL) && (wear_suit?.flags & THICKMATERIAL)) // fully pierce proof clothing is also water proof!
		return
	for(var/obj/O in list(w_uniform, shoes, belt, gloves, glasses, l_ear, r_ear, wear_id, wear_pda, r_store, l_store, s_store))
		O.water_act(volume, temperature, source, method)


/mob/living/carbon/human/attack_by(obj/item/I, mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_HUMAN_ATTACKED, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FINISH_ATTACK

	return ..()

/mob/living/carbon/human/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return TRUE
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return TRUE
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		return TRUE

/mob/living/carbon/human/proc/reagent_safety_check(hot = TRUE)
	if(wear_mask)
		to_chat(src, "<span class='danger'>Your [wear_mask.name] protects you from the [hot ? "hot" : "cold"] liquid!</span>")
		return FALSE
	if(head)
		to_chat(src, "<span class='danger'>Your [head.name] protects you from the [hot ? "hot" : "cold"] liquid!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/projectile_hit_check(obj/item/projectile/P)
	return (HAS_TRAIT(src, TRAIT_FLOORED) || HAS_TRAIT(src, TRAIT_NOKNOCKDOWNSLOWDOWN)) && !density && !(P.always_hit_living_nondense && (stat != DEAD) && !isLivingSSD(src)) // hit mobs that are intentionally lying down to prevent combat crawling.

/mob/living/carbon/human/canBeHandcuffed()
	return has_left_hand() || has_right_hand()

/// Returns a list. The first element is whether we penetrated all clothing for the zone, the rest are the clothes that got contaminated
/mob/living/carbon/human/proc/rad_contaminate_zone(zone_flag, pocket = FALSE)
	// This is for items inside of the mob
	if(!zone_flag)
		return list(TRUE)
	var/list/garments = list()
	var/list/contaminate = list()
	var/passed = TRUE
	// items in our pocket are treated uniquely as they are outside of the mob but also under most of its clothing
	if(pocket)
		garments = list(w_uniform)
	else
		// the suit is worn on top of all other stuff so it needs to be checked first
		if(wear_suit)
			garments = list(wear_suit)
		for(var/obj/item/clothing/garment in contents)
			if(garment.body_parts_covered & zone_flag)
				garments |= garment
	// If we have a suit push it to the start of the list
	if(wear_suit)
		garments -= wear_suit
		garments = list(wear_suit) + garments

	while(length(garments) && passed)
		var/obj/item/clothing/garment = garments[1]
		garments -= garment
		passed = prob((garment.permeability_coefficient * 100) - 1) && !(garment.flags_2 & RAD_PROTECT_CONTENTS_2)
		if(garment.flags_2 & RAD_NO_CONTAMINATE_2)
			continue
		contaminate += garment

	return list(passed) + contaminate

/// Tries to contaminate a human
/mob/living/carbon/human/contaminate_atom(atom/source, intensity, emission_type, zone = null)
	if(!zone)
		zone = hit_zone_to_clothes_zone(ran_zone())
	var/list/to_contaminate = rad_contaminate_zone(zone)
	if(to_contaminate[1])
		to_contaminate += src
	to_contaminate -= to_contaminate[1]
	for(var/atom/thing in to_contaminate)
		thing.AddComponent(/datum/component/radioactive, intensity, source, emission_type)

/mob/living/carbon/human/proc/peel_off_synthetic_skin()
	var/obj/item/organ/external/external_limb = get_organ(zone_selected)
	if(external_limb && external_limb.augmented_skin_cover_level)
		visible_message("<span class='warning'>[src] begins to pull at their skin...</span>")
		if(!do_mob(src, src, 5 SECONDS))
			return
		external_limb.break_augmented_skin(TRUE)
