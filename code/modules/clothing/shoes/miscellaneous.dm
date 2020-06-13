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
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 70, "acid" = 50)
	strip_delay = 70
	resistance_flags = NONE

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT shoes"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
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
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic."
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 75)

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of purple rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/step_action()
	var/turf/simulated/t_loc = get_turf(src)
	if(istype(t_loc) && t_loc.wet)
		t_loc.MakeDry(TURF_WET_WATER)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! Ctrl-click to toggle the waddle dampeners!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
	var/footstep = 1	//used for squeeks whilst walking
	shoe_sound = "clownstep"
	var/enabled_waddle = TRUE
	var/datum/component/waddle

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_shoes && enabled_waddle)
		waddle = user.AddComponent(/datum/component/waddling)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/clown_shoes/nodrop
	flags = NODROP

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
	resistance_flags = NONE
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
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
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

/obj/item/clothing/shoes/cowboy
	name = "cowboy boots"
	desc = "A pair a' brown boots."
	icon_state = "cowboy_brown"
	item_color = "cowboy_brown"

/obj/item/clothing/shoes/cowboy/black
	name = "black cowboy boots"
	desc = "A pair a' black rustlers' boots"
	icon_state = "cowboy_black"
	item_color = "cowboy_black"

/obj/item/clothing/shoes/cowboy/white
	name = "white cowboy boots"
	desc = "For the rancher in us all."
	icon_state = "cowboy_white"
	item_color = "cowboy_white"

/obj/item/clothing/shoes/cowboy/fancy
	name = "bilton wrangler boots"
	desc = "A pair of authentic haute couture boots from Japanifornia. You doubt they have ever been close to cattle."
	icon_state = "cowboy_fancy"
	item_color = "cowboy_fancy"

/obj/item/clothing/shoes/cowboy/pink
	name = "pink cowgirl boots"
	desc = "For a Rustlin' tustlin' cowgirl."
	icon_state = "cowboyboots_pink"
	item_color = "cowboyboots_pink"

/obj/item/clothing/shoes/cowboy/lizard
	name = "lizard skin boots"
	desc = "You can hear a faint hissing from inside the boots; you hope it is just a mournful ghost."
	icon_state = "lizardboots_green"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 0) //lizards like to stay warm

/obj/item/clothing/shoes/cowboy/lizardmasterwork
	name = "\improper Hugs-The-Feet lizard skin boots"
	desc = "A pair of masterfully crafted lizard skin boots. Finally a good application for the station's most bothersome inhabitants."
	icon_state = "lizardboots_blue"

/obj/effect/spawner/lootdrop/lizardboots
	name = "random lizard boot quality"
	desc = "Which ever gets picked, the lizard race loses"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "lizardboots_green"
	loot = list(
		/obj/item/clothing/shoes/cowboy/lizard = 7,
		/obj/item/clothing/shoes/cowboy/lizardmasterwork = 1)

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
