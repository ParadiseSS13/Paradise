/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/weapons/energy.dmi'
	fire_sound_text = "laser blast"

	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell/laser
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = 1
	var/charge_sections = 4
	ammo_x_offset = 2
	var/shaded_charge = 0 //if this gun uses a stateful charge bar for more detail
	var/selfcharge = 0
	var/charge_tick = 0
	var/charge_delay = 4

	var/can_add_sibyl_system = TRUE //if a sibyl system's mod can be added or removed if it already has one
	var/obj/item/sibyl_system_mod/sibyl_mod = null

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(sibyl_mod)
		. += "<span class='notice'>Вы видите индикаторы модуля Sibyl System.</span>"

/obj/item/gun/energy/attackby(obj/item/I, mob/user, params)
	..()
	if(can_add_sibyl_system)
		if(istype(I, /obj/item/sibyl_system_mod))
			if(!sibyl_mod)
				var/obj/item/sibyl_system_mod/M = I
				M.install(src, user)
				return
		if(istype(I, /obj/item/card/id/))
			if(sibyl_mod)
				sibyl_mod.toggleAuthorization(I, user)
				return

/obj/item/gun/energy/proc/toggle_voice()
	set name = "Переключить голос Sibyl System"
	set category = "Object"
	set desc = "Кликните для переключения голосовой подсистемы."

	if(sibyl_mod)
		sibyl_mod.toggle_voice(usr)

/obj/item/gun/energy/screwdriver_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_SCREWDRIVER_ACT)
			sibyl_mod.state = SIBSYS_STATE_INSTALLED
			to_chat(user, "<span class='notice'>Вы закрутили шурупы мода Sibyl System в [src].</span>")
			return
		else
			if(prob(90))
				sibyl_mod.state = SIBSYS_STATE_SCREWDRIVER_ACT
				to_chat(user, "<span class='notice'>Вы успешно открутили шурупы мода Sibyl System от [src].</span>")
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] сорвалась и повредила [affecting.name]!</span>")
			return

/obj/item/gun/energy/welder_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
			to_chat(user, "<span class='notice'>Вы начинаете заваривать болты мода Sibyl System от [src]...</span>")
			if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				sibyl_mod.state = SIBSYS_STATE_SCREWDRIVER_ACT
				to_chat(user, "<span class='notice'>Вы заварили болты мода Sibyl System в [src].</span>")
			return
		if(sibyl_mod.state == SIBSYS_STATE_SCREWDRIVER_ACT)
			to_chat(user, "<span class='notice'>Вы начинаете разваривать болты мода Sibyl System от [src]...</span>")
			if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				if(prob(70))
					sibyl_mod.state = SIBSYS_STATE_WELDER_ACT
					to_chat(user, "<span class='notice'>Вы успешно разварили болты мода Sibyl System от [src].</span>")
				else
					var/mob/living/carbon/human/H = user
					var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
					user.apply_damage(10, BURN , affecting)
					user.emote("scream")
					to_chat(user, "<span class='warning'>Проклятье! [I] дёрнулась и прожгла [affecting.name]!</span>")
			return

/obj/item/gun/energy/crowbar_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
			to_chat(user, "<span class='notice'>Вы начинаете отковыривать болты мода Sibyl System от [src]...</span>")
			if(!I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				return
			if(prob(95))
				if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
					sibyl_mod.uninstall(src)
					to_chat(user, "<span class='notice'>Вы успешно отковыряли болты мода Sibyl System от [src].</span>")
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? "l_hand" : "r_hand")
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, "<span class='warning'>Проклятье! [I] соскальзнула и повредила [affecting.name]!</span>")
			return

/obj/item/gun/energy/emag_act(mob/user)
	if(!sibyl_mod?.emagged)
		add_attack_logs(user, sibyl_mod, "emagged")
		sibyl_mod.emagged = TRUE
		sibyl_mod.unlock()
		if(user)
			user.visible_message("<span class='warning'>От [src] летят искры!</span>", "<span class='notice'>Вы взломали [src], что привело к выключению болтов предохранителя.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 30, 1)
		do_sparks(5, 1, src)
		return

/obj/item/gun/energy/emp_act(severity)
	cell.use(round(cell.charge / severity))
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot() //phil235
	update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize(mapload, ...)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.give(cell.maxcharge)
	update_ammo_types()
	on_recharge()
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if(selfcharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/process()
	if(selfcharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return // check if we actually need to recharge
		cell.give(100) //... to recharge the shot
		on_recharge()
		update_icon()

/obj/item/gun/energy/proc/on_recharge()
	newshot()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()
		if(istype(user,/mob/living/carbon/human)) //This has to be here or else if you toggle modes by clicking the gun in hand
			var/mob/living/carbon/human/H = user //Otherwise the mob icon doesn't update, blame shitty human update_icons() code
			H.update_inv_l_hand()
			H.update_inv_r_hand()

/obj/item/gun/energy/can_shoot(mob/living/user)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/check_charge = cell.charge >= shot.e_cost
	if(sibyl_mod && !sibyl_mod.check_auth(check_charge, user))
		return FALSE
	return check_charge

/obj/item/gun/energy/newshot()
	if(!ammo_type || !cell)
		return
	if(!chambered)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if(cell.charge >= shot.e_cost) //if there's enough power in the WEAPON'S cell...
			chambered = shot //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
		robocharge()
	chambered = null //either way, released the prepared shot
	newshot()

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = 1, params, zone_override, bonus_spread = 0)
	if(!chambered && can_shoot(user))
		process_chamber()
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	if(++select > ammo_type.len)
		select = 1
	else
		if(sibyl_mod && !sibyl_mod.check_select(select))
			select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(!isnull(user) && shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot()
	update_icon()
	return

/obj/item/gun/energy/update_icon()
	overlays.Cut()
	var/ratio = CEILING((cell.charge / cell.maxcharge) * charge_sections, 1)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if(modifystate)
		overlays += "[icon_state]_[shot.select_name]"
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(cell.charge < shot.e_cost)
		overlays += "[icon_state]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				overlays += image(icon = icon, icon_state = iconState, pixel_x = ammo_x_offset * (i -1))
		else
			overlays += image(icon = icon, icon_state = "[icon_state]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		overlays += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(bayonet && can_bayonet)
		overlays += knife_overlay
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/gun/energy/suicide_act(mob/user)
	if(can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of the [name] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide.</span>")
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with the [name]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return FIRELOSS
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brains out with the [name]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return OXYLOSS

/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("selfcharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/gun/energy/proc/robocharge()
	if(cell.charge == cell.maxcharge)
		// No point in recharging a weapon's cell that is already at 100%. That would just waste borg cell power for no reason.
		return
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				cell.give(shot.e_cost)	//... to recharge the shot
