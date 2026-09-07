/obj/structure/grave
	name = "grave"
	desc = "Rest in peace."
	max_integrity = 100
	icon = 'icons/obj/structures/grave.dmi'
	icon_state = "grave_basalt_open"
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	/// What does the grave contain?
	var/atom/buried
	/// What does the headstone say?
	var/headstone_message = "taken before their time."

/obj/structure/grave/Initialize(mapload)
	. = ..()
	var/turf/item_turf = get_turf(src)
	if(ispath(item_turf.baseturf, /turf/simulated/floor/plating/asteroid) || ispath(item_turf.baseturf, /turf/simulated/floor/lava/mapping_lava))
		update_icon(UPDATE_ICON_STATE)
		return
	var/obj/item/stack/ore/glass/sand_pile = new /obj/item/stack/ore/glass(get_turf(src))
	sand_pile.amount = 5
	visible_message(SPAN_DANGER("With nowhere to dig, [src] falls apart."))
	// In case somehow something is buried here already
	dig_up()
	return INITIALIZE_HINT_QDEL

/obj/structure/grave/examine(mob/user)
	. = ..()
	if(buried && ismob(buried))
		. += "Here lies [buried], [headstone_message]."
	if(buried)
		. += SPAN_NOTICE("You can dig up [src] with a shovel or other digging tool.")
	else
		. += SPAN_NOTICE("You can bury an object here by clicking on [src] with the object.")
		. += SPAN_NOTICE("You can bury a mob or person here by clicking on [src] with the mob or person strongly grabbed.")

/obj/structure/grave/update_icon_state()
	. = ..()
	var/turf/item_turf = get_turf(src)
	if(ispath(item_turf.baseturf, /turf/simulated/floor/plating/asteroid/basalt) || ispath(item_turf.baseturf, /turf/simulated/floor/lava/mapping_lava))
		icon_state = "grave_basalt"
	else
		icon_state = "grave_sand"
	if(buried)
		icon_state += "_closed"
	else
		icon_state += "_open"

/obj/structure/grave/update_overlays()
	. = ..()
	overlays.Cut()
	if(buried && ismob(buried))
		. += pick("marker_cross", "marker_lightstone", "marker_darkstone")

/obj/structure/grave/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(used))
		headstone_message = tgui_input_text(user, "Input headstone message", "Headstone", "[headstone_message]")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/shovel) || istype(used, /obj/item/pickaxe))
		to_chat(user, SPAN_NOTICE("You begin to dig up [src] with [used]."))
		playsound(loc, 'sound/effects/shovel_dig.ogg', 50, TRUE)
		if(do_after(user, 10 SECONDS, target = src))
			dig_up()
		return ITEM_INTERACT_COMPLETE

	if(buried)
		to_chat(user, SPAN_WARNING("The grave is already full."))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/grab)) // Burying Mobs
		var/obj/item/grab/G = used
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, SPAN_DANGER("You need a stronger grip on [G.affecting] to bury [G.affecting.p_them()]!"))
			return ITEM_INTERACT_COMPLETE
		if(HAS_TRAIT(user, TRAIT_PACIFISM) && G.affecting.stat != DEAD)
			to_chat(user, SPAN_DANGER("Burying [G.affecting] in [src] might hurt [G.affecting.p_them()]!"))
			return ITEM_INTERACT_COMPLETE
		visible_message(SPAN_DANGER("[user] starts to bury [G.affecting] in [src]!"), \
			SPAN_USERDANGER("[user] starts to bury [G.affecting]!"))
		to_chat(G.affecting, SPAN_USERDANGER("[user] is burying you alive!"))
		log_admin("[user] started to bury [G.affecting] in [src]")
		if(do_after(user, 10 SECONDS, target = G.affecting))
			log_attack(user, G.affecting, "buried [G.affecting] in [src].")
			bury(user, G.affecting)
	else // Burying Objects
		visible_message(SPAN_DANGER("[user] starts to bury [used] in [src]!"), \
			SPAN_USERDANGER("[user] starts to bury [used]!"))
		if(do_after(user, 10 SECONDS, target = used))
			bury(user, used)
	playsound(loc, 'sound/effects/shovel_dig.ogg', 50, TRUE)

	return ITEM_INTERACT_COMPLETE

/obj/structure/grave/return_obj_air() // If you're buried alive, suffocate
	var/datum/gas_mixture/vacuum = new()
	return vacuum

/obj/structure/grave/container_resist(mob/living)
	to_chat(living, SPAN_DANGER("You begin to dig out of [src]! This will take about 30 seconds."))
	if(do_after(living, 30 SECONDS, target = src))
		dig_up()

/obj/structure/grave/proc/bury(mob/living/user, atom/thing_to_bury)
	if(isobj(thing_to_bury))
		var/obj/bury_me = thing_to_bury
		if(bury_me.flags & NODROP || !user.transfer_item_to(bury_me, src))
			to_chat(user, SPAN_WARNING("[bury_me] is stuck to your hand!"))
			return
		bury_me.forceMove(src)
	if(ismob(thing_to_bury))
		var/mob/bury_me = thing_to_bury
		bury_me.forceMove(src)
	buried = thing_to_bury
	playsound(loc, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/grave/proc/dig_up()
	if(!buried)
		return
	if(isobj(buried))
		var/obj/dig_up_me = buried
		dig_up_me.forceMove(get_turf(src))
	if(ismob(buried))
		var/mob/dig_up_me = buried
		dig_up_me.forceMove(get_turf(src))
	buried = null
	playsound(loc, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)
