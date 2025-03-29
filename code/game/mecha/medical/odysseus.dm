/obj/mecha/medical/odysseus
	desc = "Медицинский экзокостюм, разработанный корпорацией DeForest Medical для спасательных операций."
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

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[capitalize(H.glasses.declent_ru(NOMINATIVE))] мешают вам использовать встроенный медицинский HUD.</span>")
		else
			var/datum/atom_hud/data/human/medical/advanced/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(H)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
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
		var/mob/living/brain/H = occupant
		var/datum/atom_hud/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0

	. = ..()

/obj/mecha/medical/odysseus/examine_more(mob/user)
	. = ..()
	. += "<i>Одиссей — это относительно быстрый, легкий и простой в обслуживании экзокостюм, разработанный корпорацией DeForest Medical. \
	Первоначально созданный для спасения и ухода за пациентами в сложных условиях. Он получил высокое распространение в секторе, обычно среди крупных корпораций и военных групп, которые ценят его способность входить и выходить даже из самых трудных зон бедствия.</i>"
	. += ""
	. += "<i>DeForest Medical добилась скромного успеха с экзокостюмом Одиссей, получив лишь незначительные жалобы на его медлительность и недостаток брони или оборонительных возможностей. \
	Несмотря на эти недостатки, он нашёл применение в медицинских командах Nanotrasen, где парамедики находят полезное применение ему и и его разнообразным комплектам оборудования. \
	Как в случаях со всеми станционными мехами, Nanotrasen приобрела лицензию на производство Одиссея на своих предприятиях.</i>"
