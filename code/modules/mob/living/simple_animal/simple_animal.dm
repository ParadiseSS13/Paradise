/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	universal_understand = 1
	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_resting = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0

	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
	var/force_threshold = 0 //Minimum force required to deal any damage

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atmos_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above


	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/ignored_damage_types = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 1, OXY = 0) //Set 0 to receive that damage type, 1 to ignore
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	var/speed = 1 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster
	var/can_hide    = 0

//Hot simple_animal baby making vars
	var/childtype = null
	var/scan_ready = 1
	var/simplespecies //Sorry, no spider+corgi buttbabies.

	var/master_commander = null //holding var for determining who own/controls a sentient simple animal (for sentience potions).


/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe
	if(!can_hide)
		verbs -= /mob/living/simple_animal/verb/hide


/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = list()
		client.screen += client.void
	..()

/mob/living/simple_animal/updatehealth()
	..()
	health = Clamp(health, 0, maxHealth)


/mob/living/simple_animal/Life()

	if(..())
		if(!ckey)
			handle_automated_movement()
			handle_automated_action()
			handle_automated_speech()
		. = 1

	if(resting && icon_resting && stat != DEAD)
		icon_state = icon_resting
	else if(stat != DEAD)
		icon_state = icon_living

/mob/living/simple_animal/handle_regular_status_updates()
	if(..()) //alive
		if(health < 1)
			death()
			return 0
		return 1

/mob/living/simple_animal/proc/handle_automated_action()
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	if(!stop_automated_movement && wander)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					var/anydir = pick(cardinal)
					if(Process_Spacemove(anydir))
						Move(get_step(src,anydir), anydir)
						turns_since_move = 0
			return

/mob/living/simple_animal/proc/handle_automated_speech()
	if(speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							custom_emote(1, pick(emote_see))
						else
							custom_emote(2, pick(emote_hear))
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					custom_emote(1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					custom_emote(2, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						custom_emote(1, pick(emote_see))
					else
						custom_emote(2,pick(emote_hear))


/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment)
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = get_temperature(environment)

		if( abs(areatemp - bodytemperature) > 40 && !(flags & NO_BREATHE))
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			bodytemperature += diff

		if(istype(T, /turf/simulated))
			var/turf/simulated/ST = T
			if(ST.air)
				var/tox = ST.air.toxins
				var/oxy = ST.air.oxygen
				var/n2 = ST.air.nitrogen
				var/co2 = ST.air.carbon_dioxide

				if(min_oxy && oxy < min_oxy)
					atmos_suitable = 0
					oxygen_alert = 1
				else if(max_oxy && oxy > max_oxy)
					atmos_suitable = 0
					oxygen_alert = 1
				else
					oxygen_alert = 0

				if(min_tox && tox < min_tox)
					atmos_suitable = 0
					toxins_alert = 1
				else if(max_tox && tox > max_tox)
					atmos_suitable = 0
					toxins_alert = 1
				else
					toxins_alert = 0

				if(min_n2 && n2 < min_n2)
					atmos_suitable = 0
				else if(max_n2 && n2 > max_n2)
					atmos_suitable = 0

				if(min_co2 && co2 < min_co2)
					atmos_suitable = 0
				else if(max_co2 && co2 > max_co2)
					atmos_suitable = 0

				if(!atmos_suitable)
					adjustBruteLoss(unsuitable_atmos_damage)

		else
			if(min_oxy || min_tox || min_n2 || min_co2)
				adjustBruteLoss(unsuitable_atmos_damage)

	handle_temperature_damage()

/mob/living/simple_animal/proc/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(3)

/mob/living/simple_animal/Bumped(AM as mob|obj)
	if(!AM) return

	if(resting || buckled)
		return

	if(isturf(src.loc))
		if((status_flags & CANPUSH) && ismob(AM))
			var/newamloc = src.loc
			src.loc = AM:loc
			AM:loc = newamloc
		else
			..()

/mob/living/simple_animal/gib()
	if(icon_gib)
		flick(icon_gib, src)
	if(meat_amount && meat_type)
		for(var/i = 0; i < meat_amount; i++)
			new meat_type(src.loc)
	..()


/mob/living/simple_animal/blob_act()
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/emote(var/act, var/m_type=1, var/message = null)
	if(stat)	return

	switch(act) //IMPORTANT: Emotes MUST NOT CONFLICT anywhere along the chain.
		if("scream")
			message = "<B>\The [src]</B> whimpers."
			m_type = 2

	..(act, m_type, message)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
				"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>")
		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		attack_threshold_check(damage,M.melee_damage_type)

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	if((Proj.damage_type != STAMINA))
		adjustBruteLoss(Proj.damage)
		Proj.on_hit(src, 0)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			if (health > 0)
				visible_message("<span class='notice'> [M] [response_help] [src].</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(I_GRAB)
			if (M == src || anchored)
				return
			if (!(status_flags & CANPUSH))
				return

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src )

			M.put_in_active_hand(G)

			G.synch()

			LAssailant = M

			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(I_HARM, I_DISARM)
			M.do_attack_animation(src)
			visible_message("<span class='danger'>[M] [response_harm] [src]!</span>")
			playsound(loc, "punch", 25, 1, -1)
			attack_threshold_check(harm_intent_damage)

	return

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	switch(M.a_intent)

		if (I_HELP)

			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
		if (I_GRAB)
			grabbedby(M)

		if(I_HARM, I_DISARM)
			M.do_attack_animation(src)
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
					"<span class='userdanger'>[M] has slashed at [src]!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			attack_threshold_check(damage)

	return

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else
			L.do_attack_animation(src)
			var/damage = rand(5, 10)
			visible_message("<span class='danger'>[L] bites [src]!</span>", \
					"<span class='userdanger'>[L] bites [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

			if(stat != DEAD)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)
				attack_threshold_check(damage)


/mob/living/simple_animal/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if (health > 0)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] glomps [src]!</span>", \
				"<span class='userdanger'>[M.name] glomps [src]!</span>")

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		attack_threshold_check(damage)


	return

/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/living/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					if(MED.heal_brute >= 1)
						adjustBruteLoss(-MED.heal_brute)
						MED.amount -= 1
						if(MED.amount <= 0)
							qdel(MED)
						for(var/mob/M in viewers(src, null))
							if ((M.client && !( M.blinded )))
								M.show_message("\blue [user] applies [MED] on [src]")
						return
					else
						user << "\blue [MED] won't help at all."
						return
			else
				user << "\blue [src] is at full health."
				return
		else
			user << "\blue [src] is dead, medical items won't bring it back to life."
			return
	else if(meat_type && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(istype(O, /obj/item/weapon/kitchenknife) || istype(O, /obj/item/weapon/butch))
			harvest()
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		var/damage = 0
		if(O.force)
			if(O.force >= force_threshold)
				damage = O.force
				if (O.damtype == STAMINA)
					damage = 0
				visible_message("<span class='danger'>[user] has [O.attack_verb.len ? "[pick(O.attack_verb)]": "attacked"] [src] with [O]!</span>",\
								"<span class='userdanger'>[user] has [O.attack_verb.len ? "[pick(O.attack_verb)]": "attacked"] you with [O]!</span>")
			else
				visible_message("<span class='danger'>[O] bounces harmlessly off of [src].</span>",\
								"<span class='userdanger'>[O] bounces harmlessly off of [src].</span>")
			playsound(loc, O.hitsound, 50, 1, -1)
		else
			user.visible_message("<span class='warning'>[user] gently taps [src] with [O].</span>",\
								"<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		adjustBruteLoss(damage)


/mob/living/simple_animal/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed

	return tally+config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	statpanel("Status")
	stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death(gibbed)
	health = 0
	icon_state = icon_dead
	stat = DEAD
	density = 0
	if(!gibbed)
		visible_message("<span class='danger'>\The [src] stops moving...</span>")
	..()

/mob/living/simple_animal/ex_act(severity)
	..()
	switch (severity)
		if (1.0)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)
	if(!ignored_damage_types[BRUTE])
		..()

/mob/living/simple_animal/adjustFireLoss(damage)
	if(!ignored_damage_types[BURN])
		..(damage)

/mob/living/simple_animal/adjustToxLoss(damage)
	if(!ignored_damage_types[TOX])
		..(damage)

/mob/living/simple_animal/adjustCloneLoss(damage)
	if(!ignored_damage_types[CLONE])
		..(damage)

/mob/living/simple_animal/proc/CanAttack(var/atom/the_target)
	if(see_invisible < the_target.invisibility)
		return 0
	if (isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return 0
	if (istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if (M.occupant)
			return 0
	if (istype(the_target,/obj/spacepod))
		var/obj/spacepod/S = the_target
		if (S.occupant || S.occupant2)
			return 0
	return 1

/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE)
	if(damage <= force_threshold || ignored_damage_types[damagetype])
		visible_message("<span class='warning'>[src] looks unharmed from the damage.</span>")
	else
		adjustBruteLoss(damage)
		updatehealth()


/mob/living/simple_animal/update_fire()
	return

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/mob/living/simple_animal/revive()
	..()
	health = maxHealth
	icon_state = icon_living
	density = initial(density)
	update_canmove()


/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || !scan_ready || !childtype || !simplespecies)
		return
	scan_ready = 0
	spawn(400)
		scan_ready = 1
	var/alone = 1
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/M in oview(7, src))
		if(istype(M, childtype)) //Check for children FIRST.
			children++
		else if(istype(M, simplespecies))
			if(M.client)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M
		else if(istype(M, /mob/))
			alone = 0
			continue
	if(alone && partner && children < 3)
		new childtype(loc)


// Harvest an animal's delicious byproducts
/mob/living/simple_animal/proc/harvest()
	gib()
	return

/mob/living/simple_animal/say_quote(var/message)
	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	return verb

/mob/living/simple_animal/update_canmove()
	if(paralysis || stunned || weakened || stat || resting)
		drop_r_hand()
		drop_l_hand()
		canmove = 0
	else if(buckled)
		canmove = 0
	else
		canmove = 1
	update_transform()
	return canmove

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)
