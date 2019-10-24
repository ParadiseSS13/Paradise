#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	icon_state = "trayson-meson"
	item_state = "trayson-meson"
	origin_tech = "magnets=3;plasmatech=3;materials=2;engineering=4"
	var/icon_state_base = "trayson-"
	actions_types = list(/datum/action/item_action/toggle_mode)
	hispania_icon = TRUE

	vision_flags = NONE
	see_in_dark = 2
	invis_view = SEE_INVISIBLE_LIVING
	lighting_alpha = null

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 4
	var/init_flash_protect = 0

/obj/item/clothing/glasses/meson/engine/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return TRUE

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")

	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			see_in_dark = 1
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			flash_protect = 0

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			see_in_dark = 2
			lighting_alpha = null
			flash_protect = 0

		if(MODE_NONE)
			see_in_dark = 2
			vision_flags = NONE
			flash_protect = init_flash_protect
			lighting_alpha = null

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon()
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
			t_ray_scan(user, range, 25)

/obj/item/clothing/glasses/meson/engine/update_icon()
	icon_state = icon_state_base+"[mode]"
	update_mob()

/obj/item/clothing/glasses/meson/engine/proc/update_mob()
	item_state = icon_state
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(slot_glasses) == src)
			user.update_inv_glasses()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	icon_state_base = "traysonbasic-"
	icon_state = "traysonbasic-t-ray"
	item_state = "traysonbasic-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	origin_tech = "magnets=2;plasmatech=2;engineering=2"

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_NONE)




#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
