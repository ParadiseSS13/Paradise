#define POWER_NONE 0
#define POWER_LOW  50
#define POWER_HIGH 4000

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	item_state = "rsf"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	w_class = WEIGHT_CLASS_NORMAL
	var/atom/currently_dispensing
	var/power_mode = POWER_NONE

/obj/item/rsf/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	if(!currently_dispensing)
		to_chat(user, "<span class='notice'>Choose an item to dispense!</span>")
	else
		to_chat(user, "<span class='notice'>You are currently dispensing a [initial(currently_dispensing.name)].</span>")
	var/static/list/rsf_items = list("Drinking Glass" = /obj/item/reagent_containers/food/drinks/drinkingglass,
							"Paper" = /obj/item/paper,
							"Pen" = /obj/item/pen,
							"Dice Pack" = /obj/item/storage/pill_bottle/dice,
							"Cigarette" = /obj/item/clothing/mask/cigarette,
							"Newdles" = /obj/item/reagent_containers/food/snacks/chinese/newdles,
							"Donut" = /obj/item/reagent_containers/food/snacks/donut,
							"Chicken Soup" = /obj/item/reagent_containers/food/drinks/chicken_soup,
							"Tofu Burger" = /obj/item/reagent_containers/food/snacks/burger/tofu)
	var/static/list/rsf_icons = list("Drinking Glass" = image(icon = 'icons/obj/drinks.dmi', icon_state = "glass_empty"),
							"Paper" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper"),
							"Pen" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen"),
							"Dice Pack" = image(icon = 'icons/obj/dice.dmi', icon_state = "dicebag"),
							"Cigarette" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "cigon"),
							"Newdles" = image(icon = 'icons/obj/food/food.dmi', icon_state = "chinese3"),
							"Donut" = image(icon = 'icons/obj/food/food.dmi', icon_state = "donut1"),
							"Chicken Soup" = image(icon = 'icons/obj/drinks.dmi', icon_state = "soupcan"),
							"Tofu Burger" = image(icon = 'icons/obj/food/food.dmi', icon_state = "tofuburger"))
	var/rsf_radial_choice = show_radial_menu(user, src, rsf_icons)
	if(user.stat || !in_range(user, src))
		return
	currently_dispensing = rsf_items[rsf_radial_choice]
	switch(rsf_radial_choice)
		if("Drinking Glass")
			power_mode = POWER_LOW
		if("Paper")
			power_mode = POWER_LOW
		if("Pen")
			power_mode = POWER_LOW
		if("Dice Pack")
			power_mode = POWER_LOW
		if("Cigarette")
			power_mode = POWER_LOW
		if("Newdles")
			power_mode = POWER_HIGH
		if("Donut")
			power_mode = POWER_HIGH
		if("Chicken Soup")
			power_mode = POWER_HIGH
		if("Tofu Burger")
			power_mode = POWER_HIGH
	if(currently_dispensing)
		to_chat(user, "<span class='notice'>Your RSF has been configured to now dispense a [initial(currently_dispensing.name)]!</span>")
	return TRUE


/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	if(!currently_dispensing)
		return
	if(!proximity)
		return
	if(!istype(A, /obj/structure/table) && !isfloorturf(A))
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/energy_check = user
		if(!energy_check.cell.use(power_mode))
			to_chat(user, "<span class='warning'>Insufficient energy.</span>")
			flick("[icon_state]_empty", src)
			return
	var/turf/T = get_turf(A)
	if(!istype(T) || T.density)
		to_chat(user, "The RSF can only create service items on tables, or floors.")
		return
	playsound(loc, 'sound/machines/click.ogg', 10, 1)
	new currently_dispensing(T)

#undef POWER_NONE
#undef POWER_LOW
#undef POWER_HIGH
