/datum/species/kidan
	name = "Kidan"
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	language = "Chittin"
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8
	hunger_drain = 0.15
	tox_mod = 1.7

	species_traits = list(NO_HAIR)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_BODYACC_COLOR | SHAVED
	eyes = "kidan_eyes_s"
	dietflags = DIET_HERB
	flesh_color = "#ba7814"
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/kidan,
		"lungs" =    /obj/item/organ/internal/lungs/kidan,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys/kidan,
		"brain" =    /obj/item/organ/internal/brain/kidan,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/kidan,
		"lantern" =  /obj/item/organ/internal/lantern
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"is attempting to bite their antenna off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is cracking their exoskeleton!",
		"is stabbing themselves with their mandibles!",
		"is holding their breath!")


/datum/species/kidan/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_color

// Kidan pheromones, visible by the HUD they gain just for being kidan
/datum/species/kidan/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.add_hud_to(H)

/datum/species/kidan/on_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.remove_hud_from(H)

/obj/effect/kidan_pheromones
	name = "kidan pheromones"

/obj/effect/kidan_pheromones/Initialize(mapload)
	. = ..()
	var/image/holder = hud_list[KIDAN_PHEROMONE_HUD]
	holder.icon = 'icons/effects/effects.dmi'
	holder.icon_state = "purplesparkles"
	to_chat(world, "Initialized [holder], [length(hud_list[KIDAN_PHEROMONE_HUD])]")
