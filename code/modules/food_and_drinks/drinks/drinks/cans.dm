/obj/item/reagent_containers/food/drinks/cans
	var/canopened = 0
	var/is_glass = 0
	var/is_plastic = 0

/obj/item/reagent_containers/food/drinks/cans/New()
	..()
	flags &= ~OPENCONTAINER

/obj/item/reagent_containers/food/drinks/cans/attack_self(mob/user)
	if(canopened == 0)
		playsound(loc,'sound/effects/canopen.ogg', rand(10,50), 1)
		to_chat(user, "<span class='notice'>You open the drink with an audible pop!</span>")
		canopened = 1
		flags |= OPENCONTAINER

/obj/item/reagent_containers/food/drinks/cans/proc/crush(mob/user)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
	crushed_can.icon_state = icon_state
	//inherit material vars for recycling purposes
	crushed_can.is_glass = is_glass
	crushed_can.is_plastic = is_plastic
	if(is_glass)
		playsound(user.loc, 'sound/effects/glassbr3.ogg', rand(10, 50), 1)
		crushed_can.name = "broken bottle"
	else
		playsound(user.loc, 'sound/weapons/pierce.ogg', rand(10, 50), 1)
	qdel(src)
	return crushed_can

/obj/item/reagent_containers/food/drinks/cans/attack(mob/M, mob/user, proximity)
	if(canopened == 0)
		to_chat(user, "<span class='notice'>You need to open the drink!</span>")
		return
	else if(M == user && !reagents.total_volume && user.a_intent == INTENT_HARM && user.zone_sel.selecting == "head")
		user.visible_message("<span class='warning'>[user] crushes [src] on [user.p_their()] forehead!</span>", "<span class='notice'>You crush [src] on your forehead.</span>")
		crush(user)
		return
	return ..()

/obj/item/reagent_containers/food/drinks/cans/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash/cyborg))
		user.visible_message("<span class='notice'>[user] crushes [src] in [user.p_their()] trash compactor.</span>", "<span class='notice'>You crush [src] in your trash compactor.</span>")
		var/obj/can = crush(user)
		can.attackby(I, user, params)
		return 1
	..()

/obj/item/reagent_containers/food/drinks/cans/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers) && (canopened == 0))
		to_chat(user, "<span class='notice'>You need to open the drink!</span>")
		return
	else if(target.is_open_container() && (canopened == 0))
		to_chat(user, "<span class='notice'>You need to open the drink!</span>")
		return
	else
		return ..(target, user, proximity)

/obj/item/reagent_containers/food/drinks/cans/cola
	name = "space cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list("cola" = 30)

/obj/item/reagent_containers/food/drinks/cans/beer
	name = "space beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	is_glass = 1
	list_reagents = list("beer" = 30)

/obj/item/reagent_containers/food/drinks/cans/adminbooze
	name = "admin booze"
	desc = "Bottled Griffon tears. Drink with caution."
	icon_state = "adminbooze"
	is_glass = 1
	list_reagents = list("adminordrazine" = 5, "capsaicin" = 5, "methamphetamine"= 20, "thirteenloko" = 20)

/obj/item/reagent_containers/food/drinks/cans/madminmalt
	name = "madmin malt"
	desc = "Bottled essence of angry admins. Drink with <i>EXTREME</i> caution."
	icon_state = "madminmalt"
	is_glass = 1
	list_reagents = list("hell_water" = 20, "neurotoxin" = 15, "thirteenloko" = 15)

/obj/item/reagent_containers/food/drinks/cans/badminbrew
	name = "badmin brew"
	desc = "Bottled trickery and terrible admin work. Probably shouldn't drink this one at all."
	icon_state = "badminbrew"
	is_glass = 1
	list_reagents = list("mutagen" = 25, "charcoal" = 10, "thirteenloko" = 15)

/obj/item/reagent_containers/food/drinks/cans/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	is_glass = 1
	list_reagents = list("ale" = 30)

/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)

/obj/item/reagent_containers/food/drinks/cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 25, "psilocybin" = 5)

/obj/item/reagent_containers/food/drinks/cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)


/obj/item/reagent_containers/food/drinks/cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list("brownstar" = 30)

/obj/item/reagent_containers/food/drinks/cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)

/obj/item/reagent_containers/food/drinks/cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)

/obj/item/reagent_containers/food/drinks/cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "That sweet, refreshing southern earthy flavor. That's where it's from, right? South Earth?"
	icon_state = "ice_tea_can"
	list_reagents = list("icetea" = 30)

/obj/item/reagent_containers/food/drinks/cans/grape_juice
	name = "Grapel Juice"
	desc = "500 pages of rules of how to appropriately enter into a combat with this juice!"
	icon_state = "purple_can"
	list_reagents = list("grapejuice" = 30)

/obj/item/reagent_containers/food/drinks/cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)

/obj/item/reagent_containers/food/drinks/cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Still water's more refreshing cousin."
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)

/obj/item/reagent_containers/food/drinks/cans/synthanol
	name = "Beep's Classic Synthanol"
	desc = "A can of IPC booze, however that works."
	icon_state = "synthanolcan"
	list_reagents = list("synthanol" = 50)

/obj/item/reagent_containers/food/drinks/cans/bottler
	name = "generic beverage container"
	desc = "this shouldn't ever be spawned. shame on you"
	icon_state = "glass_bottle"

/obj/item/reagent_containers/food/drinks/cans/bottler/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/food/drinks/cans/bottler/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		switch(round(reagents.total_volume))
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 19)
				filling.icon_state = "[icon_state]10"
			if(20 to 29)
				filling.icon_state = "[icon_state]20"
			if(30 to 39)
				filling.icon_state = "[icon_state]30"
			if(40 to 49)
				filling.icon_state = "[icon_state]40"
			if(50 to INFINITY)
				filling.icon_state = "[icon_state]50"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/reagent_containers/food/drinks/cans/bottler/glass_bottle
	name = "glass bottle"
	desc = "A glass bottle suitable for beverages."
	icon_state = "glass_bottle"
	is_glass = 1

/obj/item/reagent_containers/food/drinks/cans/bottler/plastic_bottle
	name = "plastic bottle"
	desc = "A plastic bottle suitable for beverages."
	icon_state = "plastic_bottle"
	is_plastic = 1

/obj/item/reagent_containers/food/drinks/cans/bottler/metal_can
	name = "metal can"
	desc = "A metal can suitable for beverages."
	icon_state = "metal_can"
