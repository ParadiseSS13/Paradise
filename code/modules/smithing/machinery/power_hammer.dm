/obj/machinery/smithing/power_hammer
	name = "power hammer"
	desc = "A heavy-duty pneumatic hammer designed to shape and mold molten metal."
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

/obj/machinery/smithing/power_hammer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can set [src] to automatically continue hammering heated metal with a multitool.</span>"
	. += "<span class='notice'>The autohammer light is currently [repeating ? "on" : "off"].</span>"

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
	if(!working_component)
		to_chat(user, "<span class='notice'>There is no component to hammer!</span>")
		return
	if(!working_component.heat)
		to_chat(user, "<span class='notice'>[working_component] is too cold to properly shape.</span>")
		return
	if(working_component.hammer_time <= 0)
		to_chat(user, "<span class='notice'>[working_component] is already fully shaped.</span>")
		return
	..()
	working_component.powerhammer()
	do_sparks(5, TRUE, src)
	// If the hammer is set to repeat mode, let it repeat operations automatically.
	if(repeating && working_component.heat && working_component.hammer_time)
		operate(loops, user)
	// When an item is done, beep.
	if(!working_component.hammer_time)
		playsound(src, 'sound/machines/boop.ogg', 50, FALSE)

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
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return FINISH_ATTACK
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
	var/armor = target.run_armor_check(def_zone = BODY_ZONE_HEAD, armor_type = MELEE, armor_penetration_percentage = 50)
	target.apply_damage(40, BRUTE, BODY_ZONE_HEAD, armor)
	target.Weaken(4 SECONDS)
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	add_attack_logs(user, target, "Hammered with [src]")
	return TRUE
