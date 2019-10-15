/obj/mecha/combat/durand
	desc = "It's time to light some fires and kick some tires."
	name = "Durand Mk. II"
	icon_state = "durand"
	base_icon_state = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 40, bullet = 35, laser = 15, energy = 10, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand

	basecoat_icon = "durand-shell"
	basecoat_colour = "#5b616e"
	glow_icon = "durand-glow"
	glow_colour = "#00AE00"
	icon_decal_root	= "durand-decal"
	decals = list()
	default_decals = list()

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "old_durand"
	base_icon_state = "old_durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 50, bullet = 35, laser = 15, energy = 15, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand/old
	cosmetics_enabled = FALSE
