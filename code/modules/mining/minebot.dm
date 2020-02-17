/**********************Mining drone**********************/
#define MINEDRONE_COLLECT 1
#define MINEDRONE_ATTACK 2

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. A mining scanner can instruct it to drop loose ore. Field repairs can be done with a welder."
	gender = NEUTER
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	faction = list("neutral")
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	move_to_delay = 10
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = 0
	check_friendly_fire = TRUE
	stop_automated_movement_when_pulled = TRUE
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	sentience_type = SENTIENCE_MINEBOT
	speak_emote = list("states")
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma,  /obj/item/stack/ore/uranium,    /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/tranquillite, /obj/item/stack/ore/glass,
						  /obj/item/stack/ore/titanium)
	healable = 0
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	del_on_death = TRUE
	var/mode = MINEDRONE_COLLECT
	var/light_on = 0
	var/mesons_active
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_gun

	var/datum/action/innate/minedrone/toggle_light/toggle_light_action
	var/datum/action/innate/minedrone/toggle_meson_vision/toggle_meson_vision_action
	var/datum/action/innate/minedrone/toggle_mode/toggle_mode_action
	var/datum/action/innate/minedrone/dump_ore/dump_ore_action

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	stored_gun = new(src)
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
	..()
	check_friendly_fire = 0

/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	. = ..()
	var/t_He = p_they(TRUE)
	var/t_him = p_them()
	var/t_s = p_s()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += "<span class='warning'>[t_He] look[t_s] slightly dented.</span>"
		else
			. += "<span class='boldwarning'>[t_He] look[t_s] severely dented!</span>"
	. += {"<span class='notice'>Using a mining scanner on [t_him] will instruct [t_him] to drop stored ore. <b>[max(0, LAZYLEN(contents) - 1)] Stored Ore</b>\n
	Field repairs can be done with a welder."}
	if(stored_gun && stored_gun.max_mod_capacity)
		. += "<b>[stored_gun.get_remaining_mod_capacity()]%</b> mod capacity remaining."
		for(var/A in stored_gun.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += "<span class='notice'>There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"


/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner))
		to_chat(user, "<span class='info'>You instruct [src] to drop any collected ore.</span>")
		DropOre()
		return
	if(istype(I, /obj/item/borg/upgrade/modkit))
		I.melee_attack_chain(user, stored_gun, params)
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!I.tool_start_check(user, 0))
		return
	I.melee_attack_chain(user, stored_gun)

/mob/living/simple_animal/hostile/mining_drone/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(health == maxHealth)
		to_chat(user, "<span class='notice'>[src] doesn't need repairing!</span>")
		return
	if(!I.tool_use_check(user, 1))
		return
	if(AIStatus != AI_OFF && AIStatus != AI_IDLE)
		to_chat(user, "<span class='info'>[src] is moving around too much to repair!</span>")
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 15, 1, volume = I.tool_volume) && health != maxHealth)
		adjustBruteLoss(-20)
		WELDER_REPAIR_SUCCESS_MESSAGE
	return

/mob/living/simple_animal/hostile/mining_drone/death()
	DropOre(0)
	if(stored_gun)
		for(var/obj/item/borg/upgrade/modkit/M in stored_gun.modkits)
			M.uninstall(stored_gun)
	deathmessage = "blows apart!"
	. = ..()

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

/mob/living/simple_animal/hostile/mining_drone/CanPass(atom/movable/O)
	if(istype(O, /obj/item/projectile/kinetic))
		var/obj/item/projectile/kinetic/K = O
		if(K.kinetic_gun)
			for(var/A in K.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	if(istype(O, /obj/item/projectile/destabilizer))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_COLLECT
	vision_range = 9
	search_objects = 2
	wander = TRUE
	ranged = FALSE
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	to_chat(src, "<span class='info'>You are set to collect mode. You can now collect loose ore.</span>")

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_ATTACK
	vision_range = 7
	search_objects = 0
	wander = FALSE
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 1
	icon_state = "mining_drone_offense"
	to_chat(src, "<span class='info'>You are set to attack mode. You can now attack from range.</span>")

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/stack/ore) && mode == MINEDRONE_COLLECT)
		CollectOre()
		return
	if(isliving(target))
		SetOffenseBehavior()
	return ..()

/mob/living/simple_animal/hostile/mining_drone/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	stored_gun.afterattack(A, src) //of the possible options to allow minebots to have KA mods, would you believe this is the best?

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	for(var/obj/item/stack/ore/O in range(1, src))
		O.forceMove(src)

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre(message = 1)
	if(!contents.len)
		if(message)
			to_chat(src, "<span class='warning'>You attempt to dump your stored ore, but you have none.</span>")
		return
	if(message)
		to_chat(src, "<span class='notice'>You dump your stored ore.</span>")
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(drop_location())

/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount, updating_health = TRUE)
	if(mode != MINEDRONE_ATTACK && amount > 0)
		SetOffenseBehavior()
	. = ..()

/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	switch(mode)
		if(MINEDRONE_ATTACK)
			SetCollectBehavior()
		else
			SetOffenseBehavior()

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
	var/sight_flags = SEE_TURFS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/user = owner
	var/is_active = user.sight & SEE_TURFS

	if(is_active)
		UnregisterSignal(user, COMSIG_MOB_UPDATE_SIGHT)
		user.update_sight()
	else
		RegisterSignal(user, COMSIG_MOB_UPDATE_SIGHT, .proc/update_user_sight)
		user.update_sight()

	to_chat(user, "<span class='notice'>You toggle your meson vision [!is_active ? "on" : "off"].</span>")

/datum/action/innate/minedrone/toggle_meson_vision/proc/update_user_sight(mob/living/user)
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

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
	M.melee_damage_lower += 7
	M.melee_damage_upper += 7
	to_chat(user, "You upgrade [M]'s combat module.")
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		to_chat(user, "[M] already has a reinforced chassis!")
		return
	M.maxHealth += 45
	M.updatehealth()
	qdel(src)

//AI

/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	sentience_type = SENTIENCE_MINEBOT
	origin_tech = "programming=6"
	var/base_health_add = 5 //sentient minebots are penalized for beign sentient; they have their stats reset to normal plus these values
	var/base_damage_add = 1 //this thus disables other minebot upgrades
	var/base_speed_add = 1
	var/base_cooldown_add = 10 //base cooldown isn't reset to normal, it's just added on, since it's not practical to disable the cooldown module

/obj/item/slimepotion/sentience/mining/after_success(mob/living/user, mob/living/simple_animal/SM)
	if(istype(SM, /mob/living/simple_animal/hostile/mining_drone))
		var/mob/living/simple_animal/hostile/mining_drone/M = SM
		M.maxHealth = initial(M.maxHealth) + base_health_add
		M.melee_damage_lower = initial(M.melee_damage_lower) + base_damage_add
		M.melee_damage_upper = initial(M.melee_damage_upper) + base_damage_add
		M.move_to_delay = initial(M.move_to_delay) + base_speed_add
		if(M.stored_gun)
			M.stored_gun.overheat_time += base_cooldown_add

/**********************Mining drone cube**********************/

/obj/item/mining_drone_cube
	name = "mining drone cube"
	desc = "Compressed mining drone, ready for deployment. Just press the button to activate!"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/aibots.dmi'
	icon_state = "minedronecube"
	item_state = "electronic"

/obj/item/mining_drone_cube/attack_self(mob/user)
	user.visible_message("<span class='warning'>\The [src] suddenly expands into a fully functional mining drone!</span>", \
	"<span class='warning'>You press center button on \the [src]. The device suddenly expands into a fully functional mining drone!</span>")
	new /mob/living/simple_animal/hostile/mining_drone(get_turf(src))
	qdel(src)

#undef MINEDRONE_COLLECT
#undef MINEDRONE_ATTACK