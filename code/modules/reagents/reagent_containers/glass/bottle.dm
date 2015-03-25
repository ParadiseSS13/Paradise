
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

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

	New()
		..()
		reagents.add_reagent("inaprovaline", 30)


/obj/item/weapon/reagent_containers/glass/bottle/hyperzine
	name = "hyperzine bottle"
	desc = "A small bottle. Contains hyperzine - a powerful stimulant."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"

	New()
		..()
		reagents.add_reagent("hyperzine", 30)



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

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("chloralhydrate", 15)		//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("anti_toxin", 30)

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

/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("pacid", 30)

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

/obj/item/weapon/reagent_containers/glass/bottle/traitor
	name = "fuck shit Bottle"
	desc = "A small bottle. Contains woody's got wood in liquid form."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	volume = 50
	var/poison = "water"
	var/poison_name = "Water"
	New()
		..()
		reagents.add_reagent(poison, 50)
		name = "[poison_name] bottle"
		desc = "A small bottle. Contains [poison_name]."

/obj/item/weapon/reagent_containers/glass/bottle/traitor/initropidril
	poison = "initropidril"
	poison_name = "Initropidril"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/polonium
	poison = "polonium"
	poison_name = "Polonium"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/pancuronium
	poison = "pancuronium"
	poison_name = "Pancuronium"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/sodium_thiopental
	poison = "sodium_thiopental"
	poison_name = "Sodium Thiopental"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/amantin
	poison = "amantin"
	poison_name = "Amantin"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/curare
	poison = "curare"
	poison_name = "Curare"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/coiine
	poison = "coiine"
	poison_name = "Coiine"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/histamine
	poison = "histamine"
	poison_name = "Histamine"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/venom
	poison = "venom"
	poison_name = "Venom"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/sulfonal
	poison = "sulfonal"
	poison_name = "Sulfonal"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/formaldehyde
	poison = "formaldehyde"
	poison_name = "Formaldehyde"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/neurotoxin2
	poison = "neurotoxin2"
	poison_name = "Neurotoxin"
/obj/item/weapon/reagent_containers/glass/bottle/traitor/cyanide
	poison = "cyanide"
	poison_name = "Cyanide"