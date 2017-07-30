#define SHOT_FLAME_TEMPERATURE	700

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "No glasses were shot in the making of this glass."
	icon_state = "shotglass"
	amount_per_transfer_from_this = 15
	volume = 15
	var/on_fire
	materials = list(MAT_GLASS=100)
	var/light_intensity = 2
	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	handleFlaming()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/update_icon()
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
		if(on_fire)
			overlays += "shotglass_fire"
			name = "flaming [name]"
	else
		name = "shot glass"

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/attackby(obj/item/W, mob/living/carbon/human/user)
	..()
	handleFlaming(W, user)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/proc/handleFlaming(obj/item/W, mob/living/carbon/human/user)
	if(!reagents && on_fire) //If no reagents exist inside the shot, it will obviously not sustain a burn
		extinguishShot()
	else if(!canBeFlaming() && on_fire) //If it's on fire, but can't sustain the flame, put it out
		extinguishShot()
	else if(canBeFlaming() && !on_fire && is_hot(W) > 300) //if it can burn yet not on fire, and is attacked by something hot, set it alight
		user.visible_message("<span class = 'warning'>[user] sets [src] alight!</span>", "<span class = 'notice'>You set [src] alight!</span>", "<span class = 'warning'>You hear a gentle crackling.</span>")
		lightShot()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/proc/canBeFlaming()
	var/datum/reagent/R = reagents.get_master_reagent()
	if(istype(R, /datum/reagent/consumable/ethanol))
		var/datum/reagent/consumable/ethanol/A = R
		if(A.volume >= 5 && A.alcohol_perc >= 0.35) //Only an approximation to if something's flammable but it will do
			return TRUE

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/proc/lightShot(var/silent)
	on_fire = TRUE
	processing_objects.Add(src) //So it can do stuff like set plasma clouds on fire
	set_light(light_intensity, null, light_color)
	if(!silent)
		visible_message("<span class = 'notice'>[src] begins to burn with a blue hue!</span>")
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/proc/extinguishShot(var/silent)
	on_fire = FALSE
	processing_objects.Remove(src)
	set_light(0)
	if(!silent)
		visible_message("<span class = 'notice'>The dancing flame on [src] dies out.</span>")
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/proc/clumsilyDrink(mob/living/carbon/human/user) //Clowns beware
	if(!on_fire)
		return
	user.visible_message("<span class = 'warning'>[user] pours [src] all over themself!</span>", "<span class = 'danger'>You pour [src] all over yourself!</span>", "<span class = 'warning'>You hear a 'whoompf' and a sizzle.</span>")
	reagents.reaction(user, TOUCH)
	reagents.clear_reagents()
	user.adjust_fire_stacks(reagents.total_volume/10)
	user.IgniteMob()
	extinguishShot(TRUE)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/process()
	if(on_fire)
		reagents.chem_temp = min(reagents.chem_temp + 10, SHOT_FLAME_TEMPERATURE)
		reagents.handle_reactions()
		var/turf/L = get_turf(src)
		if(L)
			L.hotspot_expose(SHOT_FLAME_TEMPERATURE, 5)
		return
	else
		processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/attack_self(mob/living/carbon/human/user)
	..()
	if(!on_fire)
		return
	if((CLUMSY in user.mutations) && prob(50))
		clumsilyDrink(user)
	else
		user.visible_message("<span class = 'notice'>[user] places their hand over [src] to put it out!</span>", "<span class = 'notice'>You use your hand to extinguish [src]!</span>")
		extinguishShot()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/attack(mob/living/carbon/human/user)
	if((CLUMSY in user.mutations) && prob(50) && on_fire)
		clumsilyDrink(user)
	else
		..()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass/MouseDrop(mob/living/carbon/human/user)
	if((CLUMSY in user.mutations) && prob(50) && on_fire)
		clumsilyDrink(user)
	else
		..()
