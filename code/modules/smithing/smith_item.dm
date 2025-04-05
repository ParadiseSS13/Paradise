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
	return

/obj/item/smithed_item/proc/set_name()
	if(!quality)
		return
	if(!material)
		name = "[quality.name] " + name
		return
	name = "[quality.name] [material.name] [initial(name)]"

// Random Spawners
/obj/item/smithed_item/random
	name = "random smithed item"
	desc = "If you see me please contact development because I should not exist."
	/// Weighted list of possible item qualities
	var/list/smithed_item_qualities = list(
		/datum/smith_quality = 9,
		/datum/smith_quality/improved = 1
	)
	/// Weighted list of possible item materials
	var/list/smithed_item_materials = list(
		/datum/smith_material/metal = 40,
		/datum/smith_material/silver = 10,
		/datum/smith_material/gold = 5,
		/datum/smith_material/plasma = 10,
		/datum/smith_material/titanium = 5,
		/datum/smith_material/uranium = 3,
		/datum/smith_material/brass = 15
	)
	/// List of possible item types
	var/list/smithed_type_list = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized,
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency,
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)

/obj/item/smithed_item/random/Initialize(mapload)
	. = ..()
	var/picked_type =  pick(smithed_type_list)
	var/obj/item/smithed_item/new_item = new picked_type(src.loc)
	new_item.quality = pickweight(smithed_item_qualities)
	new_item.material = pickweight(smithed_item_materials)
	new_item.set_stats()
	new_item.update_appearance(UPDATE_NAME)
	qdel(src)

/obj/item/smithed_item/random/insert
	name = "random smithed insert"
	smithed_type_list = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized
	)

/obj/item/smithed_item/random/bit
	name = "random smithed tool bit"
	smithed_type_list = list(
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency
	)

/obj/item/smithed_item/random/lens
	name = "random smithed lens"
	smithed_type_list = list(
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)
