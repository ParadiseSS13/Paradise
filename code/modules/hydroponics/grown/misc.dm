// Starthistle
/obj/item/seeds/starthistle
	name = "pack of starthistle seeds"
	desc = "A robust species of weed that often springs up in-between the cracks of spaceship parking lots"
	icon_state = "seed-starthistle"
	species = "starthistle"
	plantname = "Starthistle"
	lifespan = 70
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = 2
	potency = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)

/obj/item/seeds/starthistle/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = loc
	var/seed_count = yield
	if(prob(getYield() * 20))
		seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc
		for(var/i in 1 to seed_count)
			var/obj/item/seeds/starthistle/harvestseeds = Copy()
			harvestseeds.forceMove(output_loc)

	parent.update_tray()

// Cabbage
/obj/item/seeds/cabbage
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/replicapod)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	bitesize_mod = 2
	tastes = list("cabbage" = 1)
	wine_power = 0.2


// Sugarcane
/obj/item/seeds/sugarcane
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/reagent_containers/food/snacks/grown/sugarcane
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 60
	endurance = 50
	maturation = 3
	yield = 4
	growthstages = 3
	reagents_add = list("sugar" = 0.25)

/obj/item/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bitesize_mod = 2
	tastes = list("sugarcane" = 1)
	distill_reagent = "rum"


// Gatfruit
/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "Gatfruit Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list("sulfur" = 0.1, "carbon" = 0.1, "nitrogen" = 0.07, "potassium" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	origin_tech = "combat=6"
	trash = /obj/item/gun/projectile/revolver
	tastes = list("2nd amendment" = 1, "freedom" = 1)
	bitesize_mod = 2
	wine_power = 0.9 //It burns going down, too.

//Cherry Bombs
/obj/item/seeds/cherry/bomb
	name = "pack of cherry bomb pits"
	desc = "They give you vibes of dread and frustration."
	icon_state = "seed-cherry_bomb"
	species = "cherry_bomb"
	plantname = "Cherry Bomb Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cherry_bomb
	mutatelist = list()
	reagents_add = list("plantmatter" = 0.1, "sugar" = 0.1, "blackpowder" = 0.7)
	rarity = 60 //See above

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb
	name = "cherry bombs"
	desc = "You think you can hear the hissing of a tiny fuse."
	icon_state = "cherry_bomb"
	filling_color = rgb(20, 20, 20)
	seed = /obj/item/seeds/cherry/bomb
	bitesize_mod = 2
	tastes = list("cherry" = 1, "explosion" = 1)
	volume = 125 //Gives enough room for the black powder at max potency
	max_integrity = 40
	wine_power = 0.8

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/attack_self(mob/living/user)
	var/area/A = get_area(user)
	user.visible_message("<span class='warning'>[user] plucks the stem from [src]!</span>", "<span class='userdanger'>You pluck the stem from [src], which begins to hiss loudly!</span>")
	message_admins("[user] ([user.key ? user.key : "no key"]) primed a cherry bomb for detonation at [A] ([user.x], [user.y], [user.z]) <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>(JMP)</a>")
	log_game("[user] ([user.key ? user.key : "no key"]) primed a cherry bomb for detonation at [A] ([user.x],[user.y],[user.z]).")
	prime()

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion. Also prevents mass chain reaction with piles of cherry bombs

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/proc/prime()
	icon_state = "cherry_bomb_lit"
	playsound(src, 'sound/goonstation/misc/fuse.ogg', seed.potency, 0)
	reagents.set_reagent_temp(1000) //Sets off the black powder