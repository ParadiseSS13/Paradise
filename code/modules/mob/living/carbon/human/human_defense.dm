/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)

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

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	..()

/mob/living/carbon/human/emag_act(user as mob, var/obj/item/organ/external/affecting)
	if(!istype(affecting))
		return
	if(!(affecting.status & ORGAN_ROBOT))
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
	else
		to_chat(user, "<span class='warning'>You sneakily slide the card into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
		affecting.sabotaged = 1
	return 1

//Returns 1 if the attack hit, 0 if it missed.
/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	if(!I || !user)	return 0

	if((istype(I, /obj/item/weapon/kitchen/knife/butcher/meatcleaver) || istype(I, /obj/item/weapon/twohanded/chainsaw)) && src.stat == DEAD && user.a_intent == INTENT_HARM)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new /obj/item/weapon/reagent_containers/food/snacks/meat/human(get_turf(src.loc))
		newmeat.name = src.real_name + newmeat.name
		newmeat.subjectname = src.real_name
		newmeat.subjectjob = src.job
		newmeat.reagents.add_reagent ("nutriment", (src.nutrition / 15) / 3)
		src.reagents.trans_to (newmeat, round ((src.reagents.total_volume) / 3, 1))
		add_mob_blood(src)
		--src.meatleft
		to_chat(user, "<span class='warning'>You hack off a chunk of meat from [src.name]</span>")
		if(!src.meatleft)
			src.create_attack_log("Was chopped up into meat by <b>[key_name(user)]</b>")
			user.create_attack_log("Chopped up <b>[key_name(src)]</b> into meat</b>")
			msg_admin_attack("[key_name_admin(user)] chopped up [key_name_admin(src)] into meat")
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

	if(istype(I,/obj/item/weapon/card/emag))
		emag_act(user, affecting)

	if(! I.discrete)
		if(I.attack_verb.len)
			visible_message("<span class='combat danger'>[src] has been [pick(I.attack_verb)] in the [hit_area] with [I.name] by [user]!</span>")
		else
			visible_message("<span class='combat danger'>[src] has been attacked in the [hit_area] with [I.name] by [user]!</span>")

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].", armour_penetration = I.armour_penetration)
	var/weapon_sharp = is_sharp(I)
	if(weapon_sharp && prob(getarmor(user.zone_sel.selecting, "melee")))
		weapon_sharp = 0

	if(armor >= 100)	return 0
	if(!I.force)	return 0
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force, I.damtype, affecting, armor, sharp = weapon_sharp, used_weapon = I)

	var/bloody = 0
	if(I.damtype == BRUTE && I.force && prob(25 + I.force * 2))
		I.add_mob_blood(src)	//Make the weapon bloody, not the person.
//		if(user.hand)	user.update_inv_l_hand()	//updates the attacker's overlay for the (now bloodied) weapon
//		else			user.update_inv_r_hand()	//removed because weapons don't have on-mob blood overlays
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
		forcesay(hit_appends)	//forcesay checks stat already

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
					playsound(src, 'sound/items/Welder.ogg', 50, 1)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			updatehealth()

		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>", \
								"<span class='userdanger'>[src] has been hit by [M.name].</span>")

		create_attack_log("<font color='orange'>Has been attacked by \the [M] controlled by [key_name(M.occupant)] (INTENT: [uppertext(M.occupant.a_intent)])</font>")
		M.occupant.create_attack_log("<font color='red'>Attacked [src] with \the [M] (INTENT: [uppertext(M.occupant.a_intent)])</font>")
		msg_admin_attack("[key_name_admin(M.occupant)] attacked [key_name_admin(src)] with \the [M] (INTENT: [uppertext(M.occupant.a_intent)])")

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
	species.water_act(src,volume,temperature,source)

/mob/living/carbon/human/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return TRUE
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return TRUE
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		return TRUE