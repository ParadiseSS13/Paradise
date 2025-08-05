/obj/machinery/dye_generator
	name = "Dye Generator"
	icon = 'icons/obj/vending.dmi'
	icon_state = "barbervend"
	density = TRUE
	anchored = TRUE
	integrity_failure = 100
	idle_power_consumption = 40
	var/dye_color = "#FFFFFF"

/obj/machinery/dye_generator/Initialize(mapload)
	. = ..()
	power_change()

/obj/machinery/dye_generator/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc, 3)
	qdel(src)

/obj/machinery/dye_generator/power_change()
	if(has_power() && anchored)
		stat &= ~NOPOWER
		set_light(2, l_color = dye_color)
	else
		stat |= NOPOWER
		set_light(0)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/dye_generator/extinguish_light(force = FALSE)
	set_light(0)
	underlays.Cut()

/obj/machinery/dye_generator/update_overlays()
	. = ..()
	underlays.Cut()
	if(stat & (BROKEN|NOPOWER))
		. += "barbervend_off"
		if(stat & BROKEN)
			. += "barbervend_broken"
	if(light)
		underlays += emissive_appearance(icon, "barbervend_lightmask")

/obj/machinery/dye_generator/attack_hand(mob/user)
	..()
	src.add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = tgui_input_color(user, "Please select a dye color", "Dye Color")
	if(isnull(temp))
		return
	dye_color = temp
	set_light(2, l_color = temp)

/obj/machinery/dye_generator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_unfasten_wrench(user, used, time = 60))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/hair_dye_bottle))
		var/obj/item/hair_dye_bottle/HD = used
		user.visible_message("<span class='notice'>[user] fills [HD] up with some dye.</span>","<span class='notice'>You fill [HD] up with some hair dye.</span>")
		HD.dye_color = dye_color
		HD.update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/dye_generator/obj_break(damage_flag)
	if(!(stat & BROKEN))
		stat |= BROKEN
		update_icon(UPDATE_OVERLAYS)

//Hair Dye Bottle

/obj/item/hair_dye_bottle
	name = "hair dye bottle"
	desc = "A refillable bottle used for holding hair dyes of all sorts of colors."
	icon_state = "hairdyebottle"
	throw_speed = 4
	w_class = WEIGHT_CLASS_TINY
	var/dye_color = "#FFFFFF"

/obj/item/hair_dye_bottle/New()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/hair_dye_bottle/update_overlays()
	. = ..()
	var/image/I = new('icons/obj/items.dmi', "hairdyebottle-overlay")
	I.color = dye_color
	. += I

/obj/item/hair_dye_bottle/attack__legacy__attackchain(mob/living/carbon/M, mob/user)
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
