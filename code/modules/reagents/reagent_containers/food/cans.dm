/obj/item/weapon/reagent_containers/food/drinks/cans
	var/canopened = 0
	var/is_glass = 0
	var/is_plastic = 0

/obj/item/weapon/reagent_containers/food/drinks/cans/New()
	..()
	flags &= ~OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/cans/attack_self(mob/user as mob)
	if(canopened == 0)
		playsound(src.loc,'sound/effects/canopen.ogg', rand(10,50), 1)
		to_chat(user, "<span class='notice'>You open the drink with an audible pop!</span>")
		canopened = 1
		flags |= OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/cans/proc/crush(mob/user)
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
	crushed_can.icon_state = icon_state
	//inherit material vars for recycling purposes
	crushed_can.is_glass = is_glass
	crushed_can.is_plastic = is_plastic
	if(is_glass)
		playsound(user.loc, 'sound/effects/Glassbr3.ogg', rand(10, 50), 1)
		crushed_can.name = "broken bottle"
	else
		playsound(user.loc, 'sound/weapons/pierce.ogg', rand(10, 50), 1)
	qdel(src)
	return crushed_can

/obj/item/weapon/reagent_containers/food/drinks/cans/attack(mob/M as mob, mob/user as mob, proximity)
	if(canopened == 0)
		to_chat(user, "<span class='notice'>You need to open the drink!</span>")
		return
	else if(M == user && !src.reagents.total_volume && user.a_intent == "harm" && user.zone_sel.selecting == "head")
		user.visible_message("<span class='warning'>[user] crushes ["\the [src]"] on \his forehead!</span>", "<span class='notice'>You crush \the [src] on your forehead.</span>")
		crush(user)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/drinks/cans/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage/bag/trash/cyborg))
		user.visible_message("<span class='notice'>[user] crushes \the [src] in their trash compactor.</span>", "<span class='notice'>You crush \the [src] in your trash compactor.</span>")
		var/obj/can = crush(user)
		can.attackby(I, user, params)
		return 1
	..()

/obj/item/weapon/reagent_containers/food/drinks/cans/afterattack(obj/target, mob/user, proximity)
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

/*	examine(mob/user)
		if(!..(user, 1))
			return
		if(!reagents || reagents.total_volume==0)
			to_chat(user, "\blue \The [src] is empty!")
		else if(reagents.total_volume<=src.volume/4)
			to_chat(user, "\blue \The [src] is almost empty!")
		else if(reagents.total_volume<=src.volume*0.66)
			to_chat(user, "\blue \The [src] is half full!")
		else if(reagents.total_volume<=src.volume*0.90)
			to_chat(user, "\blue \The [src] is almost full!")
		else
			to_chat(user, "\blue \The [src] is full!")*/


//DRINKS

/obj/item/weapon/reagent_containers/food/drinks/cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	New()
		..()
		reagents.add_reagent("cola", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle
	name = "Bottled Water"
	desc = "Introduced to the vending machines by Skrellian request, this water comes straight from the Martian poles."
	icon_state = "waterbottle"
	is_plastic = 1
	New()
		..()
		reagents.add_reagent("water", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/beer
	name = "Space Beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"
	is_glass = 1
	New()
		..()
		reagents.add_reagent("beer", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/adminbooze
	name = "Admin Booze"
	desc = "Bottled Griffon tears. Drink with caution."
	icon_state = "adminbooze"
	is_glass = 1
	New()
		..()
		reagents.add_reagent("adminordrazine", 5)
		reagents.add_reagent("capsaicin", 5)
		reagents.add_reagent("methamphetamine", 20)
		reagents.add_reagent("thirteenloko", 20)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/madminmalt
	name = "Madmin Malt"
	desc = "Bottled essence of angry admins. Drink with <i>EXTREME</i> caution."
	icon_state = "madminmalt"
	is_glass = 1
	New()
		..()
		reagents.add_reagent("hell_water", 20)
		reagents.add_reagent("neurotoxin", 15)
		reagents.add_reagent("thirteenloko", 15)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/badminbrew
	name = "Badmin Brew"
	desc = "Bottled trickery and terrible admin work. Probably shouldn't drink this one at all."
	icon_state = "badminbrew"
	is_glass = 1
	New()
		..()
		reagents.add_reagent("mutagen", 25)
		reagents.add_reagent("charcoal", 10)
		reagents.add_reagent("thirteenloko", 15)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	item_state = "beer"
	is_glass = 1
	New()
		..()
		reagents.add_reagent("ale", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)


/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	New()
		..()
		reagents.add_reagent("spacemountainwind", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	New()
		..()
		reagents.add_reagent("thirteenloko", 25)
		reagents.add_reagent("psilocybin", 5)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	New()
		..()
		reagents.add_reagent("dr_gibb", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	New()
		..()
		reagents.add_reagent("brownstar", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	New()
		..()
		reagents.add_reagent("space_up", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	New()
		..()
		reagents.add_reagent("lemon_lime", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "That sweet, refreshing southern earthy flavor. That's where it's from, right? South Earth?"
	icon_state = "ice_tea_can"
	New()
		..()
		reagents.add_reagent("icetea", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice
	name = "Grapel Juice"
	desc = "500 pages of rules of how to appropriately enter into a combat with this juice!"
	icon_state = "purple_can"
	New()
		..()
		reagents.add_reagent("grapejuice", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	New()
		..()
		reagents.add_reagent("tonic", 50)

/obj/item/weapon/reagent_containers/food/drinks/cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Still water's more refreshing cousin."
	icon_state = "sodawater"
	New()
		..()
		reagents.add_reagent("sodawater", 50)

/obj/item/weapon/reagent_containers/food/drinks/cans/synthanol
	name = "Beep's Classic Synthanol"
	desc = "A can of IPC booze, however that works."
	icon_state = "synthanolcan"
	New()
		..()
		reagents.add_reagent("synthanol", 50)

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler
	name = "generic beverage container"
	desc = "this shouldn't ever be spawned. shame on you"
	icon_state = "glass_bottle"

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/update_icon()
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

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/glass_bottle
	name = "glass bottle"
	desc = "A glass bottle suitable for beverages."
	icon_state = "glass_bottle"
	is_glass = 1
/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/plastic_bottle
	name = "plastic bottle"
	desc = "A plastic bottle suitable for beverages."
	icon_state = "plastic_bottle"
	is_plastic = 1

/obj/item/weapon/reagent_containers/food/drinks/cans/bottler/metal_can
	name = "metal can"
	desc = "A metal can suitable for beverages."
	icon_state = "metal_can"
