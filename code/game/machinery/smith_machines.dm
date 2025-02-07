#define BASE_POINT_MULT 0.60
#define BASE_SHEET_MULT 0.60
#define POINT_MULT_ADD_PER_RATING 0.10
#define SHEET_MULT_ADD_PER_RATING 0.20
#define OPERATION_SPEED_MULT_PER_RATING 0.25
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
		return

/obj/machinery/mineral/smart_hopper/RefreshParts()
	var/P = BASE_POINT_MULT
	for(var/obj/item/stock_parts/M in component_parts)
		P += POINT_MULT_ADD_PER_RATING * M.rating
	// Update our values
	point_upgrade = P
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
	for(var/obj/item/stack/ore/O in input)
		if(QDELETED(O))
			continue
		ore_buffer |= O
		O.forceMove(src)
		CHECK_TICK
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		SStgui.update_uis(src)
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
			SStgui.update_uis(src)
		else
			to_chat(user, "<span class='warning'>Required access not found.</span>")
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/mineral/smart_hopper/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/M = I
		if(!istype(M.buffer, /obj/machinery/magma_crucible))
			to_chat(user, "<span class='warning'>You cannot link [src] to [M.buffer]!</span>")
			return
		linked_crucible = M.buffer

/obj/machinery/mineral/smart_hopper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

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

/obj/machinery/mineral/smart_hopper/proc/process_ores(list/obj/item/stack/ore/L)
	if(!linked_crucible)
		return
	for(var/ore in L)
		transfer_ore(ore)

/obj/machinery/mineral/smart_hopper/proc/transfer_ore(obj/item/stack/ore/O)
	// Insert materials
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/amount_compatible = materials.get_item_material_amount(O)
	if(amount_compatible)
		// Prevents duping
		if(O.refined_type)
			materials.insert_item(O, linked_crucible.sheet_per_ore)
		else
			materials.insert_item(O, 1)
	// Award points if the ore actually transfers to the magma crucible
	give_points(O.type, O.amount)
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
	for(var/c in GLOB.allRequestConsoles)
		var/obj/machinery/requests_console/C = c
		if(!(C.department in supply_consoles))
			continue
		if(!supply_consoles[C.department] || length(supply_consoles[C.department] - mats_in_stock))
			C.createMessage("Smart Hopper", "New Minerals Available!", msg, RQ_LOWPRIORITY)

/obj/machinery/mineral/smart_hopper/proc/give_points(obj/item/stack/ore/ore_path, ore_amount)
	if(initial(ore_path.refined_type))
		points += initial(ore_path.points) * point_upgrade * ore_amount

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

/obj/machinery/magma_crucible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PALLADIUM, MAT_IRIDIUM, MAT_PLATINUM, MAT_BRASS), INFINITY, FALSE, /obj/item/stack, null, null)
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

/obj/machinery/magma_crucible/RefreshParts()
	var/S = BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		S += SHEET_MULT_ADD_PER_RATING * M.rating
	// Update our values
	sheet_per_ore = S
	SStgui.update_uis(src)
// POLTODO: UI for seeing current minerals as a bar graph

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
		return ITEM_INTERACT_COMPLETE

	if(!istype(used, /obj/item/smithed_item/component))
		to_chat(user, "<span class='warning'>You feel like there's no reason to process [used].</span>")
		return ITEM_INTERACT_COMPLETE

	used.forceMove(src)
	working_component = used
	operate(operation_time, user)
	update_icon(UPDATE_ICON_STATE)
	return ..()

/obj/machinery/smithing/proc/operate(loops, mob/living/user)
	operating = TRUE
	update_icon(UPDATE_ICON_STATE)
	for(var/i=1 to loops)
		if(stat & (NOPOWER|BROKEN))
			return FALSE
		use_power(500)
		playsound(src, operation_sound, 50, TRUE)
		sleep(1 SECONDS)
	playsound(src, 'sound/machines/recycler.ogg', 50, TRUE)
	operating = FALSE

/obj/machinery/smithing/proc/special_attack_grab(obj/item/grab/G, mob/user)
	if(special_attack_on_cooldown)
		return FALSE
	if(!istype(G))
		return FALSE
	if(!iscarbon(G.affecting))
		to_chat(user, "<span class='warning'>You can't shove that in there!</span>")
		return FALSE
	if(G.state < GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return FALSE
	var/result = special_attack(user, G.affecting)
	user.changeNext_move(CLICK_CD_MELEE)
	special_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown)
	if(result && !isnull(G) && !QDELETED(G))
		qdel(G)

	return TRUE

/obj/machinery/smithing/proc/special_attack(mob/user, mob/living/target)
	return

/obj/machinery/smithing/AltClick(mob/living/user)
	. = ..()
	if(!working_component)
		to_chat(user, "<span class='notice'>There isn't anything in [src].</span>")
		return
	user.put_in_hands(working_component)
	working_component = null


/obj/machinery/smithing/casting_basin
	name = "casting basin"
	desc = "A table with a large basin for pouring molten metal. It has a slot for a mold."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "casting_bench"
	max_integrity = 100
	pixel_x = 0	// 1x1
	pixel_y = 0
	bound_height = 32
	bound_width = 32
	bound_y = 0
	operation_time = 10 SECONDS
	operating = FALSE
	/// Linked magma crucible
	var/obj/machinery/magma_crucible/linked_crucible
	/// Operational Efficiency
	var/efficiency = 1
	/// Inserted cast
	var/obj/item/smithing_cast/cast

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
		return

/obj/machinery/smithing/casting_basin/RefreshParts()
	var/O = 0
	var/E = 0
	for(var/obj/item/stock_parts/M in component_parts)
		O += OPERATION_SPEED_MULT_PER_RATING * M.rating
		E += EFFICIENCY_MULT_ADD_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - O
	efficiency = initial(efficiency) - E

/obj/machinery/smithing/casting_basin/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/M = I
		if(!istype(M.buffer, /obj/machinery/magma_crucible))
			to_chat(user, "<span class='notice'>You cannot link [src] to [M.buffer]!</span>")
			return
		linked_crucible = M.buffer

/obj/machinery/smithing/casting_basin/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/smithing_cast))
		to_chat(user, "<span class='warning'>[used] does not fit in [src]'s cast slot.</span>")
		return

	if(cast)
		to_chat(user, "<span class='warning'>[src] already has a cast inserted.</span>")
		return

	used.forceMove(src)
	cast = used

/obj/machinery/smithing/casting_basin/AltClick(mob/living/user)
	if(!cast)
		to_chat(user, "<span class='warning'>There is no cast to remove.</span>")
		return

	user.put_in_hands(cast)
	cast = null

/obj/machinery/smithing/casting_basin/attack_hand(mob/user)
	. = ..()
	if(!cast)
		to_chat(user, "<span class='warning'>There is no cast inserted!</span>")
		return
	if(!linked_crucible)
		to_chat(user, "<span class='warning'>There is no linked magma crucible!</span>")
		return
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/obj/item/product = cast.selected_product
	var/amount = 1
	var/datum/material/M
	for(var/MAT in product.materials)
		M = materials[MAT]
		var/stored = M.amount / MINERAL_MATERIAL_AMOUNT
		if(istype(cast, /obj/item/smithing_cast/sheet))
			var/obj/item/smithing_cast/sheet/sheet_cast = cast
			amount = min(sheet_cast.sheet_number, stored, MAX_STACK_SIZE)
	if(istype(cast, /obj/item/smithing_cast/component))
		var /obj/item/smithing_cast/component/comp_cast = cast
		product.materials = product.materials * comp_cast.quality.material_mult
	materials.use_amount(product.materials, multiplier = amount)
	sleep(operation_time)
	if(istype(cast, /obj/item/smithing_cast/sheet))
		var/obj/item/stack/new_stack = new product(src.loc)
		new_stack.amount = amount
	else
		new product(src.loc)

	// TODO: SMELTING

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

/obj/machinery/smithing/power_hammer/RefreshParts()
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S

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
	icon_state = "furnace"
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
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S

/obj/machinery/smithing/lava_furnace/operate(loops, mob/living/user)
	if(working_component.hot)
		to_chat(user, "<span class='notice'>[working_component] is already well heated.</span>")
		return
	if(working_component.hammer_time <= 0)
		to_chat(user, "<span class='notice'>[working_component] is already fully shaped.</span>")
		return
	..()
	working_component.heat_up()

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
	operation_time = 10 SECONDS
	operating = FALSE
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

/obj/machinery/smithing/kinetic_assembler/RefreshParts()
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S

/obj/machinery/smithing/kinetic_assembler/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(operating)
		to_chat(user, "<span class='warning'>[src] is still operating!</span>")
		return ITEM_INTERACT_COMPLETE

	if(!istype(used, /obj/item/smithed_item/component))
		to_chat(user, "<span class='warning'>You feel like there's no reason to process [used].</span>")
		return ITEM_INTERACT_COMPLETE

	var/obj/item/smithed_item/component/comp = used
	if(comp.part_type == PART_PRIMARY)
		if(primary)
			to_chat(user, "<span class='notice'>You remove [primary] from the primary component slot of [src].</span>")
			primary.forceMove(src.loc)
			primary = null
		to_chat(user, "<span class='notice'>You insert [comp] into the primary component slot of [src].</span>")
		comp.forceMove(src)
		primary = comp
		return ITEM_INTERACT_COMPLETE

	if(comp.part_type == PART_SECONDARY)
		if(secondary)
			to_chat(user, "<span class='notice'>You remove [secondary] from the secondary component slot of [src].</span>")
			secondary.forceMove(src.loc)
			secondary = null
		to_chat(user, "<span class='notice'>You insert [comp] into the secondary component slot of [src].</span>")
		comp.forceMove(src)
		secondary = comp
		return ITEM_INTERACT_COMPLETE

	if(comp.part_type == PART_TRIM)
		if(trim)
			to_chat(user, "<span class='notice'>You remove [trim] from the trim component slot of [src].</span>")
			trim.forceMove(src.loc)
			trim = null
		to_chat(user, "<span class='notice'>You insert [comp] into the trim component slot of [src].</span>")
		comp.forceMove(src)
		trim = comp
		return ITEM_INTERACT_COMPLETE

/obj/machinery/smithing/kinetic_assembler/attack_hand(mob/user)
	. = ..()
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

	operate()

/obj/machinery/smithing/kinetic_assembler/operate()
	..()
	finished_product = new primary.finished_product(src)
	var/quality_list = list(primary.quality, secondary.quality, trim.quality)
	var/datum/smith_quality/lowest = quality_list[0]
	for(var/datum/smith_quality/quality in quality_list)
		if(quality.stat_mult < lowest.stat_mult)
			lowest = quality
	finished_product.quality = lowest
	finished_product.material = trim.material
	qdel(primary)
	qdel(secondary)
	qdel(trim)

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
