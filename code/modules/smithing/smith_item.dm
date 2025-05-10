/obj/item/smithed_item
	name = "Debug smithed item"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithed item. If you see this, notify the development team."
	w_class = WEIGHT_CLASS_SMALL
	/// The quality of the item
	var/datum/smith_quality/quality
	/// The material of the item
	var/datum/smith_material/material
	/// Is this item valid for secondary goals?
	var/secondary_goal_candidate = FALSE

	new_attack_chain = TRUE

/obj/item/smithed_item/Initialize(mapload)
	. = ..()
	set_name()

/obj/item/smithed_item/update_name()
	. = ..()
	set_name()

/obj/item/smithed_item/proc/on_attached(mob/user, obj/item/target)
	return

/obj/item/smithed_item/proc/on_detached(mob/user)
	return

/obj/item/smithed_item/proc/set_stats()
	color = material.color_tint
	return

/obj/item/smithed_item/proc/set_name()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] [initial(name)]"
