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
	if((material == /datum/smith_material/uranium || istype(material, /datum/smith_material/uranium)) && quality)
		var/datum/component/inherent_radioactivity/radioactivity = AddComponent(/datum/component/inherent_radioactivity, 100 * quality.stat_mult, 0, 0, 1.5)
		START_PROCESSING(SSradiation, radioactivity)
	return

/obj/item/smithed_item/proc/set_name()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] [initial(name)]"

/obj/item/smithed_item/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user.mind, TRAIT_SMITH))
		. += "<span class='notice'>You can use <b>ALT + Click</b> while in-hand to determine specific statistics of this item.</span>"
