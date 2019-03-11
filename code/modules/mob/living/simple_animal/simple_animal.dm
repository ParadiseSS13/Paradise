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

	var/healable = 1

	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0
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
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	var/unsuitable_atmos_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above


	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/obj_damage = 0 //how much damage this simple animal does to objects, if any
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	var/speed = 1 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster
	var/can_hide    = 0

	var/obj/item/clothing/accessory/petcollar/collar = null
	var/can_collar = 0 // can add collar to mob or not

	//Hot simple_animal baby making vars

	var/childtype = null
	var/scan_ready = 1
	var/simplespecies //Sorry, no spider+corgi buttbabies.

	var/gold_core_spawnable = CHEM_MOB_SPAWN_INVALID //if CHEM_MOB_SPAWN_HOSTILE can be spawned by plasma with gold core, CHEM_MOB_SPAWN_FRIENDLY are 'friendlies' spawned with blood

	var/mob/living/carbon/human/master_commander = null //holding var for determining who own/controls a sentient simple animal (for sentience potions).

	var/mob/living/simple_animal/hostile/spawner/nest

	var/sentience_type = SENTIENCE_ORGANIC // Sentience type, for slime potions
	var/list/loot = list() //list of things spawned at mob's loc when it dies
	var/del_on_death = 0 //causes mob to be deleted on death, useful for mobs that spawn lootable corpses
	var/attacked_sound = "punch"
	var/deathmessage = ""
	var/death_sound = null //The sound played on death


/mob/living/simple_animal/Initialize()
	..()
	GLOB.simple_animal_list += src
	verbs -= /mob/verb/observe
	if(!can_hide)
		verbs -= /mob/living/simple_animal/verb/hide
	if(collar)
		if(!istype(collar))
			collar = new(src)
		regenerate_icons()

/mob/living/simple_animal/Destroy()
	if(collar)
		collar.forceMove(loc)
		collar = null
	master_commander = null
	GLOB.simple_animal_list -= src
	return ..()

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = list()
		client.screen += client.void
	..()

/mob/living/simple_animal/updatehealth(reason = "none given")
	..(reason)
	health = Clamp(health, 0, maxHealth)
	med_hud_set_status()


/mob/living/simple_animal/proc/process_ai()
	handle_automated_movement()
	handle_automated_action()
	handle_automated_speech()

/mob/living/simple_animal/lay_down()
	..()
	handle_resting_state_icons()

/mob/living/simple_animal/proc/handle_resting_state_icons()
	if(icon_resting)
		if(resting && stat != DEAD)
			icon_state = icon_resting
		else if(stat != DEAD)
			icon_state = icon_living

/mob/living/simple_animal/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return

	..(reason)
	if(stat != DEAD)
		if(health < 1)
			death()
			create_debug_log("died of damage, trigger reason: [reason]")

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

	var/areatemp = get_temperature(environment)

	if(abs(areatemp - bodytemperature) > 40 && !(BREATHLESS in mutations))
		var/diff = areatemp - bodytemperature
		diff = diff / 5
		bodytemperature += diff

	var/tox = environment.toxins
	var/oxy = environment.oxygen
	var/n2 = environment.nitrogen
	var/co2 = environment.carbon_dioxide

	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		atmos_suitable = 0
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		atmos_suitable = 0
		throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
	else
		clear_alert("not_enough_oxy")
		clear_alert("too_much_oxy")

	if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
		atmos_suitable = 0
		throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
	else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
		atmos_suitable = 0
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")
		clear_alert("not_enough_tox")

	if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		atmos_suitable = 0
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		atmos_suitable = 0

	if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		atmos_suitable = 0
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		atmos_suitable = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atmos_damage)

	handle_temperature_damage()

/mob/living/simple_animal/proc/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(heat_damage_per_tick)

/mob/living/simple_animal/gib()
	if(icon_gib)
		flick(icon_gib, src)
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
	..()


/mob/living/simple_animal/blob_act()
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/emote(var/act, var/m_type=1, var/message = null)
	if(stat)
		return
	act = lowertext(act)
	switch(act) //IMPORTANT: Emotes MUST NOT CONFLICT anywhere along the chain.
		if("scream")
			message = "<B>\The [src]</B> whimpers."
			m_type = 2
		if("help")
			to_chat(src, "scream")

	..(act, m_type, message)

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	if((Proj.damage_type != STAMINA))
		adjustBruteLoss(Proj.damage)
		Proj.on_hit(src, 0)
	return FALSE

/mob/living/simple_animal/attackby(obj/item/O, mob/living/user)
	if(can_collar && !collar && istype(O, /obj/item/clothing/accessory/petcollar))
		var/obj/item/clothing/accessory/petcollar/C = O
		user.drop_item()
		C.forceMove(src)
		collar = C
		collar.equipped(src)
		regenerate_icons()
		to_chat(usr, "<span class='notice'>You put \the [C] around \the [src]'s neck.</span>")
		if(C.tagname)
			name = C.tagname
			real_name = C.tagname
		return
	else
		..()

/mob/living/simple_animal/movement_delay()
	. = ..()

	. = speed

	. += config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	statpanel("Status")
	stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	if(loot.len)
		for(var/i in loot)
			new i(loc)
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src),death_sound, 200, 1)
		if(deathmessage)
			visible_message("<span class='danger'>\The [src] [deathmessage]</span>")
		else if(!del_on_death)
			visible_message("<span class='danger'>\The [src] stops moving...</span>")
	if(del_on_death)
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		density = 0
		lying = 1

/mob/living/simple_animal/ex_act(severity)
	..()
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/proc/adjustHealth(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return FALSE
	var/oldbruteloss = bruteloss
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth)
	if(oldbruteloss == bruteloss)
		updating_health = FALSE
		. = STATUS_UPDATE_NONE
	else
		. = STATUS_UPDATE_HEALTH
	if(updating_health)
		updatehealth()

/mob/living/simple_animal/adjustBruteLoss(amount, updating_health = TRUE)
	if(damage_coeff[BRUTE])
		return adjustHealth(amount * damage_coeff[BRUTE], updating_health)

/mob/living/simple_animal/adjustFireLoss(amount, updating_health = TRUE)
	if(damage_coeff[BURN])
		return adjustHealth(amount * damage_coeff[BURN], updating_health)

/mob/living/simple_animal/adjustOxyLoss(amount, updating_health = TRUE)
	if(damage_coeff[OXY])
		return adjustHealth(amount * damage_coeff[OXY], updating_health)

/mob/living/simple_animal/adjustToxLoss(amount, updating_health = TRUE)
	if(damage_coeff[TOX])
		return adjustHealth(amount * damage_coeff[TOX], updating_health)

/mob/living/simple_animal/adjustCloneLoss(amount, updating_health = TRUE)
	if(damage_coeff[CLONE])
		return adjustHealth(amount * damage_coeff[CLONE], updating_health)

/mob/living/simple_animal/adjustStaminaLoss(amount, updating_health = TRUE)
	if(damage_coeff[STAMINA])
		return ..(amount*damage_coeff[STAMINA], updating_health)

/mob/living/simple_animal/proc/CanAttack(var/atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
	if(istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if(M.occupant)
			return FALSE
	if(istype(the_target,/obj/spacepod))
		var/obj/spacepod/S = the_target
		if(S.pilot)
			return FALSE
	return TRUE

/mob/living/simple_animal/handle_fire()
	return

/mob/living/simple_animal/update_fire()
	return

/mob/living/simple_animal/IgniteMob()
	return FALSE

/mob/living/simple_animal/ExtinguishMob()
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
		return new childtype(loc)

/mob/living/simple_animal/say_quote(var/message)
	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	return verb

/mob/living/simple_animal/update_canmove(delay_action_updates = 0)
	if(paralysis || stunned || weakened || stat || resting)
		drop_r_hand()
		drop_l_hand()
		canmove = 0
	else if(buckled)
		canmove = 0
	else
		canmove = 1
	update_transform()
	if(!delay_action_updates)
		update_action_buttons_icon()
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

/* Inventory */

/mob/living/simple_animal/show_inv(mob/user as mob)
	if(!can_collar)
		return

	user.set_machine(src)
	var/dat = "<table><tr><td><B>Collar:</B></td><td><A href='?src=[UID()];item=[slot_collar]'>[(collar && !(collar.flags&ABSTRACT)) ? collar : "<font color=grey>Empty</font>"]</A></td></tr></table>"
	dat += "<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>"

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_collar)
			return collar
	. = ..()

/mob/living/simple_animal/can_equip(obj/item/I, slot, disable_warning = 0)
	// . = ..() // Do not call parent. We do not want animals using their hand slots.
	switch(slot)
		if(slot_collar)
			if(collar)
				return FALSE
			if(!can_collar)
				return FALSE
			if(!istype(I, /obj/item/clothing/accessory/petcollar))
				return FALSE
			return TRUE

/mob/living/simple_animal/equip_to_slot(obj/item/W, slot)
	if(!istype(W))
		return FALSE

	if(!slot)
		return FALSE

	W.forceMove(src)
	W.equipped(src, slot)
	W.layer = 20
	W.plane = HUD_PLANE

	switch(slot)
		if(slot_collar)
			collar = W
			if(collar.tagname)
				name = collar.tagname
				real_name = collar.tagname
			regenerate_icons()

/mob/living/simple_animal/unEquip(obj/item/I, force)
	. = ..()
	if(!. || !I)
		return

	if(I == collar)
		collar = null
		regenerate_icons()

/mob/living/simple_animal/get_access()
	. = ..()
	if(collar)
		. |= collar.GetAccess()

/* End Inventory */

/mob/living/simple_animal/proc/sentience_act() //Called when a simple animal gains sentience via gold slime potion
	return

/mob/living/simple_animal/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

/mob/living/simple_animal/can_hear()
	. = TRUE