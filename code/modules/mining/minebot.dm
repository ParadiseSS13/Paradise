/**********************Mining drone**********************/
#define MINEDRONE_COLLECT 1
#define MINEDRONE_ATTACK 2

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. A mining scanner can instruct it to drop loose ore. Field repairs can be done with a welder."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	faction = list("neutral")
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 0
	environment_smash = 0
	check_friendly_fire = 1
	stop_automated_movement_when_pulled = 1
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	sentience_type = SENTIENCE_MINEBOT
	ranged_message = "shoots"
	ranged_cooldown_time = 30
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/gunshots/gunshot4.ogg'
	speak_emote = list("states")
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma,  /obj/item/stack/ore/uranium,    /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/tranquillite, /obj/item/stack/ore/glass,
						  /obj/item/stack/ore/titanium)
	healable = 0
	var/mode = MINEDRONE_COLLECT
	var/light_on = 0
	var/mesons_active

	var/datum/action/innate/minedrone/toggle_light/toggle_light_action
	var/datum/action/innate/minedrone/toggle_meson_vision/toggle_meson_vision_action
	var/datum/action/innate/minedrone/toggle_mode/toggle_mode_action
	var/datum/action/innate/minedrone/dump_ore/dump_ore_action

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	toggle_light_action = new()
	toggle_light_action.Grant(src)
	toggle_meson_vision_action = new()
	toggle_meson_vision_action.Grant(src)
	toggle_mode_action = new()
	toggle_mode_action.Grant(src)
	dump_ore_action = new()
	dump_ore_action.Grant(src)

	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/emp_act(severity)
	adjustHealth(100 / severity)
	to_chat(src, "<span class='userdanger'>NOTICE: EMP detected, systems damaged!</span>")
	visible_message("<span class='warning'>[src] crackles and buzzes violently!</span>")

/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	AIStatus = AI_OFF
	check_friendly_fire = 0

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weldingtool) && user.a_intent == INTENT_HELP)
		var/obj/item/weldingtool/W = I
		if(W.welding && !stat)
			if(AIStatus != AI_OFF && AIStatus != AI_IDLE)
				to_chat(user, "<span class='info'>[src] is moving around too much to repair!</span>")
				return
			if(do_after_once(user, 15, target = src))
				if(maxHealth == health)
					to_chat(user, "<span class='info'>[src] is at full integrity.</span>")
				else
					adjustBruteLoss(-20)
					to_chat(user, "<span class='info'>You repair some of the armor on [src].</span>")
			return
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner))
		to_chat(user, "<span class='info'>You instruct [src] to drop any collected ore.</span>")
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/death()
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	new /obj/effect/decal/cleanable/blood/gibs/robot(loc)
	DropOre(0)
	qdel(src)

/mob/living/simple_animal/hostile/mining_drone/Shoot(atom/targeted_atom)
	var/obj/item/projectile/kinetic/K = ..()
	var/turf/proj_turf = get_turf(K)
	if(!isturf(proj_turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure > 50)
		K.name = "weakened [K.name]"

		K.damage *= K.pressure_decrease

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		toggle_mode()
		switch(mode)
			if(MINEDRONE_COLLECT)
				to_chat(M, "<span class='info'>[src] has been set to search and store loose ore.</span>")
			if(MINEDRONE_ATTACK)
				to_chat(M, "<span class='info'>[src] has been set to attack hostile wildlife.</span>")
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_COLLECT
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	to_chat(src, "<span class='info'>You are set to collect mode. You can now collect loose ore.</span>")

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_ATTACK
	idle_vision_range = 7
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 1
	minimum_distance = 2
	icon_state = "mining_drone_offense"
	to_chat(src, "<span class='info'>You are set to attack mode. You can now attack from range.</span>")

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/stack/ore) && mode ==  MINEDRONE_COLLECT)
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	for(var/obj/item/stack/ore/O in range(1, src))
		O.forceMove(src)

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre(message = 1)
	if(!contents.len)
		if(message)
			to_chat(src, "<span class='notice'>You attempt to dump your stored ore, but you have none.</span>")
		return
	if(message)
		to_chat(src, "<span class='notice'>You dump your stored ore.</span>")
	for(var/obj/item/stack/ore/O in contents)
		contents -= O
		O.forceMove(loc)
	return

/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount)
	if(mode != MINEDRONE_ATTACK && amount > 0)
		SetOffenseBehavior()
	. = ..()

/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	switch(mode)
		if(MINEDRONE_COLLECT)
			SetOffenseBehavior()
		if(MINEDRONE_ATTACK)
			SetCollectBehavior()
		else //This should never happen.
			mode = MINEDRONE_COLLECT
			SetCollectBehavior()


/mob/living/simple_animal/hostile/mining_drone/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	if(mesons_active)
		sight |= SEE_TURFS
		see_invisible = SEE_INVISIBLE_MINIMUM
	else
		sight &= ~SEE_TURFS
		see_invisible = SEE_INVISIBLE_LIVING

	see_in_dark = initial(see_in_dark)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

//Actions for sentient minebots

/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"

/datum/action/innate/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/innate/minedrone/toggle_light/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner

	if(user.light_on)
		user.set_light(0)
	else
		user.set_light(6)
	user.light_on = !user.light_on
	to_chat(user, "<span class='notice'>You toggle your light [user.light_on ? "on" : "off"].</span>")

/datum/action/innate/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "meson"

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.mesons_active = !user.mesons_active
	user.update_sight()

	to_chat(user, "<span class='notice'>You toggle your meson vision [(user.mesons_active) ? "on" : "off"].</span>")

/datum/action/innate/minedrone/toggle_mode
	name = "Toggle Mode"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/minedrone/toggle_mode/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.toggle_mode()

/datum/action/innate/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.DropOre()


/**********************Minebot Upgrades**********************/

//Melee

/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'

/obj/item/mine_bot_upgrade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user, proximity)
	if(!istype(M) || !proximity)
		return
	upgrade_bot(M, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		to_chat(user, "[M] already has a combat upgrade installed!")
		return
	M.melee_damage_lower = 22
	M.melee_damage_upper = 22
	to_chat(user, "You upgrade [M]'s combat module.")
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot chassis upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		to_chat(user, "[M] already has a reinforced chassis!")
		return
	var/previous = M.maxHealth
	M.maxHealth = 170
	M.health += M.maxHealth - previous
	to_chat(user, "You reinforce [M]'s chassis.")
	qdel(src)


//Cooldown

/obj/item/mine_bot_upgrade/cooldown
	name = "minebot cooldown upgrade"

/obj/item/mine_bot_upgrade/cooldown/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.ranged_cooldown_time != initial(M.ranged_cooldown_time))
		to_chat(user, "[M] already has a decreased weapon cooldown!")
		return
	M.ranged_cooldown_time = 10
	to_chat(user, "You upgrade [M]'s ranged weaponry, reducing its cooldown.")
	qdel(src)


//AI
/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	sentience_type = SENTIENCE_MINEBOT
	origin_tech = "programming=6"

#undef MINEDRONE_COLLECT
#undef MINEDRONE_ATTACK
