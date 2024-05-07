/obj/mecha/combat/durand
	desc = "A heavily armored exosuit designed for front-line combat."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 40, bullet = 35, laser = 15, energy = 10, bomb = 20, rad = 50, fire = 100, acid = 75)
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
	Supplanted by newer, more advanced models, these old machines found themselves on the open market and are popular among corporations, private security firms, and planetary militia.</t>"
	. += "<i>Able to bear a wide array of heavy weapons and defensive tools, Nanotrasen found a use for the Durand as a machine to counter biohazards and hostile alien lifeforms, using it to secure new research installations or to fend off hostile fauna and bioforms. \
	As with all station-side mechs, Nanotrasen has purchased the license to produce the Durand in their facilities. </i>"

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 50, bullet = 35, laser = 15, energy = 15, bomb = 20, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand/old
