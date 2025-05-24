#define PANEL_OPEN 0
#define WIRES_DISCONNECTED 1
#define LOCK_OFF 2

/obj/structure/closet
	var/picklocking_stage

/obj/structure/closet/examine(mob/user)
	. = ..()
	switch(picklocking_stage)
		if(PANEL_OPEN)
			. += span_notice("Панель управления снята.")
		if(WIRES_DISCONNECTED)
			. += span_notice("Панель управления снята.")
			. += span_notice("Провода отключены и торчат наружу.")
		if(LOCK_OFF)
			. += span_notice("Панель управления снята.")
			. += span_notice("Провода отключены и торчат наружу.")
			. += span_notice("Замок отключён.")

/* Secure closets */
/obj/structure/closet/secure_closet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == null && user.a_intent != INTENT_HARM) // Stage one
		to_chat(user, span_notice("Вы начинаете откручивать панель замка [src]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(95)) // EZ
				broken = TRUE
				picklocking_stage = PANEL_OPEN
				update_icon()
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка [src]!"))
			else // Bad day
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(I.force, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] сорвалась и повредила [affecting.name]!"))
		return TRUE

/obj/structure/closet/secure_closet/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == PANEL_OPEN && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, span_notice("Вы начинаете подготавливать провода панели [src]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				to_chat(user, span_notice("Вы успешно подготовили провода панели замка [src]!"))
				picklocking_stage = WIRES_DISCONNECTED
			else // Bad day
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/secure_closet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == WIRES_DISCONNECTED && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, span_notice("Вы начинаете подключать провода панели замка [src] к [I]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				broken = FALSE // Can be emagged
				picklocking_stage = LOCK_OFF
				emag_act(user)
			else // Bad day
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/* Crates */
/obj/structure/closet/crate/secure/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == null && user.a_intent != INTENT_HARM) // Stage one
		to_chat(user, span_notice("Вы начинаете откручивать панель замка [src]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(95)) // EZ
				broken = TRUE
				picklocking_stage = PANEL_OPEN
				update_icon()
				to_chat(user, span_notice("Вы успешно открутили и сняли панель с замка [src]!"))
				//icon_state = icon_off // Crates has no icon_off :(
			else // Bad day)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(I.force, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] сорвалась и повредила [affecting.name]!"))
		return TRUE

/obj/structure/closet/crate/secure/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == PANEL_OPEN && user.a_intent != INTENT_HARM) // Stage two
		to_chat(user, span_notice("Вы начинаете подготавливать провода панели [src]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				to_chat(user, span_notice("Вы успешно подготовили провода панели замка [src]!"))
				picklocking_stage = WIRES_DISCONNECTED
			else // Bad day
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

/obj/structure/closet/crate/secure/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked && picklocking_stage == WIRES_DISCONNECTED && user.a_intent != INTENT_HARM) // Stage three
		to_chat(user, span_notice("Вы начинаете подключать провода панели замка [src] к [I]..."))
		if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
			if(prob(80)) // Good hacker!
				broken = FALSE // Can be emagged
				picklocking_stage = LOCK_OFF
				emag_act(user)
			else // Bad day
				to_chat(user, span_warning("Черт! Не тот провод!"))
				do_sparks(5, TRUE, src)
				electrocute_mob(user, get_area(src), src, 0.5, TRUE)
		return TRUE

#undef PANEL_OPEN
#undef WIRES_DISCONNECTED
#undef LOCK_OFF
