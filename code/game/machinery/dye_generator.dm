/obj/machinery/dye_generator
	name = "Dye Generator"
	icon = 'icons/obj/vending.dmi'
	icon_state = "barbervend"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/dye_color = "#FFFFFF"

/obj/machinery/dye_generator/initialize()
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

/obj/machinery/dye_generator/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				stat |= BROKEN
				icon_state = "[initial(icon_state)]-broken"

/obj/machinery/dye_generator/attack_hand(mob/user as mob)
	..()
	src.add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = input(usr, "Choose a dye color", "Dye Color") as color
	dye_color = temp
	set_light(2, l_color = temp)

/obj/machinery/dye_generator/attackby(obj/item/weapon/W, mob/user, params)

	if(default_unfasten_wrench(user, W, time = 60))
		return

	if(istype(W, /obj/item/hair_dye_bottle))
		user.visible_message("<span class='notice'>[user] fills the [W] up with some dye.</span>","<span class='notice'>You fill the [W] up with some hair dye.</span>")
		var/obj/item/hair_dye_bottle/HD = W
		HD.dye_color = dye_color
		HD.update_dye_overlay()
	else
		..()

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
	w_class = 1
	var/dye_color = "#FFFFFF"

/obj/item/hair_dye_bottle/New()
	..()
	update_dye_overlay()

/obj/item/hair_dye_bottle/proc/update_dye_overlay()
	overlays.Cut()
	var/image/I = new('icons/obj/items.dmi', "hairdyebottle-overlay")
	I.color = dye_color
	overlays += I

/obj/item/hair_dye_bottle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != "help")
		..()
		return
	if(!(M in view(1)))
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/dye_list = list("hair")

		if(H.gender == MALE || H.get_species() == "Vulpkanin")
			dye_list += "facial hair"

		if(H && (H.species.bodyflags & HAS_SKIN_COLOR))
			dye_list += "body"

		var/what_to_dye = input(user, "Choose an area to apply the dye","Dye Application") in dye_list

		user.visible_message("<span class='notice'>[user] starts dying [M]'s [what_to_dye]!</span>", "<span class='notice'>You start dying [M]'s [what_to_dye]!</span>")
		if(do_after(user, 50, target = H))
			switch(what_to_dye)
				if("hair")
					var/r_hair = hex2num(copytext(dye_color, 2, 4))
					var/g_hair = hex2num(copytext(dye_color, 4, 6))
					var/b_hair = hex2num(copytext(dye_color, 6, 8))
					if(H.change_hair_color(r_hair, g_hair, b_hair))
						H.update_dna()
				if("facial hair")
					var/r_facial = hex2num(copytext(dye_color, 2, 4))
					var/g_facial = hex2num(copytext(dye_color, 4, 6))
					var/b_facial = hex2num(copytext(dye_color, 6, 8))
					if(H.change_facial_hair_color(r_facial, g_facial, b_facial))
						H.update_dna()
				if("body")
					var/r_skin = hex2num(copytext(dye_color, 2, 4))
					var/g_skin = hex2num(copytext(dye_color, 4, 6))
					var/b_skin = hex2num(copytext(dye_color, 6, 8))
					if(H.change_skin_color(r_skin, g_skin, b_skin))
						H.update_dna()
		user.visible_message("<span class='notice'>[user] finishes dying [M]'s [what_to_dye]!</span>", "<span class='notice'>You finish dying [M]'s [what_to_dye]!</span>")
