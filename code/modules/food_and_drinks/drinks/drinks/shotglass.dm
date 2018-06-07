/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "No glasses were shot in the making of this glass."
	icon_state = "shotglass"
	amount_per_transfer_from_this = 15
	volume = 15
	materials = list(MAT_GLASS=100)
	var/light_intensity = 2
	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	if(!isShotFlammable() && burn_state == ON_FIRE)
		extinguish()
	update_icon()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/update_icon()
	overlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 25)
				filling.icon_state = "[icon_state]1"
			if(26 to 79)
				filling.icon_state = "[icon_state]5"
			if(80 to INFINITY)
				filling.icon_state = "[icon_state]12"
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		name = "shot glass of " + reagents.get_master_reagent_name() //No matter what, the glass will tell you the reagent's name. Might be too abusable in the future.
		if(burn_state == ON_FIRE)
			overlays += "shotglass_fire"
			name = "flaming [name]"
	else
		name = "shot glass"

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/proc/clumsilyDrink(mob/living/carbon/human/user) //Clowns beware
	if(burn_state != ON_FIRE)
		return
	user.visible_message("<span class = 'warning'>[user] pours [src] all over [user.p_them()]self!</span>", "<span class = 'danger'>You pour [src] all over yourself!</span>", "<span class = 'warning'>You hear a 'whoompf' and a sizzle.</span>")
	extinguish(TRUE)
	reagents.reaction(user, TOUCH)
	reagents.clear_reagents()
	user.IgniteMob()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/proc/isShotFlammable()
	var/datum/reagent/R = reagents.get_master_reagent()
	if(istype(R, /datum/reagent/consumable/ethanol))
		var/datum/reagent/consumable/ethanol/A = R
		if(A.volume >= 5 && A.alcohol_perc >= 0.35) //Only an approximation to if something's flammable but it will do
			return TRUE

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/fire_act(global_overlay = FALSE)
	if(!isShotFlammable() || burn_state == ON_FIRE) //You can't light a shot that's not flammable!
		return
	..()
	set_light(light_intensity, null, light_color)
	visible_message("<span class = 'notice'>[src] begins to burn with a blue hue!</span>")
	update_icon()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/extinguish(silent = FALSE)
	..()
	set_light(0)
	if(!silent)
		visible_message("<span class = 'notice'>The dancing flame on [src] dies out.</span>")
	update_icon()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/burn() //Let's override fire deleting the reagents inside the shot
	return

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack(mob/living/carbon/human/user)
	if((CLUMSY in user.mutations) && prob(50) && burn_state == ON_FIRE)
		clumsilyDrink(user)
	else
		..()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attackby(obj/item/W)
	..()
	if(is_hot(W))
		fire_act()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack_hand(mob/user, pickupfireoverride = TRUE)
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack_self(mob/living/carbon/human/user)
	..()
	if(burn_state != ON_FIRE)
		return
	if((CLUMSY in user.mutations) && prob(50))
		clumsilyDrink(user)
	else
		user.visible_message("<span class = 'notice'>[user] places [user.p_their()] hand over [src] to put it out!</span>", "<span class = 'notice'>You use your hand to extinguish [src]!</span>")
		extinguish()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/MouseDrop(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if((CLUMSY in user.mutations) && prob(50) && burn_state == ON_FIRE)
		clumsilyDrink(user)
	else
		..()
