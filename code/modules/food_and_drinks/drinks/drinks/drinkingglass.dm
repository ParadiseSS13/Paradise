

/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	item_state = "drinking_glass"
	amount_per_transfer_from_this = 10
	volume = 50
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	materials = list(MAT_GLASS=500)
	burn_state = FLAMMABLE
	burntime = 5

/obj/item/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src] is full.</span>")
			else
				to_chat(user, "<span class='notice'>You break [E] in [src].</span>")
				E.reagents.trans_to(src, E.reagents.total_volume)
				qdel(E)
			return
	else
		..()

/obj/item/reagent_containers/food/drinks/drinkingglass/fire_act()
	if(!reagents.total_volume)
		return
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/burn()
	reagents.clear_reagents()
	extinguish()

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	overlays.Cut()
	if(reagents.reagent_list.len)
		var/datum/reagent/R = reagents.get_master_reagent()
		name = R.drink_name
		desc = R.drink_desc
		if(R.drink_icon)
			icon_state = R.drink_icon
		else
			var/image/I = image(icon, "glassoverlay")
			I.color = mix_color_from_reagents(reagents.reagent_list)
			overlays += I
	else
		icon_state = "glass_empty"
		name = "glass"
		desc = "Your standard drinking glass."

// for /obj/machinery/vending/sovietsoda
/obj/item/reagent_containers/food/drinks/drinkingglass/soda
	list_reagents = list("sodawater" = 50)


/obj/item/reagent_containers/food/drinks/drinkingglass/cola
	list_reagents = list("cola" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/devilskiss
	list_reagents = list("devilskiss" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail
	list_reagents = list("alliescocktail" = 25, "omnizine" = 25)