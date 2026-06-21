/obj/mecha/combat/gygax
	desc = "A lightweight security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 5
	armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 15, BOMB = 0, RAD = 0, FIRE = 100, ACID = 75)
	infra_luminosity = 6
	leg_overload_coeff = 2
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	step_energy_drain = 3
	normal_step_energy_drain = 3

/obj/mecha/combat/gygax/GrantActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Grant(user, src)

/obj/mecha/combat/gygax/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Remove(user)

/obj/mecha/combat/gygax/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)

/obj/mecha/combat/gygax/examine_more(mob/user)
	. = ..()
	. += "<i>A light, fast and cheap combat mech designed and produced by Shellguard Munitions. \
	Originally developed as a mobile flanker for open combat scenarios, a substantial flaw in the mech's Leg Overdrive systems caused poor sales. \
	When using this system, the legs of the Gygax are prone to overheating and damaging the rest of the machine, leading overzealous pilots to harm themselves more than the enemy.</i>"
	. += ""
	. += "<i>Despite this flaw, Shellguard was able to reconsider the use of the mech and instead marketed it as a civil defence and policing mech. \
	Popularity soared, especially among corporations like Nanotrasen, who were seeking a light, fast, cheap design to use to equip their security teams. \
	As with all station-side mechs, Nanotrasen has purchased the license to produce the Gygax in their facilities.</i>"

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	max_integrity = 300
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 40, LASER = 50, ENERGY = 35, BOMB = 20, RAD =20, FIRE = 100, ACID = 100)
	max_temperature = 35000
	leg_overload_coeff = 100
	operation_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip = 5
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	destruction_sleep_duration = 2 SECONDS

/obj/mecha/combat/gygax/dark/trader
	operation_req_access = list() //Jailbroken mech

/obj/mecha/combat/gygax/dark/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/syndie
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/gygax/dark/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/combat/gygax/dark/examine_more(mob/user)
	..()
	. = list()
	. += "<i>A light, fast and cheap combat mech designed and produced by Shellguard Munitions, though this one appears to be modified. \
	With minor alterations to the loadout, armor, and a slick black paint job, this variant strikes a menacing silhouette, its owner clearly being someone you should not mess with.</i>"
	. += ""
	. += "<i>Despite the flaws of the base model, this modified Gygax has no trouble being a speedy, dangerous killing machine. \
	Alterations such as this are common amongst fringe users and outlaw groups, and the upgrades are most certainly illegal. Don't cut yourself.</i>"
