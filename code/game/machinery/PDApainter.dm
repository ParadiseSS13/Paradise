/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = TRUE
	anchored = TRUE
	var/obj/item/pda/storedpda = null
	/// List of possible PDA colors to choose from
	var/list/colorlist = list()
	/// The preview to show of what the new paint will look like
	var/preview_icon_state = "pda"
	/// Cache of the icon state of the currently inserted PDA
	var/cached_icon_state

/obj/machinery/pdapainter/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return
	if(has_power())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/pdapainter/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return
	if(storedpda)
		. += "[initial(icon_state)]-closed"

/obj/machinery/pdapainter/Initialize(mapload)
	. = ..()
	var/blocked = list(
		/obj/item/pda/silicon,
		/obj/item/pda/silicon/ai,
		/obj/item/pda/silicon/robot,
		/obj/item/pda/silicon/pai,
		/obj/item/pda/heads,
		/obj/item/pda/clear,
		/obj/item/pda/syndicate,
		/obj/item/pda/chameleon,
		/obj/item/pda/chameleon/broken
	)

	for(var/thing in typesof(/obj/item/pda) - blocked)
		var/obj/item/pda/P = thing

		// Icon state for TGUI, only select the first frame
		var/pda_icon_state = "[icon2base64(icon(initial(P.icon), initial(P.icon_state), frame = 1))]"
		colorlist[initial(P.icon_state)] = list(pda_icon_state, initial(P.desc))

/obj/machinery/pdapainter/Destroy()
	on_pda_qdel()
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

/obj/machinery/pdapainter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_unfasten_wrench(user, used))
		power_change()
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/pda))
		insertpda(user)
		return ITEM_INTERACT_COMPLETE

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

/obj/machinery/pdapainter/attack_hand(mob/user)
	if(..())
		return TRUE

	ui_interact(user)

/obj/machinery/pdapainter/ui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PdaPainter", "PDA Painter")
		ui.open()

/obj/machinery/pdapainter/ui_data(mob/user)
	var/list/data = list()
	data["has_pda"] = storedpda ? TRUE : FALSE
	if(storedpda)
		data["current_appearance"] = cached_icon_state

		var/icon/preview_sprite = icon(storedpda.icon, preview_icon_state, frame = 1)
		data["preview_appearance"] = icon2base64(preview_sprite)

	return data

/obj/machinery/pdapainter/ui_static_data(mob/user)
	var/list/data = list()
	data["pda_colors"] = colorlist
	return data

/obj/machinery/pdapainter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	switch(action)
		if("insert_pda")
			insertpda(ui.user)
		if("eject_pda")
			ejectpda(ui.user)
		if("choose_pda")
			preview_icon_state = params["selectedPda"]
		if("paint_pda")
			paintpda()

	if(.)
		add_fingerprint(ui.user)

/obj/machinery/pdapainter/proc/insertpda(mob/user)
	if(storedpda)
		to_chat(user, "There is already a PDA inside.")
		return
	if(!ishuman(user))
		return

	var/obj/item/pda/P = user.get_active_hand()

	if(istype(P))
		if(user.drop_item())
			storedpda = P
			RegisterSignal(P, COMSIG_PARENT_QDELETING, PROC_REF(on_pda_qdel))
			P.forceMove(src)
			P.add_fingerprint(usr)
			update_icon()
			update_pda_cache()

/obj/machinery/pdapainter/proc/ejectpda(mob/user)
	if(!storedpda)
		to_chat(usr, "<span class='notice'>[src] is empty.</span>")
		return
	storedpda.forceMove(get_turf(src))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.put_in_hands(storedpda)

	UnregisterSignal(storedpda, COMSIG_PARENT_QDELETING)
	storedpda.update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	storedpda = null
	update_icon()

/obj/machinery/pdapainter/proc/paintpda()
	if(storedpda)
		storedpda.icon_state = preview_icon_state
		storedpda.desc = colorlist[preview_icon_state][2]
		playsound(loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
		update_pda_cache()

/obj/machinery/pdapainter/proc/update_pda_cache()
	if(!storedpda)
		cached_icon_state = null
		return
	var/icon/pda_sprite = icon(storedpda.icon, storedpda.icon_state, frame = 1)
	cached_icon_state = icon2base64(pda_sprite)
	SStgui.update_uis(src)

/obj/machinery/pdapainter/proc/on_pda_qdel()
	if(!storedpda)
		return
	UnregisterSignal(storedpda, COMSIG_PARENT_QDELETING)
	storedpda = null
	update_icon()

/obj/machinery/pdapainter/power_change()
	if(!..())
		return
	update_icon()
