

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
				to_chat(user, SPAN_NOTICE("[src] is full."))
			else
				to_chat(user, SPAN_NOTICE("You break [egg] in [src]."))
				egg.reagents.trans_to(src, egg.reagents.total_volume)
				qdel(egg)
		return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/drinks/drinkingglass/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!reagents || !reagents.total_volume)
		return ..()
	if(istype(reagents.get_master_reagent(), /datum/reagent/consumable/drink/salt_and_battery) && user.a_intent == INTENT_HARM)
		return CONTINUE_ATTACK
	return ..()

/obj/item/reagent_containers/drinks/drinkingglass/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!reagents || !reagents.total_volume)
		return ..()
	if(istype(reagents.get_master_reagent(), /datum/reagent/consumable/drink/salt_and_battery) && user.a_intent == INTENT_HARM)
		reagents.remove_reagent("salt_and_battery", 10) // this is not an unlimited weapon
	return ..()

/obj/item/reagent_containers/drinks/drinkingglass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!reagents.total_volume)
		return
	..()

/obj/item/reagent_containers/drinks/drinkingglass/burn()
	reagents.clear_reagents()
	extinguish()

/obj/item/reagent_containers/drinks/drinkingglass/on_reagent_change()
	overlays.Cut()
	if(!length(reagents.reagent_list))
		force = initial(force)
		attack_verb = initial(attack_verb)
		icon_state = "glass_empty"
		name = initial(name)
		desc = initial(desc)
		return

	var/datum/reagent/main_reagent = reagents.get_master_reagent()
	name = main_reagent.drink_name
	desc = main_reagent.drink_desc
	force = (istype(main_reagent, /datum/reagent/consumable/drink/salt_and_battery) && reagents.total_volume) ? 10 : initial(force)
	attack_verb = (istype(main_reagent, /datum/reagent/consumable/drink/salt_and_battery) && reagents.total_volume) ? list("assaulted", "battered") : initial(attack_verb)
	if(main_reagent.drink_icon)
		icon_state = main_reagent.drink_icon
		if((main_reagent.id == "bubbletea" || main_reagent.id == "bubblemilktea") && length(reagents.reagent_list) > 1)
			customize_bubble_tea()
	else
		var/image/drink_image = image(icon, "glassoverlay")
		drink_image.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += drink_image

/obj/item/reagent_containers/drinks/drinkingglass/proc/customize_bubble_tea()
	if(length(reagents.reagent_list) < 2)
		return
	var/datum/reagent/main_reagent = reagents.get_master_reagent()
	if(!(main_reagent.id == "bubbletea" || main_reagent.id == "bubblemilktea"))
		return

	var/datum/reagent/coloring_reagent //sub-master reagent, second by volume
	var/max_volume = 0
	for(var/datum/reagent/one_reagent in reagents.reagent_list)
		if(one_reagent.volume > max_volume && one_reagent != main_reagent)
			max_volume = one_reagent.volume
			coloring_reagent = one_reagent

	var/image/drink_overlay = image(icon, (main_reagent.id == "bubbletea" ? "bubbletea_overlay" : "bubblemilktea_overlay"))
	if(main_reagent.id == "bubblemilktea")
		var/milky_color = match_hue("#F7E0C5", coloring_reagent.color)
		if(rgb2num(milky_color, COLORSPACE_HSL)[2] > rgb2num(coloring_reagent.color, COLORSPACE_HSL)[2]) //if the color is less saturated, use that color's saturation. So we don't end up with pink milk and sugar.
			milky_color = match_saturation(milky_color, coloring_reagent.color)
		drink_overlay.color = milky_color
	else
		drink_overlay.color = coloring_reagent.color

	overlays += drink_overlay
	name = istype(coloring_reagent, /datum/reagent/consumable) ? "Glass of [coloring_reagent.name] [main_reagent.name]" : "Glass of Surprise [main_reagent.name]"

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

/obj/item/reagent_containers/drinks/drinkingglass/pina_colada
	list_reagents = list("pinacolada" = 50)

// All the species drinks
/obj/item/reagent_containers/drinks/drinkingglass/acid_dreams
	list_reagents = list("aciddreams" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/ahdomai_eclipse
	list_reagents = list("ahdomaieclipse" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/beach_feast
	list_reagents = list("beachfeast" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/die_seife
	list_reagents = list("dieseife" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/diona_smash
	list_reagents = list("dionasmash" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/fyrsskar_tears
	list_reagents = list("fyrsskartears" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/howler
	list_reagents = list("howler" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/islay_whiskey
	list_reagents = list("islaywhiskey" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/jungle_vox
	list_reagents = list("junglevox" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/slime_mold
	list_reagents = list("slimemold" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/sontse
	list_reagents = list("sontse" = 50)

/obj/item/reagent_containers/drinks/drinkingglass/ultramatter
	list_reagents = list("ultramatter" = 50)
