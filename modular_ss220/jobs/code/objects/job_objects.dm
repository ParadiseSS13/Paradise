/obj/machinery/computer/arcade/recruiter/Initialize(mapload)
	. = ..()
	jobs |= GLOB.all_jobs_ss220 + get_all_titles_ss220()
	incorrect_jobs |= list(
		"Medical Sasistant", "Shitcurity Cadet", "Traneer Enginer", "Assistant Captain", "Engineer Cadet",
		"Traine Engener", "Intarn", "Entern", "Student Directar", "Head of Scientest", "Junior Codet"
		)

/obj/effect/mob_spawn/human/intern
	name = "Medical Intern"
	mob_name = "Medical Intern"
	id_job = "Medical Intern"
	outfit = /datum/outfit/job/doctor/intern

/obj/effect/mob_spawn/human/trainee
	name = "Trainee Engineer"
	mob_name = "Trainee Engineer"
	id_job = "Trainee Engineer"
	outfit = /datum/outfit/job/engineer/trainee

/obj/effect/mob_spawn/human/student
	name = "Student Scientist"
	mob_name = "Student Scientist"
	id_job = "Student Scientist"
	outfit = /datum/outfit/job/scientist/student

/obj/effect/mob_spawn/human/cadet
	name = "Security Cadet"
	mob_name = "Security Cadet"
	id_job = "Security Cadet"
	outfit = /datum/outfit/job/officer/cadet


// TRADER - Хлам разрешенный на станции
/obj/item/storage/box/legal_loot
	name = "Коробка всячины"
	desc = "Коробка с легальными вещами или фальшивками. В любом случае, здесь ничего опасного и режущего! Безопасно для детей!"
	icon = 'modular_ss220/aesthetics/boxes/icons/boxes.dmi'
	icon_state = "thief_box"
	var/loot_amount = 1
	var/list/possible_type_loot = list(
		/obj/item/toy/balloon,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/soap/ducttape,
		/obj/item/soap/nanotrasen,
		/obj/item/soap/homemade,
		/obj/item/soap/syndie,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/bikehorn,
		/obj/item/beach_ball,
		/obj/item/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/katana,
		/obj/random/mech,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/dualsaber/toy,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible,
		/obj/random/carp_plushie,
		/obj/random/plushie,
		/obj/random/figure,
		/obj/item/deck/cards,
		/obj/item/deck/cards/tiny,
		/obj/item/deck/unum,
		/obj/item/toy/minimeteor,
		/obj/item/toy/redbutton,
		/obj/item/toy/figure/owl,
		/obj/item/toy/figure/griffin,
		/obj/item/clothing/head/blob,
		/obj/item/id_decal/gold,
		/obj/item/id_decal/silver,
		/obj/item/id_decal/prisoner,
		/obj/item/id_decal/centcom,
		/obj/item/id_decal/emag,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/toy/foamblade,
		/obj/item/toy/flash,
		/obj/item/toy/minigibber,
		/obj/item/toy/nuke,
		/obj/item/toy/AI,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
		/obj/item/stack/tile/fakespace/loaded,
		/obj/item/stack/tile/brass/fifty,
		/obj/item/sord,
		/obj/item/toy/prizeball/figure,
		/obj/item/toy/prizeball/therapy,

		// pew pew
		/obj/item/gun/projectile/automatic/toy,
		/obj/item/gun/projectile/automatic/toy/pistol,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/ammo_box/foambox,
		/obj/item/toy/foamblade,
		/obj/item/toy/syndicateballoon,
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/head/syndicatefake,
		/obj/item/gun/projectile/shotgun/toy/crossbow,
		/obj/item/gun/projectile/automatic/c20r/toy/riot,
		/obj/item/gun/projectile/automatic/l6_saw/toy/riot,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy,
		/obj/item/ammo_box/foambox/riot,
		/obj/item/deck/cards/syndicate
	)

/obj/item/storage/box/legal_loot/populate_contents()
	// "увеличиваем" шансы на выпадение коллекционного хлама
	possible_type_loot |= subtypesof(/obj/item/toy) + subtypesof(/obj/item/clothing/head/collectable) + subtypesof(/obj/item/poster) + subtypesof(/obj/item/storage/fancy/cigarettes) + subtypesof(/obj/item/lighter/zippo) + subtypesof(/obj/item/id_skin)
	possible_type_loot -= list(/obj/item/lighter/zippo/fluff, /obj/item/toy/plushie, /obj/item/toy/character, /obj/item/toy/desk, /obj/item/toy/plushie/fluff, /obj/item/toy/random)
	for(var/i in 1 to loot_amount)
		var/loot_type = pick(possible_type_loot)
		new loot_type(src)

/obj/item/storage/box/legal_loot/amount_2
	loot_amount = 2

/obj/item/storage/box/legal_loot/amount_5
	loot_amount = 5

/obj/item/storage/box/legal_loot/amount_10
	loot_amount = 10

/obj/item/storage/box/legal_loot/amount_15
	loot_amount = 15

/obj/item/storage/box/legal_loot/amount_20
	loot_amount = 20

/obj/item/storage/box/legal_loot/amount_30
	loot_amount = 30

/obj/item/storage/box/legal_loot/amount_40
	loot_amount = 40

/obj/item/storage/box/legal_loot/amount_50
	loot_amount = 50

// HONK Rifle //
/obj/item/gun/energy/clown
	icon_state = "honkrifle"
	item_state = "honkrifle"
	icon = 'modular_ss220/jobs/icons/custom_gun/custom_guns.dmi'
	lefthand_file = 'modular_ss220/jobs/icons/custom_gun/mob/custom_guns_lefthand.dmi'
	righthand_file = 'modular_ss220/jobs/icons/custom_gun/mob/custom_guns_righthand.dmi'

/obj/item/gun/energy/clown/security
	name = "ХОНК-ружье офицера"
	desc = "Личное оружие клоуна офицера. Смертоносное для ментального состояния каждого на ком было применено. Запрещено конвенкцией НТ 12 раз. Разрешено конвенкцией советов клоунов 13 раз. На рукояти выгривирован \"HONK\" и нацарапаны пару зачернутых черточек."
	icon_state = "honkrifle_security"
	item_state = "honkrifle_security"

/obj/item/gun/energy/clown/security/warden
	name = "Личное ХОНК-ружье смотрителя"
	desc = "Личное смертоносное оружие клоуна-смотрителя, выданное за заслуги перед НТ и \[ДАННЫЕ ХОНКНУТЫ\]. Ходят слухи что это один из первых экземпляров произведенных во время войны мимов и клоунов на родной планете клоунов."

// JANITOR //
/obj/item/storage/belt/janitor/full/donor/populate_contents()
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/storage/bag/trash(src)
	new /obj/item/soap/nanotrasen/prime(src)
	new /obj/item/grenade/chem_grenade/cleaner(src)
	new /obj/item/grenade/chem_grenade/cleaner(src)
	update_icon()
