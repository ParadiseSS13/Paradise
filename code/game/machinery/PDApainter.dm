/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	max_integrity = 200
	var/obj/item/pda/storedpda = null
	var/list/colorlist = list()
	var/statusLabel
	var/statusLabelCooldownTime = 0
	var/statusLabelCooldownTimeSecondsToAdd = 20 // 20 deciseconds = 2 seconds, 1sec = 0.1 decisecond
	var/allowErasePda = TRUE


/obj/machinery/pdapainter/update_icon()
	cut_overlays()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		add_overlay("[initial(icon_state)]-closed")

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()
	var/blocked = list(/obj/item/pda/silicon, /obj/item/pda/silicon/ai, /obj/item/pda/silicon/robot, /obj/item/pda/silicon/pai, /obj/item/pda/heads,
						/obj/item/pda/clear, /obj/item/pda/syndicate, /obj/item/pda/chameleon, /obj/item/pda/chameleon/broken)

	for(var/thing in typesof(/obj/item/pda) - blocked)
		var/obj/item/pda/P = thing

		// Get Base64 version of an icon for our TGUI needs.
		// Always try to get first frame as it can be animation resulting in all frames in single image.
		// pda-library as an example has 4 frames
		var/iconImage = "[icon2base64(icon(initial(P.icon), initial(P.icon_state), frame = 1))]"
		colorlist[initial(P.icon_state)] = list(iconImage, initial(P.desc))

	colorlist = sortAssoc(colorlist)

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(storedpda)
	return ..()

/obj/machinery/pdapainter/on_deconstruction()
	if(storedpda)
		storedpda.forceMove(loc)
		storedpda = null

/obj/machinery/pdapainter/ex_act(severity)
	if(storedpda)
		storedpda.ex_act(severity)
	..()

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == storedpda)
		storedpda = null
		update_icon()

/obj/machinery/pdapainter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(I, /obj/item/pda))
		if(storedpda)
			to_chat(user, "В аппарате уже есть PDA.")
			return
		else
			var/obj/item/pda/P = user.get_active_hand()
			if(istype(P))
				if(user.drop_item())
					storedpda = P
					P.forceMove(src)
					P.add_fingerprint(user)
					update_icon()
	else
		return ..()

/obj/machinery/pdapainter/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_welder_repair(user, I)

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			stat |= BROKEN
			update_icon()

/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	if(..())
		return 1

	// Do not let click buttons if you're ghost unless you're an admin.
	// TODO: To parent class or separate helper method?
	if (isobserver(usr) && !is_admin(usr))
		return FALSE

	ui_interact(user)

/obj/machinery/pdapainter/power_change()
	..()
	update_icon()



// TGUI Related.

/obj/machinery/pdapainter/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PDAPainter",  "PDA painting machine", 545, 350, master_ui, state)
		ui.open()

/obj/machinery/pdapainter/ui_data(mob/user)
	var/data = list()

	if(storedpda)
		data["hasPDA"] = TRUE
		data["pdaIcon"] = storedpda.iconImage
		data["pdaOwnerName"] = storedpda.owner
		data["pdaJobName"] = storedpda.ownjob
	else
		data["hasPDA"] = FALSE
		data["pdaIcon"] = null
		data["pdaOwnerName"]  = null
		data["pdaJobName"] = null

	if(canUpdateStatusLabel())
		data["statusLabel"] = storedpda ? "OK" : "PDA не найден"
	else
		data["statusLabel"] = statusLabel

	return data

/obj/machinery/pdapainter/ui_static_data(mob/user)
	var/data = list()
	data["pdaTypes"] = colorlist
	data["allowErasePda"] = allowErasePda
	return data

/obj/machinery/pdapainter/ui_act(action, params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("insert_pda")
			insert_pda()
		if("eject_pda")
			eject_pda()
		if("choose_pda")
			if(storedpda)
				storedpda.icon_state = params["selectedPda"]
				storedpda.desc = colorlist[storedpda.icon_state][2]
				storedpda.iconImage = colorlist[storedpda.icon_state][1]
				playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 15, TRUE)
				statusLabel = "Покраска завершена"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd
		if("erase_pda")
			erase_pda()

	if(.)
		add_fingerprint(usr)

/obj/machinery/pdapainter/proc/insert_pda()
	if(!storedpda) // PDA is NOT in the machine.
		if(ishuman(usr))
			var/obj/item/pda/P = usr.get_active_hand()

			if(istype(P)) // If it is really PDA.
				if(usr.drop_item())
					storedpda = P
					P.forceMove(src)
					P.add_fingerprint(usr)
					update_icon()
					SStgui.update_uis(src)
					return TRUE

/obj/machinery/pdapainter/proc/erase_pda()
	if(storedpda) // PDA is in machine.
		if(ishuman(usr))
			if (storedpda.id || storedpda.cartridge)
				to_chat(usr, "<span class='notice'>Уберите карту и картридж из PDA.</span>")
				statusLabel = "Уберите карту и картридж"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd
			else
				storedpda = new /obj/item/pda(src)
				to_chat(usr, "<span class='notice'>Данные на PDA полностью стерты.</span>")
				statusLabel = "PDA очищен"
				statusLabelCooldownTime = world.time + statusLabelCooldownTimeSecondsToAdd

/obj/machinery/pdapainter/proc/eject_pda(var/obj/item/pda/pda = null)
	if(storedpda) // PDA is in machine.
		if(ishuman(usr))
			storedpda.forceMove(get_turf(src))
			if(!usr.get_active_hand() && Adjacent(usr))
				usr.put_in_hands(storedpda)
			storedpda = null
		else
			storedpda.forceMove(get_turf(src))
			storedpda = null
		update_icon()
	SStgui.update_uis(src)
	// SStgui.close_uis(src) // this  can close window on its own, nice

/obj/machinery/pdapainter/proc/canUpdateStatusLabel()
	return (statusLabelCooldownTime < world.time)
