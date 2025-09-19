

/obj/item/reagent_containers/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	inhand_icon_state = "drinking_glass"
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	amount_per_transfer_from_this = 10
	materials = list(MAT_GLASS = 100)
	max_integrity = 20
	resistance_flags = ACID_PROOF
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound =  'sound/items/handling/drinkglass_pickup.ogg'

/obj/item/reagent_containers/drinks/drinkingglass/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food/egg)) //breaking eggs
		var/obj/item/food/egg/egg = used
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[src] is full.</span>")
			else
				to_chat(user, "<span class='notice'>You break [egg] in [src].</span>")
				egg.reagents.trans_to(src, egg.reagents.total_volume)
				qdel(egg)
		return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/drinks/drinkingglass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!reagents.total_volume)
		return
	..()

/obj/item/reagent_containers/drinks/drinkingglass/burn()
	reagents.clear_reagents()
	extinguish()

/obj/item/reagent_containers/drinks/drinkingglass/on_reagent_change()
	overlays.Cut()
	if(length(reagents.reagent_list))
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
		name = initial(name)
		desc = initial(desc)

// for /obj/machinery/economy/vending/sovietsoda
/obj/item/reagent_containers/drinks/drinkingglass/soda
	list_reagents = list("sodawater" = 50)


/obj/item/reagent_containers/drinks/drinkingglass/cola
	list_reagents = list("cola" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/devilskiss
	list_reagents = list("devilskiss" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/alliescocktail
	list_reagents = list("alliescocktail" = 25, "omnizine" = 25)

/obj/item/reagent_containers/drinks/drinkingglass/syndicate_bomb
	list_reagents = list("syndicatebomb" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/jungle_vox
	list_reagents = list("junglevox" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/pina_colada
	list_reagents = list("pinacolada" = 50)
