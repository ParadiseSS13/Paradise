#define NISHTYAK_DELAY 1200
/obj/structure/toilet/parasha
  name = "BIDLOparasha X-1337"
  desc = "Cоздано при помощи древней технологии, чье истинное назначение так и осталось неопознанным. Чистите вилкой и получите свою награду."
  icon = 'hyntatmta/icons/obj/parasha.dmi'
  var/nishtyak_cooldown

/obj/structure/toilet/parasha/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/weapon/kitchen/utensil/fork))
		if(!open)
			user.visible_message("<span class='notice'><B>[user]</B> скребет вилкой по зассанной крышке...</span>", "<span class='notice'>Ты поскреб вилкой по крышке сортира. Наверное, стоит ее открыть?</span>")
			return
		to_chat(user, "<span class='notice'>Вы начали чистить парашу вилкой. ЧИСТИ, ЧИСТИ!</span>")
		playsound(loc, 'sound/effects/slime_squish.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user.visible_message("<span class='notice'><B>[user]</B> чистит парашу!</span>", "<span class='notice'>Ты почистил парашу! Молодец! Чище она не стала...</span>")
			spawnloot(user)
			return

/obj/structure/toilet/parasha/proc/spawnloot(var/mob/living/petuh)
  var/chosen_nishtyak
  var/list/nishtyaks = list (
 //useless shit below
    /obj/item/weapon/lighter = 50,
    /obj/item/weapon/reagent_containers/glass/rag = 50,
    /obj/item/weapon/reagent_containers/glass/rag = 50,
    /obj/item/weapon/reagent_containers/glass/rag = 50,
    /obj/item/weapon/bedsheet = 50,
    /obj/item/weapon/coin/silver = 50,
    /obj/item/toy/balloon = 50,
    /obj/item/weapon/bikehorn = 50,
    /obj/item/toy/crayon/rainbow = 50,
    /obj/item/clothing/glasses/sunglasses = 50,
    /obj/item/weapon/cane = 50,
    /obj/item/clothing/head/collectable/tophat = 50,
    /obj/item/clothing/mask/balaclava = 50,
    /obj/item/weapon/storage/belt/champion = 50,
    /obj/item/clothing/head/ushanka = 50,
    /obj/item/clothing/mask/luchador = 50,
    /obj/item/clothing/head/corgi = 50,
    /obj/item/clothing/head/bearpelt = 50,
    /obj/item/toy/balloon = 50,
    /obj/item/toy/syndicateballoon = 50,
    /obj/item/toy/katana = 50,
    /obj/item/clothing/accessory/petcollar = 50,
    /obj/item/clothing/gloves/color/yellow/fake = 50,
    /obj/item/weapon/reagent_containers/food/snacks/donkpocket = 50,
    /obj/item/clothing/head/cueball = 50,
    /obj/item/clothing/head/fedora = 50,
    /obj/item/clothing/head/fez = 50,
    /obj/item/pizzabox/meat = 50,
    /obj/item/clothing/head/kitty = 50,
    /obj/item/clothing/mask/fakemoustache = 50,
    /obj/item/clothing/mask/pig = 50,
    /obj/item/clothing/mask/horsehead = 50,
    /obj/item/clothing/head/chicken = 50,
    /obj/item/clothing/mask/fawkes = 50,
    /obj/item/clothing/head/human_head = 50,
//some of this maybe alright
    /obj/item/weapon/kitchen/utensil/fork = 30,
    /obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 30,
    /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 30,
    /obj/item/weapon/reagent_containers/food/drinks/cans/cola = 30,
    /obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 30,
    /obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 30,
    /obj/item/stack/tape_roll = 20,
    /obj/item/weapon/hatchet = 20,
    /obj/item/clothing/gloves/color/yellow = 30,
    /obj/item/weapon/poster/random_contraband = 30,
    /obj/item/clothing/mask/breath = 20,
    /obj/item/weapon/screwdriver = 20,
    /obj/item/clothing/head/welding = 20,
    /obj/item/weapon/storage/backpack/clown = 20,
//And this usefull or nice and shiny
    /obj/item/device/pda = 13,
    /obj/item/device/assembly/prox_sensor = 12,
    /obj/item/device/assembly/timer = 12,
    /obj/item/device/assembly/igniter = 12,
    /obj/item/device/flashlight = 12,
    /obj/item/weapon/weldingtool/mini = 12,
    /obj/item/stack/sheet/mineral/diamond = 15,
    /obj/item/stack/sheet/metal{amount = 20} = 15,
    /obj/item/stack/sheet/rglass = 15,
    /obj/item/stack/rods{amount = 23} = 15,
    /obj/item/weapon/melee/classic_baton = 14,
    /obj/item/clothing/head/helmet/space = 12,
    /obj/item/weapon/tank/emergency_oxygen = 11,
    /obj/item/weapon/reagent_containers/food/snacks/monkeycube = 17,
    /obj/item/weapon/storage/backpack/satchel_flat = 16,
//Rare things
    /obj/item/weapon/storage/box/monkeycubes = 10,
    /obj/item/clothing/head/collectable/petehat = 10,
    /obj/item/device/radio/off = 6,
    /obj/item/weapon/twohanded/garrote/improvised = 6,
    /obj/item/clothing/suit/space = 8,
    /obj/item/weapon/grenade/iedcasing = 7,
    /obj/item/clothing/mask/gas = 8,
    /obj/item/weapon/grenade/smokebomb = 6,
    /obj/item/weapon/dnascrambler = 5,
    /obj/item/weapon/implanter/storage = 5,
    /obj/item/weapon/storage/pill_bottle/random_drug_bottle = 5,
//FUCKING DANGEROUS SHIT
    /obj/item/weapon/card/emag_broken = 3,
    /obj/item/weapon/pneumatic_cannon/ghetto = 3,
    /obj/item/clothing/under/contortionist/worn = 3,
    /obj/item/weapon/weldingtool/hugetank = 3,
    /obj/item/toy/cards/deck/syndicate = 3,
    /obj/item/weapon/melee/baton/cattleprod = 3,
    /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised = 2,
    /obj/item/weapon/scissors/safety = 2,
    /obj/item/weapon/grenade/bananade = 2,
    /obj/item/weapon/grenade/plastic/x4 = 1,
    /obj/item/weapon/grenade/iedcasing/filled = 1,
    /obj/item/weapon/twohanded/spear = 1,
    /obj/item/weapon/storage/box/syndie_kit/space = 1
  )

  if(nishtyak_cooldown > world.time)
    return

  chosen_nishtyak = pickweight(nishtyaks)
  new chosen_nishtyak(src.loc)
  petuh.visible_message("Вы слышите пронзительный стук со стороны параши.", "<span class='notice'>Ты услышал странный шум в бочке. Из параши что-то выплыло.</span>")
  playsound(src.loc, 'sound/effects/slosh.ogg', 50, 1)
  nishtyak_cooldown = world.time + NISHTYAK_DELAY
  return 1

#undef NISHTYAK_DELAY
