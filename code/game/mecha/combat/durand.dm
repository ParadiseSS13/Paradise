/obj/mecha/combat/durand
	desc = "A heavily armored exosuit designed for front-line combat."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 35, LASER = 15, ENERGY = 10, BOMB = 20, RAD = 50, FIRE = 100, ACID = 75)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)

/obj/mecha/combat/durand/examine_more(mob/user)
	. = ..()
	. += "<i>A durable heavyweight combat mech designed and produced by Defiance Arms. \
	The Durand is an outdated design among Defiance's line of battlemechs and was initially created to fulfill the role of a combat spearhead, breaking into enemy combat formations. \
	Supplanted by newer, more advanced models, these old machines found themselves on the open market and are popular among corporations, private security firms, and planetary militia.</i>"
	. += ""
	. += "<i>Able to bear a wide array of heavy weapons and defensive tools, Nanotrasen found a use for the Durand as a machine to counter biohazards and hostile alien lifeforms, using it to secure new research installations or to fend off hostile fauna and bioforms. \
	As with all station-side mechs, Nanotrasen has purchased the license to produce the Durand in their facilities.</i>"

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit designed by Defiance Arms. Originally developed to combat hostile alien lifeforms"
	name = "Old Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	armor = list(MELEE = 50, BULLET = 35, LASER = 15, ENERGY = 15, BOMB = 20, RAD = 50, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/durand/old

/obj/mecha/combat/durand/old/examine_more(mob/user)
	..()
	. = list()
	. += "<i>A relic of a mech, once produced by Defiance Arms in the decade of 2470. \
	It is now sought after by collectors and museums alike and has found its way into the hands of many a black market over the decades since its later versions replaced it.</i>"
	. += ""
	. += "<i>Built initially to break into and destroy Xenomorph infestations, bigger and better war machines exist. \
	But many still uphold this version of the Durand as an unstoppable classic, and finding one intact and functional has become increasingly rare.</i>"
