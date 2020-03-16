/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(!dna.species.bullet_act(P, src))
		return FALSE
	if(P.is_reflectable)
		if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")

			P.reflect_back(src)

			return -1 // complete projectile permutation

	//Shields
	if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration))
		P.on_hit(src, 100, def_zone)
		return 2

	var/obj/item/organ/external/organ = get_organ(check_zone(def_zone))
	if(isnull(organ))
		. = bullet_act(P, "chest") //act on chest instead
		return

	organ.add_autopsy_data(P.name, P.damage) // Add the bullet's name to the autopsy data

	return (..(P , def_zone))

/mob/living/carbon/human/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(!I.tool_use_check(user, 1))
		return
	var/obj/item/organ/external/S = bodyparts_by_name[user.zone_selected]
	if(!S)
		return
	if(!S.is_robotic() || S.open == 2)
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
			if(!E.brute_dam || !E.is_robotic())
				continue
		else if(S.parent && !parenthealed)
			E = S.parent
			parenthealed = TRUE
			if(!E.brute_dam || !E.is_robotic())
				break
		else
			break
		nrembrute = max(rembrute - E.brute_dam, 0)
		E.heal_damage(rembrute,0,0,1)
		rembrute = nrembrute
		user.visible_message("<span class='alert'>[user] patches some dents on [src]'s [E.name] with [I].</span>")
	if(bleed_rate && isSynthetic())
		bleed_rate = 0
		user.visible_message("<span class='alert'>[user] patches some leaks on [src] with [I].</span>")
	if(IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(src)] on fire with [I]")
		log_game("[key_name(user)] set [key_name(src)] on fire with [I]")


/mob/living/carbon/human/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	var/obj/item/organ/external/affecting = get_organ(check_zone(def_zone))
	if(affecting && !affecting.cannot_amputate && affecting.get_damage() >= (affecting.max_damage - P.dismemberment))
		var/damtype = DROPLIMB_SHARP
		switch(P.damage_type)
			if(BRUTE)
				damtype = DROPLIMB_BLUNT
			if(BURN)
				damtype = DROPLIMB_BURN

		affecting.droplimb(FALSE, damtype)

/mob/living/carbon/human/getarmor(var/def_zone, var/type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/obj/item/organ/external/organ in bodyparts)
		armorval += getarmor_organ(organ, type)
		organnum++

	return (armorval/max(organnum, 1))


//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/obj/item/organ/external/def_zone, var/type)
	if(!type || !def_zone)	return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, l_ear, r_ear, wear_id) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]

	return protection

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/obj/item/organ/external/def_zone)
	if(!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(istype(C) && (C.body_parts_covered & def_zone.body_part)) // Is that body part being targeted covered?
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)  continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				return 1
	return 0

/mob/living/carbon/human/proc/check_reflect(var/def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance var of the object
	if(wear_suit && istype(wear_suit, /obj/item/))
		var/obj/item/I = wear_suit
		if(I.IsReflect(def_zone) == 1)
			return 1
	if(l_hand && istype(l_hand, /obj/item/))
		var/obj/item/I = l_hand
		if(I.IsReflect(def_zone) == 1)
			return 1
	if(r_hand && istype(r_hand, /obj/item/))
		var/obj/item/I = r_hand
		if(I.IsReflect(def_zone) == 1)
			return 1
	return 0


//End Here

/mob/living/carbon/human/proc/check_shields(atom/AM, var/damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	var/block_chance_modifier = round(damage / -3)

	if(l_hand && !istype(l_hand, /obj/item/clothing))
		var/final_block_chance = l_hand.block_chance - (Clamp((armour_penetration-l_hand.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
		if(l_hand.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(r_hand && !istype(r_hand, /obj/item/clothing))
		var/final_block_chance = r_hand.block_chance - (Clamp((armour_penetration-r_hand.armour_penetration)/2,0,100)) + block_chance_modifier //Need to reset the var so it doesn't carry over modifications between attempts
		if(r_hand.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(wear_suit)
		var/final_block_chance = wear_suit.block_chance - (Clamp((armour_penetration-wear_suit.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_suit.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(w_uniform)
		var/final_block_chance = w_uniform.block_chance - (Clamp((armour_penetration-w_uniform.armour_penetration)/2,0,100)) + block_chance_modifier
		if(w_uniform.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return 1
	return 0

/mob/living/carbon/human/proc/check_block()
	if(martial_art && prob(martial_art.block_chance) && martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
		return TRUE

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	..()

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

		if(istype(affecting, /obj/item/organ/external/head))
			var/obj/item/organ/external/head/head_organ = affecting
			if(prob(min(acidpwr * acid_volume / 10, 90))) //Applies disfigurement
				head_organ.receive_damage(acidity, 2 * acidity)
				emote("scream")
				head_organ.h_style = "Bald"
				head_organ.f_style = "Shaved"
				update_hair()
				update_fhair()
				head_organ.disfigure()

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

/mob/living/carbon/human/emag_act(user as mob, var/obj/item/organ/external/affecting)
	if(!istype(affecting))
		return
	if(!affecting.is_robotic())
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
	else
		to_chat(user, "<span class='warning'>You sneakily slide the card into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
		affecting.sabotaged = 1
	return 1

/mob/living/carbon/human/grabbedby(mob/living/user)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	return ..()

//Returns 1 if the attack hit, 0 if it missed.
/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!I || !user)
		return 0

	if((istype(I, /obj/item/kitchen/knife/butcher/meatcleaver) || istype(I, /obj/item/twohanded/chainsaw)) && stat == DEAD && user.a_intent == INTENT_HARM)
		var/obj/item/reagent_containers/food/snacks/meat/human/newmeat = new /obj/item/reagent_containers/food/snacks/meat/human(get_turf(loc))
		newmeat.name = real_name + newmeat.name
		newmeat.subjectname = real_name
		newmeat.subjectjob = job
		newmeat.reagents.add_reagent("nutriment", (nutrition / 15) / 3)
		reagents.trans_to(newmeat, round((reagents.total_volume) / 3, 1))
		add_mob_blood(src)
		--meatleft
		to_chat(user, "<span class='warning'>You hack off a chunk of meat from [name]</span>")
		if(!meatleft)
			add_attack_logs(user, src, "Chopped up into meat")
			if(!iscarbon(user))
				LAssailant = null
			else
				LAssailant = user

			qdel(src)

	var/obj/item/organ/external/affecting = get_organ(ran_zone(user.zone_selected))
	if(!affecting)
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return 1
	var/hit_area = parse_zone(affecting.limb_name)

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armour_penetration))
			return 0

	if(check_block())
		visible_message("<span class='warning'>[src] blocks [I]!</span>")
		return FALSE

	if(istype(I,/obj/item/card/emag))
		emag_act(user, affecting)

	send_item_attack_message(I, user, hit_area)

	var/weakness = check_weakness(I,user)

	if(!I.force)
		return 0 //item force is zero

	var/armor = run_armor_check(affecting, "melee", "<span class='warning'>Your armour has protected your [hit_area].</span>", "<span class='warning'>Your armour has softened hit to your [hit_area].</span>", armour_penetration = I.armour_penetration)
	var/weapon_sharp = is_sharp(I)
	if(weapon_sharp && prob(getarmor(user.zone_selected, "melee")))
		weapon_sharp = 0
	if(armor >= 100)
		return 0
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force * weakness, I.damtype, affecting, armor, sharp = weapon_sharp, used_weapon = I)

	var/bloody = 0
	if(I.damtype == BRUTE && I.force && prob(25 + I.force * 2))
		I.add_mob_blood(src)	//Make the weapon bloody, not the person.
		if(prob(I.force * 2)) //blood spatter!
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				add_splatter_floor(location)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.add_mob_blood(src)

		if(!stat)
			switch(hit_area)
				if("head")//Harder to score a stun but if you do it lasts a bit longer
					if(stat == CONSCIOUS && armor < 50)
						if(prob(I.force))
							visible_message("<span class='combat danger'>[src] has been knocked down!</span>", \
											"<span class='combat userdanger'>[src] has been knocked down!</span>")
							apply_effect(5, WEAKEN, armor)
							AdjustConfused(15)
						if(prob(I.force + ((100 - health)/2)) && src != user && I.damtype == BRUTE)
							SSticker.mode.remove_revolutionary(mind)

					if(bloody)//Apply blood
						if(wear_mask)
							wear_mask.add_mob_blood(src)
							update_inv_wear_mask(0)
						if(head)
							head.add_mob_blood(src)
							update_inv_head(0,0)
						if(glasses && prob(33))
							glasses.add_mob_blood(src)
							update_inv_glasses(0)


				if("chest")//Easier to score a stun but lasts less time
					if(stat == CONSCIOUS && I.force && prob(I.force + 10))
						visible_message("<span class='combat danger'>[src] has been knocked down!</span>", \
										"<span class='combat userdanger'>[src] has been knocked down!</span>")
						apply_effect(5, WEAKEN, armor)

					if(bloody)
						if(wear_suit)
							wear_suit.add_mob_blood(src)
							update_inv_wear_suit(1)
						if(w_uniform)
							w_uniform.add_mob_blood(src)
							update_inv_w_uniform(1)



	if(Iforce > 10 || Iforce >= 5 && prob(33))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	dna.species.spec_attacked_by(I, user, affecting, user.a_intent, src)

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	else if(I)
		if(((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedded_ignore_throwspeed_threshold)
			if(can_embed(I))
				if(prob(I.embed_chance) && !(PIERCEIMMUNE in dna.species.species_traits))
					throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
					var/obj/item/organ/external/L = pick(bodyparts)
					L.embedded_objects |= I
					I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
					I.forceMove(src)
					L.receive_damage(I.w_class*I.embedded_impact_pain_multiplier)
					visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='userdanger'>[I] embeds itself in your [L.name]!</span>")
					hitpush = FALSE
					skipcatch = TRUE //can't catch the now embedded item
	if(!blocked)
		dna.species.spec_hitby(AM, src)
	return ..()

/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)

	if(gloves)
		gloves.add_mob_blood(source)
		gloves:transfer_blood = amount
	else
		add_mob_blood(source)
		bloody_hands = amount
	update_inv_gloves(1)		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_mob_blood(source)
		update_inv_wear_suit(0)
		return
	if(w_uniform)
		w_uniform.add_mob_blood(source)
		update_inv_w_uniform(1)

/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage)

	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	if(damtype != BURN && damtype != BRUTE) return

	var/obj/item/clothing/suit/space/SS = wear_suit
	var/penetrated_dam = max(0,(damage - max(0,(SS.breach_threshold - SS.damage))))

	if(penetrated_dam) SS.create_breaches(damtype, penetrated_dam)

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to hurt [src]!</span>")
			return FALSE
		var/hulk_verb = pick("smash", "pummel")
		if(check_shields(user, 15, "the [hulk_verb]ing"))
			return
		..(user, TRUE)
		playsound(loc, user.dna.species.unarmed.attack_sound, 25, 1, -1)
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

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)
			updatehealth("larva attack")

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == INTENT_HARM)
			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
 				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if(damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
 					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
				add_attack_logs(M, src, "Alien attacked")
			updatehealth("alien attack")

		if(M.a_intent == INTENT_DISARM)
			if(prob(80))
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				apply_effect(5, WEAKEN, run_armor_check(affecting, "melee"))
				add_attack_logs(M, src, "Alien tackled")
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>")
			else
				if(prob(99)) //this looks fucking stupid but it was previously 'var/randn = rand(1, 100); if(randn <= 99)'
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>")

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK, M.armour_penetration))
			return FALSE
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ("chest")
		affecting.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		var/armor = run_armor_check(affecting, "melee", armour_penetration = M.armour_penetration)
		apply_damage(damage, M.melee_damage_type, affecting, armor)
		updatehealth("animal attack")

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
		var/armor_block = run_armor_check(affecting, "melee")
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
					if(M.force > 35) // durand and other heavy mechas
						Paralyse(1)
					else if(M.force > 20 && !IsWeakened()) // lightweight mechas like gygax
						Weaken(2)
					update |= affecting.receive_damage(dmg, 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
				if("fire")
					update |= affecting.receive_damage(dmg, 0)
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

/mob/living/carbon/human/experience_pressure_difference(pressure_difference, direction)
	playsound(src, 'sound/effects/space_wind.ogg', 50, TRUE)
	if(shoes && istype(shoes, /obj/item/clothing))
		var/obj/item/clothing/S = shoes
		if (S.flags & NOSLIP)
			return FALSE
	return ..()

/mob/living/carbon/human/water_act(volume, temperature, source, method = TOUCH)
	. = ..()
	dna.species.water_act(src, volume, temperature, source, method)

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
