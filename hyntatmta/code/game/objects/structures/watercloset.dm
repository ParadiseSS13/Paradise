#define NISHTYAK_DELAY 3000
/obj/structure/toilet/parasha
  name = "Parasha X-7000"
  desc = "Покрыта особыми наночастицами, которые похожи на капли грязи и дерьма. Хрупкую крышку сливного бочка можно открыть даже шариковой ручкой."
  icon = 'hyntatmta/icons/obj/parasha.dmi'
  var/nishtyak_cooldown

/obj/structure/toilet/parasha/New()
  ..()
  spawnloot()

/obj/structure/toilet/parasha/attackby(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/weapon/pen))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
			cistern = !cistern
			update_icon()
			return
	if(istype(I, /obj/item/weapon/kitchen/utensil/fork))
		to_chat(user, "<span class='notice'>Вы начали чистить парашу вилкой. Видать братва опустила.</span>")
		playsound(loc, 'sound/effects/slime_squish.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user.visible_message("[user] чистит парашу! Вот же петух!", "<span class='notice'>Ты почистил парашу! Молодец! Чище она не стала...</span>")
			spawnloot()
			if(nishtyak_cooldown <= world.time || !nishtyak_cooldown)
				user.visible_message("Раздался пронзительный стук со стороны параши.", "<span class='notice'>Ты услышал странный шум в бочке. Может, стоит проверить?</span>")
				playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
			return

/obj/structure/toilet/parasha/proc/spawnloot()
  var/chosen_nishtyak
  var/list/nishtyak_useless = list (
    /obj/item/weapon/lighter,
    /obj/item/weapon/bedsheet,
    /obj/item/weapon/coin/silver,
    /obj/item/clothing/under/shorts/red,
    /obj/item/clothing/under/shorts/blue,
    /obj/item/toy/balloon,
    /obj/item/weapon/bikehorn,
    /obj/item/toy/crayon/rainbow,
    /obj/item/clothing/suit/ianshirt,
    /obj/item/weapon/cane,
    /obj/item/clothing/head/collectable/tophat,
    /obj/item/clothing/mask/balaclava,
    /obj/item/weapon/storage/belt/champion,
    /obj/item/clothing/mask/luchador,
    /obj/item/clothing/head/corgi,
    /obj/item/clothing/suit/corgisuit,
    /obj/item/clothing/head/bearpelt,
    /obj/item/toy/balloon,
    /obj/item/toy/syndicateballoon,
    /obj/item/toy/katana,
    /obj/item/clothing/accessory/petcollar,
    /obj/item/clothing/gloves/color/yellow/fake,
    /obj/item/weapon/reagent_containers/food/snacks/donkpocket,
    /obj/item/pizzabox/meat,
    /obj/item/weapon/spacecash/c100,
    /obj/item/clothing/head/kitty
  )

  var/list/nishtyak_common = list (
    /obj/item/weapon/kitchen/utensil/fork,
    /obj/item/weapon/reagent_containers/food/drinks/bottle/rum,
    /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,
    /obj/item/weapon/hatchet,
    /obj/item/weapon/crowbar,
    /obj/item/weapon/contraband/poster,
    /obj/item/weapon/spacecash/c1000,
    /obj/item/clothing/mask/breath
  )

  var/list/nishtyak_rare = list (
    /obj/item/weapon/weldingtool,
    /obj/item/weapon/wirecutters,
    /obj/item/weapon/screwdriver,
    /obj/item/weapon/storage/backpack/clown,
    /obj/item/clothing/gloves/color/yellow/power,
    /obj/item/device/multitool,
    /obj/item/device/pda,
    /obj/item/stack/sheet/mineral/diamond,
    /obj/item/seeds/cash,
    /obj/item/weapon/melee/classic_baton,
    /obj/item/clothing/head/helmet/space,
    /obj/item/weapon/tank/emergency_oxygen,
    /obj/item/weapon/reagent_containers/food/snacks/monkeycube
  )

  var/list/nishtyak_veryrare = list (
    /obj/item/weapon/storage/box/monkeycubes,
    /obj/item/weapon/gun/energy/kinetic_accelerator/hyper,
    /obj/item/clothing/suit/space,
    /obj/item/weapon/defibrillator/compact,
    /obj/item/weed_extract,
    /obj/item/ammo_box/magazine/m10mm,
    /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
    /obj/item/clothing/mask/gas,
    /obj/item/weapon/grenade/smokebomb
  )

  var/list/nishtyak_contraband = list (
    /obj/item/weapon/gun/projectile/automatic/pistol/empty,
    /obj/item/clothing/under/chameleon,
    /obj/item/toy/cards/deck/syndicate,
    /obj/item/weapon/scissors,
    /obj/item/weapon/grenade/plastic/x4,
    /obj/item/weapon/grenade/bananade
  )

  if(nishtyak_cooldown > world.time)
    return

  if(prob(1))
    chosen_nishtyak = pick(nishtyak_contraband)
  else if(prob(5))
    chosen_nishtyak = pick(nishtyak_veryrare)
  else if(prob(15))
    chosen_nishtyak = pick(nishtyak_rare)
  else if(prob(30))
    chosen_nishtyak = pick(nishtyak_common)
  else
    chosen_nishtyak = pick(nishtyak_useless)
  new chosen_nishtyak(src)
  nishtyak_cooldown = world.time + NISHTYAK_DELAY
  return 1

#undef NISHTYAK_DELAY
