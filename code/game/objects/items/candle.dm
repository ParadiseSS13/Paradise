#define TALL_CANDLE 1
#define MID_CANDLE 2
#define SHORT_CANDLE 3

/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
	light_color = "#E09D37"
	var/wax = 200
	/// Index for the icon state
	var/wax_index = TALL_CANDLE
	var/lit = FALSE
	var/infinite = FALSE
	var/start_lit = FALSE
	var/flickering = FALSE

/obj/item/candle/New()
	..()
	if(start_lit)
		// No visible message
		light(show_message = 0)

/obj/item/candle/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/candle/update_icon_state()
	if(flickering)
		icon_state = "candle[wax_index]_flicker"
	else
		icon_state = "candle[wax_index][lit ? "_lit" : ""]"

/obj/item/candle/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/candle/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(W.get_heat())
		light("<span class='notice'>[user] lights [src] with [W].</span>")
		return
	return ..()

/obj/item/candle/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0)) //Don't need to flash eyes because you are a badass
		light("<span class='notice'>[user] casually lights [src] with [I], what a badass.</span>")

/obj/item/candle/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!lit)
		light() //honk
	return ..()

/obj/item/candle/proc/light(show_message)
	if(!lit)
		lit = TRUE
		if(show_message)
			usr.visible_message(show_message)
		set_light(CANDLE_LUM)
		START_PROCESSING(SSobj, src)
		update_icon(UPDATE_ICON_STATE)

/obj/item/candle/proc/update_wax_index()
	var/new_wax_index
	if(wax > 150)
		new_wax_index = TALL_CANDLE
	else if(wax > 80)
		new_wax_index = MID_CANDLE
	else
		new_wax_index = SHORT_CANDLE
	if(wax_index != new_wax_index)
		wax_index = new_wax_index
		return TRUE
	return FALSE

/obj/item/candle/proc/start_flickering()
	flickering = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(stop_flickering)), 4 SECONDS, TIMER_UNIQUE)

/obj/item/candle/proc/stop_flickering()
	flickering = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
		if(wax_index != SHORT_CANDLE) // It's not at its shortest
			if(update_wax_index())
				update_icon(UPDATE_ICON_STATE)
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.drop_item_to_ground(src, force = TRUE) //src is being deleted anyway
		qdel(src)
	if(isturf(loc)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 1)

/obj/item/candle/proc/unlight()
	if(lit)
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		set_light(0)


/obj/item/candle/attack_self__legacy__attackchain(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] snuffs out [src].</span>")
		unlight()

/obj/item/candle/lit
	start_lit = TRUE

/obj/item/candle/eternal
	desc = "A candle. This one seems to have an odd quality about the wax."
	infinite = TRUE

/obj/item/candle/eternal/lit
	start_lit = TRUE

/obj/item/candle/get_spooked()
	if(lit)
		start_flickering()
		playsound(src, 'sound/effects/candle_flicker.ogg', 15, 1)
		return TRUE

	return FALSE

/obj/item/candle/eternal/wizard
	desc = "A candle. It smells like magic, so that would explain why it burns brighter."
	start_lit = TRUE

/obj/item/candle/eternal/wizard/attack_self__legacy__attackchain(mob/user)
	return

/obj/item/candle/eternal/wizard/process()
	return

/obj/item/candle/eternal/wizard/light(show_message)
	. = ..()
	if(lit)
		set_light(CANDLE_LUM * 2)


/obj/item/candle/extinguish_light(force)
	if(!force)
		return
	infinite = FALSE
	wax = 1 // next process will burn it out

/obj/item/candle/get_heat()
	return lit * 1000

#undef TALL_CANDLE
#undef MID_CANDLE
#undef SHORT_CANDLE
