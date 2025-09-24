/obj/machinery/smithing/lava_furnace
	name = "lava furnace"
	desc = "A furnace that uses the innate heat of lavaland to reheat metal that has not been fully reshaped."
	icon_state = "furnace_off"
	operation_sound = 'sound/surgery/cautery1.ogg'
	/// How much the device heats the component
	var/heat_amount = 5

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
	var/heat_mult = 0
	for(var/obj/item/stock_parts/component in component_parts)
		operation_mult += OPERATION_SPEED_MULT_PER_RATING * component.rating
		heat_mult += 0.25 * component.rating
	// Update our values
	operation_time = max(ROUND_UP(initial(operation_time) * (1.3 - operation_mult)), 2)
	heat_amount = round(5 * heat_mult)

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
	if(working_component.heat > 10)
		to_chat(user, "<span class='notice'>[working_component] is already well heated.</span>")
		return
	if(working_component.hammer_time <= 0)
		to_chat(user, "<span class='notice'>[working_component] is already fully shaped.</span>")
		return
	..()
	working_component.heat_up(heat_amount)

/obj/machinery/smithing/lava_furnace/attack_hand(mob/user)
	. = ..()
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FINISH_ATTACK
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
	var/armor = target.run_armor_check(def_zone = BODY_ZONE_HEAD, armor_type = MELEE, armor_penetration_percentage = 50)
	target.apply_damage(40, BURN, BODY_ZONE_HEAD, armor)
	target.adjust_fire_stacks(5)
	target.IgniteMob()
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	add_attack_logs(user, target, "Burned with [src]")
	return TRUE
