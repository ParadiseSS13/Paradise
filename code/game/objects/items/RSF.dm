#define POWER_NONE 0
#define POWER_LOW  50
#define POWER_HIGH 4000

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	new_attack_chain = TRUE
	var/atom/currently_dispensing
	var/power_mode = POWER_NONE

	var/list/rsf_items = list(
							"Drinking Glass" = /obj/item/reagent_containers/drinks/drinkingglass,
							"Paper" = /obj/item/paper,
							"Pen" = /obj/item/pen,
							"Dice Pack" = /obj/item/storage/bag/dice,
							"Cigarette" = /obj/item/clothing/mask/cigarette,
							"Newdles" = /obj/item/food/chinese/newdles,
							"Donut" = /obj/item/food/donut,
							"Chicken Soup" = /obj/item/reagent_containers/drinks/chicken_soup,
							"Tofu Burger" = /obj/item/food/burger/tofu
							)

	var/static/list/rsf_icons = list(
							"Drinking Glass" = image(icon = 'icons/obj/drinks.dmi', icon_state = "glass_empty"),
							"Shot Glass" = image(icon = 'icons/obj/drinks.dmi', icon_state = "shotglass"),
							"Paper" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper"),
							"Pen" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen"),
							"Dice Pack" = image(icon = 'icons/obj/dice.dmi', icon_state = "dicebag"),
							"Cigarette" = image(icon = 'icons/obj/clothing/smoking.dmi', icon_state = "cig_on"),
							"Newdles" = image(icon = 'icons/obj/food/food.dmi', icon_state = "chinese3"),
							"Donut" = image(icon = 'icons/obj/food/bakedgoods.dmi', icon_state = "donut1"),
							"Chicken Soup" = image(icon = 'icons/obj/drinks.dmi', icon_state = "soupcan"),
							"Tofu Burger" = image(icon = 'icons/obj/food/burgerbread.dmi', icon_state = "tofuburger"),
							"Cigar" = image(icon = 'icons/obj/clothing/smoking.dmi', icon_state = "cigar"),
							"Smoked Cheese" = image(icon = 'icons/obj/food/food.dmi', icon_state = "cheesewheel-smoked"),
							"Edam Cheese" = image(icon = 'icons/obj/food/food.dmi', icon_state = "cheesewheel-edam"),
							"Blue Cheese" = image(icon = 'icons/obj/food/food.dmi', icon_state = "cheesewheel-blue"),
							"Camembert Cheese" = image(icon = 'icons/obj/food/food.dmi', icon_state = "cheesewheel-camembert"),
							"Caviar" = image(icon = 'icons/obj/food/seafood.dmi', icon_state = "caviar")
							)

	var/static/list/power_costs = list(
							"Drinking Glass" = POWER_LOW,
							"Shot Glass" = POWER_LOW,
							"Paper" = POWER_LOW,
							"Pen" = POWER_LOW,
							"Dice Pack" = POWER_LOW,
							"Cigarette" = POWER_LOW,
							"Newdles" = POWER_HIGH,
							"Donut" = POWER_HIGH,
							"Chicken Soup" = POWER_HIGH,
							"Tofu Burger" = POWER_HIGH,
							"Cigar" = POWER_LOW,
							"Smoked Cheese" = POWER_HIGH,
							"Edam Cheese" = POWER_HIGH,
							"Blue Cheese" = POWER_HIGH,
							"Camembert Cheese" = POWER_HIGH,
							"Caviar" = POWER_HIGH
							)

/obj/item/rsf/activate_self(mob/user)
	if(..())
		return

	playsound(loc, 'sound/effects/pop.ogg', 50, FALSE)
	if(!currently_dispensing)
		to_chat(user, "<span class='notice'>Choose an item to dispense!</span>")
	else
		to_chat(user, "<span class='notice'>You are currently dispensing a [initial(currently_dispensing.name)].</span>")

	var/rsf_radial_choice = show_radial_menu(user, src, get_radial_contents())
	if(user.stat || !in_range(user, src))
		return ITEM_INTERACT_COMPLETE

	currently_dispensing = rsf_items[rsf_radial_choice]
	power_mode = power_costs[rsf_radial_choice]
	if(currently_dispensing)
		to_chat(user, "<span class='notice'>Your RSF has been configured to now dispense a [initial(currently_dispensing.name)]!</span>")
	return ITEM_INTERACT_COMPLETE

/obj/item/rsf/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!currently_dispensing)
		return ITEM_INTERACT_COMPLETE

	if(!istype(target, /obj/structure/table) && !isfloorturf(target))
		to_chat(user, "<span class='warning'>The RSF can only create service items on tables or floors!</span>")
		return ITEM_INTERACT_COMPLETE

	if(isrobot(user))
		var/mob/living/silicon/robot/energy_check = user
		if(!energy_check.cell.use(power_mode))
			to_chat(user, "<span class='warning'>Insufficient energy.</span>")
			flick("[icon_state]_empty", src)
			return ITEM_INTERACT_COMPLETE

	var/turf/T = get_turf(target)
	new currently_dispensing(T)
	playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
	return ITEM_INTERACT_COMPLETE

/obj/item/rsf/proc/get_radial_contents()
	return rsf_icons & rsf_items

/obj/item/rsf/executive
	name = "\improper Executive-Service-Fabricator"
	desc = "A fancier version of the RSF, used to deploy classy refreshments and materials to high ranking clientelle."
	icon_state = "rsf-exec"

	rsf_items = list(
							"Drinking Glass" = /obj/item/reagent_containers/drinks/drinkingglass,
							"Shot Glass" = /obj/item/reagent_containers/drinks/drinkingglass/shotglass,
							"Paper" = /obj/item/paper,
							"Pen" = /obj/item/pen,
							"Dice Pack" = /obj/item/storage/bag/dice,
							"Cigar" = /obj/item/clothing/mask/cigarette/cigar,
							"Cigarette" = /obj/item/clothing/mask/cigarette,
							"Smoked Cheese" = /obj/item/food/sliceable/cheesewheel/smoked,
							"Edam Cheese" = /obj/item/food/sliceable/cheesewheel/edam,
							"Blue Cheese" = /obj/item/food/sliceable/cheesewheel/blue,
							"Camembert Cheese" = /obj/item/food/sliceable/cheesewheel/camembert,
							"Caviar" = /obj/item/food/caviar,
							"Donut" = /obj/item/food/donut
							)

#undef POWER_NONE
#undef POWER_LOW
#undef POWER_HIGH
