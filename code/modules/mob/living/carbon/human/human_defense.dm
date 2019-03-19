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
			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.firer = src
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x
				P.Angle = null

			return -1 // complete projectile permutation

	//Shields
	if(check_shields(P.damage, "the [P.name]", P, PROJECTILE_ATTACK, P.armour_penetration))
		P.on_hit(src, 100, def_zone)
		return 2

	var/obj/item/organ/external/organ = get_organ(check_zone(def_zone))
	if(isnull(organ))
		. = bullet_act(P, "chest") //act on chest instead
		return

	organ.add_autopsy_data(P.name, P.damage) // Add the bullet's name to the autopsy data

	return (..(P , def_zone))

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

/mob/living/carbon/human/proc/check_shields(damage = 0, attack_text = "the attack", atom/movable/AM, attack_type = MELEE_ATTACK, armour_penetration = 0)
	var/block_chance_modifier = round(damage / -3)

	if(l_hand && !istype(l_hand, /obj/item/clothing))
		var/final_block_chance = l_hand.block_chance - (Clamp((armour_penetration-l_hand.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
		if(l_hand.hit_reaction(src, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(r_hand && !istype(r_hand, /obj/item/clothing))
		var/final_block_chance = r_hand.block_chance - (Clamp((armour_penetration-r_hand.armour_penetration)/2,0,100)) + block_chance_modifier //Need to reset the var so it doesn't carry over modifications between attempts
		if(r_hand.hit_reaction(src, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(wear_suit)
		var/final_block_chance = wear_suit.block_chance - (Clamp((armour_penetration-wear_suit.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_suit.hit_reaction(src, attack_text, final_block_chance, damage, attack_type))
			return 1
	if(w_uniform)
		var/final_block_chance = w_uniform.block_chance - (Clamp((armour_penetration-w_uniform.armour_penetration)/2,0,100)) + block_chance_modifier
		if(w_uniform.hit_reaction(src, attack_text, final_block_chance, damage, attack_type))
			return 1
	return 0

/mob/living/carbon/human/check_block()
	if(martial_art && prob(martial_art.block_chance) && martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
		return TRUE

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	..()

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

	var/obj/item/organ/external/affecting = get_organ(ran_zone(user.zone_sel.selecting))
	if(!affecting)
		to_chat(user, "<span class='danger'>They are missing that limb!</span>")
		return 1
	var/hit_area = parse_zone(affecting.limb_name)

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I.force, "the [I.name]", I, MELEE_ATTACK, I.armour_penetration))
			return 0

	if(istype(I,/obj/item/card/emag))
		emag_act(user, affecting)

	send_item_attack_message(I, user, hit_area)

	var/weakness = check_weakness(I,user)

	if(!I.force)
		return 0 //item force is zero

	var/armor = run_armor_check(affecting, "melee", "<span class='warning'>Your armour has protected your [hit_area].</span>", "<span class='warning'>Your armour has softened hit to your [hit_area].</span>", armour_penetration = I.armour_penetration)
	var/weapon_sharp = is_sharp(I)
	if(weapon_sharp && prob(getarmor(user.zone_sel.selecting, "melee")))
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
							ticker.mode.remove_revolutionary(mind)

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
/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = 0, hitpush = 1, blocked = 0)
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger reactions
			return ..()
	if(check_shields(throwpower, "\the [AM.name]", AM, THROWN_PROJECTILE_ATTACK))
		hitpush = 0
		skipcatch = 1
		blocked = 1
	else if(I)
		if(I.throw_speed >= EMBED_THROWSPEED_THRESHOLD)
			if(can_embed(I))
				if(prob(I.embed_chance))
					throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
					var/obj/item/organ/external/L = pick(bodyparts)
					L.embedded_objects |= I
					I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
					I.forceMove(src)
					L.receive_damage(I.w_class*I.embedded_impact_pain_multiplier)
					visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='userdanger'>[I] embeds itself in your [L.name]!</span>")
					hitpush = 0
					skipcatch = 1 //can't catch the now embedded item
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
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)
			updatehealth("larva attack")

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(0, M.name))
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
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
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
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
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
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(damage, "the [M.name]", null, MELEE_ATTACK, M.armour_penetration))
			return 0
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee", armour_penetration = M.armour_penetration)
		var/obj/item/organ/external/affected = src.get_organ(dam_zone)
		if(affected)
			affected.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		apply_damage(damage, M.melee_damage_type, affecting, armor)
		updatehealth("animal attack")

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M)
	..()
	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(10, 35)
	else
		damage = rand(5, 25)

	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")

	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	var/armor_block = run_armor_check(affecting, "melee")
	apply_damage(damage, BRUTE, affecting, armor_block)

	return

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/organ/external/affecting = get_organ(pick("chest", "chest", "chest", "head"))
		if(affecting)
			var/update = 0
			switch(M.damtype)
				if("brute")
					if(M.force > 20)
						Paralyse(1)
					update |= affecting.receive_damage(rand(M.force/2, M.force), 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
				if("fire")
					update |= affecting.receive_damage(0, rand(M.force/2, M.force))
					playsound(src, 'sound/items/welder.ogg', 50, 1)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			updatehealth("mech melee attack")

		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>", \
								"<span class='userdanger'>[src] has been hit by [M.name].</span>")

		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		..()

	return

/mob/living/carbon/human/experience_pressure_difference(pressure_difference, direction)
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes)
		if(istype(shoes,/obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP)) //TODO: Make a not-shit shoe var system to negate airflow.
			return 0
	..()

/mob/living/carbon/human/water_act(volume, temperature, source)
	..()
	dna.species.water_act(src,volume,temperature,source)

/mob/living/carbon/human/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return TRUE
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return TRUE
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		return TRUE
