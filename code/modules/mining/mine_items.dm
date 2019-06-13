/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emtter"
	anchored = 1
	invisibility = 101
	unacidable = 1
	light_range = 8
	light_power = 0

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/shoes/workboots(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)

/obj/structure/closet/wardrobe/miner/lavaland

/obj/structure/closet/wardrobe/miner/lavaland/New()
	..()
	contents = list()
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/radio/headset/headset_cargo/mining(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/stack/marker_beacon/ten

/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"

/******************************Lantern*******************************/

/obj/item/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on

/*****************************Pickaxe********************************/

/obj/item/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	var/drill_verb = "picking"
	sharp = 1
	var/excavation_amount = 100
	usesound = 'sound/effects/picaxe1.ogg'
	toolspeed = 1

/obj/item/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),20,1)

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "For extracting yourself from rough landings."

/obj/item/pickaxe/safety
	name = "safety pickaxe"
	desc = "A pickaxe designed to be only effective at digging rock and ore, very ineffective as a weapon."
	force = 1
	throwforce = 1
	attack_verb = list("ineffectively hit")

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	origin_tech = "materials=3;engineering=4"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	toolspeed = 0.75

/obj/item/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	origin_tech = "materials=4;engineering=4"
	desc = "A gold-plated pickaxe that mines faster than standard-issue."
	toolspeed = 0.6

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	origin_tech = "materials=5;engineering=4"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	toolspeed = 0.5

/obj/item/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	usesound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=2;engineering=3"
	desc = "An electric mining drill for the especially scrawny."
	toolspeed = 0.5

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	origin_tech = "materials=6;powerstorage=4;engineering=4"
	desc = "Yours is the drill that will pierce the heavens!"
	toolspeed = 0.25

/obj/item/pickaxe/diamonddrill/traitor //Pocket-sized traitor diamond drill.
	name = "supermatter drill"
	icon_state = "smdrill"
	origin_tech = "materials=6;powerstorage=4;engineering=4;syndicate=3"
	desc = "Microscopic supermatter crystals cover the head of this tiny drill."
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	toolspeed = 0.25

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."
	toolspeed = 0.1

/*****************************Shovel********************************/

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	throwforce = 4
	item_state = "shovel"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=50)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	usesound = 'sound/effects/shovel_dig.ogg'
	toolspeed = 1

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 2

/obj/item/shovel/safety
	name = "safety shovel"
	desc = "A large tool for digging and moving dirt. Was modified with extra safety, making it ineffective as a weapon."
	force = 1
	throwforce = 1
	attack_verb = list("ineffectively hit")

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "mining car (not for rails)"
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"

/*********************Mob Capsule*************************/

/obj/item/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 20
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0

/obj/item/mobcapsule/Destroy()
	if(captured)
		captured.ghostize()
		QDEL_NULL(captured)
	return ..()

/obj/item/mobcapsule/attack(var/atom/A, mob/user, prox_flag)
	if(!istype(A, /mob/living/simple_animal) || isbot(A))
		return ..()
	capture(A, user)
	return 1

/obj/item/mobcapsule/proc/capture(var/mob/target, var/mob/U as mob)
	var/mob/living/simple_animal/T = target
	if(captured)
		to_chat(U, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if(istype(T) && "neutral" in T.faction)
			T.forceMove(src)
			T.name = "[U.name]'s [initial(T.name)]"
			T.cancel_camera()
			name = "Lazarus Capsule: [initial(T.name)]"
			to_chat(U, "<span class='notice'>You placed a [T.name] inside the Lazarus Capsule!</span>")
			captured = T
		else
			to_chat(U, "You can't capture that mob!")

/obj/item/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(captured)
		dump_contents(user)

/obj/item/mobcapsule/proc/dump_contents(mob/user)
	if(captured)
		captured.forceMove(get_turf(src))
		captured = null

/obj/item/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()
