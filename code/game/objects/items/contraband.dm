//Let's get some REAL contraband stuff in here. Because come on, getting brigged for LIPSTICK is no fun.

//Illicit drugs~
/obj/item/weapon/storage/pill_bottle/happy
	name = "Happy pills"
	desc = "Highly illegal drug. When you want to see the rainbow."

/obj/item/weapon/storage/pill_bottle/happy/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )
	new /obj/item/weapon/reagent_containers/pill/happy( src )

/obj/item/weapon/storage/pill_bottle/zoom
	name = "Zoom pills"
	desc = "Highly illegal drug. Trade brain for speed."

/obj/item/weapon/storage/pill_bottle/zoom/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )
	new /obj/item/weapon/reagent_containers/pill/zoom( src )


/obj/item/weapon/reagent_containers/pill/random_drugs
	name = "pill"
	desc = ""

/obj/item/weapon/reagent_containers/pill/random_drugs/New()
	..()
	icon_state = "pill" + pick("2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20")

	name = pick("lunar","vorpal","hardcore","willow", "void","loopy","electro", "cyber","heavy", "ninja", "hydro", "blue", "red", "green", "purple", "strong", "divine","carp" ,"deadly","dead","vicious" ,"wild" ,"demon", "chill", "solid", "liquid", "crazy", "super", "hyper", "space", "wizard", "rainbow", "star", "turbo", "prism", "sticky") + " " + pick("jack","zero","null","beat","nip","bubbles" ,"ice","medicine","venom","shock","solar" ,"spice" ,"shredder", "heart" , "heat", "pill","hopper","scum","fruit", "bolt", "deck", "butter", "runoff", "grease", "flair", "sweat", "zone", "blast")

	reagents.add_reagent(pick("pancuronium","neurotoxin","frostoil", "toxin","morphine", "carpotoxin", "hippiesdelight","methamphetamine","haloperidol" , "hydrocodone", "psilocybin", "lsd", "capsaicin", "space_drugs" , "epinephrine", "serotrotium"), pick(5,7,10,13,15))
	reagents.add_reagent(pick("pancuronium","neurotoxin","frostoil", "toxin","morphine", "carpotoxin", "hippiesdelight","methamphetamine","haloperidol" ,"hydrocodone", "psilocybin", "lsd", "capsaicin", "space_drugs" , "epinephrine", "serotrotium"), pick(5,7,10,13,15))
	reagents.add_reagent(pick("pancuronium","neurotoxin","frostoil", "toxin","morphine", "carpotoxin", "hippiesdelight","methamphetamine","haloperidol" , "hydrocodone", "psilocybin", "lsd", "capsaicin", "space_drugs" , "epinephrine", "serotrotium"), pick(5,7,10,13,15))



/obj/item/weapon/storage/pill_bottle/random_drug_bottle
	name = "odd pill bottle"
	desc = "You're not sure if you trust the contents of this bottle..."

/obj/item/weapon/storage/pill_bottle/random_drug_bottle/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )
	new /obj/item/weapon/reagent_containers/pill/random_drugs( src )


