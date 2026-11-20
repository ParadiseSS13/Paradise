//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define MODE_PRESSURE "pressure"

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes, and the Radiation Scanner mode lets you see objects contaminated by radiation."
	icon_state = "trayson-meson"
	inhand_icon_state = null
	actions_types = list(/datum/action/item_action/toggle_mode)
	origin_tech = "materials=3;magnets=3;engineering=3;plasmatech=3"
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_PLASMA = 100)

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
		attach_clothing_traits(TRAIT_MESON_VISION)
	else
		detach_clothing_traits(TRAIT_MESON_VISION)

	if(mode == MODE_RAD)
		attach_clothing_traits(SM_HALLUCINATION_IMMUNE)
	else
		detach_clothing_traits(SM_HALLUCINATION_IMMUNE)

	if(mode == MODE_PRESSURE)
		attach_clothing_traits(TRAIT_PRESSURE_VISION)
	else
		detach_clothing_traits(TRAIT_PRESSURE_VISION)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon(UPDATE_ICON_STATE)
	update_action_buttons()

/obj/item/clothing/glasses/meson/engine/activate_self(mob/user)
	if(..())
		return
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
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			user.update_inv_glasses()
		else
			user.update_inv_l_hand()
			user.update_inv_r_hand()

/// Atmospherics techs get their own version with T-ray and an exlusive Pressure view.
/obj/item/clothing/glasses/meson/engine/atmos
	name = "atmospherics scanner goggles"
	icon_state = "trayson-pressure"
	desc = "Used by atmospherics techs to visualize pressure, see station structure, and see underfloor objects such as cables and pipes."
	range = 2
	origin_tech = "materials=3;magnets=2;engineering=2"
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	modes = list(MODE_NONE = MODE_PRESSURE, MODE_PRESSURE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_NONE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_PRESSURE
