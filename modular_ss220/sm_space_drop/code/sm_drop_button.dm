//////////////////////////////////////
//			Кнопка СБСКС			//
//////////////////////////////////////
/// Supermatter Drop button
/obj/machinery/driver_button/sm_drop_button
	name = "supermatter launch trigger"
	desc = "Кнопка экстренного сброс кристалла Суперматерии.\n<font color='red'>ВНИМАНИЕ:</font> Неправомерное использование может привести к тюремному заключению."
	icon = 'modular_ss220/sm_space_drop/icons/sm_buttons.dmi'
	icon_state = "button"
	// We don't want it to be randomly destroyed
	max_integrity = 500
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 10, rad = 100, fire = 90, acid = 70)
	id_tag = "SpaceDropSM"
	req_access = list(ACCESS_CE)
	/// If the safety glass is still in place
	var/glass = TRUE
	/// If it's already used and launched
	var/launched = FALSE
	var/obj/machinery/atmospherics/supermatter_crystal/engine/crystal

// In case we're annihilated by a meteor
/obj/machinery/driver_button/sm_drop_button/Destroy()
	if(!launched)
		launch_sequence()
	crystal = null
	return ..()

/obj/machinery/driver_button/sm_drop_button/update_icon_state()
	if(launched)
		icon_state = "[initial(icon_state)]_launched"
	else if(!glass)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"
	..()

/obj/machinery/driver_button/sm_drop_button/examine(mob/user)
	. = ..()
	if(!glass)
		. += span_notice("У [name] разбито защитное стекло.")
	if(launched)
		. += span_notice("Кнопка медленно мигает, сигнализируя о том, что она была нажата.")

/obj/machinery/driver_button/sm_drop_button/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)

	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		return

	if(isAI(user))
		return

	add_fingerprint(user)
	use_power(5)

	if(!allowed(user) && !glass && !launched)
		to_chat(user, span_warning("В доступе отказано."))
		return

	// Already launched
	if(launched)
		to_chat(user, span_warning("Кнопка уже нажата."))
		return

	// Glass present
	else if(glass)
		if(user.a_intent == INTENT_HARM)
			user.visible_message(span_warning("[user] разбивает стекло [name]!"), span_warning("Вы разбиваете стекло [name]!"))
			user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			glass = FALSE
			playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, TRUE)
			update_icon_state()
		else
			user.visible_message(span_notice("[user] дружески похлопывает по [name]."), span_notice("Вы дружески похлопываете по [name]."))
			playsound(loc, 'sound/effects/glassknock.ogg', 50, TRUE)
			to_chat(user, span_warning("Если вы пытаетесь разбить стекло, вам придется ударить по нему сильнее..."))
	else
		// Must be !glass and !launched and crystal is in emergency state (around 10%)
		for(crystal in SSair.atmos_machinery)
			if(crystal?.id_tag == id_tag && crystal?.get_integrity() < SUPERMATTER_EMERGENCY)
				user.visible_message(span_warning("[user] нажимает кнопку сброса [name]!"), span_warning("Вы нажимаете кнопку сброса!"))
				playsound(loc, "modular_ss220/sm_space_drop/sound/button[rand(1, 5)].ogg", 100, TRUE)
				visible_message(span_notice("Кнопка громко щелкает."))
				launch_sequence()
				update_icon_state()
				if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
					var/area/area = get_area(src)
					if(area)
						message_admins("Supermatter Crystal has been launched to space by [key_name_admin(user)] [ADMIN_JMP(src)].")
						investigate_log("has been launched to space at ([area.name]) by [key_name(user)].", "supermatter")
				break
			else
				playsound(loc, "modular_ss220/sm_space_drop/sound/button[rand(1, 5)].ogg", 100, TRUE)
				to_chat(user, span_warning("Система безопасности заблокировала попытку сброса. Кристалл не находится в состоянии расслоения!"))
				return

/obj/machinery/driver_button/sm_drop_button/launch_sequence()
	if(launched)
		return
	launched = TRUE
	GLOB.major_announcement.Announce("ВНИМАНИЕ, ПРОИЗВОДИТСЯ ЭКСТРЕННЫЙ СБРОС КРИСТАЛЛА!", "РЕАКТОР СУПЕРМАТЕРИИ: ЭКСТРЕННЫЙ СБРОС.", 'sound/effects/engine_alert2.ogg')

	for(crystal in SSair.atmos_machinery)
		if(crystal?.id_tag == id_tag)
			crystal.anchored = FALSE
			break

	..()

/obj/machinery/driver_button/sm_drop_button/rearm()
	active = FALSE

/obj/machinery/driver_button/sm_drop_button/wrench_act()
	return

/obj/machinery/driver_button/sm_drop_button/multitool_act()
	return
