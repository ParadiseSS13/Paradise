//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes, and the Radiation Scanner mode lets you see objects contaminated by radiation."
	icon_state = "trayson-meson"
	item_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)
	origin_tech = "materials=3;magnets=3;engineering=3;plasmatech=3"
	active_on_equip = FALSE

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice" : "warning"]'>[voluntary ? "You turn the goggles" : "The goggles turn"] [mode ? "to [mode] mode" : "off"][voluntary ? "." : "!"]</span>")

	if(mode == MODE_MESON)
		if(!HAS_TRAIT_FROM(user, TRAIT_MESON_VISION, "meson_glasses[UID()]"))
			ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
		active_on_equip = TRUE
	else
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
		active_on_equip = FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon(UPDATE_ICON_STATE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user, 8, range)
		if(MODE_RAD)
			show_rads()


/obj/item/clothing/glasses/meson/engine/proc/show_rads()
	var/mob/living/carbon/human/user = loc
	user.show_rads(range * 5) // Rads are easier to see than wires under the floor

/obj/item/clothing/glasses/meson/engine/update_icon_state()
	icon_state = "trayson-[mode]"
	update_mob()

/obj/item/clothing/glasses/meson/engine/proc/update_mob()
	item_state = icon_state
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(slot_glasses) == src)
			user.update_inv_glasses()
		else
			user.update_inv_l_hand()
			user.update_inv_r_hand()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	icon_state = "trayson-t-ray"
	item_state = "trayson-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	range = 2
	origin_tech = "materials=3;magnets=2;engineering=2"
	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_NONE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
