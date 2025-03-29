/datum/vox_pack/goods
	name = "DEBUG Goods Vox Pack"
	category = VOX_PACK_GOODS
	is_need_trader_cost = FALSE
	var/obj/random_subtype

/datum/vox_pack/goods/New()
	. = ..()
	if(!random_subtype)
		return
	var/list/possible_types = list(random_subtype) + subtypesof(random_subtype)
	var/choosen_type = pick(possible_types)
	contains.Add(choosen_type)

/datum/vox_pack/goods/figure
	name = "Фигурка"
	desc = "Случайный товар для продажи."
	reference = "G_FIG"
	cost = 25
	random_subtype = /obj/item/toy/figure

/datum/vox_pack/goods/mech
	name = "Механоид"
	desc = "Случайный товар для продажи."
	reference = "G_MECH"
	cost = 25
	random_subtype = /obj/item/toy/figure/mech

/datum/vox_pack/goods/plushie
	name = "Плюшка"
	desc = "Случайный товар для продажи."
	reference = "G_PLUSH"
	cost = 25
	random_subtype = /obj/item/toy/plushie

/datum/vox_pack/goods/therapy
	name = "Плюшка-Обнимашка"
	desc = "Случайный товар для продажи."
	reference = "G_THER"
	cost = 25
	random_subtype = /obj/item/toy/therapy

/datum/vox_pack/goods/carp_plushie
	name = "Плюшка-Карпушка"
	desc = "Случайный товар для продажи."
	reference = "G_CARP"
	cost = 25
	random_subtype = /obj/item/toy/plushie/carpplushie

/datum/vox_pack/goods/food
	name = "Еда"
	desc = "Случайный товар для продажи."
	reference = "G_CARP"
	cost = 50
	random_subtype = /obj/item/food

/datum/vox_pack/goods/toy
	name = "Игрушка"
	desc = "Случайный товар для продажи."
	reference = "G_TOY"
	cost = 100
	random_subtype = /obj/item/toy

/datum/vox_pack/goods/bikehorn
	name = "Гудок"
	desc = "Случайный товар для продажи."
	reference = "G_HORN"
	cost = 100
	random_subtype = /obj/item/bikehorn

/datum/vox_pack/goods/beach_ball
	name = "Мяч"
	desc = "Случайный товар для продажи."
	reference = "G_BALL"
	cost = 100
	random_subtype = /obj/item/beach_ball

/datum/vox_pack/goods/instrument
	name = "Музыкальный Инструмент"
	desc = "Случайный товар для продажи."
	reference = "G_MINS"
	cost = 100
	random_subtype = /obj/item/instrument

/datum/vox_pack/goods/soap
	name = "Мыло"
	desc = "Случайный товар для продажи."
	reference = "G_SOAP"
	cost = 25
	random_subtype = /obj/item/soap

/datum/vox_pack/goods/lighter
	name = "Зажигалка"
	desc = "Случайный товар для продажи."
	reference = "G_LIGH"
	cost = 75
	random_subtype = /obj/item/lighter

/datum/vox_pack/goods/flag
	name = "Флаг"
	desc = "Случайный товар для продажи."
	reference = "G_FLAG"
	cost = 50
	random_subtype = /obj/item/flag

/datum/vox_pack/goods/id_skin
	name = "Наклейка на карту"
	desc = "Случайный товар для продажи."
	reference = "G_IDS"
	cost = 50
	random_subtype = /obj/item/id_skin

/datum/vox_pack/goods/drugs
	name = "Наркотики"
	desc = "Мясу понравится этот товар."
	reference = "G_DRUG"
	cost = 200
	contains = list(/obj/item/storage/pill_bottle/random_drug_bottle)

/datum/vox_pack/goods/enforser
	name = "Пистолет Энфорсер (резина)"
	desc = "Мясу понравится этот товар."
	reference = "G_ENF"
	cost = 1000
	contains = list(/obj/item/gun/projectile/automatic/pistol/enforcer,
		/obj/item/ammo_box/magazine/enforcer,
		/obj/item/ammo_box/magazine/enforcer,
		/obj/item/ammo_box/magazine/enforcer,
	)

/datum/vox_pack/goods/space
	name = "Космический Старый Костюм \"NasaVoid\" - Красный"
	desc = "Мясу понравится этот товар."
	reference = "G_SP"
	cost = 200
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid,
		/obj/item/clothing/suit/space/nasavoid,
	)

/datum/vox_pack/goods/space/green
	name = "Космический Старый Костюм \"NasaVoid\" - Зеленый"
	desc = "Мясу понравится этот товар."
	reference = "G_SP_G"
	cost = 200
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid/green,
		/obj/item/clothing/suit/space/nasavoid/green,
	)

/datum/vox_pack/goods/space/ntblue
	name = "Космический Старый Костюм \"NasaVoid\" - NT Синий"
	desc = "Мясу понравится этот товар."
	reference = "G_SP_NTB"
	cost = 250
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid/ntblue,
		/obj/item/clothing/suit/space/nasavoid/ntblue,
	)

/datum/vox_pack/goods/space/purple
	name = "Космический Старый Костюм \"NasaVoid\" - Фиолетовый"
	desc = "Мясу понравится этот товар."
	reference = "G_SP_P"
	cost = 200
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid/purple,
		/obj/item/clothing/suit/space/nasavoid/purple,
	)

/datum/vox_pack/goods/space/yellow
	name = "Космический Старый Костюм \"NasaVoid\" - Желтый"
	desc = "Мясу понравится этот товар."
	reference = "G_SP_Y"
	cost = 200
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid/yellow,
		/obj/item/clothing/suit/space/nasavoid/yellow,
	)

/datum/vox_pack/goods/space/ltblue
	name = "Космический Старый Костюм \"NasaVoid\" - Светло-синий"
	desc = "Мясу понравится этот товар."
	reference = "G_SP_LTB"
	cost = 200
	contains = list(
		/obj/item/clothing/head/helmet/space/nasavoid/ltblue,
		/obj/item/clothing/suit/space/nasavoid/ltblue,
	)

/datum/vox_pack/goods/telescopic
	name = "Телескопическая дубинка"
	desc = "Мясу понравится этот товар."
	reference = "G_TEL"
	cost = 300
	contains = list(/obj/item/melee/classic_baton/telescopic)

/datum/vox_pack/goods/clown_gun
	name = "Клоунская Хлопушка"
	desc = "Мясу понравится этот товар."
	reference = "G_CL_GUN"
	cost = 100
	contains = list(/obj/item/gun/energy/clown)

/datum/vox_pack/goods/clown
	name = "Клоунское Снаряжение"
	desc = "Мясу повеселится от этого товара."
	reference = "G_CL_EQ"
	cost = 500
	contains = list(
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/under/rank/civilian/clown,
		/obj/item/pda/clown,
		/obj/item/flag/clown,
		/obj/item/id_skin/clown,
		/obj/item/bikehorn,
		/obj/item/storage/backpack/clown,
		/obj/item/food/grown/banana,
		/obj/item/stamp/clown,
		/obj/item/toy/crayon/rainbow,
		/obj/item/storage/fancy/crayons,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/reagent_containers/drinks/bottle/bottleofbanana,
		)

/datum/vox_pack/goods/clown/sec
	name = "Клоунское Снаряжение Безопасности"
	desc = "Мясо будет унижено этим товаром."
	reference = "G_CL_EQS"
	cost = 1000
	contains = list(
		/obj/item/clothing/under/rank/security/officer/clown,
		/obj/item/clothing/suit/armor/vest/security,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/gloves/color/red,
		/obj/item/flag/clown,
		/obj/item/id_skin/clown,
		/obj/item/pda/clown,
		/obj/item/bikehorn,
		/obj/item/gun/energy/clown/security,
		/obj/item/food/grown/banana,
		/obj/item/stamp/clown,
		/obj/item/toy/crayon/rainbow,
		/obj/item/storage/fancy/crayons,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/reagent_containers/drinks/bottle/bottleofbanana,
		/obj/item/instrument/bikehorn,
		/obj/item/restraints/handcuffs/toy,
		/obj/item/restraints/handcuffs/toy,
		/obj/item/storage/backpack/clown,
		)

/datum/vox_pack/goods/clown_grenade
	name = "Клоунская Граната"
	desc = "Мясу понравится этот товар."
	reference = "G_CL_GR"
	cost = 200
	contains = list(/obj/item/grenade/clusterbuster/honk)

/datum/vox_pack/goods/clown_grenade/evil
	name = "Клоунская Злая Граната"
	desc = "Мясу НЕ понравится этот товар."
	reference = "G_CL_GRE"
	cost = 500
	contains = list(/obj/item/grenade/clown_grenade)

/datum/vox_pack/goods/clown_bomba
	name = "Клоунская Бомба"
	desc = "Мясу НЕ понравится этот товар."
	reference = "G_CL_BOMBA"
	cost = 80000
	contains = list(/obj/item/grenade/clusterbuster/honk)
