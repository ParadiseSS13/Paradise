
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/living/user, params)
	return

/atom/movable/attackby(obj/item/W, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!(W.flags&NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(attempt_harvest(I, user))
		return
	I.attack(src, user)


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)

	if(!istype(M)) // not sure if this is the right thing...
		return 0
	var/messagesource = M

	if(can_operate(M))  //Checks if mob is lying down on table for surgery
		if(istype(src,/obj/item/robot_parts))//popup override for direct attach
			if(!attempt_initiate_surgery(src, M, user,1))
				return 0
			else
				return 1
		if(istype(src,/obj/item/organ/external))
			var/obj/item/organ/external/E = src
			if(E.robotic == 2) // Robot limbs are less messy to attach
				if(!attempt_initiate_surgery(src, M, user,1))
					return 0
				else
					return 1

		if(istype(src,/obj/item/weapon/screwdriver) && M.get_species() == "Machine")
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1
		if(is_sharp(src))
			if(!attempt_initiate_surgery(src, M, user))
				return 0
			else
				return 1

	if(istype(M,/mob/living/carbon/brain))
		var/mob/living/carbon/brain/B = M
		messagesource = B.container
	if(hitsound && force > 0)
		playsound(loc, hitsound, 50, 1, -1)
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	add_logs(user, M, "attacked", name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	/////////////////////////

	if(istype(M, /mob/living/simple_animal))
		return 0 // No sanic-speed double-attacks for you - simple mobs will handle being attacked on their own
	var/power = force

	if(!istype(M, /mob/living/carbon/human))
		if(istype(M, /mob/living/carbon/slime))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				to_chat(user, "\red [src] passes right through [M]!")
				return

			if(power > 0)
				slime.attacked += 10

			if(slime.Discipline && prob(50))	// wow, buddy, why am I getting attacked??
				slime.Discipline = 0

			if(power >= 3)
				if(slime.is_adult)
					if(prob(5 + round(power/2)))

						if(slime.Victim)
							if(prob(80) && !slime.client)
								slime.Discipline++
						slime.Victim = null
						slime.anchored = 0

						spawn()
							if(slime)
								slime.SStun = 1
								sleep(rand(5,20))
								if(slime)
									slime.SStun = 0

						spawn(0)
							if(slime)
								slime.canmove = 0
								step_away(slime, user)
								if(prob(25 + power))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1

				else
					if(prob(10 + power*2))
						if(slime)
							if(slime.Victim)
								if(prob(80) && !slime.client)
									slime.Discipline++

									if(slime.Discipline == 1)
										slime.attacked = 0

								spawn()
									if(slime)
										slime.SStun = 1
										sleep(rand(5,20))
										if(slime)
											slime.SStun = 0

							slime.Victim = null
							slime.anchored = 0


						spawn(0)
							if(slime && user)
								step_away(slime, user)
								slime.canmove = 0
								if(prob(25 + power*4))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1


		var/showname = "."
		if(user)
			showname = " by [user]."
			user.do_attack_animation(src)
		if(!(user in viewers(M, null)))
			showname = "."

		for(var/mob/O in viewers(messagesource, null))
			if(attack_verb.len)
				O.show_message("<span class='danger'>[M] has been [pick(attack_verb)] with [src][showname] </span>", 1)
			else
				O.show_message("<span class='danger'>[M] has been attacked with [src][showname] </span>", 1)

		if(!showname && user)
			if(user.client)
				to_chat(user, "<span class='danger'>You attack [M] with [src]. </span>")



	if(istype(M, /mob/living/carbon/human))
		return M:attacked_by(src, user, def_zone)	//make sure to return whether we have hit or miss
	else
		switch(damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/slime))
					M.adjustBrainLoss(power)

				else

					M.take_organ_damage(power)
					if(prob(33)) // Added blood for whacking non-humans too
						var/turf/simulated/location = M.loc
						if(istype(location, /turf/simulated))
							location.add_blood_floor(M)
			if("fire")
				M.take_organ_damage(0, power)
				to_chat(M, "Aargh it burns!")
		M.updatehealth()
	add_fingerprint(user)
	return 1
