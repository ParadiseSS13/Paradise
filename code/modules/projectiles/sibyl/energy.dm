/obj/item/gun/energy
	var/can_add_sibyl_system = TRUE //if a sibyl system's mod can be added or removed if it already has one
	var/obj/item/sibyl_system_mod/sibyl_mod = null

/obj/item/gun/energy/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(can_add_sibyl_system)
		if(istype(I, /obj/item/sibyl_system_mod))
			if(!sibyl_mod)
				var/obj/item/sibyl_system_mod/M = I
				M.install(src, user)
				return
		if(I.GetID())
			if(sibyl_mod)
				sibyl_mod.toggleAuthorization(I.GetID(), user)
				return

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(sibyl_mod)
		. += "<span class='notice'>Вы видите индикаторы модуля Sibyl System.</span>"

/obj/item/gun/energy/proc/toggle_voice()
	set name = "Переключить голос Sibyl System"
	set category = "Object"
	set desc = "Кликните для переключения голосовой подсистемы."

	if(sibyl_mod)
		sibyl_mod.toggle_voice()

/obj/item/gun/energy/proc/install_sibyl()
	var/obj/item/sibyl_system_mod/M = new /obj/item/sibyl_system_mod
	M.install(src)

/obj/item/gun/energy/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.integrity == 2)
			sibyl_mod.install(src, user)
			to_chat(user, "<span class='notice'>Вы закрутили шурупы мода Sibyl System в [src].</span>")
			return
		if(sibyl_mod.integrity == 3)
			to_chat(user, "<span class='notice'>Вы начинаете откручивать шурупы мода Sibyl System от [src]...</span>")
			if(prob(90))
				sibyl_mod.uninstall(src, user)
				to_chat(user, "<span class='notice'>Вы успешно открутили шурупы мода Sibyl System от [src].</span>")
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] сорвалась и повредила [affecting.name]!</span>")
			return

/obj/item/gun/energy/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.integrity == 1)
			to_chat(user, "<span class='notice'>Вы начинаете заваривать болты мода Sibyl System от [src]...</span>")
			if(!I.use_tool(src, user, 160, volume = I.tool_volume))
				return
			if(sibyl_mod.integrity == 1)
				sibyl_mod.install(src, user)
				to_chat(user, "<span class='notice'>Вы заварили болты мода Sibyl System в [src].</span>")
			return
		if(sibyl_mod.integrity == 2)
			to_chat(user, "<span class='notice'>Вы начинаете разваривать болты мода Sibyl System от [src]...</span>")
			if(!I.use_tool(src, user, 160, volume = I.tool_volume))
				return
			if(prob(70))
				if(sibyl_mod.integrity == 2)
					sibyl_mod.uninstall(src, user)
					to_chat(user, "<span class='notice'>Вы успешно разварили болты мода Sibyl System от [src].</span>")
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(10, BURN , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] дёрнулась и прожгла [affecting.name]!</span>")
			return

/obj/item/gun/energy/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.integrity == 1)
			to_chat(user, "<span class='notice'>Вы начинаете отковыривать болты мода Sibyl System от [src]...</span>")
			if(!I.use_tool(src, user, 160, volume = I.tool_volume))
				return
			if(prob(95))
				if(sibyl_mod.integrity == 1)
					sibyl_mod.uninstall(src, user)
					to_chat(user, "<span class='notice'>Вы успешно отковыряли болты мода Sibyl System от [src].</span>")
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] соскальзнула и повредила [affecting.name]!</span>")
			return

/obj/item/gun/energy/emag_act(mob/user)
	. = ..()
	if(sibyl_mod && !sibyl_mod.emagged)
		sibyl_mod.emagged = TRUE
		sibyl_mod.unlock()
		if(user)
			user.visible_message("<span class='warning'>От [src] летят искры!</span>", "<span class='notice'>Вы взломали [src], что привело к выключению болтов предохранителя.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 30, 1)
		do_sparks(5, 1, src)
		return

/obj/item/gun/energy/can_shoot()
	. = ..()
	if(sibyl_mod && !sibyl_mod.can_shoot(ammo_type[select]))
		return FALSE

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = 1, params, zone_override, bonus_spread = 0)
	. = ..()
	if(sibyl_mod)
		sibyl_mod.process_fire()

/obj/item/gun/energy/select_fire(mob/living/user)
	. = ..()
	if(sibyl_mod)
		sibyl_mod.check_select()
