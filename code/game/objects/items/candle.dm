/obj/item/candle
	name = "red candle"
	desc = "a candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1

	light_color = "#E09D37"

	var/wax = 200
	var/lit = 0
	proc
		light(var/flavor_text = "\red [usr] lights the [name].")


	update_icon()
		var/i
		if(wax>150)
			i = 1
		else if(wax>80)
			i = 2
		else i = 3
		icon_state = "candle[i][lit ? "_lit" : ""]"


	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		..()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
				light("\red [user] casually lights the [name] with [W], what a badass.")
		else if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.lit)
				light()
		else if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.lit)
				light()
		else if(istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			if(C.lit)
				light()


	light(var/flavor_text = "\red [usr] lights the [name].")
		if(!src.lit)
			src.lit = 1
			//src.damtype = "fire"
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			set_light(CANDLE_LUM)
			processing_objects.Add(src)


	process()
		if(!lit)
			return
		wax--
		if(!wax)
			new/obj/item/trash/candle(src.loc)
			if(istype(src.loc, /mob))
				var/mob/M = src.loc
				M.unEquip(src, 1) //src is being deleted anyway
			qdel(src)
		update_icon()
		if(istype(loc, /turf)) //start a fire if possible
			var/turf/T = loc
			T.hotspot_expose(700, 5)


	attack_self(mob/user as mob)
		if(lit)
			lit = 0
			update_icon()
			set_light(0)

/obj/item/candle/eternal
	desc = "A candle. This one seems to have an odd quality about the wax."
	wax = 10000