/obj/machinery/dye_generator
	name = "Dye Generator"
	icon = 'icons/obj/vending.dmi'
	icon_state = "barbervend"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/dye_color = "#FFFFFF"

/obj/machinery/dye_generator/Initialize()
	..()
	power_change()

/obj/machinery/dye_generator/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		set_light(0)
	else
		if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			set_light(2, l_color = dye_color)
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER
				set_light(0)

/obj/machinery/dye_generator/attack_hand(mob/user)
	..()
	src.add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = input(usr, "Choose a dye color", "Dye Color") as color
	dye_color = temp
	set_light(2, l_color = temp)

/obj/machinery/dye_generator/attackby(obj/item/I, mob/user, params)

	if(default_unfasten_wrench(user, I, time = 60))
		return

	if(istype(I, /obj/item/hair_dye_bottle))
		var/obj/item/hair_dye_bottle/HD = I
		user.visible_message("<span class='notice'>[user] fills the [HD] up with some dye.</span>","<span class='notice'>You fill the [HD] up with some hair dye.</span>")
		HD.dye_color = dye_color
		HD.update_dye_overlay()
		return
	return ..()

//Hair Dye Bottle

/obj/item/hair_dye_bottle
	name = "Hair Dye Bottle"
	desc = "A refillable bottle used for holding hair dyes of all sorts of colors."
	icon = 'icons/obj/items.dmi'
	icon_state = "hairdyebottle"
	throwforce = 0
	throw_speed = 4
	throw_range = 7
	force = 0
	w_class = WEIGHT_CLASS_TINY
	var/dye_color = "#FFFFFF"

/obj/item/hair_dye_bottle/New()
	..()
	update_dye_overlay()

/obj/item/hair_dye_bottle/proc/update_dye_overlay()
	overlays.Cut()
	var/image/I = new('icons/obj/items.dmi', "hairdyebottle-overlay")
	I.color = dye_color
	overlays += I

/obj/item/hair_dye_bottle/attack(mob/living/carbon/M, mob/user)
	if(user.a_intent != INTENT_HELP)
		..()
		return
	if(!(M in view(1)))
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/dye_list = list("hair", "alt. hair theme")

		if(H.gender == MALE || isvulpkanin(H))
			dye_list += "facial hair"
			dye_list += "alt. facial hair theme"

		if(H && (H.dna.species.bodyflags & HAS_SKIN_COLOR))
			dye_list += "body"

		var/what_to_dye = input(user, "Choose an area to apply the dye", "Dye Application") in dye_list
		if(!user.Adjacent(M))
			to_chat(user, "You are too far away!")
			return
		user.visible_message("<span class='notice'>[user] starts dying [M]'s [what_to_dye]!</span>", "<span class='notice'>You start dying [M]'s [what_to_dye]!</span>")
		if(do_after(user, 50, target = H))
			switch(what_to_dye)
				if("hair")
					H.change_hair_color(dye_color)
				if("alt. hair theme")
					H.change_hair_color(dye_color, 1)
				if("facial hair")
					H.change_facial_hair_color(dye_color)
				if("alt. facial hair theme")
					H.change_facial_hair_color(dye_color, 1)
				if("body")
					H.change_skin_color(dye_color)
			H.update_dna()
		user.visible_message("<span class='notice'>[user] finishes dying [M]'s [what_to_dye]!</span>", "<span class='notice'>You finish dying [M]'s [what_to_dye]!</span>")
