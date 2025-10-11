/mob/living/basic/mining_drone
	name = "nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. A mining scanner can instruct it to drop loose ore. Field repairs can be done with a welder."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_MINEBOT
	faction = list("neutral", "goldgrub") // goldgrubs are invulnerable to PKA fire
	weather_immunities = list("ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	maximum_survivable_temperature = INFINITY
	attack_sound = 'sound/weapons/circsawhit.ogg'
	speak_emote = list("states")
	healable = FALSE
	ai_controller = /datum/ai_controller/basic_controller/minebot
	var/light_on = FALSE
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_gun
	var/obj/item/radio/radio
	/// The commands our owner can give us
	var/static/list/pet_commands = list(
		/datum/pet_command/idle/minebot,
		/datum/pet_command/move,
		/datum/pet_command/protect_owner/minebot,
		/datum/pet_command/minebot_ability/light,
		/datum/pet_command/minebot_ability/dump,
		/datum/pet_command/automate_mining,
		/datum/pet_command/free/minebot,
		/datum/pet_command/follow,
		/datum/pet_command/attack/minebot,
	)

/mob/living/basic/mining_drone/Initialize(mapload)
	. = ..()
	stored_gun = new(src)
	var/static/list/innate_actions = list(
		/datum/action/innate/minedrone/toggle_light = BB_MINEBOT_LIGHT_ABILITY,
		/datum/action/innate/minedrone/toggle_meson_vision = null,
		/datum/action/innate/minedrone/dump_ore = BB_MINEBOT_DUMP_ABILITY,
	)

	grant_actions_by_list(innate_actions)

	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Supply" = TRUE))

	AddComponent(/datum/component/footstep, FOOTSTEP_OBJ_ROBOT)
	AddComponent(/datum/component/obeys_commands, pet_commands)

/mob/living/basic/mining_drone/Destroy()
	QDEL_NULL(stored_gun)
	drop_ore(message = FALSE)
	return ..()

/mob/living/basic/mining_drone/emp_act(severity)
	adjustHealth(100 / severity)
	to_chat(src, "<span class='userdanger'>NOTICE: EMP detected, systems damaged!</span>")
	visible_message("<span class='warning'>[src] crackles and buzzes violently!</span>")

/mob/living/basic/mining_drone/examine(mob/user)
	. = ..()
	var/t_He = p_they(TRUE)
	var/t_s = p_s()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += "<span class='warning'>[t_He] look[t_s] slightly dented.</span>"
		else
			. += "<span class='boldwarning'>[t_He] look[t_s] severely dented!</span>"
	var/ore_count = 0
	for(var/obj/item/stack/ore/ore_stack in contents)
		ore_count += ore_stack.amount

	. += "<span class='notice'>[t_He] is currently storing [ore_count] ore.</span>"

	if(stored_gun && stored_gun.max_mod_capacity)
		. += "<span class='notice'><b>[stored_gun.get_remaining_mod_capacity()]%</b> mod capacity remaining.</span>"
		for(var/A in stored_gun.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += "<span class='notice'>There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"

/mob/living/basic/mining_drone/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner))
		to_chat(user, "<span class='notice'>You instruct [src] to drop any collected ore.</span>")
		drop_ore()
		return ITEM_INTERACT_COMPLETE
	if(istype(I, /obj/item/borg/upgrade/modkit))
		I.melee_attack_chain(user, stored_gun, list2params(modifiers))
		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/basic/mining_drone/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	I.melee_attack_chain(user, stored_gun)

/mob/living/basic/mining_drone/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(health == maxHealth)
		to_chat(user, "<span class='notice'>[src] doesn't need repairing!</span>")
		return
	if(!I.tool_use_check(user, 1))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 15, 1, volume = I.tool_volume) && health != maxHealth)
		adjustBruteLoss(-20)
		WELDER_REPAIR_SUCCESS_MESSAGE

/mob/living/basic/mining_drone/death()
	drop_ore(message = FALSE)
	if(stored_gun)
		for(var/obj/item/borg/upgrade/modkit/M in stored_gun.modkits)
			M.uninstall(stored_gun)
	robogibs(loc)
	deathmessage = "blows apart!"
	return ..()

/mob/living/basic/mining_drone/CanPass(atom/movable/O)
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

/mob/living/basic/mining_drone/RangedAttack(atom/target, list/modifiers)
	if(a_intent != INTENT_HARM)
		return
	stored_gun.afterattack__legacy__attackchain(target, src)

/mob/living/basic/mining_drone/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag || (a_intent == INTENT_HARM))
		return

	if(istype(attack_target, /obj/item/stack/ore))
		var/obj/item/target_ore = attack_target
		target_ore.forceMove(src)

/mob/living/basic/mining_drone/proc/drop_ore(message = TRUE)
	if(!length(contents))
		if(message)
			to_chat(src, "<span class='warning'>You attempt to dump your stored ore, but you have none.</span>")
		return
	if(message)
		to_chat(src, "<span class='notice'>You dump your stored ore.</span>")
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(drop_location())

// MARK: Minebot Cube

/obj/item/mining_drone_cube
	name = "mining drone cube"
	desc = "Compressed mining drone, ready for deployment. Just press the button to activate!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "minedronecube"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/mining_drone_cube/attack_self__legacy__attackchain(mob/user)
	user.visible_message("<span class='warning'>\The [src] suddenly expands into a fully functional mining drone!</span>", \
	"<span class='warning'>You press center button on [src]. The device suddenly expands into a fully functional mining drone!</span>")
	var/mob/living/basic/mining_drone/drone = new(get_turf(src))
	drone.befriend(user)
	qdel(src)
