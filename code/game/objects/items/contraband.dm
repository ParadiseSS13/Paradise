//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/storage/pill_bottle/happiness
	name = "pill bottle (happiness)"
	desc = "Real fun drugs, for when you want to see the rainbow. Happy happy joy joy!"
	wrapper_color = COLOR_YELLOW

/obj/item/storage/pill_bottle/happiness/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/pill/happy/happiness(src)

/obj/item/storage/pill_bottle/space_drugs
	name = "pill bottle (space drugs)"
	desc = "Drugs made in space, for people in space. They're so good that synthetics and organics can both enjoy the effects!"
	wrapper_color = COLOR_PINK

/obj/item/storage/pill_bottle/space_drugs/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."
	wrapper_color = COLOR_BLUE

/obj/item/storage/pill_bottle/zoom/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/reagent_containers/pill/random_drugs
	desc = "A cocktail of illicit designer drugs, who knows what might be in here."

/obj/item/reagent_containers/pill/random_drugs/Initialize(mapload)
	. = ..()
	icon_state = "pill[rand(1,28)]"

	name = "[pick_list("chemistry_tools.json", "CYBERPUNK_drug_prefixes")] [pick_list("chemistry_tools.json", "CYBERPUNK_drug_suffixes")]"

	var/primaries = rand(1,3)
	var/adulterants = rand(2,4)

	while(primaries > 0)
		primaries--
		reagents.add_reagent(pick_list("chemistry_tools.json", "CYBERPUNK_drug_primaries"), 6)
	while(adulterants > 0)
		adulterants--
		reagents.add_reagent(pick_list("chemistry_tools.json", "CYBERPUNK_drug_adulterants"), 3)

/obj/item/storage/pill_bottle/random_drug_bottle
	name = "pill bottle (???)"
	desc = "Huh."
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/random_drug_bottle/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/random_drugs(src)

/obj/item/reagent_containers/syringe/krokodil
	name = "syringe (krokodil)"
	desc = "Contains krokodil - an illicit drug supposedly containing desomorphine, commonly impure."
	list_reagents = list("krokodil" = 15)

/obj/item/reagent_containers/glass/bottle/w33d
	name = "\improper W33D bottle"
	desc = "A small bottle. Contains W33D, an illegal drug for synthetics."
	list_reagents = list("w33d" = 50)

/obj/item/reagent_containers/glass/bottle/grokodil
	name = "grokodil bottle"
	desc = "A small bottle. Contains grokodil, an illegal drug for synthetics."
	list_reagents = list("grokodil" = 15)

/obj/item/reagent_containers/glass/beaker/waterbottle/large/jenkem
	name = "jenkem bottle"
	desc = "A bottle containing a vile mix of fermented waste. Produced and consumed only by the most truly desperate. Absolutely disgusting."
	list_reagents = list("jenkem" = 50)

/obj/item/reagent_containers/glass/beaker/waterbottle/large/prison_wine
	name = "Big Ed's Prison Wine"
	desc = "A bottle containing prison wine. A mix of basically anything containing sugar that prisoners can manage to gather and ferment. \
	Remember: You're drinking this to get drunk, not to enjoy the taste."
	list_reagents = list("prison_wine" = 50)
