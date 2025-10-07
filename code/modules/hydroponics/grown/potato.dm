// Potato
/obj/item/seeds/potato
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Potato Plants"
	product = /obj/item/food/grown/potato
	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	genes = list(/datum/plant_gene/trait/battery)
	mutatelist = list(/obj/item/seeds/potato/sweet)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/food/grown/potato
	seed = /obj/item/seeds/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"
	tastes = list("potato" = 1)
	bitesize = 100
	distill_reagent = "vodka"

/obj/item/food/grown/potato/wedges
	name = "potato wedges"
	desc = "Slices of neatly cut potato."
	icon_state = "potato_wedges"
	tastes = list("potato" = 1)
	distill_reagent = "sbiten"

/obj/item/food/grown/potato/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!used.sharp)
		return ..()

	to_chat(user, "<span class='notice'>You cut the potato into wedges with [used].</span>")
	var/obj/item/food/grown/potato/wedges/W = new /obj/item/food/grown/potato/wedges
	if(!remove_item_from_storage(user))
		user.unequip(src)
	user.put_in_hands(W)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

// Sweet Potato
/obj/item/seeds/potato/sweet
	name = "pack of sweet potato seeds"
	desc = "These seeds grow into sweet potato plants."
	icon_state = "seed-sweetpotato"
	species = "sweetpotato"
	plantname = "Sweet Potato Plants"
	product = /obj/item/food/grown/potato/sweet
	mutatelist = list()
	reagents_add = list("vitamin" = 0.1, "sugar" = 0.1, "plantmatter" = 0.1)

/obj/item/food/grown/potato/sweet
	seed = /obj/item/seeds/potato/sweet
	name = "sweet potato"
	desc = "It's sweet."
	tastes = list("sweet potato" = 1)
	icon_state = "sweetpotato"
