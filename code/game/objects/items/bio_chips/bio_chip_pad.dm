/obj/item/bio_chip_pad
	name = "bio-chip pad"
	desc = "Used to modify bio-chips."
	icon = 'icons/obj/bio_chips.dmi'
	icon_state = "implantpad-off"
	inhand_icon_state = "electronic"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/bio_chip_case/case
	var/static/list/cached_base64_icons = list()

/obj/item/bio_chip_pad/Destroy()
	if(case)
		eject_case()
	return ..()

/obj/item/bio_chip_pad/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to remove it's stored implant.</span>"

/obj/item/bio_chip_pad/update_icon_state()
	if(case)
		icon_state = "implantpad-on"
	else
		icon_state = "implantpad-off"

/obj/item/bio_chip_pad/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/bio_chip_pad/attackby__legacy__attackchain(obj/item/bio_chip_case/C, mob/user)
	if(istype(C))
		addcase(user, C)
	else
		return ..()

/obj/item/bio_chip_pad/proc/addcase(mob/user, obj/item/bio_chip_case/C)
	if(!user || !C)
		return
	if(case)
		to_chat(user, "<span class='warning'>There's already a bio-chip in the pad!</span>")
		return
	user.unequip(C)
	C.forceMove(src)
	case = C
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/item/bio_chip_pad/proc/eject_case(mob/user)
	if(!case)
		return
	if(user)
		if(user.put_in_hands(case))
			add_fingerprint(user)
			case.add_fingerprint(user)
	case = null
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/item/bio_chip_pad/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	eject_case(user)

/obj/item/bio_chip_pad/ui_state(mob/user)
	return GLOB.default_state

/obj/item/bio_chip_pad/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BioChipPad", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/bio_chip_pad/ui_data(mob/user)
	var/list/data = list()
	data["contains_case"] = case ? TRUE : FALSE
	if(case && case.imp)
		var/datum/implant_fluff/implant_data = case.imp.implant_data
		var/icon/base64icon = cached_base64_icons["[initial(case.imp.icon)][initial(case.imp.icon_state)]"]
		if(!base64icon)
			base64icon = "[icon2base64(icon(initial(case.imp.icon), initial(case.imp.icon_state), SOUTH, 1))]"
			cached_base64_icons["[initial(case.imp.icon)][initial(case.imp.icon_state)]"] = base64icon
		data["implant"] = list(
			"name" = implant_data.name,
			"life" = implant_data.life,
			"notes" = implant_data.notes,
			"function" = implant_data.function,
			"image" = "[icon2base64(icon(initial(case.imp.icon), initial(case.imp.icon_state), SOUTH, 1))]",
		)
		if(istype(case.imp, /obj/item/bio_chip/tracking))
			var/obj/item/bio_chip/tracking/T = case.imp
			data["gps"] = T
			data["tag"] = T.gpstag
		else
			data["gps"] = null
			data["tag"] = null
	else
		// Sanity check in the case that a pad is used for multiple types of implants.
		data["gps"] = null
		data["tag"] = null

	return data

/obj/item/bio_chip_pad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE
	switch(action)
		if("eject_case")
			eject_case(ui.user)
		if("tag")
			var/obj/item/bio_chip/tracking/T = case.imp
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext_char(newtag, 1, 5)))
			if(!length(newtag) || T.gpstag == newtag)
				return
			T.gpstag = newtag
