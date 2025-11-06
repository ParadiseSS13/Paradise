#define MODE_OFF "veiled"
#define MODE_NATURAL "natural sight"
#define MODE_CORRECTION "correction"

/obj/item/clothing/glasses/hud/tajblind
	name = "\improper Tajaran veil"
	desc = "A sleek, high-tech Tajaran veil, adapted from ancient designs and important to their culture and spirituality.<br>\
			<span class='notice'>Can switch between three modes: Sight-blocking veiled mode, transparent natural sight mode and colorblindness correction mode.</span>"
	icon_state = "tajblind"
	inhand_icon_state = "blindfold"
	actions_types = list(/datum/action/item_action/toggle)
	color_view = MATRIX_STANDARD
	correct_wires = TRUE
	var/list/modes = list(MODE_OFF = MODE_NATURAL, MODE_NATURAL = MODE_CORRECTION, MODE_CORRECTION = MODE_OFF)
	var/selected_mode = MODE_CORRECTION
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi'
	)
	/// Used to toggle features of specialised veils
	var/electronics = TRUE


/obj/item/clothing/glasses/hud/tajblind/examine()
	. = ..()
	. += "<span class='notice'>You can <b>Ctrl-Shift-Click</b> [src] to toggle its electronics if present.</span>"

/obj/item/clothing/glasses/hud/tajblind/activate_self(mob/user)
	if(..())
		return
	toggle_veil(user, TRUE)

/obj/item/clothing/glasses/hud/tajblind/proc/toggle_veil(mob/user, voluntary)
	var/mob/living/carbon/human/H = user
	selected_mode = modes[selected_mode]
	to_chat(user, "<span class='[voluntary ? "notice" : "warning"]'>[voluntary ? "You turn the veil" : "The veil turns"] [selected_mode ? "to [selected_mode] mode" : "off"][voluntary ? "." : "!"]</span>")

	switch(selected_mode)
		if(MODE_OFF)
			tint = TINT_BLIND
			flash_protect = FLASH_PROTECTION_WELDER
			color_view = null
			correct_wires = FALSE

		if(MODE_NATURAL)
			tint = initial(tint)
			flash_protect = initial(flash_protect)
			color_view = null

		if(MODE_CORRECTION)
			tint = initial(tint)
			flash_protect = initial(flash_protect)
			color_view = MATRIX_STANDARD
			correct_wires = TRUE

	if(ishuman(H) && H.glasses == src)
		H.update_sight()
		H.update_client_colour()

/obj/item/clothing/glasses/hud/tajblind/examine_more(mob/user)
	. = ..()
	. += "Tajaran Veils have long been an important part of their spirituality and culture, suppressed by the Overseers and making a strong return after the civil war. Tajaran believe that to see one’s eyes is to see their soul, and thus the more spiritual Tajara wear veils to conceal their eyes from everyone but the ones closest to them. <br>\
			These current designs are adapted from recreations of the ancient veils, created by the Alchemists Guild. Technologically advanced and created to help Tajara adapt to life in the larger galactic community, they have systems built-in that allow them to have holographic huds, as well as corrective technology to help Tajaran overcome their genetic tritanopia colour blindness. <br>\
			Availability on the wider market is highly restricted as a result of their cultural importance, as well as the patent held by the Alchemists Guild, and the lenses are very hard to reverse engineer. Popular theories suggest this as a result of the unique materials available on Adhomai, or the inability to recreate the light conditions of the Tajara homeworld."

/obj/item/clothing/glasses/hud/tajblind/CtrlShiftClick(mob/user, modifiers)
	if(!initial(hud_types))
		return
	if(electronics)
		electronics = FALSE
		to_chat(user, "<span class='notice'>You toggle electronics in [src] off.</span>")
		if(user.get_item_by_slot(ITEM_SLOT_EYES) != src)
			hud_types = null
			return
		for(var/new_hud in hud_types)
			var/datum/atom_hud/H = GLOB.huds[new_hud]
			H.remove_hud_from(user)
		hud_types = null
		return
	electronics = TRUE
	to_chat(user, "<span class='notice'>You toggle electronics in [src] on.</span>")
	hud_types = list(initial(hud_types))
	if(user.get_item_by_slot(ITEM_SLOT_EYES) != src)
		return
	for(var/new_hud in hud_types)
		var/datum/atom_hud/H = GLOB.huds[new_hud]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/tajblind/meson
	name = "\improper Tajaran engineering meson veil"
	icon_state = "tajblind_engi"

/obj/item/clothing/glasses/hud/tajblind/meson/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has an optical meson scanner integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/meson/CtrlShiftClick(mob/user, modifiers)
	if(electronics)
		electronics = FALSE
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
			user.update_sight()
		to_chat(user, "<span class='notice'>You toggle electronics in [src] off.</span>")
		return
	electronics = TRUE
	if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
		user.update_sight()
	to_chat(user, "<span class='notice'>You toggle electronics in [src] on.</span>")

/obj/item/clothing/glasses/hud/tajblind/meson/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES && electronics)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/hud/tajblind/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/hud/tajblind/meson/cargo
	name = "\improper Tajaran mining meson veil"
	icon_state = "tajblind_cargo"

/obj/item/clothing/glasses/hud/tajblind/sci
	name = "\improper Tajaran scientific veil"
	icon_state = "tajblind_sci"
	scan_reagents = TRUE
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/hud/tajblind/sci/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has science goggles integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/sci/CtrlShiftClick(mob/user, modifiers)
	if(electronics)
		electronics = FALSE
		scan_reagents = FALSE
		to_chat(user, "<span class='notice'>You toggle electronics in [src] off.</span>")
		return
	electronics = TRUE
	scan_reagents = TRUE
	to_chat(user, "<span class='notice'>You toggle electronics in [src] on.</span>")

/obj/item/clothing/glasses/hud/tajblind/sci/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/hud/tajblind/med
	name = "\improper Tajaran medical veil"
	icon_state = "tajblind_med"
	hud_types = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/glasses/hud/tajblind/med/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has a health HUD integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/sec
	name = "\improper Tajaran security veil"
	icon_state = "tajblind_sec"
	hud_types = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/hud/tajblind/sec/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has a security HUD integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/shaded
	name = "shaded Tajaran veil"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/tajblind/shaded/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has an in-built flash protection.</span>"

/obj/item/clothing/glasses/hud/tajblind/shaded/meson
	name = "shaded Tajaran engineering meson veil"
	icon_state = "tajblind_engi"

/obj/item/clothing/glasses/hud/tajblind/shaded/meson/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has an optical meson scanner integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/shaded/meson/CtrlShiftClick(mob/user, modifiers)
	if(electronics)
		electronics = FALSE
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
			user.update_sight()
		to_chat(user, "<span class='notice'>You toggle electronics in [src] off.</span>")
		return
	electronics = TRUE
	if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")
		user.update_sight()
	to_chat(user, "<span class='notice'>You toggle electronics in [src] on.</span>")

/obj/item/clothing/glasses/hud/tajblind/shaded/meson/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EYES && electronics)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/hud/tajblind/shaded/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_glasses[UID()]")

/obj/item/clothing/glasses/hud/tajblind/shaded/meson/cargo
	name = "shaded Tajaran mining meson veil"
	icon_state = "tajblind_cargo"

/obj/item/clothing/glasses/hud/tajblind/shaded/sci
	name = "shaded Tajaran scientific veil"
	icon_state = "tajblind_sci"
	scan_reagents = TRUE
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/glasses/hud/tajblind/shaded/sci/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has science goggles integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/shaded/sci/CtrlShiftClick(mob/user, modifiers)
	if(electronics)
		electronics = FALSE
		scan_reagents = FALSE
		to_chat(user, "<span class='notice'>You toggle electronics in [src] off.</span>")
		return
	electronics = TRUE
	scan_reagents = TRUE
	to_chat(user, "<span class='notice'>You toggle electronics in [src] on.</span>")

/obj/item/clothing/glasses/hud/tajblind/shaded/sci/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/item/clothing/glasses/hud/tajblind/shaded/med
	name = "shaded Tajaran medical veil"
	icon_state = "tajblind_med"
	hud_types = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/glasses/hud/tajblind/shaded/med/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has a health HUD integrated into it.</span>"

/obj/item/clothing/glasses/hud/tajblind/shaded/sec
	name = "shaded Tajaran security veil"
	icon_state = "tajblind_sec"
	see_in_dark = 1
	hud_types = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/hud/tajblind/shaded/sec/Initialize(mapload)
	. = ..()
	desc += "<br><span class='notice'>It has a security HUD integrated into it.</span>"

#undef MODE_OFF
#undef MODE_NATURAL
#undef MODE_CORRECTION
