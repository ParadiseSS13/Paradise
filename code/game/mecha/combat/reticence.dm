/obj/mecha/combat/reticence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper Reticence"
	icon_state = "mime"
	initial_icon = "mime"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 150
	deflect_chance = 30
	armor = list("melee" = 25, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	max_temperature = 15000
	wreckage = /obj/structure/mecha_wreckage/reticence
	operation_req_access = list(access_mime)
	add_req_access = 0
	internal_damage_threshold = 60
	max_equip = 3
	step_energy_drain = 3
	normal_step_energy_drain = 3
	stepsound = null
	turnsound = null
	starting_voice = /obj/item/mecha_modkit/voice/silent

/obj/mecha/combat/reticence/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/mimercd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)
