// Tomato
/obj/item/seeds/tomato
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato
	maturation = 8
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "tomato-grow"
	icon_dead = "tomato-dead"
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/tomato/blue, /obj/item/seeds/tomato/blood)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/tomato
	seed = /obj/item/seeds/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	splat_type = /obj/effect/decal/cleanable/tomato_smudge
	filling_color = "#FF6347"
	bitesize_mod = 2
	distill_reagent = "enzyme"

// Blood Tomato
/obj/item/seeds/tomato/blood
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blood
	mutatelist = list(/obj/item/seeds/tomato/killer)
	reagents_add = list("blood" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tomato/blood
	seed = /obj/item/seeds/tomato/blood
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	splat_type = /obj/effect/gibspawner/generic
	filling_color = "#FF0000"
	origin_tech = "biotech=5"
	distill_reagent = "bloodymary"


// Blue Tomato
/obj/item/seeds/tomato/blue
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blue
	yield = 2
	icon_grow = "bluetomato-grow"
	mutatelist = list(/obj/item/seeds/tomato/blue/bluespace)
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("lube" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tomato/blue
	seed = /obj/item/seeds/tomato/blue
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	splat_type = /obj/effect/decal/cleanable/blood/oil
	filling_color = "#0000FF"


// Bluespace Tomato
/obj/item/seeds/tomato/blue/bluespace
	name = "pack of bluespace tomato seeds"
	desc = "These seeds grow into bluespace tomato plants."
	icon_state = "seed-bluespacetomato"
	species = "bluespacetomato"
	plantname = "Bluespace Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	yield = 2
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("lube" = 0.2, "singulo" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1)
	rarity = 50

/obj/item/reagent_containers/food/snacks/grown/tomato/blue/bluespace
	seed = /obj/item/seeds/tomato/blue/bluespace
	name = "bluespace tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	origin_tech = "biotech=4;bluespace=5"
	distill_reagent = null
	wine_power = 0.8


// Killer Tomato
/obj/item/seeds/tomato/killer
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/tomato/killer
	yield = 2
	genes = list(/datum/plant_gene/trait/squash)
	growthstages = 2
	icon_grow = "killertomato-grow"
	icon_harvest = "killertomato-harvest"
	icon_dead = "killertomato-dead"
	mutatelist = list()
	reagents_add = list("vitamin" = 0.04, "protein" = 0.1)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/tomato/killer
	seed = /obj/item/seeds/tomato/killer
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	var/awakening = 0
	filling_color = "#FF0000"
	origin_tech = "biotech=4;combat=5"
	distill_reagent = "demonsblood"

/obj/item/reagent_containers/food/snacks/grown/tomato/killer/attack(mob/M, mob/user, def_zone)
	if(awakening)
		to_chat(user, "<span class='warning'>The tomato is twitching and shaking, preventing you from eating it.</span>")
		return
	..()

/obj/item/reagent_containers/food/snacks/grown/tomato/killer/attack_self(mob/user)
	if(awakening || istype(user.loc, /turf/space))
		return
	to_chat(user, "<span class='notice'>You begin to awaken the Killer Tomato...</span>")
	awakening = 1

	spawn(30)
		if(!QDELETED(src))
			var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(loc))
			K.maxHealth += round(seed.endurance / 3)
			K.melee_damage_lower += round(seed.potency / 10)
			K.melee_damage_upper += round(seed.potency / 10)
			K.move_to_delay -= round(seed.production / 50)
			K.health = K.maxHealth
			K.visible_message("<span class='notice'>The Killer Tomato growls as it suddenly awakens.</span>")
			if(user)
				user.unEquip(src)
			qdel(src)
