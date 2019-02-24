//These are the seeds
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into coconut palms."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut palm"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coconut/bombonut)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1, "sugar" =0.01)


//When it grows
/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "Coconut"
	desc = "A seed? A nut? A fruit?"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "coconut"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	attack_verb = list("hit", "bludgeoned", "whacked")
	var/coconut_wacked = /obj/item/reagent_containers/food/drinks/grown/coconut
	var/wacked_name = "Coconut drink"

/obj/item/grown/coconut/New()
	..()

//Attack with sharp object will make holes on it
/obj/item/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(is_sharp(W))
		user.show_message("<span class='notice'>You make a [wacked_name] by cutting \the [src] and making some holes on it!</span>", 1)
		new coconut_wacked(user.loc, 1)
		qdel(src)

//Here's the drink
/obj/item/reagent_containers/food/drinks/grown/coconut
	name = "Coconut drink"
	desc = "Full of juice"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "coconutdrink"
	item_state = "coconutdrink"
	list_reagents = list("ale" = 30)
	var/coconut_sliced = /obj/item/reagent_containers/food/snacks/grown/coconutsliced
	var/sliced_name = "sliced coconut"


//Attack the drink with sharp will cut it in half
/obj/item/reagent_containers/food/drinks/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(is_sharp(W))
		user.show_message("<span class='notice'>You cut \the [src] in half to make [sliced_name] </span>", 1)
		var/obj/item/reagent_containers/food/snacks/grown/coconutsliced/C = new coconut_sliced(user.loc, 2)
		qdel(src)
		usr.put_in_active_hand(C)


//Here's the food
obj/item/reagent_containers/food/snacks/grown/coconutsliced
	name = "sliced coconut"
	desc = "A coconut split in half"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "coconut-slice"
	filling_color = "#FF4500"
	bitesize = 2



//BOMBONUT HERE//

/obj/item/seeds/coconut/bombonut
	name = "pack of bombonut seeds"
	desc = "The explosive variety of coconuts."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "seed-bombonut"
	species = "coconut"
	plantname = "Coconut palm"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coconut/bombonut)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1, "sugar" =0.01)