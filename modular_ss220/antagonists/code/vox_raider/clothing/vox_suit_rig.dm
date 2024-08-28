// РИГи ВОКСов.
// Дают приемлимые защитные свойства, позволяют держать давление космоса.

/obj/item/clothing/suit/space/hardsuit/vox
	name = "vox raider hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников."
	icon_state = "vox-raider"
	item_color = "vox-raider"
	item_state = "rig_suit"
	species_restricted = list("Vox")
	icon = 'modular_ss220/antagonists/icons/clothing/obj_suit.dmi'
	icon_override = 'modular_ss220/antagonists/icons/clothing/mob/vox/suit.dmi'
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/suit.dmi'
		)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals,
		/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton,
		/obj/item/melee/energy/sword, /obj/item/shield/energy,
		/obj/item/restraints/handcuffs)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, RAD = 115, FIRE = 80, ACID = 200)
	strip_delay = 8 SECONDS
	put_on_delay = 6 SECONDS
	slowdown = 0
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox

/obj/item/clothing/head/helmet/space/hardsuit/vox
	name = "vox raider helmet"
	desc = "Специализированный космический шлем воксов-рейдеров."
	icon_state = "vox-raider"
	item_color = "vox-raider"
	species_restricted = list("Vox")
	icon = 'modular_ss220/antagonists/icons/clothing/obj_head.dmi'
	icon_override = 'modular_ss220/antagonists/icons/clothing/mob/vox/head.dmi'
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/head.dmi'
		)
	flags = HEADBANGPROTECT | BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, RAD = 115, FIRE = 80, ACID = 200)

/obj/item/clothing/head/helmet/space/hardsuit/vox/toggle_light(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "_light" : ""]"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons()

// Space Trooper

/obj/item/clothing/suit/space/hardsuit/vox/trooper
	name = "vox raider trooper hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников. \
	\nКостюм космического штурмовика рейдеров с защитой от огнестрела и колюще-режущего."
	icon_state = "vox-raider-trooper"
	item_color = "vox-raider-trooper"
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, RAD = 115, FIRE = 80, ACID = 200)
	strip_delay = 12 SECONDS
	put_on_delay = 8 SECONDS
	slowdown = 1
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/trooper

/obj/item/clothing/head/helmet/space/hardsuit/vox/trooper
	name = "vox raider trooper helmet"
	icon_state = "vox-raider-trooper"
	item_color = "vox-raider-trooper"
	armor = list(MELEE = 75, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 25, RAD = 115, FIRE = 80, ACID = 200)


/obj/item/clothing/suit/space/hardsuit/vox/scout
	name = "vox raider scout hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников. \
	\nКостюм разведчика не сковывает движение и помогает владельцу удобней двигаться в условиях невесомости."
	icon_state = "vox-raider-scout"
	item_color = "vox-raider-scout"
	armor = list(MELEE = 10, BULLET = 20, LASER = 30, ENERGY = 30, BOMB = 15, RAD = 115, FIRE = 80, ACID = 200)
	strip_delay = 6 SECONDS
	put_on_delay = 4 SECONDS
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/scout
	slowdown = -0.25

/obj/item/clothing/head/helmet/space/hardsuit/vox/scout
	name = "vox raider scout helmet"
	icon_state = "vox-raider-scout"
	item_color = "vox-raider-scout"
	armor = list(MELEE = 10, BULLET = 20, LASER = 30, ENERGY = 30, BOMB = 15, RAD = 115, FIRE = 80, ACID = 200)


// Medic

/obj/item/clothing/suit/space/hardsuit/vox/medic
	name = "vox raider medic hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников. \
	\nКостюм для работы в условиях отдаленности от опасностей. Более подвижен и обладает приемлимыми свойствами защиты от воздействий различного рода снарядов, но из-за своей структуры способен нанести вред носителю при взрывных воздействиях или колющих атак. Костюм отлично выдерживает радиационный фон и кислотное воздействие и биологическими угрозами. Имеет хранилище для ношения аптечек контейнеров с химикатами."
	icon_state = "vox-raider-medic"
	item_color = "vox-raider-medic"
	armor = list(MELEE = -30, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = -30, RAD = INFINITY, FIRE = 120, ACID = INFINITY)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/medic
	allowed = list(/obj/item/flashlight, /obj/item/storage/firstaid,
		/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton,
		/obj/item/melee/energy/sword, /obj/item/shield/energy,
		/obj/item/restraints/handcuffs, /obj/item/tank/internals,
		/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/robotanalyzer)

/obj/item/clothing/head/helmet/space/hardsuit/vox/medic
	name = "vox raider medic helmet"
	icon_state = "vox-raider-medic"
	item_color = "vox-raider-medic"
	armor = list(MELEE = -30, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = -30, RAD = INFINITY, FIRE = 120, ACID = INFINITY)


// Mechanic

/obj/item/clothing/suit/space/hardsuit/vox/mechanic
	name = "vox raider mechanic hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников. \
	\nКостюм для работы в условиях крайне опасных и недружелюбных атмосфер. За счет своей структуры и технологии рассеивания тепла, костюм обладает хорошей защитой от энергетического оружия."
	icon_state = "vox-raider-mechanic"
	item_color = "vox-raider-mechanic"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 20, BULLET = 20, LASER = 75, ENERGY = 50, BOMB = 150, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	slowdown = 2
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/mechanic
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd,
		/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton,
		/obj/item/melee/energy/sword, /obj/item/shield/energy,
		/obj/item/restraints/handcuffs, /obj/item/tank/internals)

/obj/item/clothing/head/helmet/space/hardsuit/vox/mechanic
	name = "vox raider mechanic helmet"
	icon_state = "vox-raider-mechanic"
	item_color = "vox-raider-mechanic"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 20, BULLET = 20, LASER = 75, ENERGY = 50, BOMB = 150, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)


// Heavy - Воксомех

/obj/item/clothing/suit/space/hardsuit/vox/heavy
	name = "vox raider heavy hardsuit"
	desc = "Специализированный космический защитный костюм воксов-рейдеров. Синтетический материал используемый в костюмах воксов позволяет тем действовать в неблагоприятных для них окружающих условиях, делая их костюмы универсальными. За счет иной структуры, костюм рейдеров уступает в защитных свойствах костюму наемников. \
	\nТяжелый огнеупорный и взрывостойкий костюм рейдеров с превосходной защитой от энергетического оружия и колюще-режущих и приемлимой от огнестрела. Костюм был разработан для противостояния механизированным силам в условиях космического пространства. К сожалению, его вес и ресиверы не настолько совершены, из-за чего он уступает в скорости."
	icon_state = "vox-raider-heavy"
	item_color = "vox-raider-heavy"
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 115, BULLET = 80, LASER = 150, ENERGY = 80, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = 3	// Даже черепаха быстрее чем это ведро.
	strip_delay = 20 SECONDS
	put_on_delay = 10 SECONDS
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/vox/heavy

/obj/item/clothing/head/helmet/space/hardsuit/vox/heavy
	name = "vox raider heavy helmet"
	icon_state = "vox-raider-heavy"
	item_color = "vox-raider-heavy"
	armor = list(MELEE = 115, BULLET = 80, LASER = 115, ENERGY = 80, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
