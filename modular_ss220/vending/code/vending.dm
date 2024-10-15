/obj/machinery/economy/vending/nta
	name = "NT Ammunition"
	desc = "A special equipment vendor."
	ads_list = list("Возьми патрон!","Не забывай, снаряжаться - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")
	icon = 'modular_ss220/vending/icons/vending.dmi'
	icon_state = "nta"
	icon_deny = "nta_deny"
	icon_vend = "nta_vend"
	req_access = list(ACCESS_CENT_SECURITY)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta
	products = list(
		/obj/item/storage/box/slug = 4,
		/obj/item/grenade/flashbang = 4,
		/obj/item/flash = 5,
		/obj/item/storage/box/buck = 4,
		/obj/item/ammo_box/magazine/enforcer = 8,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 8,
		/obj/item/ammo_box/magazine/enforcer/lethal = 8,
		/obj/item/ammo_box/magazine/laser = 12,
		/obj/item/ammo_box/magazine/wt550m9 = 8,
		/obj/item/storage/box/rubbershot = 4,
		/obj/item/ammo_box/magazine/m556/arg = 12,
		/obj/item/ammo_box/a40mm = 4,
		/obj/item/ammo_box/magazine/smgm9mm = 12)

/obj/machinery/economy/vending/nta/admin/Initialize(mapload)
	products = list()
	var/list/new_products = list() + subtypesof(/obj/item/ammo_box) + /obj/item/storage/box/rubbershot +\
	/obj/item/storage/box/buck + /obj/item/storage/box/dragonsbreath + /obj/item/storage/box/holy +\
	/obj/item/storage/box/rubbershot + /obj/item/storage/box/slug + /obj/item/storage/box/stun +\
	/obj/item/storage/box/tranquilizer - /obj/item/ammo_box/magazine - typesof(/obj/item/ammo_box/magazine/internal)
	for(var/ammo_type in new_products)
		products[ammo_type] = 999
	. = ..()

/obj/machinery/economy/vending/nta/blue
	name = "NT ERT Medium Gear & Ammunition"
	desc = "A ERT Medium equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")
	products = list(
		/obj/item/gun/energy/gun = 3,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/gun/projectile/automatic/lasercarbine = 3,
		/obj/item/ammo_box/magazine/laser = 6,
		/obj/item/suppressor = 4,
		/obj/item/gun/projectile/automatic/wt550 = 3,
		/obj/item/ammo_box/magazine/wt550m9 = 6,
		/obj/item/gun/projectile/shotgun/riot = 6,
		/obj/item/storage/box/rubbershot = 6,
		/obj/item/storage/box/beanbag = 4,
		/obj/item/storage/box/tranquilizer = 4)

/obj/machinery/economy/vending/nta/red
	name = "NT ERT Heavy Gear & Ammunition"
	desc = "A ERT Heavy equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")
	products = list(
		/obj/item/gun/projectile/automatic/proto = 3,
		/obj/item/ammo_box/magazine/smgm9mm/ap = 6,
		/obj/item/gun/energy/lasercannon = 3,
		/obj/item/gun/energy/immolator = 3,
		/obj/item/gun/energy/gun/nuclear = 3,
		/obj/item/gun/projectile/shotgun/automatic/combat = 3,
		/obj/item/storage/box/slug = 4,
		/obj/item/storage/box/buck = 4,
		/obj/item/storage/box/dragonsbreath = 2,
		/obj/item/storage/lockbox/t4 = 3,
		/obj/item/grenade/smokebomb = 3,
		/obj/item/grenade/frag = 4)

/obj/machinery/economy/vending/nta/green
	name = "NT ERT Light Gear & Ammunition"
	desc = "A ERT Light equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")
	products = list(
		/obj/item/restraints/handcuffs = 5,
		/obj/item/restraints/handcuffs/cable/zipties = 5,
		/obj/item/grenade/flashbang = 3,
		/obj/item/flash = 2,
		/obj/item/gun/energy/disabler = 4,
		/obj/item/gun/projectile/automatic/pistol/enforcer = 6,
		/obj/item/ammo_box/magazine/enforcer = 12,
		/obj/item/gun/projectile/shotgun/riot = 1,
		/obj/item/storage/box/rubbershot = 3)

/obj/machinery/economy/vending/nta/yellow
	name = "NT ERT Death Wish Gear & Ammunition"
	desc = "A ERT Death Wish equipment vendor."
	ads_list = list("Круши черепа ВСЕХ!","Не забывай, УБИВАТЬ - полезно!","УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ!.","УБИВАТЬ, Удержать, УБИВАТЬ!","Стоять, снярядись на УБИВАТЬ!")
	products = list(
		/obj/item/gun/projectile/automatic/gyropistol = 8,
		/obj/item/ammo_box/magazine/m75 = 12,
		/obj/item/gun/projectile/automatic/l6_saw = 6,
		/obj/item/ammo_box/magazine/mm556x45/ap = 12,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 6,
		/obj/item/gun/energy/xray = 8,
		/obj/item/gun/energy/pulse/destroyer/annihilator = 8,
		/obj/item/gun/energy/immolator/multi = 8,
		/obj/item/gun/energy/bsg/prebuilt/admin = 4,
		/obj/item/grenade/clusterbuster/inferno = 3,
		/obj/item/grenade/clusterbuster/emp = 3)

/obj/machinery/economy/vending/nta/medical
	name = "NT ERT Medical Gear"
	desc = "A ERT medical equipment vendor."
	ads_list = list("Лечи раненых от рук синдиката!","Не забывай, лечить - полезно!","Бжж-Бзз-з!.","Перевязать, Оперировать, Выписать!","Стоять, снярядись медикаментами на задание!")
	products = list(
		/obj/item/storage/firstaid/tactical = 2,
		/obj/item/reagent_containers/applicator/dual = 2,
		/obj/item/reagent_containers/iv_bag/blood/OMinus = 10,
		/obj/item/reagent_containers/iv_bag/blood/vox = 3,
		/obj/item/reagent_containers/iv_bag/slime = 3,
		/obj/item/reagent_containers/iv_bag/salglu = 3,
		/obj/item/storage/belt/medical/surgery/loaded = 2,
		/obj/item/storage/belt/medical/response_team = 3,
		/obj/item/storage/pill_bottle = 4,
		/obj/item/reagent_containers/pill/mannitol = 10,
		/obj/item/reagent_containers/pill/salbutamol = 10,
		/obj/item/reagent_containers/pill/morphine = 8,
		/obj/item/reagent_containers/pill/charcoal = 10,
		/obj/item/reagent_containers/pill/mutadone = 8,
		/obj/item/storage/pill_bottle/patch_pack = 4,
		/obj/item/reagent_containers/patch/silver_sulf = 10,
		/obj/item/reagent_containers/patch/styptic = 10,
		/obj/item/storage/firstaid/surgery = 2,
		/obj/item/scalpel/laser = 2,
		/obj/item/reagent_containers/applicator/brute = 10,
		/obj/item/reagent_containers/applicator/burn = 10,
		/obj/item/healthanalyzer/advanced = 5,
		/obj/item/roller/holo = 3)

/obj/machinery/economy/vending/nta/engineer
	name = "NT ERT Engineer Gear"
	desc = "A ERT engineering equipment vendor."
	ads_list = list("Чини станцию от рук синдиката!","Не забывай, чинить - полезно!","Бжж-Бзз-з!.","Починить, Заварить, Трубить!","Стоять, снярядись на починку труб!")
	products = list(
		/obj/item/storage/belt/utility/chief/full = 2,
		/obj/item/clothing/mask/gas/welding = 4,
		/obj/item/weldingtool/experimental = 3,
		/obj/item/crowbar/power = 3,
		/obj/item/screwdriver/power  = 3,
		/obj/item/extinguisher/mini = 3,
		/obj/item/multitool = 3,
		/obj/item/rcd/preloaded = 2,
		/obj/item/rcd_ammo = 8,
		/obj/item/stack/cable_coil = 4)

/obj/machinery/economy/vending/nta/janitor
	name = "NT ERT Janitor Gear"
	desc = "A ERT ccleaning equipment vendor."
	ads_list = list("Чисть станцию от рук синдиката!","Не забывай, чистить - полезно!","Вилкой чисти!.","Помыть, Постирать, Оттереть!","Стоять, снярядись клинерами!")
	products = list(
		/obj/item/storage/belt/janitor/full = 2,
		/obj/item/clothing/shoes/galoshes = 2,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 2,
		/obj/item/storage/box/lights/mixed = 4,
		/obj/item/melee/flyswatter= 1,
		/obj/item/soap = 2,
		/obj/item/grenade/chem_grenade/cleaner = 4,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/watertank/janitor  = 4,
		/obj/item/lightreplacer = 2,)

/obj/machinery/economy/vending/cola/red
	name = "\improper Автомат с космической колой"
	desc = "Тут можно купить колу, в космосе."
	icon = 'modular_ss220/vending/icons/vending.dmi'
	icon_state = "Cola_Machine_Red"
	icon_lightmask = "Cola_Machine_Red"
	slogan_list = list("Кола в космосе!")

/obj/machinery/economy/vending/suitdispenser/Initialize(mapload)
	products += list(/obj/item/clothing/under/yellowgreen_skirt = 10,
						/obj/item/clothing/under/black_skirt = 10,
						/obj/item/clothing/under/aqua_skirt = 10,
						/obj/item/clothing/under/blue_skirt = 10,
						/obj/item/clothing/under/brown_skirt = 10,
						/obj/item/clothing/under/darkblue_skirt = 10,
						/obj/item/clothing/under/darkred_skirt = 10,
						/obj/item/clothing/under/green_skirt = 10,
						/obj/item/clothing/under/grey_skirt = 10,
						/obj/item/clothing/under/lightblue_skirt = 10,
						/obj/item/clothing/under/lightbrown_skirt = 10,
						/obj/item/clothing/under/lightgreen_skirt = 10,
						/obj/item/clothing/under/lightpurple_skirt = 10,
						/obj/item/clothing/under/lightred_skirt = 10,
						/obj/item/clothing/under/orange_skirt = 10,
						/obj/item/clothing/under/pink_skirt = 10,
						/obj/item/clothing/under/purple_skirt = 10,
						/obj/item/clothing/under/red_skirt = 10,
						/obj/item/clothing/under/white_skirt = 10,
						/obj/item/clothing/under/yellow_skirt = 10,
						/obj/item/clothing/under/rainbow_skirt = 1)

	contraband += list(/obj/item/clothing/under/prisoner_skirt = 1)

	prices += list(/obj/item/clothing/under/yellowgreen_skirt = 30,
						/obj/item/clothing/under/aqua_skirt = 50,
						/obj/item/clothing/under/black_skirt = 30,
						/obj/item/clothing/under/blue_skirt = 50,
						/obj/item/clothing/under/brown_skirt = 30,
						/obj/item/clothing/under/darkblue_skirt = 50,
						/obj/item/clothing/under/darkred_skirt = 50,
						/obj/item/clothing/under/green_skirt = 50,
						/obj/item/clothing/under/grey_skirt = 30,
						/obj/item/clothing/under/lightblue_skirt = 30,
						/obj/item/clothing/under/lightbrown_skirt = 30,
						/obj/item/clothing/under/lightgreen_skirt = 50,
						/obj/item/clothing/under/lightpurple_skirt = 50,
						/obj/item/clothing/under/lightred_skirt = 50,
						/obj/item/clothing/under/orange_skirt = 50,
						/obj/item/clothing/under/pink_skirt = 50,
						/obj/item/clothing/under/purple_skirt = 50,
						/obj/item/clothing/under/red_skirt = 50,
						/obj/item/clothing/under/white_skirt = 50,
						/obj/item/clothing/under/yellow_skirt = 50,
						/obj/item/clothing/under/prisoner_skirt = 175,
						/obj/item/clothing/under/rainbow_skirt = 100)
	. = ..()

/obj/machinery/economy/vending/suitdispenser/free
	prices = list()

/obj/machinery/economy/vending/wallmed/emergency_ntmed
	name = "\improper Advanced Nanomed"
	desc = "Продвинутая экстренная аптечка на все случаи жизни."
	products = list(
		/obj/item/reagent_containers/applicator/dual = 1,
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/nt_emergency = 4,
		/obj/item/healthanalyzer/advanced = 1
		)
	refill_canister = /obj/item/vending_refill/adv_ntmed

/obj/item/reagent_containers/hypospray/autoinjector/nt_emergency
	name = "advanced emergency autoinjector"
	desc = "Компания всегда ставит жизни и здоровье своих сотрудников превыше всего."
	list_reagents = list("nanites" = 10)

/obj/machinery/economy/vending/shoedispenser/Initialize(mapload)
	contraband |= list(/obj/item/clothing/shoes/clown_shoes/moffers = 1)
	prices |= list(/obj/item/clothing/shoes/clown_shoes/moffers = 80)
	. = ..()

/obj/machinery/economy/vending/shoedispenser/free
	prices = list()

/obj/machinery/economy/vending/tool/Initialize(mapload)
	contraband |= list(/obj/item/clothing/gloves/color/yellow/vox = 1)
	prices |= list(/obj/item/clothing/gloves/color/yellow/vox = 500)
	. = ..()

/obj/machinery/economy/vending/tool/free
	prices = list()
