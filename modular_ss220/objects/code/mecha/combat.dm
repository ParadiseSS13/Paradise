#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

// GYGAX

/// NT Special Gygax
/obj/mecha/combat/gygax/nt
	name = "Специальный Гигакс НТ"
	desc = "Козырь Nanotrasen при решении проблем, легкий мех окрашенный в победоносные цвета НТ. Если вы видите этот мех, вероятно все проблемы уже решены."
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "ntgygax"
	initial_icon = "ntgygax"
	max_integrity = 300
	deflect_chance = 20
	leg_overload_coeff = 100
	max_temperature = 35000
	armor = list(melee = 40, bullet = 40, laser = 50, energy = 35, bomb = 20, rad = 20, fire = 100, acid = 100)
	operation_req_access = list(ERT_TYPE_AMBER)
	max_equip = 5
	wreckage = /obj/structure/mecha_wreckage/gygax/gygax_nt
	starting_voice = /obj/item/mecha_modkit/voice/nanotrasen
	destruction_sleep_duration = 2 SECONDS

/obj/mecha/combat/gygax/nt/loaded_red/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/gygax/nt/loaded_epsilon/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/gygax/nt/add_cell()
	cell = new /obj/item/stock_parts/cell/high/slime(src)

// NT Special Gygax wreckage
/obj/structure/mecha_wreckage/gygax/gygax_nt
	name = "\improper Обломки Специального Гигакса НТ"
	desc = "Видимо козырь был плохим..."
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "ntgygax-broken"

// DURAND

/// Rover
/obj/mecha/combat/durand/rover
	name = "Ровер"
	desc = "Боевой мех, разработанный Синдикатом на основе Durand Mk. II путем удаления ненужных вещей и добавления некоторых своих технологий. Гораздо лучше защищен от любых опасностей, связанных с Нанотрейзен."
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "darkdurand"
	initial_icon = "darkdurand"
	armor = list(melee = 30, bullet = 40, laser = 50, energy = 50, bomb = 20, rad = 50, fire = 100, acid = 100)
	operation_req_access = list(ACCESS_SYNDICATE)
	max_equip = 4
	internal_damage_threshold = 35
	wreckage = /obj/structure/mecha_wreckage/durand/rover
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	destruction_sleep_duration = 2 SECONDS

/obj/mecha/combat/durand/rover/GrantActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Grant(user, src)

/obj/mecha/combat/durand/rover/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Remove(user)

/obj/mecha/combat/durand/rover/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/syndi
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	ME.attach(src)

/obj/mecha/combat/durand/rover/loaded/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

// Rover's wreckage
/obj/structure/mecha_wreckage/durand/rover
	name = "\improper Обломки Ровера"
	desc = "И как такой гигант пал?"
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "darkdurand-broken"

#undef ERT_TYPE_AMBER
#undef ERT_TYPE_RED
#undef ERT_TYPE_GAMMA
