
//Not to be confused with /obj/item/weapon/reagent_containers/food/drinks/bottle

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	flags = OPENCONTAINER
	volume = 30

	New()
		..()
		if(!icon_state)
			icon_state = "bottle[rand(1,20)]"


	//Copypasta from /obj/item/weapon/reagent_containers/glass/beaker
	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_hand()
		..()
		update_icon()

	update_icon()
		overlays.Cut()

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 24) 	filling.icon_state = "[icon_state]10"
				if(25 to 49)	filling.icon_state = "[icon_state]25"
				if(50 to 74)	filling.icon_state = "[icon_state]50"
				if(75 to 90)	filling.icon_state = "[icon_state]75"
				if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

		if (!is_open_container())
			var/image/lid = image(icon, src, "lid_bottle")
			overlays += lid

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("cyanide", 30)

/obj/item/weapon/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("mutagen", 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("ammonia", 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("diethylamine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of Fluorosulfuric Acid"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("facid", 30)

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	New()
		..()
		reagents.add_reagent("adminordrazine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		reagents.add_reagent("capsaicin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("frostoil", 30)

/obj/item/weapon/reagent_containers/glass/bottle/morphine
	name = "Morphine Bottle"
	desc = "A small bottle. Contains morphine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("morphine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/ether
	name = "Ether Bottle"
	desc = "A small bottle. Contains ether."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("ether", 30)

/obj/item/weapon/reagent_containers/glass/bottle/charcoal
	name = "Charcoal Bottle"
	desc = "A small bottle. Contains charcoal."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("charcoal", 30)

/obj/item/weapon/reagent_containers/glass/bottle/epinephrine
	name = "Epinephrine Bottle"
	desc = "A small bottle. Contains epinephrine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("epinephrine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/pancuronium
	name = "Pancuronium Bottle"
	desc = "A small bottle of pancuronium."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle14"

	New()
		..()
		reagents.add_reagent("pancuronium", 30)

/obj/item/weapon/reagent_containers/glass/bottle/sulfonal
	name = "Sulfonal Bottle"
	desc = "A small bottle of Sulfonal."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

	New()
		..()
		reagents.add_reagent("sulfonal", 30)

//Reagent bottles

/obj/item/weapon/reagent_containers/glass/bottle/reagent
	name = "Reagent Bottle"
	desc = "A bottle for storing reagents"
	icon_state = "rbottle"
	volume = 50

/obj/item/weapon/reagent_containers/glass/bottle/reagent/oil
	name = "Oil Bottle"
	desc = "A reagent bottle. Contains oil."
	icon_state = "rbottle1"
	New()
		..()
		reagents.add_reagent("oil", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/phenol
	name = "Phenol Bottle"
	desc = "A reagent bottle. Contains phenol."
	icon_state = "rbottle2"
	New()
		..()
		reagents.add_reagent("phenol", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/acetone
	name = "Acetone Bottle"
	desc = "A reagent bottle. Contains acetone."
	icon_state = "rbottle3"
	New()
		..()
		reagents.add_reagent("acetone", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/ammonia
	name = "Ammonia Bottle"
	desc = "A reagent bottle. Contains ammonia."
	icon_state = "rbottle4"
	New()
		..()
		reagents.add_reagent("ammonia", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/diethylamine
	name = "Diethylamine Bottle"
	desc = "A reagent bottle. Contains diethylamine."
	icon_state = "rbottle5"
	New()
		..()
		reagents.add_reagent("diethylamine", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/acid
	name = "Acid Bottle"
	desc = "A reagent bottle. Contains sulfuric acid."
	icon_state = "rbottle6"
	New()
		..()
		reagents.add_reagent("sacid", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/formaldehyde
	name = "Formaldehyde Bottle"
	desc = "A reagent bottle. Contains formaldehyde."
	icon_state = "rbottle"
	New()
		..()
		reagents.add_reagent("formaldehyde", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/morphine
	name = "Morphine Bottle"
	desc = "A reagent bottle. Contains morphine."
	New()
		..()
		reagents.add_reagent("morphine", 50)

/obj/item/weapon/reagent_containers/glass/bottle/reagent/insulin
	name = "Insulin Bottle"
	desc = "A reagent bottle. Contains insulin."
	New()
		..()
		reagents.add_reagent("insulin", 50)

////////////////////Traitor Poison Bottle//////////////////////////////

/obj/item/weapon/reagent_containers/glass/bottle/traitor
	desc = "It has a small skull and crossbones on it. Uh-oh!"
	possible_transfer_amounts = list(5,10,15,25,30,40)
	volume = 40

	New()
		..()
		reagents.add_reagent(pick("polonium","initropidril","concentrated_initro","pancuronium","sodium_thiopental","ketamine","sulfonal","amanitin","coniine","curare","tabun","histamine","venom","cyanide"), 40)