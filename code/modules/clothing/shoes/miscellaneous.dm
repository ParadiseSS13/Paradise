/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	can_cut_open = 1
	icon_state = "jackboots"
	item_state = "jackboots"
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 25, bomb = 50, bio = 10, rad = 0)
	strip_delay = 70
	burn_state = FIRE_PROOF

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT shoes"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 25, bomb = 50, bio = 30, rad = 30)
	flags = NOSLIP

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	strip_delay = 50
	put_on_delay = 50
	magical = TRUE

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
	burn_state = FIRE_PROOF

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of purple rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/step_action()
	var/turf/simulated/t_loc = get_turf(src)
	if(istype(t_loc) && t_loc.wet)
		t_loc.MakeDry(TURF_WET_WATER)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	var/footstep = 1	//used for squeeks whilst walking
	shoe_sound = "clownstep"

/obj/item/clothing/shoes/clown_shoes/magical
	name = "magical clown shoes"
	desc = "Standard-issue shoes of the wizarding class clown. Damn they're huge! And powerful! Somehow."
	magical = TRUE

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	can_cut_open = 1
	icon_state = "jackboots"
	item_state = "jackboots"
	item_color = "hosred"
	strip_delay = 50
	put_on_delay = 50
	burn_state = FIRE_PROOF
	var/footstep = 1
	shoe_sound = "jackboot"

/obj/item/clothing/shoes/jackboots/jacksandals
	name = "jacksandals"
	desc = "Nanotrasen-issue Security combat sandals for combat scenarios. They're jacksandals, however that works."
	can_cut_open = 0
	icon_state = "jacksandal"
	item_color = "jacksandal"

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Thick-soled boots for industrial work environments."
	can_cut_open = 1
	icon_state = "workboots"

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	can_cut_open = 1
	icon_state = "winterboots"
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"

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

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	item_state = "griffinboots"


/obj/item/clothing/shoes/fluff/noble_boot
	name = "noble boots"
	desc = "The boots are economically designed to balance function and comfort, so that you can step on peasants without having to worry about blisters. The leather also resists unwanted blood stains."
	icon_state = "noble_boot"
	item_color = "noble_boot"
	item_state = "noble_boot"

/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tape_roll) && !silence_steps)
		var/obj/item/stack/tape_roll/TR = I
		if((!silence_steps || shoe_sound) && TR.use(4))
			silence_steps = TRUE
			shoe_sound = null
			to_chat(user, "You tape the soles of [src] to silence your footsteps.")
	else
		return ..()

/obj/item/clothing/shoes/sandal/white
	name = "White Sandals"
	desc = "Medical sandals that nerds wear."
	icon_state = "medsandal"
	item_color = "medsandal"

/obj/item/clothing/shoes/sandal/fancy
	name = "Fancy Sandals"
	desc = "FANCY!!."
	icon_state = "fancysandal"
	item_color = "fancysandal"

/obj/item/clothing/shoes/cursedclown
	name = "cursed clown shoes"
	desc = "Moldering clown flip flops. They're neon green for some reason."
	icon = 'icons/goonstation/objects/clothing/feet.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_shoes"
	icon_override = 'icons/goonstation/mob/clothing/feet.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	flags = NODROP
	shoe_sound = "clownstep"

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	put_on_delay = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	put_on_delay = 50

/obj/item/clothing/shoes/cowboyboots
	name = "cowboy boots"
	desc = "A pair a' brown boots."
	icon_state = "cowboyboots"
	item_color = "cowboyboots"

/obj/item/clothing/shoes/cowboyboots/black
	name = "black cowboy boots"
	desc = "A pair a' black rustlers' boots"
	icon_state = "cowboyboots_black"
	item_color = "cowboyboots_black"

/obj/item/clothing/shoes/cowboyboots/white
	name = "white cowboy boots"
	desc = "For the rancher in us all."
	icon_state = "cowboyboots_white"
	item_color = "cowboyboots_white"

/obj/item/clothing/shoes/cowboyboots/pink
	name = "pink cowgirl boots"
	desc = "For a Rustlin' tustlin' cowgirl."
	icon_state = "cowboyboots_pink"
	item_color = "cowboyboots_pink"

/obj/item/clothing/shoes/footwraps
 	name = "cloth footwraps"
 	desc = "A roll of treated canvas used for wrapping claws or paws."
 	icon_state = "clothwrap"
 	item_state = "clothwrap"
 	force = 0
 	silence_steps = TRUE
 	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	item_state = "jetboots"
	item_color = "hosred"
	resistance_flags = FIRE_PROOF
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	can_cut_open = FALSE
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")