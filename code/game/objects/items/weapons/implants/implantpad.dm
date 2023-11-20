/obj/item/implantpad
	name = "bio-chip pad"
	desc = "Used to modify bio-chips."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantpad-off"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/implantcase/case

/obj/item/implantpad/Destroy()
	if(case)
		eject_case()
	return ..()

/obj/item/implantpad/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to remove it's stored implant.</span>"

/obj/item/implantpad/update_icon_state()
	if(case)
		icon_state = "implantpad-on"
	else
		icon_state = "implantpad-off"

/obj/item/implantpad/attack_self(mob/user)
	ui_interact(user)

/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/user)
	if(istype(C))
		addcase(user, C)
	else
		return ..()

/obj/item/implantpad/proc/addcase(mob/user, obj/item/implantcase/C)
	if(!user || !C)
		return
	if(case)
		to_chat(user, "<span class='warning'>There's already a bio-chip in the pad!</span>")
		return
	user.unEquip(C)
	C.forceMove(src)
	case = C
	update_icon(UPDATE_ICON_STATE)

/obj/item/implantpad/proc/eject_case(mob/user)
	if(!case)
		return
	if(user)
		if(user.put_in_hands(case))
			add_fingerprint(user)
			case.add_fingerprint(user)
			case = null
			update_icon(UPDATE_ICON_STATE)
			return

	case.forceMove(get_turf(src))
	case = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/implantpad/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	eject_case(user)

/obj/item/implantpad/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ImplantPad", name, 410, 400, master_ui, state)
		ui.open()

/obj/item/implantpad/ui_data(mob/user)
	var/list/data = list()
	data["contains_case"] = case ? TRUE : FALSE
	if(case && case.imp)
		var/datum/implant_fluff/implant_data = case.imp.implant_data
		data["implant"] = list(
			"name" = implant_data.name,
			"life" = implant_data.life,
			"notes" = implant_data.notes,
			"function" = implant_data.function,
			"image" = "[icon2base64(icon(initial(case.imp.icon), initial(case.imp.icon_state), SOUTH, 1))]",
		)
	return data

/obj/item/implantpad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("eject_case")
			eject_case(ui.user)
