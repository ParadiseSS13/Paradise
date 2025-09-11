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
	armor = list(MELEE = 40, BULLET = 40, LASER = 50, ENERGY = 35, BOMB = 20, RAD = 20, FIRE = INFINITY, ACID = INFINITY)
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
	name = "обломки Специального Гигакса НТ"
	desc = "Видимо, козырь был плохим..."
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "ntgygax-broken"

// DURAND

/// Rover
/obj/mecha/combat/durand/rover
	name = "Ровер"
	desc = "Боевой мех, разработанный Синдикатом на основе Durand Mk. II путем удаления ненужных вещей и добавления некоторых своих технологий. \
		Гораздо лучше защищен от любых опасностей, связанных с Нанотрейзен. Ценой за такую защиту стала сильно пострадавшая мобильность."
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "darkdurand"
	initial_icon = "darkdurand"
	armor = list(MELEE = 50, BULLET = 75, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	operation_req_access = list(ACCESS_SYNDICATE)
	step_in = 6 // slowest mech in game
	max_equip = 5
	max_integrity = 425
	max_temperature = 40000
	internal_damage_threshold = 25
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
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion/syndie
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/durand/rover/loaded/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

// Rover's wreckage
/obj/structure/mecha_wreckage/durand/rover
	name = "обломки Ровера"
	desc = "И как такой гигант пал?"
	icon = 'modular_ss220/objects/icons/mecha.dmi'
	icon_state = "darkdurand-broken"

// mechtransport_new space ruin mech
/obj/mecha/combat/durand/old/mechtransport_new
	obj_integrity = 120

// spacebattle mauler
/obj/mecha/combat/marauder/mauler/spacebattle
	max_integrity = 250

// combat indeed
/obj/mecha/working/ripley/emagged
	emagged = TRUE

/obj/mecha/working/ripley/emagged/Initialize(mapload)
	. = ..()
	desc += "</br>[span_danger("Оборудование меха опасно искрится!")]"

#undef ERT_TYPE_AMBER
#undef ERT_TYPE_RED
#undef ERT_TYPE_GAMMA
