/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/

/mob/living/carbon/human/bullet_act(var/obj/item/projectile/P, var/def_zone)

	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
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
				P.Angle = ""//round(Get_Angle(P,P.original))

			return -1 // complete projectile permutation

	//Shields
	if(check_shields(P.damage, "the [P.name]", P))
		P.on_hit(src, 100, def_zone)
		return 2


	//Shrapnel
	if (P.damage_type == BRUTE)
		var/obj/item/organ/external/organ = get_organ(check_zone(def_zone))
		if(!organ)
			return
		var/armor = getarmor_organ(organ, "bullet")
		if((P.embed && prob(20 + max(P.damage - armor, -10))))
			var/obj/item/weapon/shard/shrapnel/SP = new()
			(SP.name) = "[P.name] shrapnel"
			(SP.desc) = "[SP.desc] It looks like it was fired from [P.shot_from]."
			(SP.loc) = organ
			organ.embed(SP)

	var/mob/living/carbon/human/M = src
	var/obj/item/organ/external/affected = M.get_organ(def_zone)
	affected.add_autopsy_data(P.name, P.damage) // Add the bullet's name to the autopsy data

	return (..(P , def_zone))

/mob/living/carbon/human/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone, var/used_weapon = null)
	var/obj/item/organ/external/affected = get_organ(check_zone(def_zone))
	var/siemens_coeff = get_siemens_coefficient_organ(affected)
	stun_amount *= siemens_coeff
	agony_amount *= siemens_coeff

	switch (def_zone)
		if("head")
			agony_amount *= 1.50
		if("l_hand", "r_hand")
			var/c_hand
			if (def_zone == "l_hand")
				c_hand = l_hand
			else
				c_hand = r_hand

			if(c_hand && (stun_amount || agony_amount > 10))
				msg_admin_attack("[src.name] ([src.ckey]) was disarmed by a stun effect")

				unEquip(c_hand)
				if (affected.status & ORGAN_ROBOT)
					emote("me", 1, "drops what they were holding, their [affected.name] malfunctioning!")
				else
					var/emote_scream = pick("screams in pain and", "lets out a sharp cry and", "cries out and")
					emote("me", 1, "[(species && species.flags & NO_PAIN) ? "" : emote_scream ] drops what they were holding in their [affected.name]!")

	if(used_weapon)
		var/obj/item/W = used_weapon
		affected.add_autopsy_data(W.name, agony_amount) // Add the weapon's name to the autopsy data

	..(stun_amount, agony_amount, def_zone, used_weapon)

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
	for(var/obj/item/organ/external/organ in organs)
		armorval += getarmor_organ(organ, type)
		organnum++
	return (armorval/max(organnum, 1))


//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(var/obj/item/organ/external/def_zone, var/type)
	if(!type || !def_zone)	return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]
	return protection

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(var/obj/item/organ/external/def_zone)
	if (!def_zone)
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

/mob/living/carbon/human/proc/check_shields(var/damage = 0, var/attack_text = "the attack", var/obj/item/O)
	if(O)
		if(O.flags & NOSHIELD) //weapon ignores shields altogether
			return 0
	if(l_hand && istype(l_hand, /obj/item/weapon))//Current base is the prob(50-d/3)
		var/obj/item/weapon/I = l_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("<span class='danger'>[src] blocks [attack_text] with [l_hand]!</span>", \
							"<span class='userdanger'>[src] blocks [attack_text] with [l_hand]!</span>")
			return 1
	if(r_hand && istype(r_hand, /obj/item/weapon))
		var/obj/item/weapon/I = r_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("<span class='danger'>[src] blocks [attack_text] with [r_hand]!</span>", \
							"<span class='userdanger'>[src] blocks [attack_text] with [r_hand]!</span>")
			return 1
	if(wear_suit && istype(wear_suit, /obj/item/))
		var/obj/item/I = wear_suit
		if(I.IsShield() && (prob(50)))
			visible_message("<span class='danger'>The reactive teleport system flings [src] clear of [attack_text]!</span>", \
							"<span class='userdanger'>The reactive teleport system flings [src] clear of [attack_text]!</span>")
			var/list/turfs = new/list()
			for(var/turf/T in orange(6, src))
				if(istype(T,/turf/space)) continue
				if(T.density) continue
				if(T.x>world.maxx-6 || T.x<6)	continue
				if(T.y>world.maxy-6 || T.y<6)	continue
				turfs += T
			if(!turfs.len) turfs += pick(/turf in orange(6, src))
			var/turf/picked = pick(turfs)
			if(!isturf(picked)) return
			if(buckled)
				buckled.unbuckle()
			src.loc = picked
			return 1
	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/obj/item/organ/external/O  in organs)
		if(O.status & ORGAN_DESTROYED)	continue
		O.emp_act(severity)
		for(var/obj/item/organ/I  in O.internal_organs)
			I.emp_act(severity)
	..()

/mob/living/carbon/human/emag_act(user as mob, var/obj/item/organ/external/affecting)
	if(!istype(affecting))
		return
	if(!(affecting.status & ORGAN_ROBOT))
		user << "\red That limb isn't robotic."
		return
	if(affecting.sabotaged)
		user << "\red [src]'s [affecting.name] is already sabotaged!"
	else
		user << "\red You sneakily slide the card into the dataport on [src]'s [affecting.name] and short out the safeties."
		affecting.sabotaged = 1
	return 1

//Returns 1 if the attack hit, 0 if it missed.
/mob/living/carbon/human/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone)
	if(!I || !user)	return 0

	if((istype(I, /obj/item/weapon/butch/meatcleaver) || istype(I, /obj/item/weapon/twohanded/chainsaw)) && src.stat == DEAD && user.a_intent == "harm")
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new /obj/item/weapon/reagent_containers/food/snacks/meat/human(get_turf(src.loc))
		newmeat.name = src.real_name + newmeat.name
		newmeat.subjectname = src.real_name
		newmeat.subjectjob = src.job
		newmeat.reagents.add_reagent ("nutriment", (src.nutrition / 15) / 3)
		src.reagents.trans_to (newmeat, round ((src.reagents.total_volume) / 3, 1))
		src.loc.add_blood(src)
		--src.meatleft
		user << "\red You hack off a chunk of meat from [src.name]"
		if(!src.meatleft)
			src.attack_log += "\[[time_stamp()]\] Was chopped up into meat by <b>[user]/[user.ckey]</b>"
			user.attack_log += "\[[time_stamp()]\] Chopped up <b>[src]/[src.ckey]</b> into meat</b>"
			msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] chopped up [src] ([src.ckey]) into meat (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				LAssailant = null
			else
				LAssailant = user

			del(src)

	var/obj/item/organ/external/affecting = get_organ(ran_zone(user.zone_sel.selecting))
	if(!affecting || affecting.is_stump() || (affecting.status & ORGAN_DESTROYED))
		user << "<span class='danger'>They are missing that limb!</span>"
		return 1
	var/hit_area = affecting.name

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I.force, "the [I.name]", I))
			return 0

	if(istype(I,/obj/item/weapon/card/emag))
		emag_act(user, affecting)

	if(! I.discrete)
		if(I.attack_verb.len)
			visible_message("\red <B>[src] has been [pick(I.attack_verb)] in the [hit_area] with [I.name] by [user]!</B>")
		else
			visible_message("\red <B>[src] has been attacked in the [hit_area] with [I.name] by [user]!</B>")

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].")
	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if ((weapon_sharp || weapon_edge) && prob(getarmor(user.zone_sel.selecting, "melee")))
		weapon_sharp = 0
		weapon_edge = 0

	if(armor >= 100)	return 0
	if(!I.force)	return 0
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force, I.damtype, affecting, armor, sharp=weapon_sharp, edge=weapon_edge, used_weapon=I)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
//		if(user.hand)	user.update_inv_l_hand()	//updates the attacker's overlay for the (now bloodied) weapon
//		else			user.update_inv_r_hand()	//removed because weapons don't have on-mob blood overlays
		if(prob(33))
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)
					H.bloody_hands(src)

		if(!stat)
			switch(hit_area)
				if("head")//Harder to score a stun but if you do it lasts a bit longer
					if(stat == CONSCIOUS && prob(I.force) && armor < 50)
						visible_message("<span class='danger'>[src] has been knocked down!</span>", \
										"<span class='userdanger'>[src] has been knocked down!</span>")
						apply_effect(5, WEAKEN, armor)
						confused += 15
						if(src != user && I.damtype == BRUTE)
							ticker.mode.remove_revolutionary(mind)

					if(bloody)//Apply blood
						if(wear_mask)
							wear_mask.add_blood(src)
							update_inv_wear_mask(0)
						if(head)
							head.add_blood(src)
							update_inv_head(0,0)
						if(glasses && prob(33))
							glasses.add_blood(src)
							update_inv_glasses(0)

				if("chest")//Easier to score a stun but lasts less time
					if(stat == CONSCIOUS && I.force && prob(I.force + 10))
						visible_message("<span class='danger'>[src] has been knocked down!</span>", \
										"<span class='userdanger'>[src] has been knocked down!</span>")
						apply_effect(5, WEAKEN, armor)

					if(bloody)
						bloody_body(src)


	if(Iforce > 10 || Iforce >= 5 && prob(33))
		forcesay(hit_appends)	//forcesay checks stat already

/*	//Melee weapon embedded object code. Commented out, as most people on the forums seem to find this annoying and think it does not contribute to general gameplay. - Dave
	if (I.damtype == BRUTE && !I.is_robot_module())
		var/damage = I.force
		if (armor)
			damage /= armor+1

		//blunt objects should really not be embedding in things unless a huge amount of force is involved
		var/embed_chance = weapon_sharp? damage/I.w_class : damage/(I.w_class*3)
		var/embed_threshold = weapon_sharp? 5*I.w_class : 15*I.w_class

		//Sharp objects will always embed if they do enough damage.
		if(((weapon_sharp && damage > (10*I.w_class)) || (damage > embed_threshold && prob(embed_chance))) && (I.no_embed == 0) )
			affecting.embed(I)
	return 1*/

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM as mob|obj,var/speed = 5)
	if(istype(AM,/obj/))
		var/obj/O = AM

		if(in_throw_mode && !get_active_hand() && speed <= 5)	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(isturf(O.loc))
					put_in_active_hand(O)
					visible_message("<span class='warning'>[src] catches [O]!</span>")
					throw_mode_off()
					return

		var/zone = ran_zone("chest", 65)
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce*(speed/5)

		/*
		if(!zone)
			visible_message("\blue \The [O] misses [src] narrowly!")
			return
		*/
		O.throwing = 0		//it hit, so stop moving

		if ((O.thrower != src) && check_shields(throw_damage, "[O]"))
			return

		var/obj/item/organ/external/affecting = get_organ(zone)
		if(!affecting)
			var/missverb = (O.gender == PLURAL) ? "whizz" : "whizzes"
			visible_message("<span class='notice'>\The [O] [missverb] past [src]'s missing [parse_zone(zone)]!</span>",
				"<span class='notice'>\The [O] [missverb] past your missing [parse_zone(zone)]!</span>")
			return
		var/hit_area = affecting.name

		src.visible_message("\red [src] has been hit in the [hit_area] by [O].")
		var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here


		apply_damage(throw_damage, dtype, zone, armor, is_sharp(O), has_edge(O), O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey])[isAntag(M) ? "(ANTAG)" : ""] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		//thrown weapon embedded object code.
		if(dtype == BRUTE && istype(O,/obj/item))
			var/obj/item/I = O
			if (!I.is_robot_module())
				var/sharp = is_sharp(I)
				var/damage = throw_damage
				if (armor)
					damage /= armor+1

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? damage/I.w_class : damage/(I.w_class*3)
				var/embed_threshold = sharp? 5*I.w_class : 15*I.w_class

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if(((sharp && prob(damage/(10*I.w_class)*100)) || (damage > embed_threshold && prob(embed_chance))) && (I.no_embed == 0))
					affecting.embed(I)

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && speed >= 15)
			var/obj/item/weapon/W = O
			var/momentum = speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.loc == src && W.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O


/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)

	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves(1)		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit(0)
		return
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform(1)

/mob/living/carbon/human/proc/handle_suit_punctures(var/damtype, var/damage)

	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	if(damtype != BURN && damtype != BRUTE) return

	var/obj/item/clothing/suit/space/SS = wear_suit
	var/penetrated_dam = max(0,(damage - max(0,(SS.breach_threshold - SS.damage))))

	if(penetrated_dam) SS.create_breaches(damtype, penetrated_dam)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == "harm")
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/organ/external/affecting = get_organ(pick("chest", "chest", "chest", "head"))
		if(affecting)
			var/update = 0
			switch(M.damtype)
				if("brute")
					if(M.force > 20)
						Paralyse(1)
					update |= affecting.take_damage(rand(M.force/2, M.force), 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
				if("fire")
					update |= affecting.take_damage(0, rand(M.force/2, M.force))
					playsound(src, 'sound/items/Welder.ogg', 50, 1)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			updatehealth()

		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>", \
								"<span class='userdanger'>[src] has been hit by [M.name].</span>")
		add_logs(M.occupant, src, "attacked", object=M, addition="(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")

	else
		..()

	return

/mob/living/carbon/human/experience_pressure_difference(pressure_difference, direction)
	if(shoes)
		if(istype(shoes,/obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP)) //TODO: Make a not-shit shoe var system to negate airflow.
			return 0
	..()

/mob/living/carbon/human/water_act(volume, temperature, source)
	..()
	if(temperature >= 330)	bodytemperature = bodytemperature + (temperature - bodytemperature)
	if(temperature <= 280)	bodytemperature = bodytemperature - (bodytemperature - temperature)