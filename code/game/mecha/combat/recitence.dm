/obj/mecha/combat/recitence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper Recitence"
	icon_state = "mime"
	initial_icon = "mime"
	step_in = 2
	dir_in = 1 //Facing North.
	health = 100
	deflect_chance = 3
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 15000
	wreckage = /obj/effect/decal/mecha_wreckage/mime
	internal_damage_threshold = 25
	max_equip = 2
	step_energy_drain = 3
//	color = "#87878715"
	stepsound = null

/obj/mecha/combat/recitence/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/rcd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)
	return