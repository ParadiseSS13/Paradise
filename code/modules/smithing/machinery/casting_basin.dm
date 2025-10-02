/obj/machinery/smithing/casting_basin
	name = "casting basin"
	desc = "A table with a large basin for pouring molten metal. It has a slot for a mold."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "casting_open"
	max_integrity = 100
	pixel_y = 0
	bound_height = 32
	bound_width = 32
	bound_y = 0
	/// Linked magma crucible
	var/obj/machinery/magma_crucible/linked_crucible
	/// Operational Efficiency
	var/efficiency = 1
	/// Inserted cast
	var/obj/item/smithing_cast/cast
	/// Finished product
	var/obj/item/smithed_item/component/produced_item
	/// Is it opened or closed?
	var/we_are_open = TRUE

/obj/machinery/smithing/casting_basin/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/casting_basin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	// Try to link to magma crucible on initialize. Link to the first crucible it can find.
	for(var/obj/machinery/magma_crucible/crucible in view(2, src))
		linked_crucible = crucible
		linked_crucible.linked_machines |= src
		return

/obj/machinery/smithing/casting_basin/examine(mob/user)
	. = ..()
	if(cast)
		. += "<span class='notice'>You can activate the machine with your hand, or remove the cast by alt-clicking.</span>"
		. += "<span class='notice'>There is a [cast] in the cast slot.</span>"
		. += "<span class='notice'>Currently set to produce: [cast.selected_product.name]</span>"
		if(istype(cast, /obj/item/smithing_cast/component) && !produced_item)
			var/obj/item/temp_product = new cast.selected_product(src) // This is necessary due to selected_product being a type
			var/obj/item/smithing_cast/component/comp_cast = cast
			var/datum/smith_quality/quality = new comp_cast.quality
			. += "<span class='notice'>Required Resources:</span>"
			var/MAT
			// Get the materials the item needs and display
			for(MAT in temp_product.materials)
				. += "<span class='notice'> - [MAT]: [ROUND_UP(((temp_product.materials[MAT] * quality.material_mult) * efficiency) / MINERAL_MATERIAL_AMOUNT)] sheets.</span>"
			// Get rid of the temp product
			qdel(temp_product)
		else if(istype(cast, /obj/item/smithing_cast/misc) && !produced_item)
			var/obj/item/temp_product = new cast.selected_product(src) // This is necessary due to selected_product being a type
			. += "<span class='notice'>Required Resources:</span>"
			var/MAT
			// Get the materials the item needs and display
			for(MAT in temp_product.materials)
				. += "<span class='notice'> - [MAT]: [ROUND_UP((temp_product.materials[MAT] * efficiency) / MINERAL_MATERIAL_AMOUNT)] sheets.</span>"
			// Get rid of the temp product
			qdel(temp_product)

	if(produced_item)
		. += "<span class='notice'>There is a [produced_item] in the machine. You can pick it up with your hand.</span>"

/obj/machinery/smithing/casting_basin/RefreshParts()
	var/operation_mult = 0
	var/efficiency_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += 2 * OPERATION_SPEED_MULT_PER_RATING * component.rating
		efficiency_mult += EFFICIENCY_MULT_ADD_PER_RATING * component.rating
	// Update our values
	operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)
	efficiency = initial(efficiency) * (1.1 - efficiency_mult)

/obj/machinery/smithing/casting_basin/update_overlays()
	. = ..()
	overlays.Cut()
	if(produced_item && !we_are_open)
		. += "casting_closed"
	if(cast && produced_item && we_are_open)
		. += "[cast.basin_state]_full"
		. += "casting_lip"
	if(cast && !produced_item && we_are_open)
		. += cast.basin_state
		. += "casting_lip"
	if(panel_open)
		. += "casting_wires"
	if(operating)
		. += "casting_pour"

/obj/machinery/smithing/casting_basin/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smithing/casting_basin/Destroy()
	if(cast)
		cast.forceMove(src.loc)
	if(produced_item)
		produced_item.forceMove(src.loc)
	if(linked_crucible)
		linked_crucible.linked_machines -= src
		linked_crucible = null
	. = ..()

/obj/machinery/smithing/casting_basin/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/multi = I
		if(!istype(multi.buffer, /obj/machinery/magma_crucible))
			to_chat(user, "<span class='notice'>You cannot link [src] to [multi.buffer]!</span>")
			return
		linked_crucible = multi.buffer
		linked_crucible.linked_machines |= src
		to_chat(user, "<span class='notice'>You link [src] to [multi.buffer].</span>")

/obj/machinery/smithing/casting_basin/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/smithing_cast))
		to_chat(user, "<span class='warning'>[used] does not fit in [src]'s cast slot.</span>")
		return

	if(used.flags & NODROP || !user.transfer_item_to(used, src))
		to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE
	if(cast)
		user.put_in_active_hand(cast)
		to_chat(user, "<span class='notice'>You swap [used] with [cast] in [src].</span>")
	else
		to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")
	cast = used
	update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/smithing/casting_basin/AltClick(mob/living/user)
	if(!Adjacent(user))
		return
	if(!we_are_open)
		to_chat(user, "<span class='notice'>You open [src].</span>")
		we_are_open = TRUE
		update_icon(UPDATE_OVERLAYS)
		return
	if(produced_item)
		to_chat(user, "<span class='warning'>Remove the item first!</span>")
		return
	if(!cast)
		to_chat(user, "<span class='warning'>There is no cast to remove.</span>")
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return
	user.put_in_hands(cast)
	cast = null
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smithing/casting_basin/attack_hand(mob/user)
	if(!we_are_open)
		to_chat(user, "<span class='notice'>You open [src].</span>")
		we_are_open = TRUE
		update_icon(UPDATE_OVERLAYS)
		return FINISH_ATTACK
	if(produced_item)
		if(produced_item.burn_check(user))
			produced_item.burn_user(user)
			produced_item.forceMove(user.loc)
			update_icon(UPDATE_OVERLAYS)
			produced_item = null
			return FINISH_ATTACK
		user.put_in_hands(produced_item)
		produced_item = null
		update_icon(UPDATE_OVERLAYS)
		return FINISH_ATTACK
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FINISH_ATTACK
	if(!cast)
		to_chat(user, "<span class='warning'>There is no cast inserted!</span>")
		return FINISH_ATTACK
	if(!linked_crucible)
		to_chat(user, "<span class='warning'>There is no linked magma crucible!</span>")
		return FINISH_ATTACK
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return FINISH_ATTACK

	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/obj/item/temp_product = new cast.selected_product // Product is stored as a type, I need a temporary item for handling material calcs
	var/amount = cast.amount_to_make
	var/MAT

	if(!istype(temp_product))
		to_chat(user, "<span class='warning'>The product is not an item! This is a problem you should make an issue report about!</span>")
		log_debug("Attempted to make [temp_product] at a casting basin, product is not an item.")
		return FINISH_ATTACK

	if(istype(cast, /obj/item/smithing_cast/component))
		var/obj/item/smithing_cast/component/comp_cast = cast
		var/datum/smith_quality/quality = new comp_cast.quality
		var/list/used_mats = list()

		// Check if there is enough materials to craft the item
		for(MAT in temp_product.materials)
			used_mats[MAT] = (temp_product.materials[MAT] * quality.material_mult) * efficiency

		if(!materials.has_materials(used_mats, 1))
			to_chat(user, "<span class='warning'>Not enough materials in the crucible to smelt [temp_product.name]!</span>")
			qdel(temp_product)
			return FINISH_ATTACK

		to_chat(user, "<span class='notice'>You begin to pour the liquid minerals into the [src]...</span>")
		// Use the materials and create the item.
		materials.use_amount(used_mats)
		we_are_open = FALSE
		linked_crucible.animate_pour(operation_time SECONDS)
		operate(operation_time, user)
		produced_item = new cast.selected_product(src)
		produced_item.quality = quality
		produced_item.set_worktime()
		produced_item.update_appearance(UPDATE_NAME)
		produced_item.update_icon(UPDATE_ICON_STATE)
		update_icon(UPDATE_OVERLAYS)
		// Clean up temps
		qdel(temp_product)
		return FINISH_ATTACK

	if(istype(cast, /obj/item/smithing_cast/sheet))
		// Get max amount of sheets (0-50)
		var/datum/material/M
		var/stored

		// Check if there is enough materials to craft the item
		for(MAT in temp_product.materials)
			M = materials.materials[MAT]
			if(!stored)
				stored = M.amount / MINERAL_MATERIAL_AMOUNT
			else
				stored = min(M.amount / MINERAL_MATERIAL_AMOUNT, stored)
			if(istype(cast, /obj/item/smithing_cast/sheet))
				amount = min(amount, stored, MAX_STACK_SIZE)
		if(!amount)
			to_chat(user, "<span class='warning'>Not enough materials in the crucible to smelt a sheet of [temp_product.name]!</span>")
			qdel(temp_product)
			return FINISH_ATTACK

		to_chat(user, "<span class='notice'>You begin to pour the liquid minerals into the [src]...</span>")
		playsound(src, 'sound/machines/recycler.ogg', 50, FALSE)
		// Use the materials and create the item.
		materials.use_amount(temp_product.materials, amount)
		linked_crucible.animate_pour(operation_time SECONDS)
		operate(operation_time, user)
		var/obj/item/stack/new_stack = new cast.selected_product(src.loc)
		new_stack.amount = amount
		new_stack.update_icon(UPDATE_ICON_STATE)

		// Clean up temps
		qdel(temp_product)
		return FINISH_ATTACK

	if(istype(cast, /obj/item/smithing_cast/misc))
		var/list/used_mats = list()

		// Check if there is enough materials to craft the item
		for(MAT in temp_product.materials)
			used_mats[MAT] = temp_product.materials[MAT] * efficiency

		if(!materials.has_materials(used_mats, 1))
			to_chat(user, "<span class='warning'>Not enough materials in the crucible to smelt [temp_product.name]!</span>")
			qdel(temp_product)
			return FINISH_ATTACK

		to_chat(user, "<span class='notice'>You begin to pour the liquid minerals into the [src]...</span>")
		// Use the materials and create the item.
		materials.use_amount(used_mats)
		linked_crucible.animate_pour(operation_time SECONDS)
		operate(operation_time, user)
		produced_item = new cast.selected_product(src)
		produced_item.set_worktime()
		produced_item.update_appearance(UPDATE_NAME)
		produced_item.update_icon(UPDATE_ICON_STATE)
		update_icon(UPDATE_OVERLAYS)
		// Clean up temps
		qdel(temp_product)
		return FINISH_ATTACK
