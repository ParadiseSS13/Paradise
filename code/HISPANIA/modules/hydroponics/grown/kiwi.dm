//Semillas
/obj/item/seeds/kiwi
	name = "pack of kiwi seeds"
	desc = "These seeds grow into kiwi bushes"
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "kiwi-seeds"
	species = "kiwi"
	plantname = "Kiwi Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/kiwi
	lifespan = 20
	production = 5
	yield = 2
	weed_chance = 15
	maturation = 4
	potency = 30
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/kiwi/actual_kiwi)
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("sugar" = 0.12)

/obj/item/seeds/kiwi/actual_kiwi
	name = "pack of actual kiwi seeds"
	desc = "These seeds grow into kiwi bushes but this one seems to be moving..."
	icon_state = "akiwi-seed"
	species = "kiwi"
	plantname = "Actual Kiwi Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/kiwi/actual_kiwi
	mutatelist = list()
	lifespan = 50
	endurance = 40
	yield = 5
	potency = 40
	weed_chance = 60
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("nutriment" = 0.12)

//Frutas

/obj/item/reagent_containers/food/snacks/grown/kiwi
	seed = /obj/item/seeds/kiwi
	name = "kiwi"
	desc = "Is a fruit of ovoid shape, of variable size and covered with a brown fuzzy thin skin"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "kiwi"
	tastes = list("sour" = 1, "sweet" = 1)

/obj/item/reagent_containers/food/snacks/grown/kiwi/actual_kiwi
	seed = /obj/item/seeds/kiwi/actual_kiwi
	name = "actual kiwi"
	desc = "Is a fruit of a ovoid shape but this one seems to be moving..."
	icon_state = "actual_kiwi"
	var/awakening = 0
	tastes = list("funny life" = 1)

/obj/item/reagent_containers/food/snacks/grown/kiwi/actual_kiwi/attack_self(mob/user)
	if(awakening || istype(user.loc, /turf/space))
		return
	to_chat(user, "<span class='notice'>You begin to awaken the Kiwi...</span>")
	awakening = 1

	spawn(30)
		if(!QDELETED(src))
			var/turf/T = get_turf(user)
			var/mob/living/simple_animal/kiwi/K = new /mob/living/simple_animal/kiwi(T)
			K.visible_message("<span class='notice'>The Kiwi suddenly awakens.</span>")
			if(user)
				user.unEquip(src)
			qdel(src)
