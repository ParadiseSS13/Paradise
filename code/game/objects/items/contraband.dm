//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Real fun drugs, for when you want to see the rainbow. Happy happy joy joy!"
	wrapper_color = COLOR_PINK

/obj/item/storage/pill_bottle/happy/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)
		new /obj/item/reagent_containers/pill/happy/happiness(src)

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
	icon_state = "pill[rand(1,20)]"

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
