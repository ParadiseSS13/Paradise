// Poppy
/obj/item/seeds/poppy
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/food/grown/poppy
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "poppy-grow"
	icon_dead = "poppy-dead"
	mutatelist = list(/obj/item/seeds/poppy/geranium, /obj/item/seeds/poppy/lily)
	reagents_add = list("bicaridine" = 0.2, "plantmatter" = 0.05)

/obj/item/food/grown/poppy
	seed = /obj/item/seeds/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	slot_flags = ITEM_SLOT_HEAD
	bitesize_mod = 3
	tastes = list("poppy" = 1)
	filling_color = "#FF6347"
	distill_reagent = "vermouth"

// Lily
/obj/item/seeds/poppy/lily
	name = "pack of lily seeds"
	desc = "These seeds grow into lilies."
	icon_state = "seed-lily"
	species = "lily"
	plantname = "Lily Plants"
	icon_grow = "lily-grow"
	icon_dead = "lily-dead"
	product = /obj/item/food/grown/lily
	mutatelist = list(/obj/item/seeds/poppy/lily/trumpet)

/obj/item/food/grown/lily
	seed = /obj/item/seeds/poppy/lily
	name = "lily"
	desc = "A beautiful white flower."
	icon_state = "lily"
	slot_flags = ITEM_SLOT_HEAD
	bitesize_mod = 3
	tastes = list("lily" = 1)
	filling_color = "#C7BBAD"
	distill_reagent = "vermouth"

//Spaceman's Trumpet

/obj/item/seeds/poppy/lily/trumpet
	name = "pack of spaceman's trumpet seeds"
	desc = "A plant sculped by extensive genetic engineering. The spaceman's trumpet is said to bear no resemblance to its wild ancestors. Inside NT AgriSci circles it is better known as NTPW-0372."
	icon_state = "seed-trumpet"
	species = "spacemanstrumpet"
	plantname = "Spaceman's Trumpet Plant"
	product = /obj/item/food/grown/trumpet
	lifespan = 80
	production = 5
	maturation = 12
	yield = 4
	growthstages = 4
	weed_rate = 2
	weed_chance = 10
	icon_grow = "spacemanstrumpet-grow"
	icon_dead = "spacemanstrumpet-dead"
	mutatelist = null
	reagents_add = list("nutriment" = 0.05)

/obj/item/food/grown/trumpet
	seed = /obj/item/seeds/poppy/lily/trumpet
	name = "spaceman's trumpet"
	desc = "A vivid flower that smells faintly of freshly cut grass. Touching the flower seems to stain the skin some time after contact, yet most other surfaces seem to be unaffected by this phenomenon."
	icon_state = "spacemanstrumpet"

// Geranium
/obj/item/seeds/poppy/geranium
	name = "pack of geranium seeds"
	desc = "These seeds grow into geranium."
	icon_state = "seed-geranium"
	species = "geranium"
	plantname = "Geranium Plants"
	icon_grow = "geranium-grow"
	icon_dead = "geranium-dead"
	product = /obj/item/food/grown/geranium
	mutatelist = list()

/obj/item/food/grown/geranium
	seed = /obj/item/seeds/poppy/geranium
	name = "geranium"
	desc = "A beautiful purple flower."
	icon_state = "geranium"
	slot_flags = ITEM_SLOT_HEAD
	bitesize_mod = 3
	tastes = list("geranium" = 1)
	filling_color = "#A463FB"
	distill_reagent = "vermouth"

// Harebell
/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product = /obj/item/food/grown/harebell
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 30
	growthstages = 4
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	reagents_add = list("plantmatter" = 0.04)

/obj/item/food/grown/harebell
	seed = /obj/item/seeds/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	tastes = list("harebell" = 1)
	bitesize_mod = 3
	distill_reagent = "vermouth"


// Sunflower
/obj/item/seeds/sunflower
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product = /obj/item/grown/sunflower
	endurance = 20
	production = 2
	yield = 2
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "sunflower-grow"
	icon_dead = "sunflower-dead"
	mutatelist = list(/obj/item/seeds/sunflower/moonflower, /obj/item/seeds/sunflower/novaflower)
	reagents_add = list("cornoil" = 0.08, "plantmatter" = 0.04)

/// FLOWER POWER!
/obj/item/grown/sunflower
	seed = /obj/item/seeds/sunflower
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon_state = "sunflower"
	damtype = "fire"
	slot_flags = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/grown/sunflower/attack__legacy__attackchain(mob/M, mob/user)
	to_chat(M, "<font color='green'><b>[user] smacks you with a sunflower!</b></font><font color='yellow'><b>FLOWER POWER</b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")

// Moonflower
/obj/item/seeds/sunflower/moonflower
	name = "pack of moonflower seeds"
	desc = "These seeds grow into moonflowers."
	icon_state = "seed-moonflower"
	species = "moonflower"
	plantname = "Moonflowers"
	icon_grow = "moonflower-grow"
	product = /obj/item/food/grown/moonflower
	mutatelist = list()
	reagents_add = list("moonshine" = 0.2, "vitamin" = 0.02, "plantmatter" = 0.02)
	rarity = 15

/obj/item/food/grown/moonflower
	seed = /obj/item/seeds/sunflower/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	bitesize_mod = 2
	tastes = list("moonflower" = 1)
	distill_reagent = "absinthe"  //It's made from flowers.

// Novaflower
/obj/item/seeds/sunflower/novaflower
	name = "pack of novaflower seeds"
	desc = "These seeds grow into novaflowers."
	icon_state = "seed-novaflower"
	species = "novaflower"
	plantname = "Novaflowers"
	icon_grow = "novaflower-grow"
	product = /obj/item/grown/novaflower
	mutatelist = list()
	reagents_add = list("condensedcapsaicin" = 0.25, "capsaicin" = 0.3, "plantmatter" = 0)
	rarity = 20

/obj/item/grown/novaflower
	seed = /obj/item/seeds/sunflower/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon_state = "novaflower"
	damtype = "fire"
	slot_flags = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("roasted", "scorched", "burned")

/obj/item/grown/novaflower/add_juice()
	..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/grown/novaflower/attack__legacy__attackchain(mob/living/carbon/M, mob/user)
	..()
	if(isliving(M))
		to_chat(M, "<span class='danger'>You are lit on fire from the intense heat of [src]!</span>")
		M.adjust_fire_stacks(seed.potency / 20)
		if(M.IgniteMob())
			message_admins("[key_name_admin(user)] set [key_name_admin(M)] on fire")
			log_game("[key_name(user)] set [key_name(M)] on fire")

/obj/item/grown/novaflower/afterattack__legacy__attackchain(atom/A as mob|obj, mob/user,proximity)
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1)
	else
		to_chat(usr, "<span class='warning'>All the petals have fallen off [src] from violent whacking!</span>")
		qdel(src)

/obj/item/grown/novaflower/pickup(mob/living/carbon/human/user)
	. = ..()
	if(!user.gloves)
		to_chat(user, "<span class='danger'>[src] burns your bare hand!</span>")
		user.adjustFireLoss(rand(1, 5))
