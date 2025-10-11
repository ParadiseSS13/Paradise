/obj/machinery/smithing/kinetic_assembler
	name = "kinetic assembler"
	desc = "A smart assembler that takes components and combines them at the strike of a hammer."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "assembler"
	max_integrity = 100
	pixel_y = 0
	bound_height = 32
	bound_width = 32
	bound_y = 0
	operation_sound = 'sound/items/welder.ogg'
	/// Primary component
	var/obj/item/smithed_item/component/primary
	/// Secondary component
	var/obj/item/smithed_item/component/secondary
	/// Trim component
	var/obj/item/smithed_item/component/trim
	/// Finished product
	var/obj/item/smithed_item/finished_product
	/// Products that are produced in batches
	var/list/batched_item_types = list(
		/obj/item/smithed_item/lens,
		/obj/item/smithed_item/tool_bit
	)
	/// Amount of extra items made in batches
	var/batch_extras = 1

/obj/machinery/smithing/kinetic_assembler/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/kinetic_assembler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	batched_item_types = typecacheof(batched_item_types)
	RefreshParts()

/obj/machinery/smithing/kinetic_assembler/Destroy()
	if(primary)
		primary.forceMove(src.loc)
	if(secondary)
		secondary.forceMove(src.loc)
	if(trim)
		trim.forceMove(src.loc)
	. = ..()

/obj/machinery/smithing/kinetic_assembler/examine(mob/user)
	. = ..()
	if(primary || secondary || trim)
		. += "<span class='notice'>You can activate the machine with your hand, or remove a component by alt-clicking.</span>"
	if(primary)
		. += "<span class='notice'>There is a [primary] in the primary slot.</span>"
	if(secondary)
		. += "<span class='notice'>There is a [secondary] in the secondary slot.</span>"
	if(trim)
		. += "<span class='notice'>There is a [trim] in the trim slot.</span>"
	if(finished_product)
		. += "<span class='notice'>There is a nearly-complete [finished_product] on the assembler. To complete the product, strike it with your hammer!</span>"

/obj/machinery/smithing/kinetic_assembler/RefreshParts()
	var/operation_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += OPERATION_SPEED_MULT_PER_RATING * component.rating
	// Update our values
	operation_time = operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)

/obj/machinery/smithing/kinetic_assembler/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "assembler_wires"
	else
		icon_state = "assembler"

/obj/machinery/smithing/kinetic_assembler/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/smithing/kinetic_assembler/update_overlays()
	. = ..()
	overlays.Cut()
	if(panel_open)
		icon_state = "assembler_wires"

/obj/machinery/smithing/kinetic_assembler/AltClick(mob/living/user)
	if(!Adjacent(user))
		return
	if(!primary && !secondary && !trim)
		to_chat(user, "<span class='warning'>There is no component to remove.</span>")
		return
	var/list/components = list("Primary", "Secondary", "Trim")
	var/removed = tgui_input_list(user, "Select a component to remove", src, components)
	if(!removed)
		return
	switch(removed)
		if("Primary")
			if(!primary)
				to_chat(user, "<span class='warning'>There is no primary component to remove.</span>")
				return
			to_chat(user, "<span class='notice'>You remove [primary] from the primary component slot of [src].</span>")
			if(primary.burn_check(user))
				primary.burn_user(user)
				primary.forceMove(user.loc)
				primary = null
				return
			user.put_in_hands(primary)
			primary = null
			return
		if("Secondary")
			if(!secondary)
				to_chat(user, "<span class='warning'>There is no secondary component to remove.</span>")
				return
			to_chat(user, "<span class='notice'>You remove [secondary] from the secondary component slot of [src].</span>")
			if(secondary.burn_check(user))
				secondary.burn_user(user)
				secondary.forceMove(user.loc)
				secondary = null
				return
			user.put_in_hands(secondary)
			secondary = null
			return
		if("Trim")
			if(!trim)
				to_chat(user, "<span class='warning'>There is no trim component to remove.</span>")
				return
			to_chat(user, "<span class='notice'>You remove [trim] from the trim component slot of [src].</span>")
			if(trim.burn_check(user))
				trim.burn_user(user)
				trim.forceMove(user.loc)
				trim = null
				return
			user.put_in_hands(trim)
			trim = null
			return

/obj/machinery/smithing/kinetic_assembler/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/hammer))
		return ITEM_INTERACT_COMPLETE

	if(!istype(used, /obj/item/smithed_item/component))
		to_chat(user, "<span class='warning'>You feel like there's no reason to process [used].</span>")
		return ITEM_INTERACT_COMPLETE

	if(finished_product)
		to_chat(user, "<span class='warning'>There is an almost finished [finished_product] in [src]!</span>")
		return ITEM_INTERACT_COMPLETE

	var/obj/item/smithed_item/component/comp = used
	if(comp.hammer_time)
		to_chat(user, "<span class='warning'>[used] is not complete yet!</span>")
		return ITEM_INTERACT_COMPLETE

	if(comp.part_type == PART_PRIMARY)
		if(primary)
			to_chat(user, "<span class='notice'>You remove [primary] from the primary component slot of [src].</span>")
			primary.forceMove(src.loc)
			primary = null
		if(comp.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[comp] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [comp] into the primary component slot of [src].</span>")
		primary = comp
		return ITEM_INTERACT_COMPLETE

	if(comp.part_type == PART_SECONDARY)
		if(secondary)
			to_chat(user, "<span class='notice'>You remove [secondary] from the secondary component slot of [src].</span>")
			secondary.forceMove(src.loc)
			secondary = null
		if(comp.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[comp] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [comp] into the secondary component slot of [src].</span>")
		secondary = comp
		return ITEM_INTERACT_COMPLETE

	if(comp.part_type == PART_TRIM)
		if(trim)
			to_chat(user, "<span class='notice'>You remove [trim] from the trim component slot of [src].</span>")
			trim.forceMove(src.loc)
			trim = null
		if(comp.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[comp] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [comp] into the trim component slot of [src].</span>")
		trim = comp
		return ITEM_INTERACT_COMPLETE

/obj/machinery/smithing/kinetic_assembler/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FINISH_ATTACK
	if(finished_product)
		to_chat(user, "<span class='warning'>[src] has a nearly-complete product!</span>")
		return FINISH_ATTACK

	if(!primary)
		to_chat(user, "<span class='warning'>[src] lacks a primary component!</span>")
		return FINISH_ATTACK

	if(!secondary)
		to_chat(user, "<span class='warning'>[src] lacks a secondary component!</span>")
		return FINISH_ATTACK

	if(!trim)
		to_chat(user, "<span class='warning'>[src] lacks a trim component!</span>")
		return FINISH_ATTACK

	if(primary.finished_product != secondary.finished_product)
		to_chat(user, "<span class='warning'>[primary] does not match [secondary]!</span>")
		return FINISH_ATTACK

	operate(operation_time, user)
	return FINISH_ATTACK

/obj/machinery/smithing/kinetic_assembler/operate(loops, mob/living/user)
	..()
	finished_product = new primary.finished_product(src)
	var/quality_list = list(primary.quality, secondary.quality, trim.quality)
	var/datum/smith_quality/lowest = quality_list[1]
	for(var/datum/smith_quality/quality in quality_list)
		if(quality.stat_mult < lowest.stat_mult)
			lowest = quality
	finished_product.quality = lowest
	finished_product.material = trim.material
	finished_product.set_stats()
	finished_product.update_appearance(UPDATE_NAME)
	qdel(primary)
	qdel(secondary)
	qdel(trim)
	primary = null
	secondary = null
	trim = null

/obj/machinery/smithing/kinetic_assembler/hammer_act(mob/user, obj/item/i)
	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return
	if(!finished_product)
		to_chat(user, "<span class='warning'>There is no finished product ready!</span>")
		return
	playsound(src, 'sound/magic/fellowship_armory.ogg', 50, TRUE)
	finished_product.forceMove(src.loc)
	SSblackbox.record_feedback("tally", "smith_assembler_production", 1, "[finished_product.type]")
	// Modify based on productivity
	var/total_extras = clamp(round(1 * i.bit_productivity_mod / 2), 0, 2)
	if(is_type_in_typecache(finished_product, batched_item_types))
		total_extras += clamp(round(batch_extras * i.bit_productivity_mod / 2), 1, 4)
	for(var/iterator in 1 to total_extras)
		var/obj/item/smithed_item/extra_product = new finished_product.type(src.loc)
		extra_product.quality = finished_product.quality
		extra_product.material = finished_product.material
		extra_product.set_stats()
		extra_product.update_appearance(UPDATE_NAME)
		extra_product.scatter_atom()

	finished_product = null

// MARK: Scientific Assembler

/obj/machinery/smithing/scientific_assembler
	name = "scientific assembler"
	desc = "A smart assembler that takes slime cores, energy cells, and energy gun parts to produce energy guns."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "assembler"
	max_integrity = 100
	pixel_y = 0
	bound_height = 32
	bound_width = 32
	bound_y = 0
	operation_sound = 'sound/items/welder.ogg'
	req_one_access = list(ACCESS_TOX, ACCESS_XENOBIOLOGY, ACCESS_SMITH)
	/// Slime extract for the egun
	var/obj/item/slime_extract/slime_core
	/// The gun frame
	var/obj/item/smithed_item/component/egun_parts/parts
	/// The battery
	var/obj/item/stock_parts/cell/cell

/obj/machinery/smithing/scientific_assembler/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/scientific_assembler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/smithing/scientific_assembler/examine(mob/user)
	. = ..()
	if(slime_core || parts || cell)
		. += "<span class='notice'>You can activate the machine with your hand, or remove a component by alt-clicking.</span>"
	if(slime_core)
		. += "<span class='notice'>There is a [slime_core] in the core slot.</span>"
	if(parts)
		. += "<span class='notice'>There is a [parts] in the gun frame slot.</span>"
	if(cell)
		. += "<span class='notice'>There is a [cell] in the power cell slot.</span>"

/obj/machinery/smithing/scientific_assembler/RefreshParts()
	var/operation_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += OPERATION_SPEED_MULT_PER_RATING * component.rating
	// Update our values
	operation_time = operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)

/obj/machinery/smithing/scientific_assembler/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "assembler_wires"
	else
		icon_state = "assembler"

/obj/machinery/smithing/scientific_assembler/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/smithing/scientific_assembler/update_overlays()
	. = ..()
	overlays.Cut()
	if(panel_open)
		icon_state = "assembler_wires"

/obj/machinery/smithing/scientific_assembler/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/slime_extract))
		var/obj/item/slime_extract/core = used
		if(!core.associated_gun_type)
			to_chat(user, "<span class='notice'>[core] is not capable of producing an energy gun!</span>")
			return ITEM_INTERACT_COMPLETE
		if(slime_core)
			to_chat(user, "<span class='notice'>You remove [slime_core] from the core component slot of [src].</span>")
			slime_core.forceMove(src.loc)
			slime_core = null
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [used] into the core component slot of [src].</span>")
		slime_core = used
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/smithed_item/component/egun_parts))
		if(parts)
			to_chat(user, "<span class='notice'>You remove [parts] from the gun parts component slot of [src].</span>")
			parts.forceMove(src.loc)
			parts = null
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/smithed_item/component/egun_parts/new_parts = used
		if(new_parts.hammer_time)
			to_chat(user, "<span class='warning'>[new_parts] is not complete yet!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [used] into the gun parts component slot of [src].</span>")
		parts = used
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='notice'>You remove [cell] from the power cell component slot of [src].</span>")
			cell.forceMove(src.loc)
			cell = null
		if(used.flags & NODROP || !user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You insert [used] into the power cell component slot of [src].</span>")
		cell = used
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='warning'>You feel like there's no reason to process [used].</span>")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/smithing/scientific_assembler/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FINISH_ATTACK
	if(!slime_core)
		to_chat(user, "<span class='warning'>[src] lacks a slime core!</span>")
		return FINISH_ATTACK

	if(!parts)
		to_chat(user, "<span class='warning'>[src] lacks an energy gun frame!</span>")
		return FINISH_ATTACK

	if(!cell)
		to_chat(user, "<span class='warning'>[src] lacks a power cell!</span>")
		return FINISH_ATTACK

	operate(operation_time, user)
	return FINISH_ATTACK

/obj/machinery/smithing/scientific_assembler/operate(loops, mob/living/user)
	..()
	var/obj/item/gun/energy/finished_product = new slime_core.associated_gun_type(src)
	finished_product.forceMove(src.loc)
	qdel(slime_core)
	qdel(parts)
	qdel(cell)
	slime_core = null
	parts = null
	cell = null
