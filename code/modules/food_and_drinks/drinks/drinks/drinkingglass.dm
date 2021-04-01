
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
	max_integrity = 20
	resistance_flags = ACID_PROOF
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound =  'sound/items/handling/drinkglass_pickup.ogg'

/obj/item/reagent_containers/food/drinks/set_APTFT()
	set hidden = FALSE
	..()

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

/obj/item/reagent_containers/food/drinks/drinkingglass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!reagents.total_volume)
		return
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/burn()
	reagents.clear_reagents()
	extinguish()

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	icon = initial(icon)//regresa a la carpeta original
	overlays.Cut()
	if(reagents.reagent_list.len)
		var/datum/reagent/R = reagents.get_master_reagent()
		name = R.drink_name
		desc = R.drink_desc
		if(R.drink_icon)
			if(R.icon)//si el reactivo tiene una carpeta de icono propia, para hispania solamente
				icon = R.icon//entonces cambiamos la ruta del icon
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
