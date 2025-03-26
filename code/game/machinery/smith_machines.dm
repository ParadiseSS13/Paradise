#define BASE_POINT_MULT 0.60
#define BASE_SHEET_MULT 0.60
#define POINT_MULT_ADD_PER_RATING 0.10
#define SHEET_MULT_ADD_PER_RATING 0.20
#define OPERATION_SPEED_MULT_PER_RATING 0.075
#define EFFICIENCY_MULT_ADD_PER_RATING 0.05

/obj/machinery/mineral/smart_hopper
	name = "smart hopper"
	desc = "An electronic deposit bin that accepts raw ores and delivers them to an adjacent magma crucible."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "hopper"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Linked magma crucible
	var/obj/machinery/magma_crucible/linked_crucible
	/// Access to claim points
	var/req_access_claim = ACCESS_MINING_STATION
	/// The number of unclaimed points.
	var/points = 0
	/// Point multiplier
	var/point_upgrade = 1
	/// List of ore yet to process.
	var/list/obj/item/stack/ore/ore_buffer = list()
	/// Whether the message to relevant supply consoles was sent already or not for an ore dump. If FALSE, another will be sent.
	var/message_sent = TRUE
	/// If TRUE, [/obj/machinery/mineral/smart_hopper/var/req_access_claim] is ignored and any ID may be used to claim points.
	var/anyone_claim = FALSE
	/// What consoles get alerted when this is filled
	var/list/supply_consoles = list(
		"Smith's Office",
		"Quartermaster's Desk"
	)

/obj/machinery/mineral/smart_hopper/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CRUCIBLE_DESTROYED, PROC_REF(unlink_crucible))
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smart_hopper(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	// Try to link to magma crucible on initialize. Link to the first crucible it can find.
	for(var/obj/machinery/magma_crucible/crucible in view(2, src))
		linked_crucible = crucible
		linked_crucible.linked_machines += src
		return

/obj/machinery/mineral/smart_hopper/update_overlays()
	. = ..()
	overlays.Cut()
	if(panel_open)
		. += "hopper_wires"

/obj/machinery/mineral/smart_hopper/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/mineral/smart_hopper/RefreshParts()
	var/point_mult = BASE_POINT_MULT
	for(var/obj/item/stock_parts/component in component_parts)
		point_mult += POINT_MULT_ADD_PER_RATING * component.rating
	// Update our values
	point_upgrade = point_mult
	SStgui.update_uis(src)

/obj/machinery/mineral/smart_hopper/process()
	if(panel_open || !has_power())
		return
	// Check if the input turf has a [/obj/structure/ore_box] to draw ore from. Otherwise suck ore from the turf
	var/atom/input = get_step(src, input_dir)
	var/obj/structure/ore_box/OB = locate() in input
	if(OB)
		input = OB
	// Suck the ore in
	for(var/obj/item/stack/ore/ore in input)
		if(QDELETED(ore))
			continue
		ore_buffer |= ore
		ore.forceMove(src)
		CHECK_TICK
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		send_console_message()
		message_sent = TRUE

// Interactions
/obj/machinery/mineral/smart_hopper/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(!has_power())
		return ..()

	if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/ID = used
		if(!points)
			to_chat(user, "<span class='warning'>There are no points to claim.</span>");
			return ITEM_INTERACT_COMPLETE
		if(anyone_claim || (req_access_claim in ID.access))
			ID.mining_points += points
			ID.total_mining_points += points
			to_chat(user, "<span class='notice'><b>[points] Mining Points</b> claimed. You have earned a total of <b>[ID.total_mining_points] Mining Points</b> this Shift!</span>")
			points = 0
		else
			to_chat(user, "<span class='warning'>Required access not found.</span>")
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/mineral/smart_hopper/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/multi = I
		if(!istype(multi.buffer, /obj/machinery/magma_crucible))
			to_chat(user, "<span class='warning'>You cannot link [src] to [multi.buffer]!</span>")
			return
		linked_crucible = multi.buffer
		linked_crucible.linked_machines += src
		to_chat(user, "<span class='notice'>You link [src] to [multi.buffer].</span>")

/obj/machinery/mineral/smart_hopper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/smart_hopper/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/mineral/smart_hopper/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!has_power())
		return
	if(!I.tool_start_check(src, user, 0))
		return
	input_dir = turn(input_dir, -90)
	to_chat(user, "<span class='notice'>You change [src]'s input, moving the input to [dir2text(input_dir)].</span>")

/obj/machinery/mineral/smart_hopper/Destroy()
	if(linked_crucible)
		linked_crucible.linked_machines -= src
	if(ore_buffer)
		for(var/obj/item/ores in ore_buffer)
			ores.forceMove(src.loc)
	return ..()

/obj/machinery/mineral/smart_hopper/proc/process_ores(list/obj/item/stack/ore/ore_list)
	if(!linked_crucible)
		return
	for(var/ore in ore_list)
		transfer_ore(ore)

/obj/machinery/mineral/smart_hopper/proc/transfer_ore(obj/item/stack/ore/O)
	if(!linked_crucible)
		return
	// Award points if the ore is actually transferable to the magma crucible
	give_points(O.type, O.amount)
	animate_transfer(O.amount)
	// Insert materials
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/amount_compatible = materials.get_item_material_amount(O)
	if(amount_compatible)
		// Prevents duping
		if(O.refined_type)
			materials.insert_item(O, linked_crucible.sheet_per_ore)
		else
			materials.insert_item(O, 1)
	// Delete the stack
	ore_buffer -= O
	qdel(O)

/obj/machinery/mineral/smart_hopper/proc/send_console_message()
	if(!is_station_level(z))
		return

	var/list/msg = list("Now available in [get_area_name(src, TRUE) || "Unknown"]:")
	var/mats_in_stock = list()
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		var/mineral_amount = M.amount / MINERAL_MATERIAL_AMOUNT
		if(mineral_amount)
			mats_in_stock += M.id
			msg.Add("[capitalize(M.name)]: [mineral_amount] sheets")

	// No point sending a message if we're dry
	if(!length(mats_in_stock))
		return

	// Notify
	for(var/obj/machinery/requests_console/console as anything in GLOB.allRequestConsoles)
		if(!(console.department in supply_consoles))
			continue
		if(!supply_consoles[console.department] || length(supply_consoles[console.department] - mats_in_stock))
			console.createMessage("Smart Hopper", "New Minerals Available!", msg, RQ_LOWPRIORITY)

/obj/machinery/mineral/smart_hopper/proc/give_points(obj/item/stack/ore/ore_path, ore_amount)
	if(initial(ore_path.refined_type))
		points += initial(ore_path.points) * point_upgrade * ore_amount

/obj/machinery/mineral/smart_hopper/proc/animate_transfer(ore_amount)
	icon_state = "hopper_on"
	var/time_to_animate = max(ore_amount * 2, 1 SECONDS)
	addtimer(VARSET_CALLBACK(src, icon_state, "hopper"), time_to_animate)
	linked_crucible.animate_transfer(time_to_animate)

/obj/machinery/mineral/smart_hopper/proc/unlink_crucible(atom/source, obj/machinery/magma_crucible/crucible)
	SIGNAL_HANDLER // COMSIG_CRUCIBLE_DESTROYED
	if(!istype(crucible))
		return
	if(crucible == linked_crucible)
		linked_crucible = null

/obj/machinery/magma_crucible
	name = "magma crucible"
	desc = "A massive machine that smelts down raw ore into a fine slurry, then sorts it into respective tanks for storage and use."
	icon = 'icons/obj/machines/magma_crucible.dmi'
	icon_state = "crucible"
	max_integrity = 300
	pixel_x = -32	// 3x3
	pixel_y = -32
	bound_width = 96
	bound_x = -32
	bound_height = 96
	bound_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Sheet multiplier applied when smelting ore.
	var/sheet_per_ore = 1
	/// State for adding ore
	var/adding_ore
	/// State for if ore is being taken from it
	var/pouring
	/// List of linked machines
	var/list/linked_machines = list()

/obj/machinery/magma_crucible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PALLADIUM, MAT_IRIDIUM, MAT_PLATINUM, MAT_BRASS), INFINITY, FALSE, list(/obj/item/stack, /obj/item/smithed_item), null, null)
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/magma_crucible(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	RefreshParts()

/obj/machinery/magma_crucible/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/magma_crucible/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/magma_crucible/RefreshParts()
	var/sheet_mult = BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/component in component_parts)
		sheet_mult += SHEET_MULT_ADD_PER_RATING * component.rating
	// Update our values
	sheet_per_ore = sheet_mult

/obj/machinery/magma_crucible/update_overlays()
	. = ..()
	overlays.Cut()
	if(adding_ore)
		. += "crucible_input"
	if(panel_open)
		. += "crucible_wires"
	if(pouring)
		. += "crucible_output"

/obj/machinery/magma_crucible/update_icon_state()
	. = ..()
	if(!has_power())
		icon_state = "[initial(icon_state)]_off"
	else
		icon_state = initial(icon_state)

/obj/machinery/magma_crucible/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/Destroy()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	for(var/obj/machinery/machine in linked_machines)
		SEND_SIGNAL(machine, COMSIG_CRUCIBLE_DESTROYED, src)
	return ..()

/obj/machinery/magma_crucible/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/magma_crucible/proc/animate_transfer(time_to_animate)
	adding_ore = TRUE
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(stop_animating)), time_to_animate)

/obj/machinery/magma_crucible/proc/stop_animating()
	adding_ore = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/proc/animate_pour(time_to_animate)
	pouring = TRUE
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(stop_pouring)), time_to_animate)

/obj/machinery/magma_crucible/proc/stop_pouring()
	pouring = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		if(!I.multitool_check_buffer(user))
			return
		var/obj/item/multitool/multi = I
		multi.set_multitool_buffer(user, src)
		to_chat(user, "<span class='notice'>You save [src]'s linking data to the buffer.</span>")
		return

	var/list/msgs = list()
	msgs += "<span class='notice'>Scanning contents of [src]:</span>"

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		if(!M)
			continue
		msgs += "[M.name]: [floor(M.amount / MINERAL_MATERIAL_AMOUNT)] sheets."
	to_chat(user, chat_box_regular(msgs.Join("<br>")))

/obj/machinery/smithing
	name = "smithing machine"
	desc = "A large unknown smithing machine. If you see this, there's a problem and you should notify the development team."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "power_hammer"
	max_integrity = 200
	pixel_x = 0	// 2x2
	pixel_y = -32
	bound_height = 64
	bound_width = 64
	bound_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// How many loops per operation
	var/operation_time = 10
	/// Is this active
	var/operating = FALSE
	/// Cooldown on harming
	var/special_attack_cooldown = 10 SECONDS
	/// Are we on harm cooldown
	var/special_attack_on_cooldown = FALSE
	/// Store the worked component
	var/obj/item/smithed_item/component/working_component
	/// The noise the machine makes when operating
	var/operation_sound
	/// Will the machine auto-repeat?
	var/repeating = FALSE

/obj/machinery/smithing/examine(mob/user)
	. = ..()
	if(working_component)
		. += "<span class='notice'>You can activate the machine with your hand, or remove the component by alt-clicking.</span>"

/obj/machinery/smithing/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/smithing/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='danger'>Putting [G.affecting] in [src] might hurt them!</span>")
			return ITEM_INTERACT_COMPLETE
		special_attack_grab(G, user)
		return ITEM_INTERACT_COMPLETE

	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return FINISH_ATTACK

	if(istype(used, /obj/item/smithed_item/component))
		if(working_component)
			to_chat(user, "<span class='warning'>There is already a component in the machine!</span>")
			return ITEM_INTERACT_COMPLETE

		if(used.flags & NODROP || !user.drop_item() || !used.forceMove(src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE

		working_component = used
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/smithing/proc/operate(loops, mob/living/user)
	operating = TRUE
	update_icon(ALL)
	for(var/i in 1 to loops)
		if(stat & (NOPOWER|BROKEN))
			return FALSE
		use_power(500)
		if(operation_sound)
			playsound(src, operation_sound, 50, TRUE)
		sleep(1 SECONDS)
	playsound(src, 'sound/machines/recycler.ogg', 50, FALSE)
	operating = FALSE
	update_icon(ALL)

/obj/machinery/smithing/proc/special_attack_grab(obj/item/grab/G, mob/user)
	if(special_attack_on_cooldown)
		return FALSE
	if(!istype(G))
		return FALSE
	if(!iscarbon(G.affecting))
		to_chat(user, "<span class='warning'>You can't shove that in there!</span>")
		return FALSE
	if(G.state < GRAB_NECK)
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return FALSE
	var/result = special_attack(user, G.affecting)
	user.changeNext_move(CLICK_CD_MELEE)
	special_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown)
	if(result && !QDELETED(G))
		qdel(G)

	return TRUE

/obj/machinery/smithing/proc/special_attack(mob/user, mob/living/target)
	return

/obj/machinery/smithing/AltClick(mob/living/user)
	. = ..()
	if(!Adjacent(user))
		return
	if(!working_component)
		to_chat(user, "<span class='notice'>There isn't anything in [src].</span>")
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return
	if(working_component.burn_check(user))
		working_component.burn_user(user)
		working_component.forceMove(user.loc)
		working_component = null
		return
	user.put_in_hands(working_component)
	working_component = null

/obj/machinery/smithing/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(operating)
		to_chat(user, "<span class='alert'>[src] is busy. Please wait for completion of previous operation.</span>")
		return
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/smithing/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/smithing/casting_basin
	name = "casting basin"
	desc = "A table with a large basin for pouring molten metal. It has a slot for a mold."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "casting_open"
	max_integrity = 100
	pixel_x = 0	// 1x1
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

/obj/machinery/smithing/casting_basin/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CRUCIBLE_DESTROYED, PROC_REF(unlink_crucible))
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
		linked_crucible.linked_machines += src
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
	if(produced_item)
		. += "casting_closed"
	if(cast && !produced_item)
		if(istype(cast, /obj/item/smithing_cast/sheet))
			. += "cast_sheet"
		else if(istype(cast, /obj/item/smithing_cast/component/insert_frame))
			. += "cast_armorframe"
		else if(istype(cast, /obj/item/smithing_cast/component/insert_lining))
			. += "cast_mesh"
		else if(istype(cast, /obj/item/smithing_cast/component/bit_mount))
			. += "cast_bitmount"
		else if(istype(cast, /obj/item/smithing_cast/component/bit_head))
			. += "cast_bithead"
		else if(istype(cast, /obj/item/smithing_cast/component/lens_focus))
			. += "cast_focus"
		else if(istype(cast, /obj/item/smithing_cast/component/lens_frame))
			. += "cast_lens"
		else if(istype(cast, /obj/item/smithing_cast/component/trim))
			. += "cast_trim"
		. += "casting_lip"
	if(panel_open)
		. += "casting_wires"
	if(operating)
		. += "casting_pour"

/obj/machinery/smithing/casting_basin/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

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
		linked_crucible.linked_machines += src
		to_chat(user, "<span class='notice'>You link [src] to [multi.buffer].</span>")

/obj/machinery/smithing/casting_basin/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/smithing_cast))
		to_chat(user, "<span class='warning'>[used] does not fit in [src]'s cast slot.</span>")
		return

	if(cast)
		to_chat(user, "<span class='warning'>[src] already has a cast inserted.</span>")
		return

	if(used.flags & NODROP || !user.transfer_item_to(used, src))
		to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE
	cast = used
	update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/smithing/casting_basin/AltClick(mob/living/user)
	if(!Adjacent(user))
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
	if(produced_item)
		if(produced_item.burn_check(user))
			produced_item.burn_user(user)
			produced_item.forceMove(user.loc)
			produced_item = null
			return FINISH_ATTACK
		user.put_in_hands(produced_item)
		produced_item = null
		update_icon(UPDATE_OVERLAYS)
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
		playsound(src, 'sound/machines/recycler.ogg', 50, TRUE)
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

/obj/machinery/smithing/casting_basin/Destroy()
	if(linked_crucible)
		linked_crucible.linked_machines -= src
	return ..()

/obj/machinery/smithing/casting_basin/proc/unlink_crucible(atom/source, obj/machinery/magma_crucible/crucible)
	SIGNAL_HANDLER // COMSIG_CRUCIBLE_DESTROYED
	if(!istype(crucible))
		return
	if(crucible == linked_crucible)
		linked_crucible = null

/obj/machinery/smithing/power_hammer
	name = "power hammer"
	desc = "A heavy-duty pneumatic hammer designed to shape and mold molten metal."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "power_hammer"
	operation_sound = 'sound/magic/fellowship_armory.ogg'

/obj/machinery/smithing/power_hammer/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_hammer(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/plasteel(null)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smithing/power_hammer/update_overlays()
	. = ..()
	overlays.Cut()
	if(operating)
		. += "hammer_hit"
	else
		. += "hammer_idle"
	if(panel_open)
		. += "hammer_wires"
	if(has_power())
		. += "hammer_fan_on"

/obj/machinery/smithing/power_hammer/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smithing/power_hammer/RefreshParts()
	var/operation_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += OPERATION_SPEED_MULT_PER_RATING * component.rating
	// Update our values
	operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)

/obj/machinery/smithing/power_hammer/operate(loops, mob/living/user)
	if(!working_component.hot)
		to_chat(user, "<span class='notice'>[working_component] is too cold to properly shape.</span>")
		return
	if(working_component.hammer_time <= 0)
		to_chat(user, "<span class='notice'>[working_component] is already fully shaped.</span>")
		return
	..()
	working_component.powerhammer()
	do_sparks(5, TRUE, src)
	// If the hammer is set to repeat mode, let it repeat operations automatically.
	if(repeating && working_component.hot && working_component.hammer_time)
		operate(loops, user)
	// When an item is done, beep.
	if(!working_component.hammer_time)
		playsound(src, 'sound/machines/boop.ogg', 50, TRUE)

/obj/machinery/smithing/power_hammer/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!repeating)
		repeating = TRUE
		to_chat(user, "<span class='notice'>You set [src] to auto-repeat.</span>")
	else
		repeating = FALSE
		to_chat(user, "<span class='notice'>You set [src] to not auto-repeat.</span>")

/obj/machinery/smithing/power_hammer/attack_hand(mob/user)
	. = ..()
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return
	operate(operation_time, user)
	update_icon(UPDATE_ICON_STATE)
	return FINISH_ATTACK

/obj/machinery/smithing/power_hammer/special_attack(mob/user, mob/living/target)
	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!istype(head))
		to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
		return FALSE
	target.visible_message("<span class='danger'>[user] hammers [target]'s head with [src]!</span>", \
					"<span class='userdanger'>[user] hammers your head with [src]! Did somebody get the license plate on that car?</span>")
	var/armor = target.run_armor_check(def_zone = BODY_ZONE_HEAD, attack_flag = MELEE, armour_penetration_percentage = 50)
	target.apply_damage(40, BRUTE, BODY_ZONE_HEAD, armor)
	target.Weaken(4 SECONDS)
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	add_attack_logs(user, target, "Hammered with [src]")
	return TRUE

/obj/machinery/smithing/lava_furnace
	name = "lava furnace"
	desc = "A furnace that uses the innate heat of lavaland to reheat metal that has not been fully reshaped."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "furnace_off"
	operation_sound = 'sound/surgery/cautery1.ogg'

/obj/machinery/smithing/lava_furnace/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/lava_furnace(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	RefreshParts()

/obj/machinery/smithing/lava_furnace/RefreshParts()
	var/operation_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += OPERATION_SPEED_MULT_PER_RATING * component.rating
	// Update our values
	operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)

/obj/machinery/smithing/lava_furnace/update_overlays()
	. = ..()
	overlays.Cut()
	if(panel_open)
		. += "furnace_wires"

/obj/machinery/smithing/lava_furnace/update_icon_state()
	. = ..()
	if(operating)
		icon_state = "furnace"
	else
		icon_state = "furnace_off"

/obj/machinery/smithing/lava_furnace/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/smithing/lava_furnace/operate(loops, mob/living/user)
	if(working_component.hot)
		to_chat(user, "<span class='notice'>[working_component] is already well heated.</span>")
		return
	if(working_component.hammer_time <= 0)
		to_chat(user, "<span class='notice'>[working_component] is already fully shaped.</span>")
		return
	..()
	working_component.heat_up()

/obj/machinery/smithing/lava_furnace/attack_hand(mob/user)
	. = ..()
	if(operating)
		to_chat(user, "<span class='warning'>[src] is currently operating!</span>")
		return
	if(!working_component)
		to_chat(user, "<span class='warning'>There is nothing in [src]!</span>")
		return

	operate(operation_time, user)
	return FINISH_ATTACK

/obj/machinery/smithing/lava_furnace/special_attack(mob/user, mob/living/target)
	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!istype(head))
		to_chat(user, "<span class='warning'>This person doesn't have a head!</span>")
		return FALSE
	target.visible_message("<span class='danger'>[user] pushes [target]'s head into [src]!</span>", \
					"<span class='userdanger'>[user] pushes your head into [src]! The heat is agonizing!</span>")
	var/armor = target.run_armor_check(def_zone = BODY_ZONE_HEAD, attack_flag = MELEE, armour_penetration_percentage = 50)
	target.apply_damage(40, BURN, BODY_ZONE_HEAD, armor)
	target.adjust_fire_stacks(5)
	target.IgniteMob()
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	add_attack_logs(user, target, "Burned with [src]")
	return TRUE

#define PART_PRIMARY 1
#define PART_SECONDARY 2
#define PART_TRIM 3

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

#undef PART_PRIMARY
#undef PART_SECONDARY
#undef PART_TRIM
#undef BASE_POINT_MULT
#undef BASE_SHEET_MULT
#undef POINT_MULT_ADD_PER_RATING
#undef SHEET_MULT_ADD_PER_RATING
#undef OPERATION_SPEED_MULT_PER_RATING
#undef EFFICIENCY_MULT_ADD_PER_RATING
