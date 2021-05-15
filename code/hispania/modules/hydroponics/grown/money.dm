//These are the seeds
/obj/item/seeds/money
	name = "pack of coins"
	desc = "Money doesn't grow on trees... right?"
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "seed-money"
	species = "money"
	plantname = "Money Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/money
	lifespan = 30
	endurance = 7
	yield = 2
	maturation = 7
	production = 7
	potency = 30
	weed_chance = 15 //Percentage chance per tray update to grow weeds
	growing_icon = 'icons/hispania/obj/hydroponics/growing.dmi'

//When it grows
/obj/item/reagent_containers/food/snacks/grown/money
	seed = /obj/item/seeds/money
	name = "wad of bills"
	desc = "A nicely arranged wad of 10 credits. Open to reveal them."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "wad"
	resistance_flags = FLAMMABLE
	var/stacktype = /obj/item/stack/spacecash

/obj/item/reagent_containers/food/snacks/grown/money/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You open [src].</span>")
	var/wadAmt = 1 // The wad we're holding
	for(var/obj/item/reagent_containers/food/snacks/grown/money/M in user.loc) // The wads on the floor
		wadAmt += 1
		qdel(M)
	new stacktype(get_turf(user), wadAmt * 10)
	qdel(src)
