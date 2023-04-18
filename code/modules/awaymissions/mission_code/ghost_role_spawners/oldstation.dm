//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.

/obj/effect/mob_spawn/human/oldstation/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	outfit = /datum/outfit/oldstation/officer
	mob_species = /datum/species/human
	description = "Work as a team with your fellow survivors aboard a ruined, ancient space station."
	important_info = ""
	flavour_text = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/oldmed
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a medical uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a medical doctor"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	outfit = /datum/outfit/oldstation/medic
	mob_species = /datum/species/human
	description = "Work as a team with your fellow survivors aboard a ruined, ancient space station."
	important_info = ""
	flavour_text = "You are a medical doctor working for Nanotrasen, stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	outfit = /datum/outfit/oldstation/engineer
	mob_species = /datum/species/human
	description = "Work as a team with your fellow survivors aboard a ruined, ancient space station."
	important_info = ""
	flavour_text = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human")
	outfit = /datum/outfit/oldstation/scientist
	mob_species = /datum/species/human
	description = "Work as a team with your fellow survivors aboard a ruined, ancient space station."
	important_info = ""
	flavour_text = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station. You vaguely recall rushing into a \
	cryogenics pod due to an oncoming radiation storm. The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	assignedrole = "Ancient Crew"

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = "A damaged cryogenic pod long since lost to time, including its former occupant..."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "opened cryogenic pod"
	desc = "A cryogenic pod that has recently discharged its occupant. The pod appears non-functional."

/datum/outfit/oldstation/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.remove_language("Galactic Common")
	H.set_default_language(GLOB.all_languages["Sol Common"])
	H.dna.species.default_language = "Sol Common"

/datum/outfit/oldstation/officer
	name = "Old station officer"
	uniform = /obj/item/clothing/under/retro/security
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/flash

/datum/outfit/oldstation/medic
	name = "Old station medic"
	uniform = /obj/item/clothing/under/retro/medical
	shoes = /obj/item/clothing/shoes/black
	id = /obj/item/card/id/away/old/med
	l_pocket = /obj/item/stack/medical/ointment
	r_pocket = /obj/item/stack/medical/ointment

/datum/outfit/oldstation/engineer
	name = "Old station engineer"
	uniform = /obj/item/clothing/under/retro/engineering
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/oldstation/scientist
	name = "Old station scientist"
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack

/obj/effect/mob_spawn/human/oldstation/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/obj/effect/mob_spawn/human/oldstation/Destroy()
	new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()
