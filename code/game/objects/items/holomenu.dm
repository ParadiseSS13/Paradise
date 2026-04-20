/obj/item/holomenu
	name = "holo-menu"
	desc = "A hologram projector, this one has been set up to display text above itself."
	icon = 'icons/obj/holomenu.dmi'
	icon_state = "holomenu"

	layer = ABOVE_OBJ_LAYER

	light_color = LIGHT_COLOR_CYAN
	light_range = 1.4

	req_one_access = list(ACCESS_BAR, ACCESS_KITCHEN)

	var/rave_mode = FALSE
	var/menu_text = ""
	var/border_on = FALSE

	var/image/holo_lights
	var/image/holo_text
	var/image/holo_border

/obj/item/holomenu/examine(mob/user)
	. = ..()
	if(anchored && length(menu_text))
		interact(user)
		return
	. += "<span class='notice'>If you have Bar or Kitchen access, you can swipe your ID on this to anchor it.</span>"
	. += "<span class='notice'>Click it with an empty hand to view the text, or use a paper to transfer its contents.</span>"
	. += "<span class='notice'>ALT-click to toggle its border. CTRL-click to toggle RAVE MODE.</span>"

/obj/item/holomenu/Initialize()
	. = ..()
	holo_lights = image(icon, null, "holomenu-lights")
	holo_text = image(icon, null, "holomenu-text")
	holo_border = image(icon, null, "holomenu-border")

/obj/item/holomenu/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holomenu/process()
	update_icon()

/obj/item/holomenu/update_icon()
	cut_overlays()
	if(anchored)
		set_light(2)
		if(rave_mode)
			var/randcolor = rgb(rand(100,255), rand(100,255), rand(100,255))
			holo_lights.color = randcolor
			holo_text.color = randcolor
			holo_border.color = randcolor
		else
			holo_lights.color = null
			holo_text.color = null
			holo_border.color = null
		overlays += holo_lights
		if(length(menu_text))
			overlays += holo_text
		if(border_on)
			overlays += holo_border
	else
		set_light(0)

/obj/item/holomenu/attackby__legacy__attackchain(obj/I, mob/user)
	if(istype(I, /obj/item/card/id))
		if(allowed(user))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "" : "un"]anchor \the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	if(istype(I, /obj/item/paper) && allowed(user))
		var/obj/item/paper/P = I
		to_chat(user, "<span class='notice'>You scan \the [I.name] into \the [name].</span>")
		menu_text = P.info
		menu_text = replacetext(menu_text, "color=black>", "color=white>")
		update_icon()
		return
	return ..()

/obj/item/holomenu/attack_hand(mob/user)
	if(anchored)
		if(allowed(user))
			ui_interact(user)
			update_icon()
		else
			interact(user)
		return
	return ..()

/obj/item/holomenu/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holomenu", name)
		ui.open()

/obj/item/holomenu/ui_data(mob/user)
	var/parsed = menu_text
	parsed = replacetext(parsed, "\[b]", "<b>")
	parsed = replacetext(parsed, "\[/b]", "</b>")
	parsed = replacetext(parsed, "\[i]", "<i>")
	parsed = replacetext(parsed, "\[/i]", "</i>")
	parsed = replacetext(parsed, "\[u]", "<u>")
	parsed = replacetext(parsed, "\[/u]", "</u>")
	parsed = replacetext(parsed, "\[br]", "<br>")
	parsed = replacetext(parsed, "\[h1]", "<h1>")
	parsed = replacetext(parsed, "\[/h1]", "</h1>")
	parsed = replacetext(parsed, "\[h2]", "<h2>")
	parsed = replacetext(parsed, "\[/h2]", "</h2>")
	parsed = replacetext(parsed, "\[h3]", "<h3>")
	parsed = replacetext(parsed, "\[/h3]", "</h3>")
	parsed = replacetext(parsed, "\[list]", "<ul>")
	parsed = replacetext(parsed, "\[/list]", "</ul>")
	parsed = replacetext(parsed, "\[*]", "<li>")
	parsed = replacetext(parsed, "\[hr]", "<hr>")
	parsed = replacetext(parsed, "\[small]", "<small>")
	parsed = replacetext(parsed, "\[/small]", "</small>")
	parsed = replacetext(parsed, "\[table]", "<table>")
	parsed = replacetext(parsed, "\[/table]", "</table>")
	parsed = replacetext(parsed, "\[cell]", "<td>")
	parsed = replacetext(parsed, "\[row]", "<tr>")

	return list("menu_text" = parsed)

/obj/item/holomenu/ui_act(action, list/params, datum/tgui/ui = null)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_text")
			if(!allowed(usr))
				return FALSE
			menu_text = sanitize(params["text"])
			update_icon()
			return TRUE

/obj/item/holomenu/AltClick(mob/user)
	if(Adjacent(user))
		if(allowed(user))
			border_on = !border_on
			to_chat(user, "<span class='notice'>You toggle \the [src]'s border [border_on ? "on" : "off"].</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	return ..()

/obj/item/holomenu/CtrlClick(mob/user)
	if(Adjacent(user))
		if(allowed(user))
			rave_mode = !rave_mode
			to_chat(user, "<span class='notice'>You toggle \the [src]'s rave mode [rave_mode ? "on" : "off"].</span>")
			update_icon()
			if(rave_mode)
				START_PROCESSING(SSobj, src)
				light_color = LIGHT_COLOR_HALOGEN
			else
				STOP_PROCESSING(SSobj, src)
				light_color = initial(light_color)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	return ..()

/obj/item/holomenu/holodeck
	name = "holodeck status projector"
	desc = "A hologram projector, this one has been set up to display text."
	icon = 'icons/obj/holomenu_holodeck.dmi'
	anchored = 1
	layer = 4
	req_one_access = list()

/obj/item/holomenu/holodeck/attack_self__legacy__attackchain(mob/user)
	var/new_text = sanitize(input(user, "Enter new text for the hologram to display.", "Hologram Display", menu_text) as null|message)
	if(!isnull(new_text))
		menu_text = new_text
		update_icon()

/obj/item/holomenu/holodeck/attackby__legacy__attackchain(obj/I, mob/user)
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		to_chat(user, "<span class='notice'>You scan \the [I.name] into \the [name].</span>")
		menu_text = P.info
		menu_text = replacetext(menu_text, "color=black>", "color=white>")
		update_icon()
		return
	return ..()
