/obj/item/clothing/shoes/proc/step_action(var/mob/living/carbon/human/H) //squeek squeek

/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	permeability_coefficient = 0.05
	flags = NOSLIP
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8
	species_restricted = null
	silence_steps = 1

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon_state = "jackboots"
	item_state = "jackboots"
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 10, rad = 0)
	species_restricted = null //Syndicate tech means even Tajarans can kick ass with these
	siemens_coefficient = 0.6
	strip_delay = 70

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT shoes"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	armor = list(melee = 80, bullet = 60, laser = 50, energy = 50, bomb = 50, bio = 30, rad = 30)
	flags = NOSLIP

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	strip_delay = 50
	put_on_delay = 50
	species_restricted = null

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 50
	put_on_delay = 50
	species_restricted = null

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	var/footstep = 1	//used for squeeks whilst walking
	species_restricted = null

/obj/item/clothing/shoes/clown_shoes/step_action(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0

	if(H.m_intent == "run")
		if(footstep >= 2)
			playsound(src, "clownstep", 50, 1)
			footstep = 0
		else
			footstep++
	else
		playsound(src, "clownstep", 20, 1)

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	item_color = "hosred"
	siemens_coefficient = 0.7
	strip_delay = 50
	put_on_delay = 50
	var/footstep = 1

/obj/item/clothing/shoes/jackboots/step_action(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0

	if(H.m_intent == "run")
		if(footstep >= 2)
			playsound(src, "jackboot", 50, 1)
			footstep = 0
		else
			footstep++
	else
		playsound(src, "jackboot", 20, 1)

/obj/item/clothing/shoes/jackboots/jacksandals
	name = "jacksandals"
	desc = "Nanotrasen-issue Security combat sandals for combat scenarios. They're jacksandals, however that works."
	icon_state = "jacksandal"
	item_color = "jacksandal"
	species_restricted = null

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"
	siemens_coefficient = 0.7

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	species_restricted = null

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"
	species_restricted = null

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	put_on_delay = 50

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	put_on_delay = 100
	species_restricted = null

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	item_state = "griffinboots"
	flags = NODROP

/obj/item/clothing/shoes/fluff/noble_boot
	name = "noble boots"
	desc = "The boots are economically designed to balance function and comfort, so that you can step on peasants without having to worry about blisters. The leather also resists unwanted blood stains."
	icon_state = "noble_boot"
	item_color = "noble_boot"
	item_state = "noble_boot"


/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shoe_silencer))
		silence_steps = 1
		user.unEquip(I)
		qdel(I)
	else . = ..()

/obj/item/shoe_silencer
	name = "shoe rags"
	desc = "Looks sneaky."
	icon_state = "sheet-cloth"

/datum/table_recipe/shoe_rags
	name = "Shoe Rags"

	result = /obj/item/shoe_silencer
	reqs = list(/obj/item/stack/tape_roll = 10)
	tools = list(/obj/item/weapon/wirecutters)

	time = 40
