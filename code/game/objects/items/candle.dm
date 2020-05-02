/obj/item/candle
	name = "red candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to humankind. The jewelry he kept for himself."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = WEIGHT_CLASS_TINY
	var/wax = 200
	var/lit = 0
	var/infinite = 0
	var/start_lit = 0
	light_color = "#E09D37"

/obj/item/candle/New()
	..()
	if(start_lit)
		// No visible message
		light(show_message = 0)

/obj/item/candle/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/candle/update_icon()
	var/i
	if(wax>150)
		i = 1
	else if(wax>80)
		i = 2
	else i = 3
	icon_state = "candle[i][lit ? "_lit" : ""]"


/obj/item/candle/attackby(obj/item/W, mob/user, params)
	if(is_hot(W))
		light("<span class='notice'>[user] lights [src] with [W].</span>")
		return
	return ..()

/obj/item/candle/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(I.tool_use_check(user, 0)) //Don't need to flash eyes because you are a badass
		light("<span class='notice'>[user] casually lights the [name] with [I], what a badass.</span>")

/obj/item/candle/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!lit)
		light() //honk
	return ..()

/obj/item/candle/proc/light(show_message)
	if(!lit)
		lit = 1
		if(show_message)
			usr.visible_message(show_message)
		set_light(CANDLE_LUM)
		START_PROCESSING(SSobj, src)
		update_icon()


/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
	if(!wax)
		new/obj/item/trash/candle(src.loc)
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			M.unEquip(src, 1) //src is being deleted anyway
		qdel(src)
	update_icon()
	if(isturf(loc)) //start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)


/obj/item/candle/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] snuffs out [src].</span>")
		lit = 0
		update_icon()
		set_light(0)

/obj/item/candle/eternal
	desc = "A candle. This one seems to have an odd quality about the wax."
	infinite = 1
