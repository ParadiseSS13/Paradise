/obj/machinery/smithing/kinetic_assembler
	name = "kinetic assembler"
	desc = "A smart assembler that takes components and combines them at the strike of a hammer."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "assembler"
	max_integrity = 100
	pixel_x = 0	// 1x1
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
	RefreshParts()

/obj/machinery/smithing/kinetic_assembler/examine(mob/user)
	. = ..()
	if(primary || secondary || trim)
		. += "<span class='notice'>You can activate the machine with your hand, or remove a component by alt-clicking.</span>"
	if(primary)
		. += "<span class='notice'>There is a [primary] in the primary slot.</span>"
	if(secondary)
		. += "<span class='notice'>There is a [secondary] in the primary slot.</span>"
	if(trim)
		. += "<span class='notice'>There is a [trim] in the primary slot.</span>"
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
	finished_product = null
