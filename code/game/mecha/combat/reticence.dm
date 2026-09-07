/obj/mecha/combat/reticence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper Reticence"
	icon_state = "mime"
	initial_icon = "mime"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 150
	deflect_chance = 30
	armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 15, BOMB = 0, RAD = 0, FIRE = 100, ACID = 75)
	max_temperature = 15000
	wreckage = /obj/structure/mecha_wreckage/reticence
	operation_req_access = list(ACCESS_MIME)
	add_req_access = 0
	internal_damage_threshold = 60
	step_energy_drain = 3
	normal_step_energy_drain = 3
	stepsound = null
	turnsound = null
	starting_voice = /obj/item/mecha_modkit/voice/silent

/obj/mecha/combat/reticence/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/mimercd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)

/obj/mecha/combat/reticence/examine_more(mob/user)
	. = ..()
	. += "<i>A dour, colorless modification of a Gygax chassis, the Reticence is a sight to behold…or not behold. \
	It utilizes a mysterious dampening field, added by a cabal of nearly unheard-of mimes, to be entirely silent as it moves over any terrain, making it a favored weapon of this supposed conspiracy and the assassins they may, or may not, employ.</i>"
	. += ""
	. += "<i>Armed with an S.H.H. “Quietus” Carbine, an utterly silent weapon that can drain the stamina of targets unfortunate enough to be shot by it, it can ensure swift getaways. \
	As a secondary tool, it comes equipped with a mime R.C.D., a device capable of replicating a mime's mysterious ability to create impenetrable, invisible walls. \
	Strangely, the design for the Reticence seems to be present aboard every Nanotrasen station, though to what ends, no one knows.</i>"
