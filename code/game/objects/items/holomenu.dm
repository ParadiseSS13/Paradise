/obj/item/holomenu
	name = "holo-menu"
	desc = "A hologram projector, this one has been set up to display text above itself."
	icon = 'icons/obj/holomenu.dmi'
	icon_state = "holomenu"

	layer = ABOVE_OBJ_LAYER

	light_color = LIGHT_COLOR_CYAN
	light_range = 1.4

	req_one_access = list(ACCESS_BAR, ACCESS_GALLEY, ACCESS_HYDROPONICS)

	var/rave_mode = FALSE
	var/menu_text = ""
	var/border_on = FALSE

	var/image/holo_lights
	var/image/holo_text
	var/image/holo_border

/obj/item/holomenu/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "If you have Bar, Galley, or Hydroponics access, you can swipe your ID on this to anchor it in place."
	. += "You can enter text manually by clicking it with an empty hand, or you can use a paper on the [src] to transfer its written contents."
	. += "ALT-click the [src] to toggle its border."
	. += "CTRL-click the [src] to toggle RAVE MODE."

/obj/item/holomenu/Initialize()
	. = ..()
	holo_lights = image(icon, null, "holomenu-lights")
	holo_text = image(icon, null, "holomenu-text")
	holo_border = image(icon, null, "holomenu-border")

/obj/item/holomenu/Destroy()
	STOP_PROCESSING(SSfast_process, src)
	return ..()

/obj/item/holomenu/process()
	update_icon()

/obj/item/holomenu/update_icon()
	ClearOverlays()
	if(anchored)
		set_light(2)
		if(rave_mode)
			var/color_rotate = color_rotation(rand(-80, 80))
			holo_lights.color = color_rotate
			holo_text.color = color_rotate
			holo_border.color = color_rotate
		else
			holo_lights.color = null
			holo_text.color = null
			holo_border.color = null
		AddOverlays(holo_lights)
		if(length(menu_text))
			AddOverlays(holo_text)
		if(border_on)
			AddOverlays(holo_border)
	else
		set_light(0)

/obj/item/holomenu/attackby(obj/item/attacking_item, mob/user)
	var/obj/item/card/id/ID = attacking_item.GetID()
	if(istype(ID))
		if(check_access(ID))
			anchored = !anchored
			to_chat(user, SPAN_NOTICE("You [anchored ? "" : "un"]anchor \the [src]."))
			update_icon()
		else
			to_chat(user, SPAN_WARNING("Access denied."))
		return TRUE
	if(istype(attacking_item, /obj/item/paper) && allowed(user))
		var/obj/item/paper/P = attacking_item
		to_chat(user, SPAN_NOTICE("You scan \the [attacking_item.name] into \the [name]."))
		menu_text = P.info
		menu_text = replacetext(menu_text, "color=black>", "color=white>")
		update_icon()
		return TRUE
	return ..()

/obj/item/holomenu/examine(mob/user, distance, is_adjacent, infix, suffix, show_extended)
	if(anchored && length(menu_text))
		interact(user)
		return TRUE
	else
		. = ..()

/obj/item/holomenu/attack_hand(mob/user)
	if(anchored)
		if(allowed(user))
			var/new_text = sanitize(input(user, "Enter new text for the holo-menu to display.", "Holo-Menu Display", html2pencode(menu_text, TRUE)) as null|message)
			if(!isnull(new_text))
				menu_text = pencode2html(new_text)
				update_icon()
		else
			interact(user)
		return
	return ..()

/obj/item/holomenu/interact(mob/user)
	var/datum/browser/holomenu_win = new(user, "holomenu", "Holo-Display", 450, 500)
	holomenu_win.set_content(menu_text)
	holomenu_win.open()

/obj/item/holomenu/AltClick(mob/user)
	if(Adjacent(user))
		if(allowed(user))
			border_on = !border_on
			to_chat(user, SPAN_NOTICE("You toggle \the [src]'s border to be [border_on ? "on" : "off"]."))
			update_icon()
		else
			to_chat(user, SPAN_WARNING("Access denied."))
		return
	return ..()

/obj/item/holomenu/CtrlClick(mob/user)
	if(Adjacent(user))
		if(allowed(user))
			rave_mode = !rave_mode
			to_chat(user, SPAN_NOTICE("You toggle \the [src]'s rave mode [rave_mode ? "on" : "off"]."))
			update_icon()
			if(rave_mode)
				START_PROCESSING(SSfast_process, src)
				light_color = LIGHT_COLOR_HALOGEN // a more generic lighting
			else
				STOP_PROCESSING(SSfast_process, src)
				light_color = initial(light_color)
		else
			to_chat(user, SPAN_WARNING("Access denied."))
		return
	return ..()

/obj/item/holomenu/holodeck
	name = "holodeck status projector"
	desc = "A hologram projector, this one has been set up to display text."
	icon = 'icons/obj/holomenu_holodeck.dmi'
	anchored = 1
	layer = 4

	req_one_access = list()

/obj/item/holomenu/holodeck/mechanics_hints(mob/user, distance, is_adjacent)
	. += ..()
	. += "Note that holodecks do not support RAVE MODE."

/obj/item/holomenu/holodeck/attack_hand(mob/user)
	var/new_text = sanitize(input(user, "Enter new text for the hologram to display.", "Hologram Display", html2pencode(menu_text, TRUE)) as null|message)
	if(!isnull(new_text))
		menu_text = pencode2html(new_text)
		update_icon()

/obj/item/holomenu/holodeck/attackby(obj/item/attacking_item, mob/user)
	var/obj/item/card/id/ID = attacking_item.GetID()
	if(istype(ID))
		return TRUE
	if(istype(attacking_item, /obj/item/paper))
		var/obj/item/paper/P = attacking_item
		to_chat(user, SPAN_NOTICE("You scan \the [attacking_item.name] into \the [name]."))
		menu_text = P.info
		menu_text = replacetext(menu_text, "color=black>", "color=white>")
		update_icon()
		return TRUE
	return ..()
