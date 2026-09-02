/obj/item/gun/projectile/automatic/toy
	name = "foam force SMG"
	desc = "A prototype three-round burst toy submachine gun. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "saber"
	inhand_icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/toy/smg
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	suppressed_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	force = 0
	throwforce = 0
	clumsy_check = FALSE
	needs_permit = FALSE

/obj/item/gun/projectile/automatic/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/toy/pistol
	name = "foam force pistol"
	desc = "A small, easily concealable toy handgun. Ages 8 and up."
	icon_state = "pistol"
	inhand_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/toy/pistol
	fire_sound = 'sound/weapons/gunshots/gunshot.ogg'
	suppressed_sound = 'sound/weapons/gunshots/gunshot.ogg'
	burst_size = 1
	fire_delay = 0
	can_holster = TRUE
	actions_types = list()

/obj/item/gun/projectile/automatic/toy/pistol/riot
	name = "foam force riot pistol"
	desc = "RIOT! Ages 8 and up."
	mag_type = /obj/item/ammo_box/magazine/toy/pistol/riot

/obj/item/gun/projectile/automatic/toy/pistol/enforcer
	name = "foam Enforcer"
	desc = "A toy inspired by the popular Enforcer pistol. Ages 8 and up!"
	icon_state = "enforcer"
	mag_type = /obj/item/ammo_box/magazine/toy/enforcer
	can_flashlight = TRUE

/obj/item/gun/projectile/automatic/toy/pistol/enforcer/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/toy/pistol/enforcer/update_overlays()
	. = ..()
	if(suppressed)
		. += image(icon = 'icons/obj/guns/attachments.dmi', icon_state = "suppressor_attached", pixel_x = 15, pixel_y = 5)
	if(gun_light)
		var/flashlight = "uflashlight_attached"
		if(gun_light.on)
			flashlight = "uflashlight_attached-on"
		. += image(icon = 'icons/obj/guns/attachments.dmi', icon_state = flashlight, pixel_x = 5, pixel_y = -2)

/obj/item/gun/projectile/automatic/toy/pistol/enforcer/ui_action_click()
	toggle_gunlight()

/obj/item/gun/projectile/shotgun/toy
	name = "foam force shotgun"
	desc = "A toy shotgun with wood furniture and a four-shell capacity underneath. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	force = 0
	throwforce = 0
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy
	clumsy_check = FALSE
	needs_permit = FALSE

/obj/item/gun/projectile/shotgun/toy/process_chamber()
	..()
	if(chambered && !chambered.BB)
		qdel(chambered)

/obj/item/gun/projectile/shotgun/toy/process_fire(atom/target, mob/living/user, message = 1, params, zone_override, bonus_spread = 0)
	. = ..()
	chambered = null

/obj/item/gun/projectile/shotgun/toy/crossbow
	name = "foam force crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon_state = "crossbow"
	worn_icon_state = "gun"
	inhand_icon_state = "foamcrossbow"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/crossbow
	fire_sound = 'sound/items/syringeproj.ogg'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/projectile/automatic/c20r/toy
	name = "donksoft SMG"
	desc = "A bullpup two-round burst toy SMG, designated 'C-20r'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	suppressed_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	needs_permit = FALSE
	mag_type = /obj/item/ammo_box/magazine/toy/smgm45
	origin_tech = "combat=3;materials=2;syndicate=2"

/obj/item/gun/projectile/automatic/c20r/toy/riot
	mag_type = /obj/item/ammo_box/magazine/toy/smgm45/riot

/obj/item/gun/projectile/automatic/c20r/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/l6_saw/toy
	name = "donksoft LMG"
	desc = "A heavily modified toy light machine gun, designated 'L6 SAW'. Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	needs_permit = FALSE
	mag_type = /obj/item/ammo_box/magazine/toy/m762
	origin_tech = "combat=5;engineering=3;syndicate=3"

/obj/item/gun/projectile/automatic/l6_saw/toy/riot
	mag_type = /obj/item/ammo_box/magazine/toy/m762/riot

/obj/item/gun/projectile/automatic/l6_saw/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/shotgun/toy/tommygun
	name = "tommy gun"
	desc = "Looks almost like the real thing! Great for practicing Drive-bys. Ages 8 and up."
	icon_state = "tommygun"
	worn_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/tommygun
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/projectile/automatic/sniper_rifle/toy
	name = "donksoft sniper rifle"
	desc = "A recoil-operated, semi-automatic donksoft sniper rifle. Perfect to annoy/kill the neighbour’s cat! Ages 8 and up."
	icon = 'icons/obj/guns/toy.dmi'
	can_suppress = FALSE
	needs_permit = FALSE
	zoomable = FALSE
	mag_type = /obj/item/ammo_box/magazine/toy/sniper_rounds

/obj/item/gun/projectile/automatic/sniper_rifle/toy/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

//////////////////////////////
// MARK: Paintball Guns
//////////////////////////////
#define PAINTBALL_BLUE "blue"
#define PAINTBALL_RED "red"
#define PAINTBALL_GREEN "green"
#define PAINTBALL_YELLOW "yellow"
#define PAINTBALL_CMAGGED "cmag"

/obj/item/gun/projectile/automatic/paintball_gun
	name = "paintball gun"
	desc = "A gas-powered gun that shoots small balls of paint! Ages 13 and up. Do not aim at the eyes."
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "paintgun"
	inhand_icon_state = "paintgun"
	can_suppress = FALSE
	needs_permit = FALSE
	mag_type = /obj/item/ammo_box/magazine/paintball
	actions_types = list()
	burst_size = 1
	/// What color are we configured at?
	var/paintball_color = PAINTBALL_BLUE

/obj/item/gun/projectile/automatic/paintball_gun/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += SPAN_WARNING("The paint selector is covered in yellow sludge!")
	else if(istype(magazine, /obj/item/ammo_box/magazine/paintball/pepperball))
		. += SPAN_WARNING("A magazine of pepperballs is loaded!")
	else
		. += SPAN_NOTICE("It is configured to fire [paintball_color] paintballs.")
	if(emagged)
		. += SPAN_WARNING("The air compressor sparks dangerously.")

/obj/item/gun/projectile/automatic/paintball_gun/update_icon_state()
	icon_state = "paintgun"
	if(istype(magazine, /obj/item/ammo_box/magazine/paintball/pepperball))
		inhand_icon_state = "paintgun-pepper"
		return
	inhand_icon_state = "paintgun[magazine ? "-[paintball_color]" : ""]"

/obj/item/gun/projectile/automatic/paintball_gun/update_overlays()
	. = ..()
	if(istype(magazine, /obj/item/ammo_box/magazine/paintball/pepperball))
		. += "paintgun-pepper[chambered ? "" : "-empty"]"
		return
	if(magazine)
		. += "paintgun-[paintball_color][chambered ? "" : "-empty"]"

/obj/item/gun/projectile/automatic/paintball_gun/chamber_round()
	. = ..()
	if(chambered)
		color_paintball()

/obj/item/gun/projectile/automatic/paintball_gun/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!magazine)
		return
	if(istype(magazine, /obj/item/ammo_box/magazine/paintball/pepperball))
		return
	paintball_color = tgui_input_list(user, "Select a color", src, list(PAINTBALL_BLUE, PAINTBALL_RED, PAINTBALL_GREEN, PAINTBALL_YELLOW))
	color_paintball()
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/automatic/paintball_gun/proc/color_paintball()
	if(!istype(magazine, /obj/item/ammo_box/magazine/paintball/pepperball))
		switch(paintball_color)
			if(PAINTBALL_BLUE)
				chambered.color = "#0000CC"
			if(PAINTBALL_RED)
				chambered.color = "#CC0000"
			if(PAINTBALL_GREEN)
				chambered.color = "#00CC00"
			if(PAINTBALL_YELLOW)
				chambered.color = "#CCCC00"
			if(PAINTBALL_CMAGGED)
				chambered.color = pick("#d41e3c", "#ed7b39", "#fff540", "#77b02a", "#488bd4", "#b0fff1", "#94007a", "#ff417d")
	chambered.BB.color = chambered.color
	if(emagged)
		chambered.BB.damage = 8
		chambered.BB.muzzle_flash_intensity = 2

/obj/item/gun/projectile/automatic/paintball_gun/cmag_act(mob/user)
	. = ..()
	to_chat(user, SPAN_WARNING("You smear bananium over [src]'s paint selector."))
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	paintball_color = PAINTBALL_CMAGGED
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/automatic/paintball_gun/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	to_chat(user, SPAN_WARNING("You overcharge [src]'s air compressor."))
	if(magazine)
		color_paintball()

/obj/item/gun/projectile/automatic/paintball_gun/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	var/cmagged = HAS_TRAIT(src, TRAIT_CMAGGED)
	. = ..()
	if(cmagged && .)
		paintball_color = PAINTBALL_BLUE
		color_paintball()
		update_icon(UPDATE_OVERLAYS)

#undef PAINTBALL_BLUE
#undef PAINTBALL_RED
#undef PAINTBALL_GREEN
#undef PAINTBALL_YELLOW
#undef PAINTBALL_CMAGGED
