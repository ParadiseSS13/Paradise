//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/weapon/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."

/obj/item/weapon/storage/pill_bottle/happy/New()
	..()
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )
	new /obj/item/weapon/reagent_containers/food/pill/happy( src )

/obj/item/weapon/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."

/obj/item/weapon/storage/pill_bottle/zoom/New()
	..()
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/food/pill/zoom( src )

/obj/item/weapon/reagent_containers/food/pill/random_drugs
	name = "pill"
	desc = "A cocktail of illicit designer drugs, who knows what might be in here."

/obj/item/weapon/reagent_containers/food/pill/random_drugs/New()
	..()
	icon_state = "pill" + pick("2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20")

	name = "[pick_list("chemistry_tools.json", "CYBERPUNK_drug_prefixes")] [pick_list("chemistry_tools.json", "CYBERPUNK_drug_suffixes")]"

	var/primaries = rand(1,3)
	var/adulterants = rand(2,4)

	while(primaries > 0)
		primaries--
		reagents.add_reagent(pick_list("chemistry_tools.json", "CYBERPUNK_drug_primaries"), 6)
	while(adulterants > 0)
		adulterants--
		reagents.add_reagent(pick_list("chemistry_tools.json", "CYBERPUNK_drug_adulterants"), 3)



/obj/item/weapon/storage/pill_bottle/random_drug_bottle
	name = "pill bottle (???)"
	desc = "Huh."

/obj/item/weapon/storage/pill_bottle/random_drug_bottle/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/pill/random_drugs(src)


