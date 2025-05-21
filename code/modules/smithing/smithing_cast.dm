/obj/item/smithing_cast
	name = "smithing cast"
	icon = 'icons/obj/smithing.dmi'
	icon_state = "debug"
	desc = "Debug smithing cast. If you see this, notify the development team."
	w_class = WEIGHT_CLASS_SMALL
	/// The selected final product of the item
	var/obj/item/selected_product
	/// Possible products of the item
	var/list/possible_products = list()
	/// How many products are we smelting at any given operation?
	var/amount_to_make = 1
	/// What is the icon state we pass to the basin?
	var/basin_state = "error"

	new_attack_chain = TRUE

/obj/item/smithing_cast/Initialize(mapload)
	. = ..()
	populate_products()

/obj/item/smithing_cast/examine(mob/user)
	. = ..()
	. += "It is currently configured to make [amount_to_make == 1 ? "a" : "[amount_to_make]"] [selected_product.name][amount_to_make == 1 ? "" : "s"]."
	. += "<span class='notice'>You can select the desired product by using [src] in your hand.</span>"

/obj/item/smithing_cast/activate_self(mob/user)
	. = ..()
	if(!possible_products)
		return
	if(!length(possible_products))
		return
	var/list/product_names = list()
	var/product
	for(product in possible_products)
		var/obj/item/possible_product = product
		product_names[possible_product.name] = possible_product
	if(!length(product_names))
		return
	var/new_product = tgui_input_list(user, "Select a product", src, product_names)
	if(!new_product)
		selected_product = possible_products[1]
	else
		selected_product = product_names[new_product]

/obj/item/smithing_cast/update_desc()
	return ..()

/obj/item/smithing_cast/proc/populate_products()
	return

/obj/item/smithing_cast/sheet
	name = "sheet cast"
	icon_state = "sheet_cast"
	desc = "A cast for forging molten minerals into workable sheets."
	basin_state = "cast_sheet"

/obj/item/smithing_cast/sheet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can change the amount of sheets smelted by alt-clicking [src].</span>"

/obj/item/smithing_cast/sheet/populate_products()
	possible_products = list(/obj/item/stack/sheet/metal,
							/obj/item/stack/sheet/glass,
							/obj/item/stack/sheet/mineral/silver,
							/obj/item/stack/sheet/mineral/gold,
							/obj/item/stack/sheet/mineral/plasma,
							/obj/item/stack/sheet/mineral/uranium,
							/obj/item/stack/sheet/mineral/diamond,
							/obj/item/stack/ore/bluespace_crystal/refined,
							/obj/item/stack/sheet/mineral/titanium,
							/obj/item/stack/sheet/plasmaglass,
							/obj/item/stack/sheet/titaniumglass,
							/obj/item/stack/sheet/plasteel,
							/obj/item/stack/sheet/mineral/plastitanium,
							/obj/item/stack/sheet/plastitaniumglass,
							/obj/item/stack/sheet/mineral/bananium,
							/obj/item/stack/sheet/mineral/tranquillite,
							/obj/item/stack/sheet/mineral/platinum,
							/obj/item/stack/sheet/mineral/palladium,
							/obj/item/stack/sheet/mineral/iridium,
							/obj/item/stack/tile/brass
							)
	if(length(possible_products))
		selected_product = possible_products[1]

/obj/item/smithing_cast/sheet/AltClick(mob/user)
	. = ..()
	if(!Adjacent(user))
		return
	amount_to_make = tgui_input_number(user, "Select an amount (1-50)", src, 1, 50, 1)

/obj/item/smithing_cast/component
	name = "component cast"
	desc = "Debug component cast. If you see this, notify the development team."
	/// The selected quality of the item
	var/datum/smith_quality/quality = /datum/smith_quality
	/// The type of product
	var/product_type

/obj/item/smithing_cast/component/examine(mob/user)
	. = ..()
	. += "The current selected quality is [quality.name]."
	. += "<span class='notice'>You can change the quality of the product by alt-clicking [src].</span>"

/obj/item/smithing_cast/component/AltClick(mob/user)
	. = ..()
	if(!Adjacent(user))
		return
	var/list/quality_name_list = list()
	var/list/quality_type_list = typesof(/datum/smith_quality)
	var/quality_type
	for(quality_type in quality_type_list)
		var/datum/smith_quality/new_quality = quality_type
		quality_name_list[new_quality.name] = new_quality
	var/selected_quality = tgui_input_list(user, "Select a quality", src, quality_name_list)
	if(!selected_quality)
		quality = quality_type_list[1]
	else
		quality = quality_name_list[selected_quality]

/obj/item/smithing_cast/component/populate_products()
	possible_products = (typesof(product_type) - list(product_type))
	if(length(possible_products))
		selected_product = possible_products[1]

/obj/item/smithing_cast/component/insert_frame
	name = "insert frame cast"
	icon_state = "insert_frame_cast"
	desc = "A cast for creating insert frames."
	product_type = /obj/item/smithed_item/component/insert_frame
	basin_state = "cast_armorframe"

/obj/item/smithing_cast/component/insert_lining
	name = "insert lining cast"
	icon_state = "insert_lining_cast"
	desc = "A cast for creating insert linings."
	product_type = /obj/item/smithed_item/component/insert_lining
	basin_state = "cast_mesh"

/obj/item/smithing_cast/component/bit_mount
	name = "bit mount cast"
	icon_state = "bit_mount_cast"
	desc = "A cast for creating bit mounts."
	product_type = /obj/item/smithed_item/component/bit_mount
	basin_state = "cast_bitmount"

/obj/item/smithing_cast/component/bit_head
	name = "bit head cast"
	icon_state = "bit_head_cast"
	desc = "A cast for creating bit heads."
	product_type = /obj/item/smithed_item/component/bit_head
	basin_state = "cast_bithead"

/obj/item/smithing_cast/component/lens_frame
	name = "lens frame cast"
	icon_state = "lens_frame_cast"
	desc = "A cast for creating lens frames."
	product_type = /obj/item/smithed_item/component/lens_frame
	basin_state = "cast_lens"

/obj/item/smithing_cast/component/lens_focus
	name = "lens focus cast"
	icon_state = "lens_focus_cast"
	desc = "A cast for creating lens foci."
	product_type = /obj/item/smithed_item/component/lens_focus
	basin_state = "cast_focus"

/obj/item/smithing_cast/component/trim
	name = "trim cast"
	icon_state = "trim_cast"
	desc = "A cast for creating trims."
	product_type = /obj/item/smithed_item/component/trim
	basin_state = "cast_trim"

/obj/item/smithing_cast/misc
	name = "misc cast"
	icon_state = "insert_frame_cast"
	desc = "Debug cast. If you see this, notify the development team."

/obj/item/smithing_cast/misc/AltClick(mob/user, modifiers)
	return

/obj/item/smithing_cast/misc/egun_parts
	name = "energy gun parts cast"
	icon_state = "egun_parts_cast"
	desc = "A cast for creating energy gun frames."
	selected_product = /obj/item/smithed_item/component/egun_parts
	basin_state = "cast_egun_parts"
