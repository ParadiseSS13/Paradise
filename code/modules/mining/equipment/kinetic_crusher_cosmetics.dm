/// Cosmetic items for changing the crusher's look
/obj/item/crusher_trophy/retool_kit
	name = "crusher retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit

	/// The crusher reskin
	var/datum/crusher_skin/active_skin

/obj/item/crusher_trophy/retool_kit/Destroy(force)
	if(istype(active_skin))
		QDEL_NULL(active_skin)
	return ..()

/obj/item/crusher_trophy/retool_kit/effect_desc()
	return "the crusher to have the appearance of \a [active_skin::name]"

/obj/item/crusher_trophy/retool_kit/add_to(obj/item/kinetic_crusher/pkc, mob/user)
	. = ..()
	if(!.)
		return
	active_skin = new active_skin(pkc)
	if(active_skin.retool_icon)
		pkc.icon = active_skin.retool_icon
	pkc.icon_state = active_skin.retool_icon_state
	pkc.inhand_icon_state = active_skin.retool_inhand_icon
	if(active_skin.retool_projectile_icon)
		pkc.projectile_icon = active_skin.retool_projectile_icon
	if(active_skin.retool_projectile_icon_state)
		pkc.projectile_icon_state = active_skin.retool_projectile_icon_state
	// Should either have both, or neither
	if(active_skin.retool_lefthand_file)
		pkc.lefthand_file = active_skin.retool_lefthand_file
		pkc.righthand_file = active_skin.retool_righthand_file
	if(active_skin.retool_worn_file)
		pkc.worn_icon = active_skin.retool_worn_file
		pkc.worn_icon_state = active_skin::retool_icon_state
	if(active_skin.retool_inhand_x)
		pkc.inhand_x_dimension = active_skin.retool_inhand_x
	if(active_skin.retool_inhand_y)
		pkc.inhand_y_dimension = active_skin.retool_inhand_y
	pkc.update_appearance()
	pkc.update_slot_icon()

/obj/item/crusher_trophy/retool_kit/remove_from(obj/item/kinetic_crusher/pkc)
	var/skin_type = active_skin.type
	qdel(active_skin)
	active_skin = skin_type
	pkc.icon = initial(pkc.icon)
	pkc.icon_state = initial(pkc.icon_state)
	pkc.inhand_icon_state = initial(pkc.inhand_icon_state)
	pkc.projectile_icon = initial(pkc.projectile_icon)
	pkc.projectile_icon_state = initial(pkc.projectile_icon_state)
	pkc.lefthand_file = initial(pkc.lefthand_file)
	pkc.righthand_file = initial(pkc.righthand_file)
	pkc.worn_icon = initial(pkc.worn_icon)
	pkc.worn_icon_state = initial(pkc.worn_icon_state)
	pkc.inhand_x_dimension = initial(pkc.inhand_x_dimension)
	pkc.inhand_y_dimension = initial(pkc.inhand_y_dimension)
	pkc.update_appearance()
	pkc.update_slot_icon()
	return ..()

/obj/item/crusher_trophy/retool_kit/sword
	name = "crusher sword retool kit"
	desc = "A kit containing all the tools you need to reconfigure your crusher into a sword."
	active_skin = /datum/crusher_skin/sword

/obj/item/crusher_trophy/retool_kit/harpoon
	name = "crusher harpoon retool kit"
	desc = "A kit containing all the tools you need to reconfigure your crusher into a harpoon."
	active_skin = /datum/crusher_skin/harpoon

/obj/item/crusher_trophy/retool_kit/glaive
	name = "crusher glaive retool kit"
	desc = "A kit containing all the tools you need to reconfigure your crusher into a glaive."
	active_skin = /datum/crusher_skin/glaive

/obj/item/crusher_trophy/retool_kit/dagger
	name = "crusher dagger retool kit"
	desc = "A kit containing all the tools you need to reconfigure your crusher into a dagger and blaster."
	active_skin = /datum/crusher_skin/dagger

/obj/item/crusher_trophy/retool_kit/ashenskull
	name = "ashen skull"
	desc = "It burns with the flame of the necropolis, whispering in your ear. It demands to be bound to a suitable weapon."
	icon_state = "retool_kit_skull"
	active_skin = /datum/crusher_skin/ashen_skull

/// Alternate PKC skins
/datum/crusher_skin
	/// Name of the modification
	var/name = "error that should be reported to coders"
	/// Specifies the icon file in which the crusher's new state is stored.
	var/retool_icon = 'icons/obj/mining.dmi'
	/// Specifies the sprite/icon state which the crusher is changed to as an item. Should appear in the icons/obj/mining.dmi file with accompanying "lit" and "recharging" sprites
	var/retool_icon_state = "ipickaxe"
	/// Specifies the icon state for the crusher's appearance in hand. Should appear in both retool_lefthand_file and retool_righthand_file.
	var/retool_inhand_icon = "ipickaxe"
	/// Specifies the icon file in which the crusher's projectile sprite is located.
	var/retool_projectile_icon = 'icons/obj/projectiles.dmi'
	/// For if the retool kit changes the projectile's appearance.
	var/retool_projectile_icon_state = null
	/// Specifies the left hand inhand icon file. Don't forget to set the right hand file as well.
	var/retool_lefthand_file = null
	/// Specifies the right hand inhand icon file. Don't forget to set the left hand file as well.
	var/retool_righthand_file = null
	/// Specifies the worn icon file.
	var/retool_worn_file = null
	/// Specifies the X dimensions of the new inhand, only relevant with different inhand files.
	var/retool_inhand_x = null
	/// Specifies the Y dimensions of the new inhand, only relevant with different inhand files.
	var/retool_inhand_y = null
	/// Can this skin be normally selected by a generic retool kit?
	var/normal_skin = TRUE
	/// Crusher this skin is attached to
	var/obj/item/kinetic_crusher/crusher

/datum/crusher_skin/sword
	name = "sword"
	retool_icon_state = "crusher_sword"
	retool_inhand_icon = "crusher_sword"

/datum/crusher_skin/harpoon
	name = "harpoon"
	retool_icon_state = "crusher_harpoon"
	retool_inhand_icon = "crusher_harpoon"
	retool_projectile_icon_state = "pulse_harpoon"

/datum/crusher_skin/dagger
	name = "dual dagger and blaster"
	retool_icon_state = "crusher_dagger"
	retool_inhand_icon = "crusher_dagger"

/datum/crusher_skin/glaive
	name = "glaive"
	retool_icon_state = "crusher_glaive"
	retool_inhand_icon = "crusher_glaive"
	retool_lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	retool_righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	retool_inhand_x = 64
	retool_inhand_y = 64

/datum/crusher_skin/ashen_skull
	retool_icon_state = "crusher_skull"
	retool_inhand_icon = "crusher_skull"
	retool_projectile_icon_state = "pulse_skull"
	normal_skin = FALSE
