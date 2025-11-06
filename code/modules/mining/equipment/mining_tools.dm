/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	desc = "A tool for digging rock and stone. Better get to work."
	icon = 'icons/obj/mining_tool.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 2000) //one sheet, but where can you make them?
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("hit", "pierced", "sliced", "attacked")
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	var/drill_verb = "picking"
	sharp = TRUE
	var/excavation_amount = 100
	usesound = 'sound/effects/picaxe1.ogg'

/obj/item/pickaxe/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

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

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	inhand_icon_state = "pickaxe"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 1000)

/obj/item/pickaxe/bone
	name = "bone pickaxe"
	desc = "Do it yourself pickaxe."
	icon_state = "bone_pickaxe"
	origin_tech = "materials=1;engineering=2"
	toolspeed = 0.7
	force = 16
	materials = list()

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	icon_state = "spickaxe"
	origin_tech = "materials=3;engineering=4"
	toolspeed = 0.5 //mines faster than a normal pickaxe, bought from mining vendor
	force = 17
	materials = list(MAT_METAL = 1900, MAT_SILVER = 100)

/obj/item/pickaxe/gold
	name = "golden pickaxe"
	desc = "A gold-plated pickaxe that mines faster than standard-issue."
	icon_state = "gpickaxe"
	origin_tech = "materials=4;engineering=4"
	toolspeed = 0.4
	force = 18
	materials = list(MAT_METAL = 1900, MAT_GOLD = 100)

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	icon_state = "dpickaxe"
	origin_tech = "materials=5;engineering=4"
	toolspeed = 0.3
	force = 19
	materials = list(MAT_METAL = 1900, MAT_DIAMOND = 100)

/obj/item/pickaxe/drill
	name = "mining drill"
	desc = "An electric mining drill for the especially scrawny."
	icon_state = "handdrill"
	inhand_icon_state = "jackhammer"
	digsound = list('sound/weapons/drill.ogg')
	toolspeed = 0.6 //available from roundstart, faster than a pickaxe.
	hitsound = 'sound/weapons/drill.ogg'
	usesound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=2;engineering=3"

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	desc = "Yours is the drill that will pierce the heavens!"
	icon_state = "diamonddrill"
	origin_tech = "materials=6;powerstorage=4;engineering=4"
	toolspeed = 0.2

/// This is the BORG version!
/obj/item/pickaxe/drill/cyborg/diamond
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	toolspeed = 0.2

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."
	icon_state = "jackhammer"
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	toolspeed = 0.1 //the epitome of powertools. extremely fast mining, laughs at puny walls
	force = 20 //This thing breaks rwalls, it should be able to hit harder than a DIY bone pickaxe.

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining_tool.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 4
	materials = list(MAT_METAL = 200)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	usesound = 'sound/effects/shovel_dig.ogg'
	toolspeed = 0.5

/obj/item/shovel/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	belt_icon = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/safety
	name = "safety shovel"
	desc = "A large tool for digging and moving dirt. Was modified with extra safety, making it ineffective as a weapon."
	force = 1
	throwforce = 1
	attack_verb = list("ineffectively hit")
