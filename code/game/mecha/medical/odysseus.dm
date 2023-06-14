/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 3
	max_temperature = 15000
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	normal_step_energy_drain = 6
	var/builtin_hud_user = 0

/obj/mecha/medical/odysseus/moved_inside(var/mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[H.glasses] prevent you from using the built-in medical hud.</span>")
		else
			var/datum/atom_hud/data/human/medical/advanced/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(H)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/mmi_moved_inside(var/obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		if(occupant.client)
			var/datum/atom_hud/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(occupant)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant) && builtin_hud_user)
		var/mob/living/carbon/human/H = occupant
		var/datum/atom_hud/data/human/medical/advanced/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0
	else if((isbrain(occupant) || pilot_is_mmi()) && builtin_hud_user)
		var/mob/living/carbon/brain/H = occupant
		var/datum/atom_hud/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0

	. = ..()

/obj/mecha/medical/odysseus/full_load
	name = "Тестовый Одиссей"
	desc = "Специальная версия \"Одиссея\", созданная с одной целью - проверять все модули разом. Конструкция не позволяет меху быть массовым образцом, выпущенная специально для ведущих инженеров-роботехников."
	max_equip = 5
	strafe_allowed = TRUE
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0) // для тестов урона
	max_integrity = 1000
	deflect_chance = 0 // нахуй рандом
	mech_enter_time = 1

/obj/mecha/medical/odysseus/full_load/New()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/medical/improved_exosuit_control_system
	ME.attach(src)

/obj/mecha/medical/odysseus/full_load/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)
